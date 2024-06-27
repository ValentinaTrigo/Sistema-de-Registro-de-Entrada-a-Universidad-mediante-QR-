<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

$conn = new mysqli("localhost", "root", "", "student_management");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$first_name = $_POST['first_name'];
$last_name = $_POST['last_name'];
$phone = $_POST['phone'];
$email = $_POST['email'];

// Ruta donde se guardarán las imágenes
$uploadDir = "C:\\Users\\manuc\\Universidad\\IOTRobotica\\Recognition-Face\\Imagenes\\";

// Procesar la imagen si existe
$imagePath = "";
if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
    $imageTmpName = $_FILES['image']['tmp_name'];
    $imageName = basename($_FILES['image']['name']);
    $imageExt = pathinfo($imageName, PATHINFO_EXTENSION);
    $newImageName = $first_name . '.' . $imageExt;
    $imagePath = $uploadDir . $newImageName;

    if (!move_uploaded_file($imageTmpName, $imagePath)) {
        echo json_encode(["status" => "error", "message" => "Error al subir la imagen"]);
        exit;
    }
}
echo "First Name: $first_name\n";
echo "Last Name: $last_name\n";
echo "Phone: $phone\n";
echo "Email: $email\n";
echo "Image Path: $imagePath\n";

$sql = "INSERT INTO students (first_name, last_name, phone, email, image_path) VALUES ('$first_name', '$last_name', '$phone', '$email', '$imagePath')";
if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Estudiante registrado correctamente."]);
} else {
    echo json_encode(["status" => "error", "message" => $conn->error]);
}

$conn->close();
?>
