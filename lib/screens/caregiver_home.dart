import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/app_dictionary.dart';

class CaregiverHome extends StatefulWidget {
  const CaregiverHome({super.key});

  @override
  State<CaregiverHome> createState() => _CaregiverHomeState();
}

class _CaregiverHomeState extends State<CaregiverHome>
    with TickerProviderStateMixin {
  final TextEditingController _emailSearchController = TextEditingController();
  late final AnimationController _breatheController;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
  }

  @override
  void dispose() {
    _emailSearchController.dispose();
    _breatheController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F8FF),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        String lang = 'English';
        String? linkedUserId;
        lang = (userData?['language'] as String?) ?? 'English';
        linkedUserId = userData?['linkedUser'] as String?;

        return StreamBuilder<DocumentSnapshot>(
          stream: linkedUserId == null
              ? null
              : FirebaseFirestore.instance
                    .collection('users')
                    .doc(linkedUserId)
                    .snapshots(),
          builder: (context, patientSnapshot) {
            String status = 'Normal';
            if (linkedUserId != null && patientSnapshot.hasData) {
              status =
                  patientSnapshot.data!.get('status') as String? ?? 'Normal';
            }
            final bool isEmergency = status == 'Emergency';

            if (isEmergency && !_shakeController.isAnimating) {
              _shakeController.repeat(reverse: true);
            } else if (!isEmergency && _shakeController.isAnimating) {
              _shakeController.stop();
              _shakeController.value = 0;
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isEmergency
                      ? const [Color(0xFFFFF3F3), Color(0xFFFFE2E2)]
                      : const [Color(0xFFF4F8FF), Color(0xFFF0F4FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    AppDictionary.getString(lang, 'caregiver_title'),
                    style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout, color: Color(0xFF1A237E)),
                      tooltip: AppDictionary.getString(lang, 'logout'),
                      onPressed: () async => await AuthService().signOut(),
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang == 'English' ? 'Care Monitor' : 'مركز المتابعة',
                        style: const TextStyle(
                          color: Color(0xFF1A237E),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppDictionary.getString(lang, 'welcome_caregiver'),
                        style: const TextStyle(
                          color: Color(0xFF344095),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (linkedUserId == null)
                        _buildLinkingCard(context, lang)
                      else ...[
                        _buildPulseCard(
                          context,
                          isEmergency,
                          linkedUserId,
                          lang,
                        ),
                        const SizedBox(height: 18),
                        _buildStatusGrid(isEmergency, lang),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLinkingCard(BuildContext context, String lang) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang == 'English' ? 'Link Patient' : 'ربط المريض',
                style: const TextStyle(
                  color: Color(0xFF1A237E),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'English'
                    ? "Connect to a Patient's account"
                    : 'اربط حسابك بحساب المريض',
                style: const TextStyle(color: Color(0xFF3F4B9A)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailSearchController,
                decoration: InputDecoration(
                  hintText: lang == 'English'
                      ? 'Patient Email'
                      : 'إيميل المريض',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.58),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      color: Color(0xFF00BFA5),
                    ),
                    onPressed: () async {
                      if (_emailSearchController.text.isEmpty) {
                        return;
                      }
                      final resultKey = await AuthService().linkByEmail(
                        _emailSearchController.text.trim(),
                      );
                      final message = AppDictionary.getString(lang, resultKey);
                      if (!mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: resultKey == 'link_success'
                              ? Colors.green
                              : Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseCard(
    BuildContext context,
    bool isEmergency,
    String linkedUserId,
    String lang,
  ) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breatheController, _shakeController]),
      builder: (context, child) {
        final glow = 10 + (_breatheController.value * 18);
        final shake = isEmergency ? ((_shakeController.value - 0.5) * 14) : 0.0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                colors: isEmergency
                    ? const [Color(0xFFFF7A7A), Color(0xFFEA3E3E)]
                    : const [Color(0xFFE7FFFB), Color(0xFFCFF7F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isEmergency
                      ? const Color(0xFFE53935).withOpacity(0.45)
                      : const Color(0xFF00BFA5).withOpacity(0.35),
                  blurRadius: glow,
                  spreadRadius: isEmergency ? 4 : 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isEmergency
                      ? Icons.warning_amber_rounded
                      : Icons.monitor_heart,
                  size: 54,
                  color: isEmergency ? Colors.white : const Color(0xFF00897B),
                ),
                const SizedBox(height: 10),
                Text(
                  isEmergency
                      ? (lang == 'English'
                            ? 'EMERGENCY DETECTED'
                            : 'حالة طوارئ!')
                      : (lang == 'English' ? 'Patient is Safe' : 'المريض بخير'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isEmergency ? Colors.white : const Color(0xFF075E54),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isEmergency
                      ? (lang == 'English'
                            ? 'Immediate response is recommended.'
                            : 'يُنصح بالاستجابة الفورية.')
                      : (lang == 'English'
                            ? 'Live pulse monitor stable.'
                            : 'مؤشر النبض المباشر مستقر.'),
                  style: TextStyle(
                    color: isEmergency
                        ? Colors.white.withOpacity(0.92)
                        : const Color(0xFF1A237E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isEmergency) ...[
                  const SizedBox(height: 14),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(linkedUserId)
                          .update({'status': 'Normal'});
                    },
                    child: Text(
                      lang == 'English' ? 'Clear Alert' : 'إلغاء التنبيه',
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

  Widget _buildStatusGrid(bool isEmergency, String lang) {
    final isEnglish = lang == 'English';
    final items = <Map<String, dynamic>>[
      {
        'title': isEnglish ? 'Battery Level' : 'مستوى البطارية',
        'value': isEmergency ? '28%' : '84%',
        'icon': Icons.battery_5_bar,
      },
      {
        'title': isEnglish ? 'Current Location' : 'الموقع الحالي',
        'value': isEnglish ? 'Home' : 'المنزل',
        'icon': Icons.location_on,
      },
      {
        'title': isEnglish ? 'Last Movement' : 'آخر حركة',
        'value': isEnglish
            ? (isEmergency ? '2 min ago' : '45 sec ago')
            : (isEmergency ? 'منذ دقيقتين' : 'منذ ٤٥ ثانية'),
        'icon': Icons.directions_walk,
      },
      {
        'title': isEnglish ? 'Heart Rate' : 'معدل النبض',
        'value': isEnglish
            ? (isEmergency ? '118 bpm' : '74 bpm')
            : (isEmergency ? '١١٨ نبضة/دقيقة' : '٧٤ نبضة/دقيقة'),
        'icon': Icons.favorite,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item['icon'] as IconData, color: const Color(0xFF00BFA5)),
                const Spacer(),
                Text(
                  item['title'] as String,
                  style: const TextStyle(
                    color: Color(0xFF4A579F),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['value'] as String,
                  style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
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
