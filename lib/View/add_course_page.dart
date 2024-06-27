import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({Key? key}) : super(key: key);

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  List<Map<String, dynamic>> coursesList = []; // Lista de cursos

  TextEditingController nameController = TextEditingController();
  TextEditingController scheduleController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCourses(); // Obtener los cursos al iniciar la página
  }

  Future<void> _getCourses() async {
    var coursesUrl = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_courses.php');
    var response = await http.get(coursesUrl);

    if (response.statusCode == 200) {
      var coursesJson = json.decode(response.body);
      setState(() {
        coursesList = List<Map<String, dynamic>>.from(coursesJson);
      });
    } else {
      print('Error al obtener la lista de cursos: ${response.body}');
    }
  }

  Future<void> _saveCourse() async {
    String name = nameController.text;
    String schedule = scheduleController.text;
    String code = codeController.text;

    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/create_course.php');
    var data = {
      'nombre': name,
      'horario': schedule,
      'codigo': code,
    };

    var response = await http.post(url, body: data);

    if (response.statusCode == 200) {
      print('Curso guardado correctamente');
      _getCourses(); // Actualizar la lista de cursos después de guardar un nuevo curso
      nameController.clear();
      scheduleController.clear();
      codeController.clear();
    } else {
      print('Error al guardar el curso: ${response.body}');
    }
  }

  Future<void> _deleteCourse(int courseId) async {
    var deleteUrl = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/delete_course.php');
    var data = {'id': courseId.toString()};

    var response = await http.post(deleteUrl, body: data);

    if (response.statusCode == 200) {
      print('Curso eliminado correctamente');
      _getCourses(); // Actualizar la lista de cursos después de eliminar
    } else {
      print('Error al eliminar el curso: ${response.body}');
    }
  }

  Future<void> _editCourse(int courseId) async {
    var courseToEdit = coursesList.firstWhere((course) => course['id'] == courseId.toString());
    nameController.text = courseToEdit['nombre'];
    scheduleController.text = courseToEdit['horario'];
    codeController.text = courseToEdit['codigo'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(labelText: 'Course Schedule'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                nameController.clear();
                scheduleController.clear();
                codeController.clear();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveEditedCourse(courseId);
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEditedCourse(int courseId) async {
    String name = nameController.text;
    String schedule = scheduleController.text;
    String code = codeController.text;

    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/edit_course.php');
    var data = {
      'id': courseId.toString(),
      'nombre': name,
      'horario': schedule,
      'codigo': code,
    };

    var response = await http.post(url, body: data);

    if (response.statusCode == 200) {
      print('Curso editado correctamente');
      _getCourses(); // Actualizar la lista de cursos después de editar
      nameController.clear();
      scheduleController.clear();
      codeController.clear();
    } else {
      print('Error al editar el curso: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Course'),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Course Name'),
                ),
                TextField(
                  controller: scheduleController,
                  decoration: const InputDecoration(labelText: 'Course Schedule'),
                ),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Course Code'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveCourse,
                  child: const Text('Save Course'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: coursesList.length,
              itemBuilder: (context, index) {
                var courseInfo = coursesList[index];
                var courseId = int.parse(courseInfo['id']);

                return ListTile(
                  title: Text('${courseInfo['nombre']} - ${courseInfo['horario']} - ${courseInfo['codigo']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editCourse(courseId); // Lógica para editar el curso
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteCourse(courseId); // Pasar el ID del curso a la función de eliminar
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
