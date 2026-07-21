<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

header('Content-Type: application/json');

// Security: Allow POST requests only.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 1: Extract Bearer token from Authorization header.
// apache_request_headers() covers Apache mod_php; $_SERVER fallback covers
// Nginx / PHP-FPM.
// ---------------------------------------------------------------------------
$headers    = function_exists('apache_request_headers') ? apache_request_headers() : [];
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

if (empty($authHeader) || !preg_match('/^Bearer\s(\S+)$/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Missing or invalid Bearer token']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 2: Verify token — rejects expired, tampered, or 'none'-algorithm tokens.
// Returns decoded payload array on success, false on any failure.
// ---------------------------------------------------------------------------
$token   = $matches[1];
$payload = verify_jwt($token);

if ($payload === false) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Invalid or expired token']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 3: Extract identity from the *verified* JWT payload.
// Security: company_id and user_id are NEVER read from the request body.
// They come exclusively from the server-signed token to prevent IDOR and
// privilege escalation.
// ---------------------------------------------------------------------------
$jwtCompanyId = $payload['company_id'] ?? null;
$jwtUserId    = $payload['user_id']    ?? null;
$jwtRole      = $payload['role']       ?? null;

if (!$jwtCompanyId || !$jwtUserId) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Token is missing required claims']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 4: Parse request body and dispatch on 'action'.
// ---------------------------------------------------------------------------
$input  = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? null;

if (!$action) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required field: action']);
    exit;
}

