import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';

import '../talk/talk_screen.dart';
import '../reminders/reminders_screen.dart';
import '../location/location_screen.dart';
import '../messages/messages_screen.dart';

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
            // soft decorative blobs (keeps your wireframe feel)
            Positioned(
              top: -90,
              right: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground.withValues(alpha:0.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -110,
              child: Container(
                width: 280,
                height: 280,
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
                        fontSize: 22, // bigger
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
                      fontSize: 38, // bigger (elder friendly)
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "How are you today?",
                    style: TextStyle(
                      fontSize: 20, // bigger
                      fontWeight: FontWeight.w600,
                      color: AppColors.descriptionText,
                    ),
                  ),

                  // Push the grid to be visually centered
                  const Spacer(),

                  // Grid centered + more spacing + taller tiles
                  Align(
                    alignment: Alignment.center,
                    child: GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 24, // more spread out
                        mainAxisSpacing: 24, // more spread out
                        childAspectRatio: 1.05, // slightly taller rectangles
                      ),
                      children: [
                        _HomeTile(
                          title: "Talk to\nCompanion",
                          icon: Icons.mic_rounded,
                          bg: AppColors.primary,
                          fg: Colors.white,
                          onTap: () =>
                              _open(context, const TalkCompanionScreen()),
                        ),
                        _HomeTile(
                          title: "Reminders",
                          icon: Icons.calendar_month_rounded,
                          bg: AppColors.alertNonCritical,
                          fg: AppColors.primaryText,
                          onTap: () => _open(context, const RemindersScreen()),
                        ),
                        _HomeTile(
                          title: "Location",
                          icon: Icons.location_on_rounded,
                          bg: AppColors.sectionBackground,
                          fg: AppColors.primaryText,
                          onTap: () => _open(context, const LocationScreen()),
                        ),
                        _HomeTile(
                          title: "Messages",
                          icon: Icons.mail_rounded,
                          bg: AppColors.emergencyBackground,
                          fg: AppColors.primaryText,
                          onTap: () => _open(context, const MessagesScreen()),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(), // keeps grid vertically centered between header & navbar
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom nav
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.home,
        onHome: () {},
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
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
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
            // Bigger icon container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 34,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Bigger tile label (elder friendly)
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 18, // bigger
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}