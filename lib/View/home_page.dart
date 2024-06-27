import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'init_course_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> courses = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_student_course.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        courses = List<Map<String, dynamic>>.from(data);
      });
    } else {
      print('Error al obtener datos: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DataRow> tableRows = [];

    courses.forEach((course) {
      List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(course['students']);

      tableRows.add(DataRow(cells: [
        DataCell(
          Text(course["nombre"]),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailPage(courseId: course["id"], course: course),
              ),
            );
          },
        ),
        DataCell(Text(course["horario"])),
        DataCell(Text(course["codigo"])),
        DataCell(const Text('')), // Celdas vacías para los estudiantes
        DataCell(const Text('')),
        DataCell(const Text('')),
      ]));

      students.forEach((student) {
        tableRows.add(DataRow(cells: [
          const DataCell(Text('')), // Celdas vacías para los cursos
          const DataCell(Text('')),
          const DataCell(Text('')),
          DataCell(Text(student["first_name"] + " " + student["last_name"])),
          // DataCell(Text(student["phone"])),
          // DataCell(Text(student["email"])),
        ]));
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students and Courses Management'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addStudent');
                  },
                  child: const Text('Configurar Estudiantes'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/addCourse');
                  },
                  child: const Text('Configurar Cursos'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/courseStudents');
                  },
                  child: const Text('Asignacion de Cursos'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Curso')),
                    DataColumn(label: Text('Horario')),
                    DataColumn(label: Text('Código')),
                    DataColumn(label: Text('Nombre Estudiante')),
                    // DataColumn(label: Text('Teléfono')),
                    // DataColumn(label: Text('Email')),
                  ],
                  rows: tableRows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final int courseId;
  final Map<String, dynamic> course;

  CourseDetailPage({required this.courseId, required this.course});

  @override
  Widget build(BuildContext context) {
    List<DataRow> studentRows = [];

    List<Map<String, dynamic>> students = List<Map<String, dynamic>>.from(course['students']);

    students.forEach((student) {
      studentRows.add(DataRow(cells: [
        DataCell(Text(student["first_name"] + " " + student["last_name"])),
        // DataCell(Text(student["phone"])),
        // DataCell(Text(student["email"])),
      ]));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Details for ${course["nombre"]}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Nombre Estudiante')),
              // DataColumn(label: Text('Teléfono')),
              // DataColumn(label: Text('Email')),
            ],
            rows: studentRows,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InitCoursePage(courseId: courseId),
            ),
          );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
