<?php

header("Access-Control-Allow-Origin: http://localhost:59509");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Origin: *");

header('Content-Type: application/json');

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "student_management";  // Reemplaza con el nombre de tu base de datos

// Obtener los datos del curso a editar
$courseId = $_POST['id'];
$nombre = $_POST['nombre'];
$horario = $_POST['horario'];
$codigo = $_POST['codigo'];

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die(json_encode(['success' => false, 'message' => 'Connection failed: ' . $conn->connect_error]));
}

$sql = "UPDATE courses SET nombre = ?, horario = ?, codigo = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sssi", $nombre, $horario, $codigo, $courseId);

if ($stmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Course updated successfully']);
} else {
    echo json_encode(['success' => false, 'message' => 'Error updating course: ' . $stmt->error]);
}

$stmt->close();
$conn->close();

?>
