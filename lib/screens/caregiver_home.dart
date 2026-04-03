import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_dictionary.dart';

class CaregiverHome extends StatelessWidget {
  const CaregiverHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        String lang = 'English';
        if (snapshot.hasData && snapshot.data!.exists) {
          lang = snapshot.data!['language'] ?? 'English';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(AppDictionary.getString(lang, 'caregiver_title')),
            backgroundColor: Colors.teal,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: AppDictionary.getString(lang, 'logout'),
                onPressed: () async => await AuthService().signOut(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDictionary.getString(lang, 'welcome_caregiver'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                // Placeholder for linking logic
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Logic for linking a patient will go here
                    },
                    icon: const Icon(Icons.add),
                    label: Text(lang == 'English' ? "Link New Patient" : "إضافة مريض جديد"),
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