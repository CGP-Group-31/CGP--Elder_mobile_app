import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),

            decoration: BoxDecoration(
              color: AppColors.containerBackground,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                )
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                /// HEART ICON
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 30),

                /// TITLE
                const Text(
                  "Welcome to\nElder Care",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                /// DESCRIPTION
                const Text(
                  "Simplifying daily tasks and staying\nconnected.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.descriptionText,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                /// LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// FOOTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _footerText("Terms of Service"),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "|",
                        style: TextStyle(
                          color: AppColors.textShade,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    _footerText("Privacy Policy"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerText(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textShade,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}