switch ($action) {

    // -----------------------------------------------------------------------
    // ACTION: get_products
    // Returns active (non-deleted) products for the authenticated company.
    // Optionally filtered by branch_id from the body — but the branch must
    // belong to the JWT's company_id (IDOR prevention via subquery).
    // -----------------------------------------------------------------------
    case 'get_products':
        try {
            $branchId = isset($input['branch_id']) ? (int) $input['branch_id'] : 0;

            if ($branchId > 0) {
                // Security: Confirm the requested branch belongs to the caller's
                // company before using it as a filter, preventing cross-company
                // data leakage via a body-supplied branch_id.
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
                // No branch filter — return all products for this company.
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
                    'id'            => $row['id'],
                    'name'          => $row['name']          ?? '',
                    'brand'         => $row['brand']         ?? '',
                    'model'         => $row['brand']         ?? '', // alias kept for client compatibility
                    'category'      => $row['category']      ?? '',
                    'specification' => $row['specification']  ?? '',
                    'selling_price' => $row['selling_price'],
                    'unit_price'    => $row['selling_price'], // alias kept for client compatibility
                    'units'         => $row['current_stock'] ?? 0,
                    'stock'         => $row['current_stock'] ?? 0,
                    'branch_id'     => $row['branch_id'],
                    'cost_price'    => $row['cost_price'],
                    'costPrice'     => $row['cost_price'],   // alias kept for client compatibility
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'products' => $products]);
        } catch (PDOException $e) {
            // Security: Log full error server-side; return generic message to client.
            error_log('Products get_products DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    // -----------------------------------------------------------------------
    // ACTION: create_product
    // Security: Owner-only. branch_id from body is validated to belong to the
    // caller's company (IDOR prevention). company_id is never trusted from body.
    // Supports upsert (ON DUPLICATE KEY UPDATE) when product_id is provided.
    // -----------------------------------------------------------------------
    case 'create_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can create products']);
            exit;
        }

        $branchId   = isset($input['branch_id'])     ? (int)    $input['branch_id']              : null;
        $name       = isset($input['product_name'])  ? trim($input['product_name'])              : '';
        $brand      = isset($input['brand'])         ? trim($input['brand'])                     : '';
        $category   = isset($input['category'])      ? trim($input['category'])                  : '';
        $spec       = isset($input['specification']) ? trim($input['specification'])              : '';
        $sPrice     = isset($input['selling_price']) ? (float) $input['selling_price']           : null;
        $cPrice     = isset($input['cost_price'])    ? (float) $input['cost_price']              : null;
        $stock      = isset($input['total_stock'])   ? (int)   $input['total_stock']             : null;
        $lowAlert   = isset($input['low_stock_alert'])  ? (int) $input['low_stock_alert']        : 5;
        $highAlert  = isset($input['high_stock_alert']) ? (int) $input['high_stock_alert']       : 10;

        if (!$branchId || !$name || $sPrice === null || $cPrice === null || $stock === null) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields: branch_id, product_name, selling_price, cost_price, total_stock']);
            exit;
        }

        try {
            // Security: Verify the supplied branch_id belongs to the caller's
            // company before writing. Prevents inserting products into another
            // company's branch via a body-supplied branch_id.
            $branchCheck = $pdo->prepare(
                'SELECT id FROM branches WHERE id = :branch_id AND company_id = :company_id LIMIT 1'
            );
            $branchCheck->execute([':branch_id' => $branchId, ':company_id' => $jwtCompanyId]);
            if (!$branchCheck->fetch()) {
                http_response_code(403);
                echo json_encode(['error' => 'Forbidden: branch_id does not belong to your company']);
                exit;
            }

            $providedProductId = isset($input['product_id']) ? (int) $input['product_id']
                               : (isset($input['id'])        ? (int) $input['id'] : null);

            if ($providedProductId) {
                // Upsert: insert with explicit ID, update if it already exists.
                $stmt = $pdo->prepare(
                    'INSERT INTO products
                     (id, branch_id, name, brand, category, specification,
                      cost_price, selling_price, current_stock, total_inventory,
                      low_stock_alert, high_stock_alert, is_deleted)
                     VALUES
                     (:id, :branch_id, :name, :brand, :category, :specification,
                      :cost_price, :selling_price, :stock, :stock2,
                      :low_alert, :high_alert, 0)
                     ON DUPLICATE KEY UPDATE
                       name            = VALUES(name),
                       brand           = VALUES(brand),
                       category        = VALUES(category),
                       specification   = VALUES(specification),
                       cost_price      = VALUES(cost_price),
                       selling_price   = VALUES(selling_price),
                       current_stock   = VALUES(current_stock),
                       total_inventory = VALUES(total_inventory),
                       low_stock_alert = VALUES(low_stock_alert),
                       high_stock_alert= VALUES(high_stock_alert),
                       is_deleted      = 0'
                );
                $stmt->execute([
                    ':id'           => $providedProductId,
                    ':branch_id'    => $branchId,
                    ':name'         => $name,
                    ':brand'        => $brand,
                    ':category'     => $category,
                    ':specification'=> $spec,
                    ':cost_price'   => $cPrice,
                    ':selling_price'=> $sPrice,
                    ':stock'        => $stock,
                    ':stock2'       => $stock,
                    ':low_alert'    => $lowAlert,
                    ':high_alert'   => $highAlert,
                ]);
                $returnId = $providedProductId;
            } else {
                $stmt = $pdo->prepare(
                    'INSERT INTO products
                     (branch_id, name, brand, category, specification,
                      cost_price, selling_price, current_stock, total_inventory,
                      low_stock_alert, high_stock_alert, is_deleted)
                     VALUES
                     (:branch_id, :name, :brand, :category, :specification,
                      :cost_price, :selling_price, :stock, :stock2,
                      :low_alert, :high_alert, 0)'
                );
                $stmt->execute([
                    ':branch_id'    => $branchId,
                    ':name'         => $name,
                    ':brand'        => $brand,
                    ':category'     => $category,
                    ':specification'=> $spec,
                    ':cost_price'   => $cPrice,
                    ':selling_price'=> $sPrice,
                    ':stock'        => $stock,
                    ':stock2'       => $stock,
                    ':low_alert'    => $lowAlert,
                    ':high_alert'   => $highAlert,
                ]);
                $returnId = (int) $pdo->lastInsertId();
            }

            echo json_encode(['status' => 'success', 'id' => $returnId]);
        } catch (PDOException $e) {
            error_log('Products create_product DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    // -----------------------------------------------------------------------
    // ACTION: update_product
    // Security: Owner-only. WHERE clause includes company_id scope via
    // subquery to prevent cross-company IDOR edits.
    // -----------------------------------------------------------------------
    case 'update_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can update products']);
            exit;
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
            exit;
        }

        try {
            // Security: AND branch_id IN (...) ensures the product belongs to
            // the caller's company. An attacker knowing a foreign product_id
            // cannot modify it (IDOR prevention).
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
                // Product not found or belongs to a different company.
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

    // -----------------------------------------------------------------------
    // ACTION: restock
    // Security: Owner-only. Uses a PDO transaction (beginTransaction/commit/
    // rollBack) instead of raw SQL strings. user_id comes from the JWT payload,
    // not the request body. product_id is scoped to the caller's company.
    // -----------------------------------------------------------------------
    case 'restock':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can restock products']);
            exit;
        }

        $productId      = isset($input['product_id'])   ? (int)   $input['product_id']   : null;
        $unitsToAdd     = isset($input['units_to_add']) ? (int)   $input['units_to_add'] : null;
        $newSellingPrice= isset($input['new_selling_price']) ? (float) $input['new_selling_price'] : null;
        $newCostPrice   = isset($input['new_cost_price'])    ? (float) $input['new_cost_price']    : null;

        if (!$productId || $unitsToAdd === null || $unitsToAdd <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing or invalid required fields: product_id, units_to_add (must be > 0)']);
            exit;
        }

        try {
            // Security: Verify product belongs to the caller's company before
            // beginning the transaction (fail fast, no partial writes).
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
                exit;
            }

            // Use PDO transaction API — never raw SQL string 'START TRANSACTION'.
            $pdo->beginTransaction();

            // 1. Record the restock event in the audit/history table.
            //    Security: user_id comes from the JWT payload, not the body.
            $txStmt = $pdo->prepare(
                'INSERT INTO inventory_transactions
                 (product_id, user_id, type, quantity,
                  cost_price_at_transaction, selling_price_at_transaction)
                 VALUES
                 (:product_id, :user_id, \'restock\', :quantity, :cost_price, :selling_price)'
            );
            $txStmt->execute([
                ':product_id'    => $productId,
                ':user_id'       => $jwtUserId,   // from JWT, not body
                ':quantity'      => $unitsToAdd,
                ':cost_price'    => $newCostPrice,
                ':selling_price' => $newSellingPrice,
            ]);

            // 2. Increment stock and optionally update prices.
            //    Build the SET clause dynamically but safely (only appending
            //    named placeholders for optional price fields).
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

    // -----------------------------------------------------------------------
    // ACTION: delete_product
    // Security: Owner-only. Hard-deletes the product only if it belongs to
    // the caller's company (IDOR prevention via subquery scope).
    // TODO(security): Consider soft-delete (is_deleted = 1) to preserve
    // audit trails and referential integrity with inventory_transactions.
    // -----------------------------------------------------------------------
    case 'delete_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can delete products']);
            exit;
        }

        $productId = isset($input['product_id']) ? (int) $input['product_id'] : null;

        if (!$productId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing or invalid required field: product_id']);
            exit;
        }

        try {
            // Security: AND branch_id IN (...) prevents deletion of products
            // belonging to other companies (IDOR prevention).
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

    // -----------------------------------------------------------------------
    // Default: unknown action
    // -----------------------------------------------------------------------
    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        break;
}
