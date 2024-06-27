<?php
header("Access-Control-Allow-Origin: *");
// Permitir los métodos HTTP específicos
header("Access-Control-Allow-Methods: POST, GET, OPTIONS, PUT, DELETE");
// Permitir los encabezados específicos
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Verifica si la solicitud es de tipo OPTIONS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$conn = new mysqli("localhost", "root", "", "student_management");

$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$phone = $_POST['phone'];
$email = $_POST['email'];
$password = password_hash($_POST['password'], PASSWORD_DEFAULT);

$sql = "INSERT INTO users (first_name, last_name, phone, email, password) VALUES ('$first_name', '$last_name', '$phone', '$email', '$password')";
if ($conn->query($sql) === TRUE) {
  echo "Registro exitoso";
} else {
  echo "Error: " . $sql . "<br>" . $conn->error;
}

$conn->close();
?>
