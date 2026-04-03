import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'caregiver_home.dart';
import 'patient_home.dart';

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
            TextField(
              controller: _emailController, 
              decoration: InputDecoration(labelText: "Email")
            ),
            TextField(
              controller: _passwordController, 
              decoration: InputDecoration(labelText: "Password"), 
              obscureText: true
            ),
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
                try {
                  // 1. Attempt the sign-up logic
                  var user = await AuthService().signUp(
                    _emailController.text, 
                    _passwordController.text, 
                    _selectedRole
                  );

                  // 2. If user is created successfully, navigate based on role
                  if (user != null && mounted) {
                    if (_selectedRole == 'Caregiver') {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => CaregiverHome())
                      );
                    } else {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (context) => PatientHome())
                      );
                    }
                  }
                } catch (errorMessage) {
                  // 3. Catch any Firebase errors and show them in a red SnackBar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage.toString()),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text("Sign Up"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => LoginScreen())
                );
              },
              child: Text("Already have an account? Login here"),
            ),
          ],
        ),
      ),
    );
  }
}