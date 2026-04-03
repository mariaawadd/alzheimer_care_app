import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'caregiver_home.dart';
import 'patient_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var user = await AuthService().login(_emailController.text, _passwordController.text);
                if (user != null) {
                  String? role = await AuthService().getUserRole(user.uid);
                  if (role == 'Caregiver') {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CaregiverHome()));
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientHome()));
                  }
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}