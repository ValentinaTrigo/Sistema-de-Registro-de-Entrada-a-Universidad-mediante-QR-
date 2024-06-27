import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';

class InitCoursePage extends StatefulWidget {
  final int courseId;

  const InitCoursePage({Key? key, required this.courseId}) : super(key: key);

  @override
  _InitCoursePageState createState() => _InitCoursePageState();
}

class _InitCoursePageState extends State<InitCoursePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool scanning = false;
  List<String> scannedFaces = [];
  String? nombreStudent;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _controller.initialize();
      setState(() {}); // Trigger a rebuild after camera is initialized
    } else {
      _showMessage(context, 'Error', 'No cameras found on this device.');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facial Recognition'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: scanning ? null : _recognizeFace,
            child: scanning ? CircularProgressIndicator() : Text('Scan Face'),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            height: 200,
            child: ListView.builder(
              itemCount: scannedFaces.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(scannedFaces[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _recognizeFace() async {
    try {
      await _initializeControllerFuture;

      XFile? image = await _controller.takePicture();

      setState(() {
        scanning = true;
      });

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.56.186.3:5000/check_face'),
      );
      request.files.add(await http.MultipartFile.fromBytes(
        'image',
        await image!.readAsBytes(),
        filename: 'image.jpg',
        contentType: MediaType('image', 'jpg'),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var responseData;
        try {
          responseData = json.decode(response.body);
        } catch (e) {
          _showMessage(context, 'Error', 'Error en la respuesta del servidor: ${response.body}');
          return;
        }

        nombreStudent = responseData['name'];

        if (responseData['success']) {
          _registerAttendance(nombreStudent!);
        } else {
          _showMessage(context, 'Error', responseData['message']);
        }
      } else {
        _showMessage(context, 'Error', 'Failed to connect to server.');
      }

      setState(() {
        scanning = false;
      });
    } catch (e) {
      _showMessage(context, 'Error', 'An error occurred: ${e.toString()}');
      setState(() {
        scanning = false;
      });
    }
  }

  Future<void> _registerAttendance(String nombreStudent) async {
    try {
      if (widget.courseId == null) {
        _showMessage(context, 'Error', 'Debe seleccionar un curso primero.');
        return;
      }

      // Mostrar mensaje de confirmación antes de enviar la solicitud
      bool confirm = await _showConfirmationDialog(context, nombreStudent, widget.courseId.toString());
      if (!confirm) return;

      var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/registrate_attendance.php'); // Asegúrate de que la URL sea correcta
      var response = await http.post(
        url,
        body: {
          'student_name': nombreStudent,
          'course_id': widget.courseId.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data;
        try {
          data = json.decode(response.body);
        } catch (e) {
          _showMessage(context, 'Error', 'Error en la respuesta del servidor: ${response.body}');
          return;
        }

        if (data['success'] != null && data['success']) {
          setState(() {
            scannedFaces.add("${DateTime.now()}: $nombreStudent");
          });
          _showMessage(context, 'Success', data['message']);
        } else {
          _showMessage(context, 'Error', data['message'] ?? 'Unknown error occurred');
        }
      } else {
        _showMessage(context, 'Error', 'Failed to connect to server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage(context, 'Error', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context, String nombreStudent, String courseId) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Información'),
          content: Text('¿Desea registrar la asistencia para el estudiante $nombreStudent en el curso'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cerrar el diálogo y retornar falso
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Cerrar el diálogo y retornar verdadero
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    ) ?? false; // Retorna falso si el usuario cierra el diálogo sin seleccionar una opción
  }

  void _showMessage(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
