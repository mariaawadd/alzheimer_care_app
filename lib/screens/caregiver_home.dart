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
    final TextEditingController _emailSearchController = TextEditingController();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        String lang = 'English';
        String? linkedUserId;
        
        if (snapshot.hasData && snapshot.data!.exists) {
          lang = snapshot.data!['language'] ?? 'English';
          linkedUserId = snapshot.data!['linkedUser'];
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
                const SizedBox(height: 20),

                // --- LINKING SECTION ---
                if (linkedUserId == null) ...[
                  Text(
                    lang == 'English' 
                    ? "Connect to a Patient's account:" 
                    : "اربط حسابك بحساب المريض:",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailSearchController,
                    decoration: InputDecoration(
                      hintText: lang == 'English' ? "Patient Email" : "إيميل المريض",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.person_add, color: Colors.teal),
                        onPressed: () async {
                          if (_emailSearchController.text.isNotEmpty) {
                            // 1. Get the key from the service
                            String resultKey = await AuthService().linkByEmail(
                              _emailSearchController.text
                            );

                            // 2. Look up the translation using the dictionary
                            String message = AppDictionary.getString(lang, resultKey);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(message),
                                  backgroundColor: resultKey == "link_success" 
                                      ? Colors.green 
                                      : Colors.redAccent,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  // --- LINKED PATIENT VIEW ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.teal),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.teal, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          lang == 'English' 
                              ? "Linked to Patient" 
                              : "تم الربط مع المريض",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lang == 'English' 
                              ? "Status: Monitoring..." 
                              : "الحالة: جاري المتابعة...",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}