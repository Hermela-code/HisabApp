<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/jwt_helper.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$headers = function_exists('apache_request_headers') ? apache_request_headers() : [];
$authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? $_SERVER['HTTP_AUTHORIZATION'] ?? '';

if (empty($authHeader) || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized: Missing or invalid Bearer token']);
    exit;
}

$token = $matches[1];
$payload = verify_jwt($token);

if (!$payload) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Invalid or expired token']);
    exit;
}

if (!isset($payload['role']) || $payload['role'] !== 'Owner') {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Only Owners can provision cashiers']);
    exit;
}

if (!isset($input['action']) || $input['action'] !== 'create_cashier') {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid action']);
    exit;
}

$ownerCompanyId = $input['owner_company_id'] ?? null;
$branchId = $input['branch_id'] ?? null;
$cashierName = $input['cashier_name'] ?? null;
$cashierPhone = $input['cashier_phone'] ?? null;
$cashierPassword = $input['cashier_password'] ?? null;

if (!$ownerCompanyId || !$cashierName || !$cashierPhone || !$cashierPassword) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing required fields']);
    exit;
}

// Security: Hash password using Argon2id as per secure backend guidelines
$hashedPassword = password_hash($cashierPassword, PASSWORD_ARGON2ID);
$role = 'Cashier';

try {
    $stmt = $pdo->prepare("INSERT INTO users (name, phone, password, role, company_id, branch_id) VALUES (:name, :phone, :password, :role, :company_id, :branch_id)");
    $stmt->execute([
        ':name' => $cashierName,
        ':phone' => $cashierPhone,
        ':password' => $hashedPassword,
        ':role' => $role,
        ':company_id' => $ownerCompanyId,
        ':branch_id' => $branchId
    ]);

    echo json_encode(['status' => 'success', 'message' => 'Cashier provisioned successfully']);
} catch (PDOException $e) {
    // 23000 indicates an integrity constraint violation (e.g. duplicate phone)
    if ($e->getCode() == 23000) {
        // Security: Log actual error server-side, send clean JSON to client
        error_log("Cashier Provisioning Error: Duplicate phone number attempted - " . $e->getMessage());
        http_response_code(409);
        echo json_encode(['error' => 'Phone number already in use']);
    } else {
        error_log("Cashier Provisioning Database Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Internal Server Error']);
    }
}
