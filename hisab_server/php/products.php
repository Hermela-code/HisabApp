<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

// Security: Dynamically check and allow trusted origins (localhost for development)
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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit();
}

$headers    = function_exists('apache_request_headers') ? apache_request_headers() : [];
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

if (empty($authHeader) || !preg_match('/^Bearer\s(\S+)$/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Missing or invalid Bearer token']);
    exit();
}

$token   = $matches[1];
$payload = verify_jwt($token);

if ($payload === false) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Invalid or expired token']);
    exit();
}

$jwtCompanyId = $payload['company_id'] ?? null;
$jwtUserId    = $payload['user_id']    ?? null;
$jwtRole      = $payload['role']       ?? null;

if (!$jwtCompanyId || !$jwtUserId) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Token is missing required claims']);
    exit();
}

$input  = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? null;

if (!$action) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required field: action']);
    exit();
}

switch ($action) {

    case 'get_products':
        try {
            $branchId = isset($input['branch_id']) ? (int) $input['branch_id'] : 0;

            if ($branchId > 0) {
                $stmt = $pdo->prepare(
                    'SELECT id, name, brand, category, specification,
                            selling_price, current_stock, branch_id, cost_price
                     FROM products
                     WHERE branch_id = :branch_id
                       AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                       AND is_deleted = 0'
                );
                $stmt->execute([
                    ':branch_id'  => $branchId,
                    ':company_id' => $jwtCompanyId,
                ]);
            } else {
                $stmt = $pdo->prepare(
                    'SELECT id, name, brand, category, specification,
                            selling_price, current_stock, branch_id, cost_price
                     FROM products
                     WHERE branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                       AND is_deleted = 0'
                );
                $stmt->execute([':company_id' => $jwtCompanyId]);
            }

            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $products = array_map(function ($row) {
                return [
                    'id'            => (int)$row['id'],
                    'name'          => $row['name']          ?? '',
                    'brand'         => $row['brand']         ?? '',
                    'model'         => $row['brand']         ?? '',
                    'category'      => $row['category']      ?? '',
                    'specification' => $row['specification']  ?? '',
                    'selling_price' => (float)$row['selling_price'],
                    'unit_price'    => (float)$row['selling_price'],
                    'units'         => (int)$row['current_stock'],
                    'stock'         => (int)$row['current_stock'],
                    'branch_id'     => (int)$row['branch_id'],
                    'cost_price'    => (float)$row['cost_price'],
                    'costPrice'     => (float)$row['cost_price'],
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'products' => $products]);
        } catch (PDOException $e) {
            error_log('Products get_products DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'addProduct':
    case 'create_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can create products']);
            exit();
        }

        $id        = isset($input['id']) ? (int) $input['id'] : (isset($input['product_id']) ? (int) $input['product_id'] : null);
        $branchId  = isset($input['branch_id']) ? (int) $input['branch_id'] : null;
        $name      = isset($input['product_name']) ? trim($input['product_name']) : (isset($input['name']) ? trim($input['name']) : '');
        $brand     = isset($input['brand']) ? trim($input['brand']) : '';
        $category  = isset($input['category']) ? trim($input['category']) : '';
        $spec      = isset($input['specification']) ? trim($input['specification']) : '';
        $sPrice    = isset($input['selling_price']) ? (float) $input['selling_price'] : (isset($input['unit_price']) ? (float) $input['unit_price'] : 0.0);
        $cPrice    = isset($input['cost_price']) ? (float) $input['cost_price'] : 0.0;
        $stock     = isset($input['total_stock']) ? (int) $input['total_stock'] : (isset($input['current_stock']) ? (int) $input['current_stock'] : 0);
        $totalInv  = isset($input['total_inventory']) ? (int) $input['total_inventory'] : $stock;

        if (!$branchId || !$name) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields: branch_id, product_name']);
            exit();
        }

        try {
            $branchCheck = $pdo->prepare(
                'SELECT id FROM branches WHERE id = :branch_id AND company_id = :company_id LIMIT 1'
            );
            $branchCheck->execute([':branch_id' => $branchId, ':company_id' => $jwtCompanyId]);
            if (!$branchCheck->fetch()) {
                http_response_code(403);
                echo json_encode(['error' => 'Forbidden: branch_id does not belong to your company']);
                exit();
            }

            if ($id !== null) {
                $stmt = $pdo->prepare(
                    'INSERT INTO products (id, branch_id, name, brand, category, specification, cost_price, selling_price, current_stock, total_inventory) 
                     VALUES (:id, :branch_id, :name, :brand, :category, :specification, :cost_price, :selling_price, :current_stock, :total_inventory)'
                );
                $stmt->execute([
                    ':id'             => $id,
                    ':branch_id'      => $branchId,
                    ':name'           => $name,
                    ':brand'          => $brand,
                    ':category'       => $category,
                    ':specification'  => $spec,
                    ':cost_price'     => $cPrice,
                    ':selling_price'  => $sPrice,
                    ':current_stock'  => $stock,
                    ':total_inventory'=> $totalInv,
                ]);
                $productId = $id;
            } else {
                $stmt = $pdo->prepare(
                    'INSERT INTO products (branch_id, name, brand, category, specification, cost_price, selling_price, current_stock, total_inventory) 
                     VALUES (:branch_id, :name, :brand, :category, :specification, :cost_price, :selling_price, :current_stock, :total_inventory)'
                );
                $stmt->execute([
                    ':branch_id'      => $branchId,
                    ':name'           => $name,
                    ':brand'          => $brand,
                    ':category'       => $category,
                    ':specification'  => $spec,
                    ':cost_price'     => $cPrice,
                    ':selling_price'  => $sPrice,
                    ':current_stock'  => $stock,
                    ':total_inventory'=> $totalInv,
                ]);
                $productId = (int)$pdo->lastInsertId();
            }

            echo json_encode(['status' => 'success', 'id' => $productId, 'product_id' => $productId]);
        } catch (PDOException $e) {
            error_log('Products create_product DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Internal Server Error']);
        }
        break;

    case 'update_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can update products']);
            exit();
        }

        $productId = isset($input['product_id']) ? (int) $input['product_id'] : null;
        $name      = isset($input['product_name'])  ? trim($input['product_name'])   : '';
        $brand     = isset($input['brand'])         ? trim($input['brand'])          : '';
        $category  = isset($input['category'])      ? trim($input['category'])       : '';
        $spec      = isset($input['specification']) ? trim($input['specification'])   : '';
        $sPrice    = isset($input['selling_price']) ? (float) $input['selling_price'] : null;
        $cPrice    = isset($input['cost_price'])    ? (float) $input['cost_price']    : null;
        $stock     = isset($input['total_stock'])   ? (int)   $input['total_stock']   : null;
        $lowAlert  = isset($input['low_stock_alert'])  ? (int) $input['low_stock_alert']  : 5;
        $highAlert = isset($input['high_stock_alert']) ? (int) $input['high_stock_alert'] : 10;

        if (!$productId || $sPrice === null || $cPrice === null || $stock === null) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields: product_id, selling_price, cost_price, total_stock']);
            exit();
        }

        try {
            $stmt = $pdo->prepare(
                'UPDATE products
                 SET name             = :name,
                     brand            = :brand,
                     category         = :category,
                     specification    = :specification,
                     cost_price       = :cost_price,
                     selling_price    = :selling_price,
                     current_stock    = :stock,
                     low_stock_alert  = :low_alert,
                     high_stock_alert = :high_alert
                 WHERE id = :product_id
                   AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)'
            );
            $stmt->execute([
                ':name'         => $name,
                ':brand'        => $brand,
                ':category'     => $category,
                ':specification'=> $spec,
                ':cost_price'   => $cPrice,
                ':selling_price'=> $sPrice,
                ':stock'        => $stock,
                ':low_alert'    => $lowAlert,
                ':high_alert'   => $highAlert,
                ':product_id'   => $productId,
                ':company_id'   => $jwtCompanyId,
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Product not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Product updated successfully']);
            }
        } catch (PDOException $e) {
            error_log('Products update_product DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'restock':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can restock products']);
            exit();
        }

        $productId      = isset($input['product_id'])   ? (int)   $input['product_id']   : null;
        $unitsToAdd     = isset($input['units_to_add']) ? (int)   $input['units_to_add'] : null;
        $newSellingPrice= isset($input['new_selling_price']) ? (float) $input['new_selling_price'] : null;
        $newCostPrice   = isset($input['new_cost_price'])    ? (float) $input['new_cost_price']    : null;

        if (!$productId || $unitsToAdd === null || $unitsToAdd <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing or invalid required fields: product_id, units_to_add (must be > 0)']);
            exit();
        }

        try {
            $ownerCheck = $pdo->prepare(
                'SELECT id FROM products
                 WHERE id = :product_id
                   AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                   AND is_deleted = 0
                 LIMIT 1'
            );
            $ownerCheck->execute([':product_id' => $productId, ':company_id' => $jwtCompanyId]);
            if (!$ownerCheck->fetch()) {
                http_response_code(404);
                echo json_encode(['error' => 'Product not found']);
                exit();
            }

            $pdo->beginTransaction();

            $txStmt = $pdo->prepare(
                'INSERT INTO inventory_transactions
                 (product_id, user_id, type, quantity,
                  cost_price_at_transaction, selling_price_at_transaction)
                 VALUES
                 (:product_id, :user_id, \'restock\', :quantity, :cost_price, :selling_price)'
            );
            $txStmt->execute([
                ':product_id'    => $productId,
                ':user_id'       => $jwtUserId,
                ':quantity'      => $unitsToAdd,
                ':cost_price'    => $newCostPrice,
                ':selling_price' => $newSellingPrice,
            ]);

            $setClauses = [
                'current_stock    = current_stock + :units',
                'total_inventory  = total_inventory + :units2',
            ];
            $updateParams = [
                ':units'      => $unitsToAdd,
                ':units2'     => $unitsToAdd,
                ':product_id' => $productId,
                ':company_id' => $jwtCompanyId,
            ];

            if ($newSellingPrice !== null) {
                $setClauses[]                    = 'selling_price = :selling_price';
                $updateParams[':selling_price']  = $newSellingPrice;
            }
            if ($newCostPrice !== null) {
                $setClauses[]                 = 'cost_price = :cost_price';
                $updateParams[':cost_price']  = $newCostPrice;
            }

            $setSQL    = implode(', ', $setClauses);
            $updateStmt = $pdo->prepare(
                "UPDATE products
                 SET $setSQL
                 WHERE id = :product_id
                   AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)"
            );
            $updateStmt->execute($updateParams);

            $pdo->commit();

            echo json_encode(['status' => 'success', 'message' => 'Stock and history updated.']);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log('Products restock DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'delete_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can delete products']);
            exit();
        }

        $productId = isset($input['product_id']) ? (int) $input['product_id'] : null;

        if (!$productId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing or invalid required field: product_id']);
            exit();
        }

        try {
            $stmt = $pdo->prepare(
                'DELETE FROM products
                 WHERE id = :product_id
                   AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)'
            );
            $stmt->execute([
                ':product_id' => $productId,
                ':company_id' => $jwtCompanyId,
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Product not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Product deleted successfully']);
            }
        } catch (PDOException $e) {
            error_log('Products delete_product DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'get_attributes':
        try {
            $stmt = $pdo->prepare('SELECT attribute_name FROM product_attributes WHERE company_id = :company_id');
            $stmt->execute([':company_id' => $jwtCompanyId]);
            $rows = $stmt->fetchAll(PDO::FETCH_COLUMN);

            echo json_encode(['status' => 'success', 'attributes' => $rows]);
        } catch (PDOException $e) {
            error_log('Products get_attributes DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'define_attributes':
        $attributes = $input['attributes'] ?? [];
        if (!is_array($attributes)) {
            http_response_code(400);
            echo json_encode(['error' => 'Attributes must be an array']);
            exit();
        }

        try {
            $pdo->beginTransaction();
            $delStmt = $pdo->prepare('DELETE FROM product_attributes WHERE company_id = :company_id');
            $delStmt->execute([':company_id' => $jwtCompanyId]);

            $insStmt = $pdo->prepare('INSERT INTO product_attributes (company_id, attribute_name) VALUES (:company_id, :attr)');
            foreach ($attributes as $attr) {
                if (is_string($attr) && trim($attr) !== '') {
                    $insStmt->execute([':company_id' => $jwtCompanyId, ':attr' => trim($attr)]);
                }
            }

            $pdo->commit();
            echo json_encode(['status' => 'success', 'message' => 'Attributes saved successfully']);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log('Products define_attributes DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        break;
}
