<?php
require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['action'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Action is required']);
    exit;
}

$action = $input['action'];

if ($action === 'signup') {
    $name = $input['name'] ?? null;
    $phone = $input['phone'] ?? null;
    $password = $input['password'] ?? null;
    $role = $input['role'] ?? 'Owner';

    if (!$name || !$phone || !$password || !$role) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields for signup']);
        exit;
    }

    // Security: Hash password using Argon2id as per secure backend guidelines
    $hashedPassword = password_hash($password, PASSWORD_ARGON2ID);
    
    // Generate secure random string for company_id
    $companyId = bin2hex(random_bytes(16));

    try {
        $stmt = $pdo->prepare("INSERT INTO users (name, phone, password, role, company_id) VALUES (:name, :phone, :password, :role, :company_id)");
        $stmt->execute([
            ':name' => $name,
            ':phone' => $phone,
            ':password' => $hashedPassword,
            ':role' => $role,
            ':company_id' => $companyId
        ]);
        
        echo json_encode(['success' => true, 'message' => 'User registered successfully']);
    } catch (PDOException $e) {
        // Handle duplicate phone number (SQLSTATE 23000 Integrity constraint violation)
        if ($e->getCode() == 23000) {
            http_response_code(409);
            echo json_encode(['error' => 'Phone number already exists']);
        } else {
            // Security: Log actual error server-side, send generic message to client
            error_log("Signup Database Error: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'Internal Server Error']);
        }
    }
} elseif ($action === 'login') {
    $phone = $input['phone'] ?? null;
    $password = $input['password'] ?? null;

    if (!$phone || !$password) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields for login']);
        exit;
    }

    try {
        $stmt = $pdo->prepare("SELECT id, name, password, role, company_id, branch_id FROM users WHERE phone = :phone");
        $stmt->execute([':phone' => $phone]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user && password_verify($password, $user['password'])) {
            echo json_encode([
                'success' => true,
                'role' => $user['role'],
                'name' => $user['name'],
                'company_id' => $user['company_id'],
                'branch_id' => $user['branch_id']
            ]);
        } else {
            http_response_code(401);
            echo json_encode(['error' => 'Invalid phone or password']);
        }
    } catch (PDOException $e) {
        error_log("Login Database Error: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Internal Server Error']);
    }
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid action']);
}
