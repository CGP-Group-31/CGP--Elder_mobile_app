import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../sos/sos_screen.dart';

import 'medical_details_view_screen.dart';
import 'vitals_view_screen.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

// ✅ CHANGE THIS IMPORT PATH IF YOUR WELCOME SCREEN IS IN A DIFFERENT FOLDER
import '../auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const double kLabelSize = 18;
  static const double kValueSize = 19;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ElderProfileDto> _profileFuture;

  static const String _errPlaceholder = "Unable to fetch data";

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _refresh() {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  // ✅ Elder-friendly logout confirm dialog
  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.sosButton, size: 28),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Log out?",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to log out?\n\nYou will need to log in again to use the app.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: AppColors.textShade.withValues(alpha: 0.7),
                        width: 1.3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sosButton,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Log out",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await ElderSessionManager.logout();
      if (!mounted) return;

      // ✅ go back to welcome/login flow and remove all previous pages
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (_) => false,
      );
    }
  }

  Future<_ElderProfileDto> _fetchProfile() async {
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) {
      throw Exception("No elder_id found in session. Please login again.");
    }

    try {
      final res = await DioClient.dio.get("/api/v1/elder/elder-profile/$elderId");

      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data)
          : <String, dynamic>{};

      final caregiverRaw = (data["caregiver"] is Map)
          ? Map<String, dynamic>.from(data["caregiver"])
          : <String, dynamic>{};

      return _ElderProfileDto(
        userId: _toInt(data["UserID"]),
        elderFullName: _toStr(data["ElderFullName"]),
        email: _toStr(data["Email"]),
        phone: _toStr(data["Phone"]),
        dob: _toStr(data["DateOfBirth"]),
        address: _toStr(data["Address"]),
        gender: _toStr(data["Gender"]),
        caregiverId: _toInt(caregiverRaw["CaregiverID"]),
        caregiverFullName: _toStr(caregiverRaw["CaregiverFullName"]),
        relationshipType: _toStr(caregiverRaw["RelationshipType"]),
        isPrimary: _toBool(caregiverRaw["IsPrimary"]),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch elder profile");
    }
  }

  static String _toStr(dynamic v) => (v ?? "").toString().trim();
  static int? _toInt(dynamic v) => int.tryParse((v ?? "").toString());
  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    final s = (v ?? "").toString().toLowerCase();
    return s == "true" || s == "1";
  }

  String _safe(String v) => v.trim().isEmpty ? "-" : v;
  bool _isErrorValue(String v) => v == _errPlaceholder;

  _ElderProfileDto _fallbackDto() {
    return const _ElderProfileDto(
      userId: null,
      elderFullName: _errPlaceholder,
      email: _errPlaceholder,
      phone: _errPlaceholder,
      dob: _errPlaceholder,
      address: _errPlaceholder,
      gender: _errPlaceholder,
      caregiverId: null,
      caregiverFullName: _errPlaceholder,
      relationshipType: _errPlaceholder,
      isPrimary: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => _goHome(context),
      child: Scaffold(
        backgroundColor: AppColors.mainBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text("Profile"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _goHome(context),
          ),
          actions: [
            IconButton(
              tooltip: "Refresh",
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder<_ElderProfileDto>(
            future: _profileFuture,
            builder: (context, snap) {
              final bool isLoading = snap.connectionState == ConnectionState.waiting;
              final bool isError = snap.hasError;

              final p = (!isLoading && !isError && snap.data != null)
                  ? snap.data!
                  : _fallbackDto();

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 130), // ✅ extra bottom space for navbar
                child: Column(
                  children: [
                    // Profile icon
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_rounded,
                        size: 60,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Error hint (UI still visible)
                    if (isError)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyBackground.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.sosButton.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.sosButton.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Could not load profile right now. Showing placeholders.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),

                    // Details card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.sectionSeparator.withValues(alpha: 0.7),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _InfoRow(label: "Name", value: _safe(p.elderFullName), isPlaceholder: _isErrorValue(p.elderFullName)),
                          _InfoRow(label: "Mobile Number", value: _safe(p.phone), isPlaceholder: _isErrorValue(p.phone)),
                          _InfoRow(label: "Date of Birth", value: _safe(p.dob), isPlaceholder: _isErrorValue(p.dob)),
                          _InfoRow(label: "Gender", value: _safe(p.gender), isPlaceholder: _isErrorValue(p.gender)),
                          _InfoRow(label: "Address", value: _safe(p.address), isPlaceholder: _isErrorValue(p.address)),
                          _InfoRow(label: "Email", value: _safe(p.email), isPlaceholder: _isErrorValue(p.email)),
                          _InfoRow(label: "Caregiver Name", value: _safe(p.caregiverFullName), isPlaceholder: _isErrorValue(p.caregiverFullName)),
                          _InfoRow(label: "Relationship", value: _safe(p.relationshipType), isPlaceholder: _isErrorValue(p.relationshipType)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ✅ Bigger tiles + text only
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTileTextOnly(
                            title: "Medical\nDetails",
                            bg: AppColors.alertNonCritical,
                            onTap: () => _open(context, const MedicalDetailsViewScreen()),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _ActionTileTextOnly(
                            title: "Vitals",
                            bg: AppColors.primary,
                            textColor: Colors.white,
                            onTap: () => _open(context, const VitalsViewScreen()),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ✅ Logout button (not covered by navbar)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded, size: 22),
                        label: const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sosButton,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          color: AppColors.primary,
                          backgroundColor: AppColors.sectionSeparator.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        bottomNavigationBar: ElderBottomNav(
          activeTab: ElderTab.profile,
          onHome: () => _goHome(context),
          onSos: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SosScreen()),
            );
          },
          onProfile: () {},
        ),
      ),
    );
  }
}

// --------------------------
// DTO
// --------------------------
class _ElderProfileDto {
  final int? userId;
  final String elderFullName;
  final String email;
  final String phone;
  final String dob;
  final String address;
  final String gender;

  final int? caregiverId;
  final String caregiverFullName;
  final String relationshipType;
  final bool? isPrimary;

  const _ElderProfileDto({
    required this.userId,
    required this.elderFullName,
    required this.email,
    required this.phone,
    required this.dob,
    required this.address,
    required this.gender,
    required this.caregiverId,
    required this.caregiverFullName,
    required this.relationshipType,
    required this.isPrimary,
  });
}

// --------------------------
// Info Row
// --------------------------
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPlaceholder;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPlaceholder = false,
  });

  static const double kLabelSize = ProfileScreen.kLabelSize;
  static const double kValueSize = ProfileScreen.kValueSize;

  @override
  Widget build(BuildContext context) {
    final valueStyle = TextStyle(
      fontSize: kValueSize,
      fontWeight: FontWeight.w900,
      color: isPlaceholder
          ? AppColors.primaryText.withValues(alpha: 0.45)
          : AppColors.primaryText,
      height: 1.2,
      fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: kLabelSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textShade,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: valueStyle,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------
// Action Tile Text-only (Bigger)
// --------------------------
class _ActionTileTextOnly extends StatelessWidget {
  final String title;
  final Color bg;
  final Color? textColor;
  final VoidCallback onTap;

  const _ActionTileTextOnly({
    required this.title,
    required this.bg,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color tColor = textColor ?? AppColors.primaryText;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21, // ✅ bigger
            fontWeight: FontWeight.w900,
            color: tColor,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}