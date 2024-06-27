import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  // Función para enviar los datos de inicio de sesión al backend
  void _loginUser(BuildContext context, String email, String password) async {
    // URL de tu script PHP en el servidor
    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/login.php');
 // Actualiza la ruta aquí

    // Datos a enviar al servidor
    var data = {
      'email': email,
      'password': password,
    };

    // Realizar la solicitud HTTP POST al servidor
    var response = await http.post(url, body: data);

    // Verificar la respuesta del servidor
    if (response.statusCode == 200) {
      // Manejar la respuesta exitosa
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        print('Inicio de sesión exitoso');
        // Redirigir a la página principal después del inicio de sesión exitoso
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('Error en el inicio de sesión: ${responseData['message']}');
        _showErrorDialog(context, responseData['message']);
      }
    } else {
      // Manejar posibles errores
      print('Error en el inicio de sesión: ${response.body}');
      _showErrorDialog(context, 'Error en el servidor');
    }
  }

  // Mostrar un diálogo de error
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Obtener los valores de los campos de texto
                String email = emailController.text;
                String password = passwordController.text;

                // Llamar a la función para iniciar sesión
                _loginUser(context, email, password);
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
