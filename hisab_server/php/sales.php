<?php
require_once 'config.php';
require_once 'jwt_helper.php';

header('Content-Type: application/json');

// Ensure HTTP POST/GET as needed
$method = $_SERVER['REQUEST_METHOD'];

// Extract and verify Bearer token
$authHeader = '';
if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
} elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
    $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
} elseif (function_exists('apache_request_headers')) {
    $headers = apache_request_headers();
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
    } elseif (isset($headers['authorization'])) {
        $authHeader = $headers['authorization'];
    }
}

if (empty($authHeader) || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'Unauthorized: Missing or invalid token format']);
    exit;
}

$token = $matches[1];
$payload = verify_jwt($token);

if (!$payload) {
    http_response_code(403);
    echo json_encode(['status' => 'error', 'message' => 'Forbidden: Invalid or expired token']);
    exit;
}

$jwt_company_id = $payload['company_id'] ?? null;
$jwt_branch_id = $payload['branch_id'] ?? null;
$jwt_user_id = $payload['user_id'] ?? null;
$jwt_role = $payload['role'] ?? null;

$action = isset($_GET['action']) ? $_GET['action'] : '';

if ($action === 'sync_sales') {
    if ($method !== 'POST') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit;
    }

    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Invalid input, expected an array of sales']);
        exit;
    }

    try {
        $pdo->beginTransaction();

        $synced_sale_ids = [];

        foreach ($data as $sale) {
            // Ignore any ids sent in JSON, force use of JWT extracted IDs to ensure cashier is recording for their authorized branch
            $branch_id = $jwt_branch_id;
            $user_id = $jwt_user_id;
            $staff_id = $jwt_user_id; 

            // Validate inputs
            $customer_name = isset($sale['customer_name']) ? (string)$sale['customer_name'] : 'Walk-in';
            $total_amount = isset($sale['total_amount']) ? (float)$sale['total_amount'] : 0.0;
            $items = isset($sale['items']) ? $sale['items'] : [];

            if (empty($items) || !is_array($items)) {
                throw new Exception('Sale items cannot be empty');
            }

            $provided_id = isset($sale['sale_id']) ? $sale['sale_id'] : (isset($sale['id']) ? $sale['id'] : null);

            if ($provided_id !== null) {
                $stmt = $pdo->prepare('INSERT INTO sales (id, branch_id, user_id, staff_id, total_amount, customer_name, sale_date) VALUES (?, ?, ?, ?, ?, ?, NOW())');
                $stmt->execute([$provided_id, $branch_id, $user_id, $staff_id, $total_amount, $customer_name]);
                $sale_id = $provided_id;
            } else {
                $stmt = $pdo->prepare('INSERT INTO sales (branch_id, user_id, staff_id, total_amount, customer_name, sale_date) VALUES (?, ?, ?, ?, ?, NOW())');
                $stmt->execute([$branch_id, $user_id, $staff_id, $total_amount, $customer_name]);
                $sale_id = $pdo->lastInsertId();
            }

            $totalQtySoldInThisSale = 0;

            foreach ($items as $item) {
                $pId = isset($item['product_id']) ? (int)$item['product_id'] : 0;
                $qty = isset($item['quantity']) ? (int)$item['quantity'] : 0;
                $sPrice = isset($item['price']) ? (float)$item['price'] : 0.0;
                $cPrice = isset($item['cost']) ? (float)$item['cost'] : 0.0;

                if ($pId === 0 || $qty <= 0) {
                    throw new Exception('Invalid Product ID or Quantity');
                }

                $stockStmt = $pdo->prepare('SELECT current_stock, name FROM products WHERE id = ?');
                $stockStmt->execute([$pId]);
                $product = $stockStmt->fetch(PDO::FETCH_ASSOC);

                if (!$product) {
                    throw new Exception("Product ID $pId not found");
                }

                $currentStock = (int)$product['current_stock'];
                if ($currentStock < $qty) {
                    throw new Exception("Insufficient stock for product ID $pId. Available: $currentStock, Requested: $qty");
                }

                $totalQtySoldInThisSale += $qty;
                $productName = $product['name'];

                $updateStock = $pdo->prepare('UPDATE products SET current_stock = current_stock - ? WHERE id = ?');
                $updateStock->execute([$qty, $pId]);

                $updateStaffSummary = $pdo->prepare('
                    UPDATE staff 
                    SET sold_items_summary = JSON_SET(
                        IFNULL(sold_items_summary, JSON_OBJECT()), 
                        CONCAT(\'$.\', JSON_QUOTE(?)), 
                        CAST(IFNULL(JSON_EXTRACT(sold_items_summary, CONCAT(\'$.\', JSON_QUOTE(?))), 0) AS UNSIGNED) + ?
                    ) 
                    WHERE id = ?
                ');
                $updateStaffSummary->execute([$productName, $productName, $qty, $staff_id]);

                $insertItem = $pdo->prepare('INSERT INTO sale_items (sale_id, product_id, quantity, price_at_sale, cost_price_at_sale) VALUES (?, ?, ?, ?, ?)');
                $insertItem->execute([$sale_id, $pId, $qty, $sPrice, $cPrice]);

                $insertInv = $pdo->prepare('INSERT INTO inventory_transactions (product_id, user_id, type, quantity) VALUES (?, ?, "sale", ?)');
                $insertInv->execute([$pId, $user_id, $qty]);
            }

            $updateStaffUnits = $pdo->prepare('UPDATE staff SET total_units_sold = IFNULL(total_units_sold, 0) + ? WHERE id = ?');
            $updateStaffUnits->execute([$totalQtySoldInThisSale, $staff_id]);

            $synced_sale_ids[] = $sale_id;
        }

        $pdo->commit();
        echo json_encode(['status' => 'success', 'synced_sales' => $synced_sale_ids]);

    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        error_log("Sync Sales Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'An error occurred while syncing sales. Transaction rolled back.']);
    }

} elseif ($action === 'get_sales') {
    if ($method !== 'GET') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit;
    }

    try {
        if ($jwt_role === 'Owner') {
            $stmt = $pdo->prepare('
                SELECT 
                  si.product_id, 
                  p.name AS product_name, 
                  st.name AS salesperson, 
                  si.quantity, 
                  si.price_at_sale AS unit_price, 
                  (si.quantity * si.price_at_sale) AS total, 
                  (si.quantity * si.cost_price_at_sale) AS cost_total, 
                  s.sale_date AS created_at, 
                  s.branch_id,
                  si.sale_id
                FROM sale_items si
                JOIN sales s ON si.sale_id = s.id
                JOIN products p ON si.product_id = p.id
                JOIN staff st ON s.staff_id = st.id
                JOIN branches b ON s.branch_id = b.id
                WHERE b.company_id = ?
                ORDER BY s.sale_date DESC
                LIMIT 500
            ');
            $stmt->execute([$jwt_company_id]);
        } else {
            $stmt = $pdo->prepare('
                SELECT 
                  si.product_id, 
                  p.name AS product_name, 
                  st.name AS salesperson, 
                  si.quantity, 
                  si.price_at_sale AS unit_price, 
                  (si.quantity * si.price_at_sale) AS total, 
                  (si.quantity * si.cost_price_at_sale) AS cost_total, 
                  s.sale_date AS created_at, 
                  s.branch_id,
                  si.sale_id
                FROM sale_items si
                JOIN sales s ON si.sale_id = s.id
                JOIN products p ON si.product_id = p.id
                JOIN staff st ON s.staff_id = st.id
                WHERE s.branch_id = ? AND s.user_id = ? AND DATE(s.sale_date) = CURDATE()
                ORDER BY s.sale_date DESC
            ');
            $stmt->execute([$jwt_branch_id, $jwt_user_id]);
        }

        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $sales = [];

        foreach ($results as $row) {
            $saleId = (int)$row['sale_id'];
            $productId = (int)$row['product_id'];
            $compositeId = ($saleId * 10000) + $productId;
            
            $sales[] = [
                'id' => $compositeId,
                'product_id' => $productId,
                'product_name' => $row['product_name'],
                'salesperson' => $row['salesperson'],
                'quantity' => (int)$row['quantity'],
                'unit_price' => (float)$row['unit_price'],
                'total' => (float)$row['total'],
                'cost_total' => (float)$row['cost_total'],
                'costTotal' => (float)$row['cost_total'],
                'created_at' => $row['created_at'],
                'branch_id' => (int)$row['branch_id']
            ];
        }

        echo json_encode(['status' => 'success', 'data' => $sales]);
    } catch (Exception $e) {
        error_log("Get Sales Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'An error occurred while retrieving sales.']);
    }

} elseif ($action === 'get_reports') {
    if ($method !== 'GET') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit;
    }

    try {
        if ($jwt_role === 'Owner') {
            $stmt = $pdo->prepare('
                SELECT dr.* 
                FROM daily_reports dr
                JOIN branches b ON dr.branch_id = b.id
                WHERE b.company_id = ?
                ORDER BY dr.report_date DESC
                LIMIT 100
            ');
            $stmt->execute([$jwt_company_id]);
        } else {
            $stmt = $pdo->prepare('
                SELECT dr.* 
                FROM daily_reports dr
                WHERE dr.branch_id = ? AND dr.report_date = CURDATE()
            ');
            $stmt->execute([$jwt_branch_id]);
        }

        $reports = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Decode JSON fields in reports for easier client usage
        foreach ($reports as &$report) {
            if (isset($report['product_summary_json'])) {
                $report['product_summary_json'] = json_decode($report['product_summary_json'], true);
            }
            if (isset($report['staff_sales_json'])) {
                $report['staff_sales_json'] = json_decode($report['staff_sales_json'], true);
            }
        }

        echo json_encode(['status' => 'success', 'data' => $reports]);
    } catch (Exception $e) {
        error_log("Get Reports Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'An error occurred while retrieving reports.']);
    }

} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid or missing action']);
}
