<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");


$conn = new mysqli("localhost", "root", "", "student_management");

// Verificar la conexión
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}

// Obtener estudiantes de la base de datos
$sql = "SELECT * FROM students";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
  // Convertir resultados a un array asociativo
  $students = array();
  while($row = $result->fetch_assoc()) {
    $students[] = $row;
  }
  // Devolver estudiantes como JSON
  echo json_encode($students);
} else {
  echo json_encode(array()); // Devolver un array vacío si no hay estudiantes
}

$conn->close();
?>
