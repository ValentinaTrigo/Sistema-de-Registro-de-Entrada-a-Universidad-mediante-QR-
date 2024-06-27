<?php
$conn = new mysqli("localhost", "root", "", "student_management");

$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$phone = $_POST['phone'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$sql = "INSERT INTO users (first_name, last_name, phone, email, password) VALUES ('$first_name', '$last_name', '$phone', '$email', '$password')";
if ($conn->query($sql) === TRUE) {
  echo json_encode(["status" => "success"]);
} else {
  echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
