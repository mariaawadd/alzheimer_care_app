import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Caregiver'; // Default role

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            Text("I am a:"),
            ListTile(
              title: const Text('Caregiver'),
              leading: Radio<String>(
                value: 'Caregiver',
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
            ),
            ListTile(
              title: const Text('Patient'),
              leading: Radio<String>(
                value: 'Patient',
                groupValue: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // This calls the logic we wrote earlier!
                await AuthService().signUp(_emailController.text, _passwordController.text, _selectedRole);
                print("User Created as $_selectedRole");
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}