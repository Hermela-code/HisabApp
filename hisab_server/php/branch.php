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

$token = get_bearer_token();
$payload = verify_jwt($token);

if ($payload === false) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Invalid or expired token']);
    exit();
}

$jwtCompanyId = $payload['company_id'] ?? null;
$jwtRole      = $payload['role']       ?? null;

if (!$jwtCompanyId) {
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
                    'id'          => (int)$row['id'],
                    'name'        => $row['name'],
                    'branch_name' => $row['name'],
                    'location'    => $row['location']     ?? '',
                    'cashier'     => $row['cashier_name'] ?? 'Not Assigned',
                    'cashier_name'=> $row['cashier_name'] ?? 'Not Assigned',
                    'company_id'  => (int)$row['company_id'],
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'branches' => $branches]);
        } catch (PDOException $e) {
            error_log('Branch get_branches DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'addBranch':
    case 'create_branch':
        if (strtolower($jwtRole ?? '') !== 'owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can create branches']);
            exit();
        }

        $branchName = $input['name'] ?? $input['branch_name'] ?? null;
        if (is_string($branchName)) {
            $branchName = trim($branchName);
        }
        if (empty($branchName)) {
            http_response_code(400);
            echo json_encode(['status' => 'error', 'message' => 'Branch name is required']);
            exit();
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

            $newId = (int)$pdo->lastInsertId();
            echo json_encode([
                'status'    => 'success',
                'branch_id' => $newId,
                'message'   => "Branch $branchName saved!",
            ]);
        } catch (PDOException $e) {
            error_log('Branch create_branch DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Internal Server Error']);
        }
        break;

    case 'update_branch':
        if ($jwtRole !== 'Owner') {
            http_response_code(403);
            echo json_encode(['error' => 'Forbidden: Only Owners can update branches']);
            exit();
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
            exit();
        }

        try {
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

    case 'delete_branch':
        $branchId = isset($input['branch_id']) ? (int) $input['branch_id']
                  : (isset($input['id'])        ? (int) $input['id'] : null);

        if (!$branchId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required field: branch_id']);
            exit();
        }

        try {
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

    case 'get_branch_costs':
        $branchId = isset($input['branch_id']) ? (int)$input['branch_id'] : 0;
        try {
            if ($branchId > 0) {
                $stmt = $pdo->prepare('
                    SELECT id, branch_id, description, amount, expense_date AS created_at 
                    FROM branch_costs 
                    WHERE branch_id = :branch_id AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                    ORDER BY expense_date DESC
                ');
                $stmt->execute([':branch_id' => $branchId, ':company_id' => $jwtCompanyId]);
            } else {
                $stmt = $pdo->prepare('
                    SELECT id, branch_id, description, amount, expense_date AS created_at 
                    FROM branch_costs 
                    WHERE branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                    ORDER BY expense_date DESC
                ');
                $stmt->execute([':company_id' => $jwtCompanyId]);
            }

            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $costs = array_map(function ($row) {
                return [
                    'id' => (int)$row['id'],
                    'branch_id' => (int)$row['branch_id'],
                    'description' => $row['description'],
                    'amount' => (float)$row['amount'],
                    'created_at' => $row['created_at'],
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'costs' => $costs, 'data' => $costs]);
        } catch (PDOException $e) {
            error_log('get_branch_costs DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'add_branch_cost':
        $branchId = isset($input['branch_id']) ? (int)$input['branch_id'] : null;
        $description = isset($input['description']) ? trim($input['description']) : '';
        $amount = isset($input['amount']) ? (float)$input['amount'] : 0.0;
        $expenseDate = isset($input['expense_date']) ? trim($input['expense_date']) : date('Y-m-d');

        if (!$branchId || empty($description) || $amount <= 0) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing or invalid required fields for branch cost']);
            exit();
        }

        try {
            $stmt = $pdo->prepare('
                INSERT INTO branch_costs (branch_id, description, amount, expense_date)
                VALUES (:branch_id, :description, :amount, :expense_date)
            ');
            $stmt->execute([
                ':branch_id' => $branchId,
                ':description' => $description,
                ':amount' => $amount,
                ':expense_date' => $expenseDate,
            ]);

            $newId = (int)$pdo->lastInsertId();
            echo json_encode(['status' => 'success', 'cost_id' => $newId, 'message' => 'Branch cost added successfully']);
        } catch (PDOException $e) {
            error_log('add_branch_cost DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'delete_branch_cost':
        $costId = isset($input['cost_id']) ? (int)$input['cost_id'] : (isset($input['id']) ? (int)$input['id'] : null);

        if (!$costId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing cost_id']);
            exit();
        }

        try {
            $stmt = $pdo->prepare('
                DELETE FROM branch_costs 
                WHERE id = :cost_id 
                  AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
            ');
            $stmt->execute([':cost_id' => $costId, ':company_id' => $jwtCompanyId]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Branch cost not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Branch cost deleted successfully']);
            }
        } catch (PDOException $e) {
            error_log('delete_branch_cost DB Error: ' . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        break;
}
