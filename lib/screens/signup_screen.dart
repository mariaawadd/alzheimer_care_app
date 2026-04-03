import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Caregiver';
  String _selectedLanguage = 'English'; // New state variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == 'English' ? "Create Account" : "إنشاء حساب",
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added scrollview to prevent overflow with keyboard
          child: Column(
            children: [
              // --- LANGUAGE SELECTOR ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[200],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      underline: SizedBox(), // Removes the default underline
                      items: <String>['English', 'Egyptian Arabic'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedLanguage = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // --- INPUT FIELDS ---
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'English'
                      ? "Email"
                      : "الايميل",
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: _selectedLanguage == 'English'
                      ? "Password"
                      : "كلمة السر",
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // --- ROLE SELECTION ---
              Text(
                _selectedLanguage == 'English'
                    ? "I am a:"
                    : "أنا بستخدم التطبيق كـ:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text(
                  _selectedLanguage == 'English'
                      ? 'Caregiver'
                      : 'مرافق (Caregiver)',
                ),
                leading: Radio<String>(
                  value: 'Caregiver',
                  groupValue: _selectedRole,
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ),
              ListTile(
                title: Text(
                  _selectedLanguage == 'English' ? 'Patient' : 'مريض (Patient)',
                ),
                leading: Radio<String>(
                  value: 'Patient',
                  groupValue: _selectedRole,
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ),
              SizedBox(height: 20),

              // --- SIGN UP BUTTON ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
                onPressed: () async {
                  try {
                    // AuthWrapper listens to auth changes and routes automatically.
                    await AuthService().signUp(
                      _emailController.text,
                      _passwordController.text,
                      _selectedRole,
                      _selectedLanguage, // Added this argument
                    );
                  } catch (errorMessage) {
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
                child: Text(
                  _selectedLanguage == 'English' ? "Sign Up" : "تسجيل",
                ),
              ),

              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  _selectedLanguage == 'English'
                      ? "Already have an account? Login here"
                      : "عندك حساب أصلاً؟ ادخل من هنا",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
