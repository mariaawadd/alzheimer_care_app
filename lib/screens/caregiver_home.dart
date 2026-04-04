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
    final TextEditingController _emailSearchController =
        TextEditingController();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String lang = 'English';
        String? linkedUserId;

        if (snapshot.hasData && snapshot.data!.exists) {
          lang = snapshot.data!['language'] ?? 'English';
          linkedUserId = snapshot.data!['linkedUser'];
        }

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                if (linkedUserId == null) ...[
                  // --- LINKING SECTION ---
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
                            String resultKey = await AuthService().linkByEmail(
                              _emailSearchController.text,
                            );
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
                  // --- REAL-TIME PULSE MONITOR ---
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(linkedUserId)
                        .snapshots(),
                    builder: (context, patientSnapshot) {
                      if (!patientSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var patientData = patientSnapshot.data!;
                      String status = patientData['status'] ?? 'Normal';
                      bool isEmergency = status == 'Emergency';

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isEmergency ? Colors.red[100] : Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isEmergency ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isEmergency ? Icons.warning : Icons.check_circle,
                              color: isEmergency ? Colors.red : Colors.teal,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isEmergency
                                  ? (lang == 'English' ? "EMERGENCY DETECTED" : "حالة طوارئ!")
                                  : (lang == 'English' ? "Patient is Safe" : "المريض بخير"),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isEmergency ? Colors.red : Colors.black,
                              ),
                            ),
                            if (isEmergency) ...[
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                onPressed: () async {
                                  // Caregiver can remotely clear the alert
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(linkedUserId)
                                      .update({'status': 'Normal'});
                                },
                                child: Text(
                                  lang == 'English' ? "Clear Alert" : "إلغاء التنبيه",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
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