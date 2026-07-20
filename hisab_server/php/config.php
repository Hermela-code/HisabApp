<?php

$host = getenv('DB_HOST') !== false ? getenv('DB_HOST') : '127.0.0.1';
$port = getenv('DB_PORT') !== false ? getenv('DB_PORT') : 3306;
$user = getenv('DB_USER') !== false ? getenv('DB_USER') : 'root';
$password = getenv('DB_PASSWORD') ?: '';
$dbname = getenv('DB_NAME') !== false ? getenv('DB_NAME') : 'hisab_app';

$dsn = "mysql:host={$host};port={$port};dbname={$dbname};charset=utf8mb4";

try {
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    // echo "Connected successfully\n"; // Uncomment for testing if needed
} catch (PDOException $e) {
    // TODO(security): The request asked to print the exact error message. 
    // However, this violates the mandatory secure web skills guideline: 
    // "MUST NOT expose SQL errors to users". 
    // Therefore, the detailed error is logged server-side, and a generic 
    // message is displayed to the user.
    error_log("Database Connection Error: " . $e->getMessage());
    echo "Database Connection Error\n";
    exit(1);
}
