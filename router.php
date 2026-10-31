<?php
/**
 * Router for PHP built-in server (php -S)
 * This handles .htaccess-equivalent CORS headers since php -S doesn't read .htaccess
 * Used when deploying to Render/Railway via Docker
 */

// Set CORS headers on ALL requests
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Let the built-in server handle the request normally
return false;
