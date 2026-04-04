import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Caregiver';
  String _selectedLanguage = 'English';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = _selectedLanguage == 'English';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFBFD9FF),
                  Color(0xFFAEC5FF),
                  Color(0xFFC8B8FF),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -40,
            child: _meshBlob(
              size: 280,
              color: const Color(0xFF7FB3FF).withOpacity(0.45),
            ),
          ),
          Positioned(
            bottom: -90,
            right: -50,
            child: _meshBlob(
              size: 260,
              color: const Color(0xFF9FA8FF).withOpacity(0.55),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 520,
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.26),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.78),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2A3D8F).withOpacity(0.18),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isEnglish ? 'Create Account' : 'إنشاء حساب',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEnglish
                                ? 'Build your care profile in a minute'
                                : 'أنشئ حسابك بسهولة خلال دقيقة',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF3D4A94),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildLanguagePicker(isEnglish),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _emailController,
                            decoration: _inputDecoration(
                              isEnglish ? 'Email' : 'الايميل',
                              Icons.alternate_email,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              isEnglish ? 'Password' : 'كلمة السر',
                              Icons.lock_outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isEnglish ? 'I am a:' : 'أنا بستخدم التطبيق كـ:',
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _roleChip(
                                value: 'Caregiver',
                                label: isEnglish ? 'Caregiver' : 'مرافق',
                              ),
                              _roleChip(
                                value: 'Patient',
                                label: isEnglish ? 'Patient' : 'مريض',
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 58,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3E5BF1),
                                    Color(0xFF1E88E5),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3E5BF1,
                                    ).withOpacity(0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await AuthService().signUp(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                      _selectedRole,
                                      _selectedLanguage,
                                    );
                                  } catch (errorMessage) {
                                    if (!mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(errorMessage.toString()),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  isEnglish ? 'Sign Up' : 'تسجيل',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              isEnglish
                                  ? 'Already have an account? Login here'
                                  : 'عندك حساب أصلاً؟ ادخل من هنا',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF2F3E90),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePicker(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.68),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white70),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(20),
          items: const [
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(
              value: 'Egyptian Arabic',
              child: Text('عربي مصري'),
            ),
          ],
          onChanged: (newValue) {
            if (newValue == null) {
              return;
            }
            setState(() {
              _selectedLanguage = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _roleChip({required String value, required String label}) {
    final isSelected = _selectedRole == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1A237E),
        fontWeight: FontWeight.w600,
      ),
      selectedColor: const Color(0xFF3E5BF1),
      backgroundColor: Colors.white.withOpacity(0.7),
      side: BorderSide(
        color: isSelected ? const Color(0xFF3E5BF1) : Colors.white70,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (_) {
        setState(() {
          _selectedRole = value;
        });
      },
    );
  }

  Widget _meshBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
          radius: 0.8,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      prefixIcon: Icon(icon, color: const Color(0xFF3E5BF1)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color(0xFF4A67FF), width: 1.6),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white70),
      ),
    );
  }
}
