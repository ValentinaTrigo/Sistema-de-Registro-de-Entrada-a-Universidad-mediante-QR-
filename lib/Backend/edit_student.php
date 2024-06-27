<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Verificar si se recibieron los datos del estudiante y la imagen
if (isset($_POST['id']) && isset($_POST['first_name']) && isset($_POST['last_name']) && isset($_POST['phone']) && isset($_POST['email'])) {
    $id = $_POST['id']; // Obtener el ID del estudiante a editar
    $first_name = $_POST['first_name'];
    $last_name = $_POST['last_name'];
    $phone = $_POST['phone'];
    $email = $_POST['email'];

    // Ruta donde se guardarán las imágenes
    $uploadDir = "C:\\Users\\manuc\\Universidad\\IOTRobotica\\Recognition-Face\\Imagenes\\";

    // Conectar a la base de datos
    $conn = new mysqli("localhost", "root", "", "student_management");

    // Verificar la conexión
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Escapar los datos para prevenir inyección SQL
    $id = $conn->real_escape_string($id);
    $first_name = $conn->real_escape_string($first_name);
    $last_name = $conn->real_escape_string($last_name);
    $phone = $conn->real_escape_string($phone);
    $email = $conn->real_escape_string($email);

    $imagePath = "";

    // Verificar si se ha subido una nueva imagen
    if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
        $fileTmpName = $_FILES['image']['tmp_name'];
        $fileName = basename($_FILES['image']['name']);
        $fileExt = pathinfo($fileName, PATHINFO_EXTENSION);
        $newImageName = $first_name . '.' . $fileExt;
        $imagePath = $uploadDir . $newImageName;

        if (!move_uploaded_file($fileTmpName, $imagePath)) {
            echo json_encode(["status" => "error", "message" => "Error al subir la imagen"]);
            exit;
        }
    }

    // Consulta SQL para editar el estudiante
    if ($imagePath) {
        $sql = "UPDATE students SET first_name='$first_name', last_name='$last_name', phone='$phone', email='$email', image_path='$imagePath' WHERE id=$id";
    } else {
        $sql = "UPDATE students SET first_name='$first_name', last_name='$last_name', phone='$phone', email='$email' WHERE id=$id";
    }

    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Estudiante editado correctamente"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Error al editar el estudiante: " . $conn->error]);
    }

    $conn->close();
} else {
    echo json_encode(["status" => "error", "message" => "Datos del estudiante o imagen no recibidos correctamente"]);
}
?>
