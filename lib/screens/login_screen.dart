import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _savedAccountsKey = 'saved_login_accounts';

  final _storage = const FlutterSecureStorage();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _saveCurrentAccount = false;
  List<_SavedAccount> _savedAccounts = [];
  String? _selectedAccountEmail;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final savedAccountsJson = await _storage.read(key: _savedAccountsKey);

    if (!mounted || savedAccountsJson == null || savedAccountsJson.isEmpty) {
      return;
    }

    try {
      final decoded = jsonDecode(savedAccountsJson);

      if (decoded is! List) {
        return;
      }

      final accounts = decoded
          .whereType<Map>()
          .map(
            (entry) => _SavedAccount.fromJson(Map<String, dynamic>.from(entry)),
          )
          .where(
            (account) =>
                account.email.isNotEmpty && account.password.isNotEmpty,
          )
          .toList();

      if (accounts.isEmpty) {
        return;
      }

      final firstAccount = accounts.first;
      setState(() {
        _savedAccounts = accounts;
        _selectedAccountEmail = firstAccount.email;
        _emailController.text = firstAccount.email;
        _passwordController.text = firstAccount.password;
        _saveCurrentAccount = true;
      });
    } catch (_) {}
  }

  Future<void> _saveCurrentAccountCredentials() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    final updatedAccounts = [
      _SavedAccount(email: email, password: password),
      ..._savedAccounts.where((account) => account.email != email),
    ];

    await _storage.write(
      key: _savedAccountsKey,
      value: jsonEncode(
        updatedAccounts.map((account) => account.toJson()).toList(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _savedAccounts = updatedAccounts;
      _selectedAccountEmail = email;
      _saveCurrentAccount = true;
    });
  }

  void _selectSavedAccount(_SavedAccount account) {
    setState(() {
      _selectedAccountEmail = account.email;
      _emailController.text = account.email;
      _passwordController.text = account.password;
      _saveCurrentAccount = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSavedAccounts = _savedAccounts.isNotEmpty;

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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                  return;
                                }

                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              label: const Text('Back to Sign Up'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1A237E),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1A237E),
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Secure access to your care dashboard',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF3D4A94),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 22),
                          DropdownButtonFormField<String>(
                            value: hasSavedAccounts
                                ? _selectedAccountEmail
                                : null,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              'Saved account',
                              Icons.account_circle_outlined,
                            ),
                            hint: const Text('Choose saved account'),
                            disabledHint: const Text('No saved accounts yet'),
                            items: _savedAccounts
                                .map(
                                  (account) => DropdownMenuItem<String>(
                                    value: account.email,
                                    child: Text(account.email),
                                  ),
                                )
                                .toList(),
                            onChanged: hasSavedAccounts
                                ? (selectedEmail) {
                                    if (selectedEmail == null) {
                                      return;
                                    }

                                    final selectedAccount = _savedAccounts
                                        .firstWhere(
                                          (account) =>
                                              account.email == selectedEmail,
                                        );
                                    _selectSavedAccount(selectedAccount);
                                  }
                                : null,
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _emailController,
                            decoration: _inputDecoration(
                              'Email',
                              Icons.alternate_email,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: _inputDecoration(
                              'Password',
                              Icons.lock_outline,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            value: _saveCurrentAccount,
                            onChanged: (value) {
                              setState(() {
                                _saveCurrentAccount = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'Save this account',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                                    await AuthService().login(
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    );

                                    if (_saveCurrentAccount) {
                                      await _saveCurrentAccountCredentials();
                                    }

                                    if (!context.mounted) {
                                      return;
                                    }

                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop();
                                    }
                                  } catch (errorMessage) {
                                    if (!context.mounted) {
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
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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

class _SavedAccount {
  const _SavedAccount({required this.email, required this.password});

  final String email;
  final String password;

  factory _SavedAccount.fromJson(Map<String, dynamic> json) {
    return _SavedAccount(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
