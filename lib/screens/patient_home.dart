import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/app_dictionary.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7FA),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        String lang = 'English';
        lang = (userData?['language'] as String?) ?? 'English';
        final isEnglish = lang == 'English';

        final displayName =
            (userData?['name'] as String?) ??
            user?.email ??
            (isEnglish ? 'Patient' : 'مريض');

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 30),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F7CFF), Color(0xFF1E40AF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '$displayName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            tooltip: AppDictionary.getString(lang, 'logout'),
                            onPressed: () async =>
                                await AuthService().signOut(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppDictionary.getString(lang, 'welcome_patient'),
                        style: const TextStyle(
                          color: Color(0xFFE5ECFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEnglish ? 'Safe Status' : 'حالة آمنة',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: GestureDetector(
                    onTap: () async {
                      await AuthService().updateStatus('Emergency');

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == 'English'
                                  ? 'Alert Sent!'
                                  : 'تم إرسال التنبيه!',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFE03131)],
                          center: Alignment(-0.2, -0.2),
                          radius: 0.85,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE03131).withOpacity(0.45),
                            blurRadius: 30,
                            spreadRadius: 8,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppDictionary.getString(lang, 'help_btn'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE9F7F4),
                            child: Icon(Icons.call, color: Color(0xFF00BFA5)),
                          ),
                          title: Text(
                            isEnglish ? 'Call Caregiver' : 'اتصل بالمرافق',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          subtitle: Text(
                            isEnglish
                                ? 'Fast direct contact'
                                : 'اتصال مباشر سريع',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEnglish
                                      ? 'Caregiver call feature coming soon.'
                                      : 'ميزة الاتصال بالمرافق ستتوفر قريبًا.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFEAF2FF),
                            child: Icon(
                              Icons.calendar_today,
                              color: Color(0xFF4F7CFF),
                            ),
                          ),
                          title: Text(
                            isEnglish ? 'Daily Routine' : 'الروتين اليومي',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                          subtitle: Text(
                            isEnglish
                                ? 'Medication and activity schedule'
                                : 'جدول الدواء والأنشطة',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isEnglish
                                      ? 'Daily routine details will be added.'
                                      : 'سيتم إضافة تفاصيل الروتين اليومي قريبًا.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
