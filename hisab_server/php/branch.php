<?php
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
// Security: Restrict to POST only; reject all other methods.
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 1: Extract and validate the Bearer token from the Authorization header.
// ---------------------------------------------------------------------------
$token = get_bearer_token();

// ---------------------------------------------------------------------------
// Step 2: Verify the token signature and expiry using verify_jwt().
// Returns the decoded payload array on success, or false on failure.
// ---------------------------------------------------------------------------
$payload = verify_jwt($token);

if ($payload === false) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Invalid or expired token']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 3: Extract identity fields from the *verified* JWT payload.
// Security: company_id is NEVER read from the request body. It comes
// exclusively from the server-signed token, preventing IDOR/horizontal
// privilege escalation.
// ---------------------------------------------------------------------------
$jwtCompanyId = $payload['company_id'] ?? null;
$jwtRole      = $payload['role']       ?? null;

if (!$jwtCompanyId) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Token is missing required claims']);
    exit;
}

// ---------------------------------------------------------------------------
// Step 4: Parse the JSON request body and dispatch on 'action'.
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
    // ACTION: get_branches
    // Returns all branches belonging to the authenticated user's company.
    // Security: WHERE clause is bound exclusively to $jwtCompanyId.
    // -----------------------------------------------------------------------
    case 'get_branches':
        try {
            $stmt = $pdo->prepare(
                'SELECT id, name, location, cashier_name, company_id
                 FROM branches
                 WHERE company_id = :company_id'
            );
            $stmt->execute([':company_id' => $jwtCompanyId]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            $branches = array_map(function ($row) {
                return [
                    'id'          => $row['id'],
                    'name'        => $row['name'],
                    'branch_name' => $row['name'],
                    'location'    => $row['location']     ?? '',
                    'cashier'     => $row['cashier_name'] ?? 'Not Assigned',
                    'cashier_name'=> $row['cashier_name'] ?? 'Not Assigned',
                    'company_id'  => $row['company_id'],
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'branches' => $branches]);
        } catch (PDOException $e) {
            // Security: Log full error server-side; return generic message to client.
            error_log('Branch get_branches DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    // -----------------------------------------------------------------------
    // ACTION: addBranch / create_branch
    // Security: Restricted to role 'Owner' only.
    // company_id is bound from JWT — body-supplied company_id is ignored.
    // -----------------------------------------------------------------------
    case 'addBranch':
    case 'create_branch':
        // RBAC enforcement: Only Owners may create branches.
        if (strtolower($jwtRole ?? '') !== 'owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can create branches']);
            exit;
        }

        $branchName = $input['name'] ?? $input['branch_name'] ?? null;
        if (is_string($branchName)) {
            $branchName = trim($branchName);
        }
        if (empty($branchName)) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Branch name is required']);
            exit;
        }

        $location = isset($input['location']) && trim($input['location']) !== '' ? trim($input['location']) : 'Unknown';
        $cashierName = isset($input['cashier_name']) && trim($input['cashier_name']) !== '' ? trim($input['cashier_name']) : (isset($input['cashier']) && trim($input['cashier']) !== '' ? trim($input['cashier']) : 'Not Assigned');

        try {
            $stmt = $pdo->prepare(
                'INSERT INTO branches (company_id, name, location, cashier_name) VALUES (:company_id, :name, :location, :cashier_name)'
            );
            $stmt->execute([
                ':company_id'   => $jwtCompanyId,
                ':name'         => $branchName,
                ':location'     => $location,
                ':cashier_name' => $cashierName,
            ]);

            $newId = $pdo->lastInsertId();
            echo json_encode([
                'status'    => 'success',
                'branch_id' => $newId,
                'message'   => "Branch $branchName saved!",
            ]);
        } catch (PDOException $e) {
            error_log('Branch create_branch DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
        }
        break;

    // -----------------------------------------------------------------------
    // ACTION: update_branch
    // Security: Restricted to role 'Owner' only.
    // WHERE clause includes company_id from JWT to prevent cross-company edits.
    // Uses COALESCE so only provided fields are updated.
    // -----------------------------------------------------------------------
    case 'update_branch':
        // RBAC enforcement: Only Owners may update branches.
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can update branches']);
            exit;
        }

        $branchId    = isset($input['branch_id']) ? (int) $input['branch_id']
                     : (isset($input['id'])        ? (int) $input['id'] : null);
        $branchName  = isset($input['branch_name']) ? trim($input['branch_name'])
                     : (isset($input['name'])       ? trim($input['name']) : null);
        $location    = isset($input['location'])    ? trim($input['location'])    : null;
        $cashierName = isset($input['cashier_name'])? trim($input['cashier_name'])
                     : (isset($input['cashier'])    ? trim($input['cashier'])     : null);

        if (!$branchId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required field: branch_id']);
            exit;
        }

        try {
            // Security: AND company_id = :company_id ensures an Owner cannot
            // modify a branch belonging to a different company, even if they
            // know its ID (IDOR prevention).
            $stmt = $pdo->prepare(
                'UPDATE branches
                 SET name        = COALESCE(:name,        name),
                     location    = COALESCE(:location,    location),
                     cashier_name= COALESCE(:cashier_name,cashier_name)
                 WHERE id = :branch_id
                   AND company_id = :company_id'
            );
            $stmt->execute([
                ':name'        => $branchName,
                ':location'    => $location,
                ':cashier_name'=> $cashierName,
                ':branch_id'   => $branchId,
                ':company_id'  => $jwtCompanyId,
            ]);

            if ($stmt->rowCount() === 0) {
                // Either branch doesn't exist or belongs to another company.
                // Return 404 to avoid leaking existence of other companies' branches.
                http_response_code(404);
                echo json_encode(['error' => 'Branch not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Branch updated successfully']);
            }
        } catch (PDOException $e) {
            error_log('Branch update_branch DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    // -----------------------------------------------------------------------
    // ACTION: delete_branch
    // Security: WHERE clause includes company_id from JWT (IDOR prevention).
    // Any authenticated user of the company can delete (no Owner restriction
    // in the original Dart logic), matching source behaviour. Add RBAC here
    // if business rules require it in future.
    // TODO(security): Restrict delete_branch to 'Owner' role if business logic
    // requires it — the original Dart controller had no RBAC on delete.
    // -----------------------------------------------------------------------
    case 'delete_branch':
        $branchId = isset($input['branch_id']) ? (int) $input['branch_id']
                  : (isset($input['id'])        ? (int) $input['id'] : null);

        if (!$branchId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required field: branch_id']);
            exit;
        }

        try {
            // Security: AND company_id = :company_id prevents deletion of
            // branches belonging to other companies (IDOR prevention).
            $stmt = $pdo->prepare(
                'DELETE FROM branches
                 WHERE id = :branch_id
                   AND company_id = :company_id'
            );
            $stmt->execute([
                ':branch_id'  => $branchId,
                ':company_id' => $jwtCompanyId,
            ]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Branch not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Branch deleted successfully']);
            }
        } catch (PDOException $e) {
            error_log('Branch delete_branch DB Error: ' . $e->getMessage());
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
