import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_dictionary.dart';

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        // Default to English while the database is loading
        String lang = 'English';
        if (snapshot.hasData && snapshot.data!.exists) {
          lang = snapshot.data!['language'] ?? 'English';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppDictionary.getString(lang, 'patient_title')),
            backgroundColor: Colors.blueAccent,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: AppDictionary.getString(lang, 'logout'),
                onPressed: () async => await AuthService().signOut(),
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                Text(
                  AppDictionary.getString(lang, 'welcome_patient'),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Logic for real-time SOS alert will go here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: Text(
                    AppDictionary.getString(lang, 'help_btn'),
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}