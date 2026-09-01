<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

// Security: Allow trusted development origins
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

if (!$payload) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Invalid or expired token']);
    exit();
}

$jwtCompanyId = $payload['company_id'] ?? null;
$jwtRole = $payload['role'] ?? null;

if (!$jwtCompanyId) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Missing company claims']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? null;

if (!$action) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required field: action']);
    exit();
}

switch ($action) {
    case 'get_staff':
        try {
            $branchId = isset($input['branch_id']) ? (int)$input['branch_id'] : 0;

            if ($branchId > 0) {
                $stmt = $pdo->prepare('
                    SELECT id, branch_id, name, role, phone_number, total_units_sold 
                    FROM staff 
                    WHERE branch_id = :branch_id 
                      AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                ');
                $stmt->execute([':branch_id' => $branchId, ':company_id' => $jwtCompanyId]);
            } else {
                $stmt = $pdo->prepare('
                    SELECT id, branch_id, name, role, phone_number, total_units_sold 
                    FROM staff 
                    WHERE branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
                ');
                $stmt->execute([':company_id' => $jwtCompanyId]);
            }

            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $staffList = array_map(function ($row) {
                return [
                    'id' => (int)$row['id'],
                    'branch_id' => (int)$row['branch_id'],
                    'name' => $row['name'],
                    'role' => $row['role'] ?? 'Staff',
                    'phone' => $row['phone_number'] ?? '',
                    'phone_number' => $row['phone_number'] ?? '',
                    'total_units_sold' => (int)($row['total_units_sold'] ?? 0),
                ];
            }, $rows);

            echo json_encode(['status' => 'success', 'staff' => $staffList, 'data' => $staffList]);
        } catch (PDOException $e) {
            error_log("get_staff DB Error: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'create_cashier':
    case 'add_staff':
    case 'create_staff':
        $branchId = isset($input['branch_id']) ? (int)$input['branch_id'] : null;
        $name = isset($input['name']) ? trim($input['name']) : (isset($input['cashier_name']) ? trim($input['cashier_name']) : '');
        $phone = isset($input['phone_number']) ? trim($input['phone_number']) : (isset($input['cashier_phone']) ? trim($input['cashier_phone']) : (isset($input['phone']) ? trim($input['phone']) : ''));
        $role = isset($input['role']) ? trim($input['role']) : 'Staff';
        $password = isset($input['cashier_password']) ? trim($input['cashier_password']) : (isset($input['password']) ? trim($input['password']) : null);

        if (!$branchId || empty($name)) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing required fields: branch_id and name']);
            exit();
        }

        try {
            // Verify branch belongs to user's company
            $checkBranch = $pdo->prepare('SELECT id FROM branches WHERE id = :branch_id AND company_id = :company_id LIMIT 1');
            $checkBranch->execute([':branch_id' => $branchId, ':company_id' => $jwtCompanyId]);
            if (!$checkBranch->fetch()) {
                http_response_code(403);
                echo json_encode(['error' => 'Forbidden: Invalid branch for this company']);
                exit();
            }

            $pdo->beginTransaction();

            $stmt = $pdo->prepare('INSERT INTO staff (branch_id, name, role, phone_number) VALUES (:branch_id, :name, :role, :phone)');
            $stmt->execute([
                ':branch_id' => $branchId,
                ':name' => $name,
                ':role' => $role,
                ':phone' => $phone
            ]);
            $staffId = (int)$pdo->lastInsertId();

            if (!empty($password)) {
                $hashedPassword = password_hash($password, PASSWORD_ARGON2ID);
                $stmtUser = $pdo->prepare('INSERT INTO users (username, password, role, company_id, branch_id) VALUES (:username, :password, :role, :company_id, :branch_id)');
                $stmtUser->execute([
                    ':username' => $name,
                    ':password' => $hashedPassword,
                    ':role' => 'Cashier',
                    ':company_id' => $jwtCompanyId,
                    ':branch_id' => $branchId
                ]);
            }

            $pdo->commit();

            echo json_encode(['status' => 'success', 'message' => 'Staff created successfully', 'id' => $staffId]);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            error_log("Create staff DB Error: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    case 'delete_staff':
        $staffId = isset($input['staff_id']) ? (int)$input['staff_id'] : (isset($input['id']) ? (int)$input['id'] : null);

        if (!$staffId) {
            http_response_code(400);
            echo json_encode(['error' => 'Missing staff_id']);
            exit();
        }

        try {
            $stmt = $pdo->prepare('
                DELETE FROM staff 
                WHERE id = :staff_id 
                  AND branch_id IN (SELECT id FROM branches WHERE company_id = :company_id)
            ');
            $stmt->execute([':staff_id' => $staffId, ':company_id' => $jwtCompanyId]);

            if ($stmt->rowCount() === 0) {
                http_response_code(404);
                echo json_encode(['error' => 'Staff member not found']);
            } else {
                echo json_encode(['status' => 'success', 'message' => 'Staff deleted successfully']);
            }
        } catch (PDOException $e) {
            error_log("Delete staff DB Error: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
        break;

    default:
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
        break;
}
