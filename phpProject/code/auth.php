<?php

function getBearerToken() {
    $headers = getallheaders();

    if (isset($headers['Authorization'])) {
        if (preg_match('/Bearer\s+(.*)$/i', $headers['Authorization'], $matches)) {
            return trim($matches[1]);
        }
    }

    return null;
}

function isValidToken($token) {
    $validTokens = [
        'admin-demo-token' => 'admin'
    ];

    return isset($validTokens[$token]) ? $validTokens[$token] : false;
}

function sendJsonError($statusCode, $message) {
    http_response_code($statusCode);
    header('Content-Type: application/json');
    echo json_encode(['error' => $message]);
    exit;
}

function requireAuth() {
    $token = getBearerToken();

    if (!$token) {
        sendJsonError(401, 'Bearer token required');
    }

    $user = isValidToken($token);

    if (!$user) {
        sendJsonError(401, 'Invalid or expired token');
    }

    return $user;
}
