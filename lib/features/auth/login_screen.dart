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

      final resp = await ElderAuthService.loginElder(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final ok = await ElderSessionManager.isLoggedIn();

      if (!ok) throw Exception("Session not saved");

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.sosButton,
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
        ),
      );

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {

    if (value == null || value.isEmpty) {
      return "Enter phone or email";
    }

    return null;
  }

  String? _validatePassword(String? value) {

    if (value == null || value.isEmpty) {
      return "Enter password";
    }

    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Container(

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),

              child: Form(
                key: _formKey,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Back Button + Title
                    Row(
                      children: [

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Text(
                          "Elder Care",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.sectionBackground,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Login Title
                    const Center(
                      child: Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Center(
                      child: Text(
                        "Enter your details to continue.",
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.descriptionText,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Email
                    const Text(
                      "Phone or Email",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _emailController,
                      validator: _validateEmail,
                      style: const TextStyle(fontSize: 18),

                      decoration: InputDecoration(
                        hintText: "e.g., 07X XXX XXXX",
                        filled: true,
                        fillColor: AppColors.containerBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Password
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscure,
                      validator: _validatePassword,
                      style: const TextStyle(fontSize: 18),

                      decoration: InputDecoration(
                        hintText: "Enter password",
                        filled: true,
                        fillColor: AppColors.containerBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    /// Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,

                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        child: Text(
                          _loading ? "Logging in..." : "Log In",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// Forgot password
                    const Center(
                      child: Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
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
    );
  }
}