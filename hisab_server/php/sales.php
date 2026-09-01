<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

// Allow trusted dev origins
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (preg_match('/^http:\/\/localhost(:\d+)?$/', $origin) || preg_match('/^http:\/\/127\.0\.0\.1(:\d+)?$/', $origin)) {
    header("Access-Control-Allow-Origin: $origin");
}
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

header('Content-Type: application/json');

$token = get_bearer_token();
$payload = verify_jwt($token);

if (!$payload) {
    http_response_code(401);
    echo json_encode(['status' => 'error', 'message' => 'Unauthorized: Invalid or expired token']);
    exit();
}

$jwt_company_id = $payload['company_id'] ?? null;
$jwt_branch_id = $payload['branch_id'] ?? null;
$jwt_user_id = $payload['user_id'] ?? null;
$jwt_role = $payload['role'] ?? null;

if (!$jwt_company_id) {
    http_response_code(403);
    echo json_encode(['status' => 'error', 'message' => 'Forbidden: Missing company claims']);
    exit();
}

$action = $_GET['action'] ?? $_POST['action'] ?? '';

if (empty($action)) {
    $inputRaw = file_get_contents('php://input');
    $parsedInput = json_decode($inputRaw, true);
    if (is_array($parsedInput) && isset($parsedInput['action'])) {
        $action = $parsedInput['action'];
    }
}

