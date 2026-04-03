import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// ADD THESE TWO IMPORTS
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
                // 1. Call the sign-up logic
                var user = await AuthService().signUp(
                  _emailController.text, 
                  _passwordController.text, 
                  _selectedRole
                );

                // 2. Check if the user was created successfully
                if (user != null && mounted) {
                  // 3. Navigate to the correct screen based on role
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
              },
              child: Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}