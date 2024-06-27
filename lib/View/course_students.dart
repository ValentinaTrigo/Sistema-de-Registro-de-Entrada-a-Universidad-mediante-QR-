import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseStudentsPage extends StatefulWidget {
  @override
  _CourseStudentsPageState createState() => _CourseStudentsPageState();
}

class _CourseStudentsPageState extends State<CourseStudentsPage> {
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> courseStudents = [];
  String? selectedCourseId;
  String? selectedStudentId;
  String? selectedCourseForView;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _fetchStudents();
  }

  Future<void> _fetchCourses() async {
    try {
      var response = await http.get(Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_courses.php'));
      if (response.statusCode == 200) {
        setState(() {
          courses = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load courses');
      }
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  Future<void> _fetchStudents() async {
    try {
      var response = await http.get(Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_students.php'));
      if (response.statusCode == 200) {
        setState(() {
          students = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> _fetchCourseStudents(String courseId) async {
    try {
      var response = await http.post(
        Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/get_student_to_course2.php'),
        body: {'course_id': courseId},
      );
      if (response.statusCode == 200) {
        setState(() {
          courseStudents = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        print('Failed to load course students');
      }
    } catch (e) {
      print('Error fetching course students: $e');
    }
  }

  Future<void> _addStudentToCourse() async {
    if (selectedCourseId != null && selectedStudentId != null) {
      try {
        var response = await http.post(
          Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/add_student_to_course.php'),
          body: {
            'course_id': selectedCourseId!,
            'student_id': selectedStudentId!,
          },
        );

        if (response.statusCode == 200) {
          print('Student added successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student added successfully to the course!')),
          );
          _fetchCourseStudents(selectedCourseId!); // Refresh course students
        } else {
          print('Failed to add student');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add student to the course.')),
          );
        }
      } catch (e) {
        print('Error adding student to course: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding student to course.')),
        );
      }
    } else {
      print('Please select a course and a student');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a course and a student.')),
      );
    }
  }

  Future<void> _removeStudentFromCourse(String courseId, String studentId) async {
    try {
      var response = await http.post(
        Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/remove_student_from_course.php'),
        body: {
          'course_id': courseId,
          'student_id': studentId,
        },
      );

      if (response.statusCode == 200) {
        var responseData = response.body;
        if (responseData.isNotEmpty) {
          // Verificar la respuesta del servidor
          if (responseData.contains('success')) {
            var deletedId = studentId;
            print('Student removed successfully with ID: $deletedId');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student removed successfully from the course with ID: $deletedId')),
            );
            _fetchCourseStudents(courseId); // Refresh course students
          } else if (responseData.contains('not_found')) {
            print('Student not found in the course');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student not found in the course.')),
            );
          } else {
            print('Failed to remove student');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to remove student from the course.')),
            );
          }
        } else {
          print('Empty response from server');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Empty response from server')),
          );
        }
      } else {
        print('Error removing student: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing student from course.')),
        );
      }
    } catch (e) {
      print('Error removing student from course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing student from course.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Cursos a Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section to add student to course
            DropdownButton<String>(
              hint: const Text('Seleccionar Estudiante'),
              value: selectedCourseId,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourseId = newValue;
                });
              },
              items: courses.map<DropdownMenuItem<String>>((Map<String, dynamic> course) {
                return DropdownMenuItem<String>(
                  value: course['id']?.toString() ?? '',
                  child: Text(course['nombre'] ?? 'No course name'),
                );
              }).toList(),
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Buscar Estudiante',
              ),
              onChanged: (String value) {
                setState(() {});
              },
            ),
            DropdownButton<String>(
              hint: const Text('Select a Student'),
              value: selectedStudentId,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStudentId = newValue;
                });
              },
              items: students.where((student) {
                String fullName = '${student['first_name']} ${student['last_name']}';
                return fullName.toLowerCase().contains(searchController.text.toLowerCase());
              }).map<DropdownMenuItem<String>>((Map<String, dynamic> student) {
                return DropdownMenuItem<String>(
                  value: student['id']?.toString() ?? '',
                  child: Text('${student['first_name']} ${student['last_name']}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStudentToCourse,
              child: const Text('Añadir estudiante a curso'),
            ),
            const SizedBox(height: 20),

            // Section to view and remove students from a selected course
            DropdownButton<String>(
              hint: const Text('Seleccionar Curso'),
              value: selectedCourseForView,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCourseForView = newValue;
                  if (newValue != null) {
                    _fetchCourseStudents(newValue);
                  }
                });
              },
              items: courses.map<DropdownMenuItem<String>>((Map<String, dynamic> course) {
                return DropdownMenuItem<String>(
                  value: course['id']?.toString() ?? '',
                  child: Text(course['nombre'] ?? 'No course name'),
                );
              }).toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: courseStudents.map((student) {
                    return DataRow(cells: [
                      DataCell(Text(student['id'].toString())),
                      DataCell(Text(student['first_name'] ?? '')),
                      DataCell(Text(student['last_name'] ?? '')),
                      DataCell(
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            if (selectedCourseForView != null) {
                              _removeStudentFromCourse(selectedCourseForView!, student['id'].toString());
                            }
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
