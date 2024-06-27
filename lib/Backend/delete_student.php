<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Verificar si se recibió el ID del estudiante
if(isset($_POST['id'])) {
    $id = $_POST['id']; // Obtener el ID del estudiante a eliminar

    $conn = new mysqli("localhost", "root", "", "student_management");

    // Verificar la conexión
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Escapar el ID para prevenir inyección SQL
    $id = $conn->real_escape_string($id);

    // Consulta SQL para eliminar el estudiante
    $sql_delete_student = "DELETE FROM students WHERE id=$id";

    // Consulta SQL para eliminar registros relacionados en student_course si existen
    $sql_delete_student_course = "DELETE FROM student_course WHERE student_id=$id";

    // Iniciar transacción para asegurar operaciones atómicas
    $conn->begin_transaction();

    // Intentar ejecutar ambas consultas
    if ($conn->query($sql_delete_student) === TRUE && $conn->query($sql_delete_student_course) === TRUE) {
        $conn->commit(); // Confirmar la transacción si ambas consultas tienen éxito
        echo json_encode(["status" => "success", "message" => "Estudiante eliminado correctamente"]);
    } else {
        $conn->rollback(); // Revertir la transacción si alguna consulta falla
        echo json_encode(["status" => "error", "message" => "Error al eliminar el estudiante: " . $conn->error]);
    }

    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "ID del estudiante no recibido"]);
}
?>
