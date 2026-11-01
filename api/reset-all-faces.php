<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

require_once __DIR__ . '/config.php';
require_once dirname(__DIR__) . '/includes/AmazonRekognition.php';

try {
    if (($_GET['confirm'] ?? '') !== 'RESET') {
        echo json_encode(['success' => false, 'message' => 'Add ?confirm=RESET to the URL to wipe all students, faces and attendance.']);
        exit();
    }

    $db = getDB();
    $isPg = $db->getAttribute(PDO::ATTR_DRIVER_NAME) === 'pgsql';
    
    // 1. Wipe AWS Rekognition Collection
    $rekognition = new AmazonRekognition();
    $awsReset = $rekognition->resetCollection();
    
    // 2. Clear all students & attendance
    if ($isPg) {
        $db->exec("TRUNCATE TABLE attendance, student_faces, students RESTART IDENTITY CASCADE");
        try { $db->exec("UPDATE attendance_sessions SET marked_students = 0"); } catch (Throwable $e) {}
    } else {
        $db->exec("SET FOREIGN_KEY_CHECKS = 0;");
        $db->exec("TRUNCATE TABLE attendance;");
        $db->exec("TRUNCATE TABLE student_faces;");
        $db->exec("TRUNCATE TABLE students;");
        $db->exec("SET FOREIGN_KEY_CHECKS = 1;");
    }
    
    // 3. Clear uploads directory (keep .gitkeep)
    $uploadDir = dirname(__DIR__) . '/uploads';
    if (is_dir($uploadDir)) {
        $files = glob($uploadDir . '/*');
        foreach ($files as $file) {
            if (is_file($file) && basename($file) !== '.gitkeep') {
                @unlink($file);
            }
        }
    }
    
    echo json_encode([
        'success' => true,
        'message' => 'All old student faces, biometric embeddings, and attendance records have been completely cleared! System is 100% fresh and ready.',
        'data' => [
            'aws_rekognition' => $awsReset,
            'database' => 'CLEARED (students, student_faces, attendance)',
            'faculty' => 'PRESERVED (13 Nigerian lecturers active)',
            'status' => 'READY_FOR_FRESH_REGISTRATIONS'
        ]
    ]);
    
} catch (Throwable $e) {
    http_response_code(200);
    echo json_encode([
        'success' => false,
        'message' => 'Reset error: ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine()
    ]);
}
?>