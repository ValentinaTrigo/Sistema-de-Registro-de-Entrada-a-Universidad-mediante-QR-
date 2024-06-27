import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/camera_web.dart';

// Importa las páginas y otros componentes necesarios
import 'View/login_page.dart';
import 'View/register_page.dart';
import 'View/home_page.dart';
import 'View/add_student_page.dart';
import 'View/add_course_page.dart';
import 'View/course_students.dart';
import 'View/init_course_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = [];
  CameraDescription? firstCamera;

  try {
    cameras = await availableCameras();
    firstCamera = cameras.first;
  } on CameraException catch (e) {
    print('Error al inicializar la cámara: ${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/addStudent': (context) => const AddStudentPage(),
        '/addCourse': (context) => const AddCoursePage(),
        '/courseStudents': (context) => CourseStudentsPage(),
        '/initCourse': (context) => InitCoursePage(courseId: 1),
      },
    );
  }
}
