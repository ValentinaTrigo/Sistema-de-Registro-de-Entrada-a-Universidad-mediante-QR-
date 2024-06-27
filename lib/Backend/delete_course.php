<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "student_management");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$id = $_POST['id'];

// Primero elimina los registros en attendance que están asociados con el curso
$deleteAttendanceSql = "DELETE FROM attendance WHERE course_id = '$id'";
if ($conn->query($deleteAttendanceSql) === TRUE) {
    // Luego elimina los registros en student_course que están asociados con el curso
    $deleteStudentCourseSql = "DELETE FROM student_course WHERE course_id = '$id'";
    if ($conn->query($deleteStudentCourseSql) === TRUE) {
        // Finalmente, elimina el curso
        $deleteCourseSql = "DELETE FROM courses WHERE id = '$id'";
        if ($conn->query($deleteCourseSql) === TRUE) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
