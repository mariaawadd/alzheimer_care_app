import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../screens/signup_screen.dart';
import '../screens/caregiver_home.dart';
import '../screens/patient_home.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. If the connection is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. If no user is logged in, show the Sign-Up screen
        if (!snapshot.hasData) {
          return SignUpScreen();
        }

        // 3. If a user IS logged in, find their role and go to the dashboard
        return FutureBuilder<String?>(
          future: AuthService().getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (roleSnapshot.data == 'Caregiver') {
              return CaregiverHome();
            } else {
              return PatientHome();
            }
          },
        );
      },
    );
  }
}