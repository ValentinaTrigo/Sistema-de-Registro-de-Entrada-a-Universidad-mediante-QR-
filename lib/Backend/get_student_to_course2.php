<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "student_management");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Obtener el ID del curso desde la solicitud POST o GET
$courseId = $_POST['course_id']; // Si estás enviando el ID mediante POST
// $courseId = $_GET['course_id']; // Si estás enviando el ID mediante GET

// Consulta SQL para obtener los estudiantes relacionados con el curso
$courseStudentsSql = "SELECT s.id, s.first_name, s.last_name
                      FROM students s
                      INNER JOIN student_course sc ON s.id = sc.student_id
                      WHERE sc.course_id = $courseId";

$courseStudentsResult = $conn->query($courseStudentsSql);

if ($courseStudentsResult->num_rows > 0) {
    // Crear un array para almacenar los datos de los estudiantes
    $courseStudentsList = array();

    // Recorrer los resultados y agregarlos al array
    while ($row = $courseStudentsResult->fetch_assoc()) {
        $courseStudentsList[] = $row;
    }

    // Devolver los datos en formato JSON
    echo json_encode($courseStudentsList);
} else {
    echo "No se encontraron estudiantes para este curso.";
}

$conn->close();
?>
