import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../sos/sos_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Profile"),
      ),
      body: Center(
        child: Text(
          "Profile page ✅",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryText,
          ),
        ),
      ),
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.profile,
        onHome: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
        onSos: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SosScreen()),
          );
        },
        onProfile: () {},
      ),
    );
  }
}