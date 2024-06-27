import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  List<Map<String, dynamic>> studentsList = [];

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  File? _image;

  @override
  void initState() {
    super.initState();
    _getStudents();
  }

  Future<void> _deleteStudent(int studentId) async {
    var deleteUrl = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/delete_student.php');
    var data = {'id': studentId.toString()};
    var response = await http.post(deleteUrl, body: data);

    if (response.statusCode == 200) {
      print('Estudiante eliminado correctamente');
      setState(() {
        studentsList.removeWhere((student) => student['id'] == studentId.toString());
      });
    } else {
      print('Error al eliminar el estudiante: ${response.body}');
    }
  }

  Future<void> _editStudent(int studentId) async {
    var studentToEdit = studentsList.firstWhere((student) => student['id'] == studentId.toString());
    firstNameController.text = studentToEdit['first_name'];
    lastNameController.text = studentToEdit['last_name'];
    phoneController.text = studentToEdit['phone'];
    emailController.text = studentToEdit['email'];

    setState(() {
      _image = studentToEdit['image_path'] != null ? File(studentToEdit['image_path']) : null;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              _image == null
                  ? const Text('No image selected.')
                  : Image.file(_image!),
              ElevatedButton(
                onPressed: () => _pickImage(),
                child: const Text('Pick Image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _clearControllers();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveEditedStudent(studentId);
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEditedStudent(int studentId) async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String phone = phoneController.text;
    String email = emailController.text;
    String imagePath = _image?.path ?? '';

    print('Sending edit request with the following data:');
    print('Student ID: $studentId');
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Phone: $phone');
    print('Email: $email');
    print('Image Path: $imagePath');

    var editUrl = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/edit_student.php');
    var data = {
      'id': studentId.toString(),
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'image_path': imagePath,
    };

    var response = await http.post(editUrl, body: data);

    if (response.statusCode == 200) {
      print('Estudiante editado correctamente');
      setState(() {
        _getStudents(); // Actualizar la lista de estudiantes después de editar
      });
      _clearControllers();
    } else {
      print('Error al editar el estudiante: ${response.body}');
    }
  }

  void _clearControllers() {
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    emailController.clear();
    setState(() {
      _image = null;
    });
  }

  int getStudentId(Map<String, dynamic> studentInfo) {
    return int.tryParse(studentInfo['id'].toString()) ?? 0;
  }

  Future<void> _getStudents() async {
    var studentsUrl = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_students.php');
    var studentsResponse = await http.get(studentsUrl);

    if (studentsResponse.statusCode == 200) {
      Iterable studentsJson = json.decode(studentsResponse.body);

      List<Map<String, dynamic>> studentsListConverted = studentsJson
          .map((student) => student as Map<String, dynamic>)
          .toList();

      setState(() {
        studentsList.clear();
        studentsList.addAll(studentsListConverted);
      });
    } else {
      print('Error al obtener la lista de estudiantes: ${studentsResponse.body}');
    }
  }

  Future<void> _saveStudent() async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String phone = phoneController.text;
    String email = emailController.text;
    String imagePath = _image?.path ?? '';

    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/save_student.php');
    var data = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'image_path': imagePath, // Aquí debería ser correcto si _image?.path contiene la ruta válida
    };

    var response = await http.post(url, body: data);

    if (response.statusCode == 200) {
      print('Estudiante guardado correctamente');
      setState(() {
        _getStudents(); // Actualizar la lista de estudiantes después de guardar
      });
      _clearControllers();
    } else {
      print('Error al guardar el estudiante: ${response.body}');
    }
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  
  // Usar la cámara para capturar la imagen
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

  setState(() async {
    if (pickedFile != null) {
      // Convertir XFile a File
      File imageFile = File(pickedFile.path);

      // Obtener el directorio temporal de la aplicación
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      // Generar un nombre único para la imagen
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';

      // Copiar la imagen seleccionada al directorio temporal con el nuevo nombre
      File newImage = await imageFile.copy('$tempPath/$fileName');

      // Asignar la nueva ruta del archivo al estado _image
      setState(() {
        _image = newImage;
        print('Image path: ${_image?.path}');
      });

    } else {
      print('No image selected.');
    }
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _pickImage(),
                    child: const Text('Pick Image'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveStudent(),
                    child: const Text('Save Student'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: studentsList.length,
                itemBuilder: (context, index) {
                  var student = studentsList[index];
                  return ListTile(
                    title: Text('${student['first_name']} ${student['last_name']}'),
                    subtitle: Text(student['email']),
                    leading: CircleAvatar(
                      backgroundImage: student['image_path'] != null
                          ? FileImage(File(student['image_path']))
                          : null,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editStudent(int.parse(student['id'])),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteStudent(int.parse(student['id'])),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
