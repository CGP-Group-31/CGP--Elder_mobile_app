import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.sosButton,
        foregroundColor: Colors.white,
        title: const Text("SOS"),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.emergencyBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            "SOS page ✅",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ),
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.sos,
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
        onSos: () {},
        onProfile: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        },
      ),
    );
  }
}