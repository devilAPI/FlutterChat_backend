<?php
$servername = "server_adress";
$username = "mysql_username";
$password = "mysql_password";
$dbname = "database_name";
error_reporting(E_ALL);
// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
