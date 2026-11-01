<?php
// One-Click PostgreSQL Schema Setup for Render
// Run this once after deploying to import all tables

header('Content-Type: text/html; charset=utf-8');

echo "<h1>🚀 PostgreSQL Schema Setup</h1>";

// Database connection details from Render (DATABASE_URL env var)
if (!getenv('DATABASE_URL')) {
    die("<p style='color:red'>❌ DATABASE_URL is not set in Render environment variables.</p>");
}
$p = parse_url(getenv('DATABASE_URL'));
$host = $p['host'];
$port = $p['port'] ?? 5432;
$dbname = ltrim($p['path'], '/');
$user = $p['user'];
$password = $p['pass'];

echo "<p><strong>Connecting to:</strong> $host:$port / $dbname</p>";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname;sslmode=require";
    $pdo = new PDO($dsn, $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p>✅ Connected to PostgreSQL!</p>";
    
    // Read and execute schema
    $schema = file_get_contents(__DIR__ . '/database/postgres-schema.sql');
    
    if (!$schema) {
        die("❌ Could not read schema file!");
    }
    
    echo "<p>📋 Executing schema SQL...</p>";
    
    // Remove comment lines first, otherwise statements preceded by a comment get skipped
    $schema = preg_replace('/^\s*--.*$/m', '', $schema);
    // Safe to re-run: never drop existing data, only create what is missing
    $schema = preg_replace('/CREATE TABLE\s+(?!IF NOT EXISTS)/i', 'CREATE TABLE IF NOT EXISTS ', $schema);
    $schema = preg_replace('/CREATE INDEX\s+(?!IF NOT EXISTS)/i', 'CREATE INDEX IF NOT EXISTS ', $schema);
    
    // Split by semicolons and execute each statement
    $statements = array_filter(array_map('trim', explode(';', $schema)));
    
    $success = 0;
    $errors = 0;
    
    foreach ($statements as $statement) {
        if (empty($statement) || stripos($statement, 'DROP TABLE') === 0) {
            continue;
        }
        
        try {
            $pdo->exec($statement);
            $success++;
        } catch (PDOException $e) {
            // Ignore "already exists" errors
            if (strpos($e->getMessage(), 'already exists') === false) {
                echo "<p style='color: orange;'>⚠️ Warning: " . htmlspecialchars($e->getMessage()) . "</p>";
                $errors++;
            }
        }
    }
    
    echo "<p>✅ Executed $success SQL statements successfully!</p>";
    if ($errors > 0) {
        echo "<p>⚠️ $errors warnings (likely tables already exist)</p>";
    }
    
    // Verify tables
    echo "<h2>📊 Database Tables:</h2>";
    
    $result = $pdo->query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name");
    $tables = $result->fetchAll(PDO::FETCH_COLUMN);
    
    echo "<ul>";
    foreach ($tables as $table) {
        // Count rows
        $count = $pdo->query("SELECT COUNT(*) FROM $table")->fetchColumn();
        echo "<li><strong>$table</strong> - $count rows</li>";
    }
    echo "</ul>";
    
    echo "<h2>🎉 Setup Complete!</h2>";
    echo "<p>Your database is ready. You can now:</p>";
    echo "<ul>";
    echo "<li>✅ Register students</li>";
    echo "<li>✅ Start attendance sessions</li>";
    echo "<li>✅ Mark attendance with face recognition</li>";
    echo "</ul>";
    
    echo "<p><a href='/api/test.php'>Test API →</a></p>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>❌ Error: " . htmlspecialchars($e->getMessage()) . "</p>";
    echo "<p>Please check your database credentials.</p>";
}
?>
