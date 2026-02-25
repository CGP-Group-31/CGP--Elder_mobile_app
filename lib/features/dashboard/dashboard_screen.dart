import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';

// Feature pages (create below)

import '../reminders/reminders_screen.dart';
import '../location/location_screen.dart';
import '../ai_companion/talk_to_companion_screen.dart';
import '../messaging/messaging_screen.dart';
import '../profile/profile_screen.dart';
import '../sos/sos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // soft decorative blobs like your wireframe background
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground.withValues(alpha:0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -100,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground.withValues(alpha:0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top title
                  Center(
                    child: Text(
                      "Elderly Care",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Greeting
                  Text(
                    "Hi John!",
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "How are you today?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.descriptionText,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 2x2 tiles
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.05,
                      children: [
                        _HomeTile(
                          title: "Talk to\nCompanion",
                          icon: Icons.mic_rounded,
                          bg: AppColors.primary,
                          fg: Colors.white,
                         onTap: () => _open(context, const TalkToCompanionScreen()),
                        ),
                        _HomeTile(
                          title: "Reminders",
                          icon: Icons.calendar_month_rounded,
                          bg: AppColors.alertNonCritical, // gold-ish
                          fg: AppColors.primaryText,
                          onTap: () => _open(context, const RemindersScreen()),
                        ),
                        _HomeTile(
                          title: "Location",
                          icon: Icons.location_on_rounded,
                          bg: AppColors.sectionBackground, // mint
                          fg: AppColors.primaryText,
                          onTap: () => _open(context, const LocationScreen()),
                        ),
                        _HomeTile(
                          title: "Messages",
                          icon: Icons.mail_rounded,
                          bg: AppColors.emergencyBackground, // pink
                          fg: AppColors.primaryText,
                         onTap: () => _open(context, const MessagingScreen()),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.home,
        onHome: () {
          // already here - do nothing
        },
        onSos: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SosScreen()),
          );
        },
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

class _HomeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _HomeTile({
    required this.title,
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 32, color: AppColors.primaryText),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}