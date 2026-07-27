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

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method Not Allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['action'])) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Action is required']);
    exit();
}

$action = $input['action'];

if ($action === 'signup') {
    $username = $input['username'] ?? null;
    $password = $input['password'] ?? null;
    $roleRaw = $input['role'] ?? 'owner';
    $role = ucfirst($roleRaw);
    $providedId = $input['id'] ?? $input['user_id'] ?? null;
    $companyName = $input['company_name'] ?? $input['business_name'] ?? 'My Business';
    $branchName = $input['branch_name'] ?? 'Main Branch';
    $location = $input['location'] ?? 'Unknown';

    if (!$username || !$password || !$role) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing required fields for registration']);
        exit();
    }

    // Security: Hash password using Argon2id as per secure backend guidelines
    $hashedPassword = password_hash($password, PASSWORD_ARGON2ID);
    
    $cashierName = (strtolower($role) === 'cashier') ? $username : 'Not Assigned';

    try {
        $pdo->beginTransaction();

        $stmt1 = $pdo->prepare("INSERT INTO companies (company_name, business_type) VALUES (:name, 'General')");
        $stmt1->execute([':name' => $companyName]);
        $companyId = $pdo->lastInsertId();

        $stmt2 = $pdo->prepare("INSERT INTO branches (company_id, name, location, cashier_name) VALUES (:company_id, :branch_name, :location, :cashier_name)");
        $stmt2->execute([
            ':company_id' => $companyId,
            ':branch_name' => $branchName,
            ':location' => $location,
            ':cashier_name' => $cashierName
        ]);
        $branchId = $pdo->lastInsertId();

        if ($providedId !== null) {
            $stmt3 = $pdo->prepare("INSERT INTO users (id, username, password, role, company_id, branch_id) VALUES (:id, :username, :password, :role, :company_id, :branch_id)");
            $stmt3->execute([
                ':id' => $providedId,
                ':username' => $username,
                ':password' => $hashedPassword,
                ':role' => $role,
                ':company_id' => $companyId,
                ':branch_id' => $branchId
            ]);
        } else {
            $stmt3 = $pdo->prepare("INSERT INTO users (username, password, role, company_id, branch_id) VALUES (:username, :password, :role, :company_id, :branch_id)");
            $stmt3->execute([
                ':username' => $username,
                ':password' => $hashedPassword,
                ':role' => $role,
                ':company_id' => $companyId,
                ':branch_id' => $branchId
            ]);
        }

        $pdo->commit();
        echo json_encode(['status' => 'success', 'message' => 'Account successfully created!']);
    } catch (PDOException $e) {
        $pdo->rollBack();
        // Security: Log actual error server-side, send generic message to client
        error_log("Signup Database Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Internal Server Error']);
    }
} elseif ($action === 'login') {
    $username = $input['username'] ?? null;
    $password = $input['password'] ?? null;

    if (!$username || !$password) {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing required fields for login']);
        exit();
    }

    try {
        $stmt = $pdo->prepare("SELECT id, username, password, role, company_id, branch_id FROM users WHERE username = :username");
        $stmt->execute([':username' => $username]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($password, $user['password'])) {
            $branchId = $user['branch_id'];
            
            // Mirroring Dart behavior: update branch_id if missing for cashiers
            if ($branchId === null && strtolower($user['role']) === 'cashier') {
                $stmtBranch = $pdo->prepare("SELECT id FROM branches WHERE LOWER(cashier_name) = LOWER(:username)");
                $stmtBranch->execute([':username' => trim($user['username'])]);
                $branch = $stmtBranch->fetch(PDO::FETCH_ASSOC);
                if ($branch) {
                    $branchId = $branch['id'];
                    $stmtUpdate = $pdo->prepare("UPDATE users SET branch_id = :branch_id WHERE id = :id");
                    $stmtUpdate->execute([':branch_id' => $branchId, ':id' => $user['id']]);
                }
            }

            $token = generate_jwt($user['id'], $user['role'], $user['company_id'], $branchId);
            echo json_encode([
                'status' => 'success',
                'user_id' => $user['id'],
                'username' => $user['username'],
                'role' => $user['role'],
                'company_id' => $user['company_id'],
                'branch_id' => $branchId,
                'message' => 'Login successful',
                'token' => $token
            ]);
        } else {
            http_response_code(401);
            echo json_encode(['status' => 'error', 'message' => 'Invalid username or password']);
        }
    } catch (PDOException $e) {
        // Security: Log actual error server-side, send generic message to client
        error_log("Login Database Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['status' => 'error', 'message' => 'Internal Server Error']);
    }
} else {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
}
