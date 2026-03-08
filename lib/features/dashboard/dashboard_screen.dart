import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';

import '../talk/talk_screen.dart';
import '../reminders/reminders_screen.dart';
import '../location/location_screen.dart';
import '../messages/messages_screen.dart';

import '../profile/profile_screen.dart';
import '../sos/sos_service.dart';
import '../sos/ambulance_sos_service.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> _nameFuture;

  @override
  void initState() {
    super.initState();
    _nameFuture = _fetchElderName();
  }

  Future<String> _fetchElderName() async {
    final elderId = await ElderSessionManager.getElderUserId();

    if (elderId == null) {
      throw Exception("No elder_id found in session.");
    }

    try {
      final response = await DioClient.dio.get("/api/v1/caregiver/elder/$elderId");

      final data = (response.data is Map)
          ? Map<String, dynamic>.from(response.data)
          : <String, dynamic>{};

      final name = (data["FullName"] ?? "").toString().trim();
      return name.isEmpty ? "User" : name;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch elder name");
    }
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _refreshName() {
    setState(() {
      _nameFuture = _fetchElderName();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -90,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.sectionBackground.withValues(alpha: 0.55),
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
                  color: AppColors.sectionBackground.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "TrustCare",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        tooltip: "Refresh name",
                        onPressed: _refreshName,
                        icon: Icon(
                          Icons.refresh,
                          color: AppColors.primaryText.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  FutureBuilder<String>(
                    future: _nameFuture,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 220,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 240,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.background.withValues(alpha: 0.60),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        );
                      }

                      final name = (snap.hasError) ? "User" : (snap.data ?? "User");

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi $name!",
                            style: TextStyle(
                              fontSize: 33,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "How are you today?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.descriptionText,
                            ),
                          ),
                          if (snap.hasError) ...[
                            const SizedBox(height: 6),
                            Text(
                              "Could not load name. Tap refresh.",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.descriptionText,
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GridView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.05,
                          ),
                          children: [
                            _HomeTile(
                              title: "Talk to\nCompanion",
                              icon: Icons.mic_rounded,
                              bg: AppColors.primary,
                              fg: Colors.white,
                              onTap: () => _open(
                                context,
                                const TalkToCompanionScreen(),
                              ),
                            ),
                            _HomeTile(
                              title: "Reminders",
                              icon: Icons.calendar_month_rounded,
                              bg: AppColors.alertNonCritical,
                              fg: AppColors.primaryText,
                              onTap: () => _open(
                                context,
                                const RemindersScreen(),
                              ),
                            ),
                            _HomeTile(
                              title: "Location",
                              icon: Icons.location_on_rounded,
                              bg: AppColors.sectionBackground,
                              fg: AppColors.primaryText,
                              onTap: () => _open(
                                context,
                                const ElderSendLocation(),
                              ),
                            ),
                            _HomeTile(
                              title: "Messages",
                              icon: Icons.mail_rounded,
                              bg: AppColors.emergencyBackground,
                              fg: AppColors.primaryText,
                              onTap: () => _open(
                                context,
                                const MessagingScreen(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _FullWidthActionButton(
                          title: "Call Ambulance",
                          icon: Icons.local_hospital_rounded,
                          bg: AppColors.alertNonCritical,
                          fg: AppColors.primaryText,
                          onTap: () async {
                            try {
                              await AmbulanceSOSService.triggerAmbulanceSOS(context);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst("Exception: ", ""),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ElderBottomNav(
        activeTab: ElderTab.home,
        onHome: () {},
        onSos: () async {
          try {
            await SOSService.triggerSOSAndCall(triggerTypeId: 1);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst("Exception: ", "")),
              ),
            );
          }
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
              color: Colors.black.withValues(alpha: 0.08),
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
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 34,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 17),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: fg,
                fontSize: 20,
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

class _FullWidthActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _FullWidthActionButton({
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
        width: double.infinity,
        height: 72,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 30,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: fg,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}