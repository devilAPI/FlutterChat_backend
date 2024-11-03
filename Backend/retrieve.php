<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// Database connection information
include 'database.php'; // Including the database connection

// Establish a database connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check the connection
if ($conn->connect_error) {
    echo json_encode(["error" => "Connection failed."]);
    exit;
}

// Retrieve parameters
$user1Id = isset($_GET['user1Id']) ? (int)$_GET['user1Id'] : null; // Cast to int for security
$user2Id = isset($_GET['user2Id']) ? (int)$_GET['user2Id'] : null; // Cast to int for security
$encryptionKey = isset($_GET['encryptionKey']) ? $_GET['encryptionKey'] : null; // Get encryption key

// Validate input parameters
if ($user1Id === null || $user2Id === null || $encryptionKey === null) {
    echo json_encode(["error" => "Invalid input parameters."]);
    exit;
}

// Prepare the SQL query
$sql = "SELECT senderId, message, timestamp FROM messages 
        WHERE ((senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)) 
        AND encryption_key = ?";
$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode(["error" => "Query preparation failed."]);
    exit;
}

// Bind parameters and execute the statement
$stmt->bind_param("iiiss", $user1Id, $user2Id, $user2Id, $user1Id, $encryptionKey);
if (!$stmt->execute()) {
    echo json_encode(["error" => "Query execution failed."]);
    exit;
}

$result = $stmt->get_result();

// Initialize messages array
$messages = [];

// Fetch messages
while ($row = $result->fetch_assoc()) {
    $messages[] = $row;
}

// Format response
$response = ["messages" => $messages];

// Return JSON response
echo json_encode($response);

// Free resources
$stmt->close();
$conn->close();
?>
