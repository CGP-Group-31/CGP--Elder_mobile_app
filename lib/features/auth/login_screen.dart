import 'package:flutter/material.dart';
import '../theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/session/elder_session_manager.dart';
import './elder_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool obscure = true;
  bool _loading = false;

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {

      await ElderAuthService.loginElder(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final ok = await ElderSessionManager.isLoggedIn();
      if (!ok) throw Exception("Session not saved");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sosButton,
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
            style: const TextStyle(fontSize: 18),
          ),
        ),
      );

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showForgotMessage() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Need Help?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Please contact your caregiver to reset your password.",
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD6EFE6),
              Color(0xFFBEE8DA),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(

          child: Center(

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(24),

              child: Container(

                padding: const EdgeInsets.all(28),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),

                child: Form(
                  key: _formKey,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      /// HEART ICON
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.sectionBackground,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Log in to continue",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.descriptionText,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emailController,
                        validator: _validateEmail,
                        style: const TextStyle(fontSize: 20),

                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          filled: true,
                          fillColor: AppColors.containerBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// PASSWORD
                      Align(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: obscure,
                        validator: _validatePassword,
                        style: const TextStyle(fontSize: 20),

                        decoration: InputDecoration(
                          hintText: "Enter password",
                          filled: true,
                          fillColor: AppColors.containerBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 18),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 60,

                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          child: Text(
                            _loading ? "Logging in..." : "Log In",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// FORGOT PASSWORD
                      GestureDetector(
                        onTap: _showForgotMessage,
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
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
    );
  }
}