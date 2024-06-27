<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "student_management");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Verificar el método de solicitud
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $student_name = $_POST['student_name'] ?? null;
    $course_id = $_POST['course_id'] ?? null;

    if ($student_name && $course_id) {
        // Obtener el ID del estudiante
        $studentId = null;
        $studentQuery = "SELECT id FROM students WHERE first_name = ?";
        $stmt = $conn->prepare($studentQuery);
        if (!$stmt) {
            echo json_encode(['success' => false, 'message' => 'Error en la consulta: ' . $conn->error]);
            exit;
        }
        $stmt->bind_param("s", $student_name);
        $stmt->execute();
        $stmt->bind_result($studentId);
        $stmt->fetch();
        $stmt->close();

        if (!$studentId) {
            echo json_encode(['success' => false, 'message' => 'Estudiante no encontrado']);
            exit;
        }

        // Verificar si el estudiante está inscrito en el curso
        $enrollmentQuery = "SELECT COUNT(*) FROM student_course WHERE student_id = ? AND course_id = ?";
        $stmt = $conn->prepare($enrollmentQuery);
        if (!$stmt) {
            echo json_encode(['success' => false, 'message' => 'Error en la consulta: ' . $conn->error]);
            exit;
        }
        $stmt->bind_param("ii", $studentId, $course_id);
        $stmt->execute();
        $stmt->bind_result($enrolledCount);
        $stmt->fetch();
        $stmt->close();

        if ($enrolledCount == 0) {
            echo json_encode(['success' => false, 'message' => 'El estudiante no está inscrito en el curso']);
            exit;
        }

        // Obtener la hora actual
        $current_time = date('Y-m-d');

        // Consulta SQL para insertar la asistencia con la hora actual
        $sql = "INSERT INTO attendance (student_id, course_id, scan_time) VALUES (?, ?, ?)";
        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            echo json_encode(['success' => false, 'message' => 'Error en la consulta: ' . $conn->error]);
            exit;
        }
        $stmt->bind_param("iis", $studentId, $course_id, $current_time);

        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Asistencia registrada correctamente']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Error al registrar asistencia: ' . $stmt->error]);
        }

        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Faltan datos requeridos']);
    }
} else if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    // Obtener el ID del curso desde la solicitud GET
    $courseId = $_GET['course_id'] ?? null;

    if ($courseId) {
        // Consulta SQL para obtener los estudiantes relacionados con el curso
        $courseStudentsSql = "SELECT s.id, s.first_name, s.last_name
                              FROM students s
                              INNER JOIN student_course sc ON s.id = sc.student_id
                              WHERE sc.course_id = ?";
        $stmt = $conn->prepare($courseStudentsSql);
        if (!$stmt) {
            echo json_encode(['success' => false, 'message' => 'Error en la consulta: ' . $conn->error]);
            exit;
        }
        $stmt->bind_param("i", $courseId);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // Crear un array para almacenar los datos de los estudiantes
            $courseStudentsList = array();

            // Recorrer los resultados y agregarlos al array
            while ($row = $result->fetch_assoc()) {
                $courseStudentsList[] = $row;
            }

            // Devolver los datos en formato JSON
            echo json_encode($courseStudentsList);
        } else {
            echo json_encode(['success' => false, 'message' => 'No se encontraron estudiantes para este curso.']);
        }

        $stmt->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Falta el ID del curso.']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Método no permitido']);
}

$conn->close();
?>
