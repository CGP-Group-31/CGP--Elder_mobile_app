import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_screen.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        _goHome(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.sosButton,
          foregroundColor: Colors.white,
          title: const Text("SOS"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goHome(context),
          ),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.emergencyBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "SOS page",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ),
        bottomNavigationBar: ElderBottomNav(
          activeTab: ElderTab.sos,
          onHome: () => _goHome(context),
          onSos: () {},
          onProfile: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ),
    );
  }
}