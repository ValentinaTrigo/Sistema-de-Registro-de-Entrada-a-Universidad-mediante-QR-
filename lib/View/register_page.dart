import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  // Función para enviar los datos de registro al backend
  void _registerUser(BuildContext context, String firstName, String lastName, String phone, String email, String password) async {
    // URL de tu script PHP en el servidor
    var url = Uri.parse('http://localhost/ProyectoFlutter/appregister/lib/Backend/register.php');

    // Datos a enviar al servidor en formato JSON
    var data = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password': password,
    };

    // Realizar la solicitud HTTP POST al servidor
    var response = await http.post(url, body: data);

    // Verificar la respuesta del servidor
    if (response.statusCode == 200) {
      // Manejar la respuesta exitosa
      print('Registro exitoso');
      // Redirigir a otra pantalla después del registro exitoso
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Manejar posibles errores
      print('Error en el registro: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNameController = TextEditingController();
    TextEditingController lastNameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Obtener los valores de los campos de texto
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String phone = phoneController.text;
                String email = emailController.text;
                String password = passwordController.text;

                // Llamar a la función para registrar al usuario
                _registerUser(context, firstName, lastName, phone, email, password);
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
