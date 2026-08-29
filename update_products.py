import re

with open('hisab_server/php/products.php', 'r') as f:
    content = f.read()

# Chunk 1: CORS headers
target_1 = """<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

header('Content-Type: application/json');

// Security: Allow POST requests only.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}"""

replacement_1 = """<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

// Security: Dynamically check and allow trusted origins (localhost for development)
// rather than using a wildcard (*) which is forbidden by secure coding guidelines.
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

// Security: Allow POST requests only.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}"""

content = content.replace(target_1, replacement_1)

# Chunk 2: action handler
pattern_2 = re.compile(
    r"    // -----------------------------------------------------------------------\n"
    r"    // ACTION: create_product\n"
    r".*?    case 'create_product':\n.*?        break;\n",
    re.DOTALL
)

replacement_2 = """    // -----------------------------------------------------------------------
    // ACTION: addProduct / create_product
    // Security: Owner-only. branch_id from body is validated to belong to the
    // caller's company (IDOR prevention). company_id is never trusted from body.
    // -----------------------------------------------------------------------
    case 'addProduct':
    case 'create_product':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can create products']);
            exit;
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

            echo json_encode(['status' => 'success', 'id' => $id ?? $pdo->lastInsertId()]);
        } catch (PDOException $e) {
            error_log('Products create_product DB Error: ' . $e->getMessage());
            http_response_code(500);
            // TODO(security): The request asked to print the exact error message.
            // However, this violates the mandatory secure web skills guideline:
            // "MUST NOT expose SQL errors to users".
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;
"""

if not pattern_2.search(content):
    print("Could not find the create_product block!")
else:
    content = pattern_2.sub(replacement_2, content)
    with open('hisab_server/php/products.php', 'w') as f:
        f.write(content)
    print("Successfully updated products.php")

