<?php

function get_jwt_secret() {
    $env_secret = getenv('JWT_SECRET');
    if ($env_secret !== false && $env_secret !== '') {
        return $env_secret;
    }

    $secret_file = __DIR__ . '/jwt_secret.txt';
    if (file_exists($secret_file)) {
        return trim(file_get_contents($secret_file));
    }

    // Security: Fallback to ephemeral secret if no static secret is found.
    // This logs a severe warning because horizontal scalability will break.
    error_log("SEVERE WARNING: JWT_SECRET environment variable is missing and jwt_secret.txt not found. Generating an ephemeral secret for this instance. This will cause authentication failures if scaled horizontally!");
    
    // Store it in memory for this request cycle
    static $ephemeral_secret = null;
    if ($ephemeral_secret === null) {
        $ephemeral_secret = bin2hex(random_bytes(32));
    }
    
    return $ephemeral_secret;
}

function base64url_encode($data) {
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64url_decode($data) {
    return base64_decode(strtr($data, '-_', '+/') . str_repeat('=', 3 - (3 + strlen($data)) % 4));
}

function generate_jwt($user_id, $role, $company_id, $branch_id) {
    $header = json_encode([
        'alg' => 'HS256',
        'typ' => 'JWT'
    ]);

    $payload = json_encode([
        'user_id' => $user_id,
        'role' => $role,
        'company_id' => $company_id,
        'branch_id' => $branch_id,
        'iat' => time(),
        'exp' => time() + (24 * 60 * 60)
    ]);

    $base64UrlHeader = base64url_encode($header);
    $base64UrlPayload = base64url_encode($payload);

    $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, get_jwt_secret(), true);
    $base64UrlSignature = base64url_encode($signature);

    return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
}

function verify_jwt($token) {
    if (!$token || !is_string($token)) {
        return false;
    }

    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return false;
    }

    list($base64UrlHeader, $base64UrlPayload, $base64UrlSignature) = $parts;

    $headerStr = base64url_decode($base64UrlHeader);
    if ($headerStr === false) {
        return false;
    }

    $header = json_decode($headerStr, true);
    if (!$header || !isset($header['alg'])) {
        return false;
    }

    // Security: Reject 'none' algorithm or anything other than HS256 to prevent algorithm confusion attacks
    if ($header['alg'] !== 'HS256') {
        error_log("Security Warning: Attempted JWT bypass using unexpected algorithm: " . $header['alg']);
        return false;
    }

    $payloadStr = base64url_decode($base64UrlPayload);
    if ($payloadStr === false) {
        return false;
    }

    $payload = json_decode($payloadStr, true);
    if (!$payload || !isset($payload['exp'])) {
        return false;
    }

    // Verify signature
    $signature = base64url_decode($base64UrlSignature);
    $expectedSignature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, get_jwt_secret(), true);

    // Security: Use hash_equals to prevent timing attacks
    if (!hash_equals($expectedSignature, $signature)) {
        return false;
    }

    // Verify expiration
    if ($payload['exp'] < time()) {
        return false; // Token expired
    }

    return $payload;
}
