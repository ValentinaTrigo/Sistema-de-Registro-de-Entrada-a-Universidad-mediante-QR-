<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "student_management");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Obtener estudiantes
$studentsSql = "SELECT * FROM students";
$studentsResult = $conn->query($studentsSql);

$students = array();
if ($studentsResult->num_rows > 0) {
    while($row = $studentsResult->fetch_assoc()) {
        $students[$row['id']] = $row; // Indexar por id
    }
}

// Obtener cursos
$coursesSql = "SELECT * FROM courses";
$coursesResult = $conn->query($coursesSql);

$courses = array();
if ($coursesResult->num_rows > 0) {
    while($row = $coursesResult->fetch_assoc()) {
        $courses[$row['id']] = $row; // Indexar por id
        $courses[$row['id']]['students'] = array(); // Inicializar el array de estudiantes
    }
}

// Obtener relaciones estudiante-curso
$studentCourseSql = "SELECT * FROM student_course";
$studentCourseResult = $conn->query($studentCourseSql);

if ($studentCourseResult->num_rows > 0) {
    while($row = $studentCourseResult->fetch_assoc()) {
        $studentId = $row['student_id'];
        $courseId = $row['course_id'];
        
        if (isset($courses[$courseId]) && isset($students[$studentId])) {
            $courses[$courseId]['students'][] = $students[$studentId];
        }
    }
}

echo json_encode(array_values($courses)); // Convertir a array indexado
$conn->close();
?>
