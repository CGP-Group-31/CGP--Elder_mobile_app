import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Center(
                child: CustomPaint(
                  size: const Size(180, 150),
                  painter: ElderHeartPainter(),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Welcome to\nElder Care",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Simplifying your daily tasks\nand staying connected",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.descriptionText,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _footerText("Terms of Service"),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "|",
                      style: TextStyle(color: AppColors.textShade),
                    ),
                  ),
                  _footerText("Privacy Policy"),
                ],
              ),

              const SizedBox(height: 20),
            ],
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
        fontSize: 13,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class ElderHeartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6F7F7D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..color = const Color(0xFF6F7F7D)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height * 0.3);
    path.cubicTo(
        size.width * 0.2, 0, 0, size.height * 0.5,
        size.width / 2, size.height);
    path.moveTo(size.width / 2, size.height * 0.3);
    path.cubicTo(
        size.width * 0.8, 0, size.width, size.height * 0.5,
        size.width / 2, size.height);
    canvas.drawPath(path, paint);

    canvas.drawCircle(
        Offset(size.width * 0.42, size.height * 0.5),
        10,
        fillPaint);
    canvas.drawCircle(
        Offset(size.width * 0.58, size.height * 0.45),
        12,
        fillPaint);

    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.5,
        size.height * 0.8,
        const Radius.circular(10),
      ),
      fillPaint,
    );

    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * 0.5,
        size.height * 0.58,
        size.width * 0.65,
        size.height * 0.8,
        const Radius.circular(10),
      ),
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}