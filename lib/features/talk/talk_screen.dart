import 'package:flutter/material.dart';
import '../theme.dart';

class TalkCompanionScreen extends StatelessWidget {
  const TalkCompanionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Talk to Companion"),
      ),
      body: Center(
        child: Text(
          "Talk to Companion page ✅",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}