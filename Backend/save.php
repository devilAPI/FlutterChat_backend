<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$servername = "";
$username = "";
$password = "";
$dbname = "";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get POST parameters
$user1Id = isset($_POST['user1Id']) ? $_POST['user1Id'] : null;
$user2Id = isset($_POST['user2Id']) ? $_POST['user2Id'] : null;
$message = isset($_POST['message']) ? $_POST['message'] : null;
$encryptionKey = isset($_POST['encryptionKey']) ? $_POST['encryptionKey'] : null;

// Check if all required parameters are provided
if ($user1Id && $user2Id && $message && $encryptionKey) {
    // Prepare SQL statement to insert the message into the database
    $stmt = $conn->prepare("INSERT INTO messages (senderId, receiverId, message, encryption_key) VALUES (?, ?, ?, ?)");
    $stmt->bind_param("ssss", $user1Id, $user2Id, $message, $encryptionKey);

    // Execute the query and check for success
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Message saved successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error: " . $stmt->error]);
    }

    // Close statement
    $stmt->close();
} else {
    // If required parameters are missing
    echo json_encode(["status" => "error", "message" => "Missing required parameters"]);
}

// Close the database connection
$conn->close();
?>