if ($action === 'sync_sales') {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit();
    }

    $input = file_get_contents('php://input');
    $data = json_decode($input, true);

    if (!is_array($data)) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Invalid input, expected an array of sales']);
        exit();
    }

    try {
        $pdo->beginTransaction();
        $synced_sale_ids = [];

        foreach ($data as $sale) {
            // Determine branch_id
            $branch_id = $jwt_branch_id;
            if (!$branch_id && isset($sale['branch_id'])) {
                $checkBranch = $pdo->prepare('SELECT id FROM branches WHERE id = ? AND company_id = ? LIMIT 1');
                $checkBranch->execute([(int)$sale['branch_id'], $jwt_company_id]);
                if ($checkBranch->fetch()) {
                    $branch_id = (int)$sale['branch_id'];
                }
            }

            if (!$branch_id) {
                // Fallback: pick first branch of the company
                $firstBranch = $pdo->prepare('SELECT id FROM branches WHERE company_id = ? ORDER BY id ASC LIMIT 1');
                $firstBranch->execute([$jwt_company_id]);
                $fbRow = $firstBranch->fetch();
                if ($fbRow) {
                    $branch_id = (int)$fbRow['id'];
                } else {
                    throw new Exception('No valid branch found for company');
                }
            }

            $user_id = $jwt_user_id;

            // Resolve staff_id
            $staff_id = isset($sale['staff_id']) ? (int)$sale['staff_id'] : 0;
            if ($staff_id > 0) {
                $checkStaff = $pdo->prepare('SELECT id FROM staff WHERE id = ? AND branch_id = ? LIMIT 1');
                $checkStaff->execute([$staff_id, $branch_id]);
                if (!$checkStaff->fetch()) {
                    $staff_id = 0;
                }
            }

            if ($staff_id === 0) {
                // Check if any staff exists for this branch
                $findStaff = $pdo->prepare('SELECT id FROM staff WHERE branch_id = ? ORDER BY id ASC LIMIT 1');
                $findStaff->execute([$branch_id]);
                $sRow = $findStaff->fetch();
                if ($sRow) {
                    $staff_id = (int)$sRow['id'];
                } else {
                    // Auto-provision a default staff entry for this branch
                    $createStaff = $pdo->prepare('INSERT INTO staff (branch_id, name, role) VALUES (?, "Default Cashier", "Staff")');
                    $createStaff->execute([$branch_id]);
                    $staff_id = (int)$pdo->lastInsertId();
                }
            }

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
                    throw new Exception("Insufficient stock for product ID {$product['name']}. Available: $currentStock, Requested: $qty");
                }

                $totalQtySoldInThisSale += $qty;

                $updateStock = $pdo->prepare('UPDATE products SET current_stock = current_stock - ? WHERE id = ?');
                $updateStock->execute([$qty, $pId]);

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
        echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
    }

} elseif ($action === 'get_sales') {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
        exit();
    }

    try {
        $requestedBranchId = isset($_GET['branch_id']) ? (int)$_GET['branch_id'] : 0;

        if ($requestedBranchId > 0) {
            $stmt = $pdo->prepare('
                SELECT 
                  si.product_id, 
                  p.name AS product_name, 
                  COALESCE(st.name, u.username, "Staff") AS salesperson, 
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
                LEFT JOIN staff st ON s.staff_id = st.id
                LEFT JOIN users u ON s.user_id = u.id
                JOIN branches b ON s.branch_id = b.id
                WHERE s.branch_id = ? AND b.company_id = ?
                ORDER BY s.sale_date DESC
                LIMIT 500
            ');
            $stmt->execute([$requestedBranchId, $jwt_company_id]);
        } else {
            $stmt = $pdo->prepare('
                SELECT 
                  si.product_id, 
                  p.name AS product_name, 
                  COALESCE(st.name, u.username, "Staff") AS salesperson, 
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
                LEFT JOIN staff st ON s.staff_id = st.id
                LEFT JOIN users u ON s.user_id = u.id
                JOIN branches b ON s.branch_id = b.id
                WHERE b.company_id = ?
                ORDER BY s.sale_date DESC
                LIMIT 500
            ');
            $stmt->execute([$jwt_company_id]);
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

} elseif ($action === 'generate_daily_snapshot') {
    $inputRaw = file_get_contents('php://input');
    $input = json_decode($inputRaw, true);
    $branch_id = isset($input['branch_id']) ? (int)$input['branch_id'] : $jwt_branch_id;

    if (!$branch_id) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing branch_id']);
        exit();
    }

    try {
        $stmtSales = $pdo->prepare('
            SELECT SUM(s.total_amount) AS income, SUM(si.quantity) AS units, SUM(si.quantity * si.cost_price_at_sale) AS total_cost
            FROM sales s
            JOIN sale_items si ON s.id = si.sale_id
            WHERE s.branch_id = ? AND DATE(s.sale_date) = CURDATE()
        ');
        $stmtSales->execute([$branch_id]);
        $sRow = $stmtSales->fetch();

        $income = (float)($sRow['income'] ?? 0.0);
        $units = (int)($sRow['units'] ?? 0);
        $cost = (float)($sRow['total_cost'] ?? 0.0);

        $stmtCosts = $pdo->prepare('SELECT SUM(amount) AS branch_costs FROM branch_costs WHERE branch_id = ? AND expense_date = CURDATE()');
        $stmtCosts->execute([$branch_id]);
        $cRow = $stmtCosts->fetch();
        $bCosts = (float)($cRow['branch_costs'] ?? 0.0);

        $stmtReport = $pdo->prepare('
            INSERT INTO daily_reports (branch_id, report_date, total_income, total_branch_costs, total_units_sold, status)
            VALUES (?, CURDATE(), ?, ?, ?, "Generated")
            ON DUPLICATE KEY UPDATE 
                total_income = VALUES(total_income),
                total_branch_costs = VALUES(total_branch_costs),
                total_units_sold = VALUES(total_units_sold),
                status = "Updated"
        ');
        $stmtReport->execute([$branch_id, $income, $bCosts, $units]);

        echo json_encode(['status' => 'success', 'message' => 'Daily snapshot generated successfully']);
    } catch (Exception $e) {
        error_log("Generate Snapshot Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to generate daily snapshot']);
    }

} elseif ($action === 'mark_as_deposited') {
    $inputRaw = file_get_contents('php://input');
    $input = json_decode($inputRaw, true);
    $report_id = isset($input['id']) ? (int)$input['id'] : 0;

    if (!$report_id) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing report id']);
        exit();
    }

    try {
        $stmt = $pdo->prepare('UPDATE daily_reports SET status = "Deposited" WHERE id = ? AND branch_id IN (SELECT id FROM branches WHERE company_id = ?)');
        $stmt->execute([$report_id, $jwt_company_id]);

        echo json_encode(['status' => 'success', 'message' => 'Report marked as deposited']);
    } catch (Exception $e) {
        error_log("Mark Deposited Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Failed to mark report deposited']);
    }

} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid or missing action']);
}
