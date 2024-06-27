<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");

$conn = new mysqli("localhost", "root", "", "student_management");

$email = $_POST['email'];
$password = $_POST['password'];

$sql = "SELECT * FROM users WHERE email = '$email'";
$result = $conn->query($sql);
$user = $result->fetch_assoc();

if ($user && password_verify($password, $user['password'])) {
  echo json_encode(["status" => "success", "user_id" => $user['id']]);
} else {
  echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
}

$conn->close();
?>
