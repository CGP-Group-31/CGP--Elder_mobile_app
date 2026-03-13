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
import '../auth/login_screen.dart';


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

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.sectionSeparator.withValues(alpha: 0.9),
                width: 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: AppColors.emergencyBackground,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.logout_rounded,
                    size: 34,
                    color: AppColors.sosButton,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: AppColors.descriptionText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "You can log in again anytime.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textShade,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryText,
                            side: BorderSide(
                              color: AppColors.sectionSeparator,
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sosButton,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text("Log out"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldLogout == true) {
      await ElderSessionManager.logout();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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

  String _initialsFromName(String name) {
    final clean = name.trim();
    if (clean.isEmpty || clean == _errPlaceholder) {
      return "U";
    }

    final parts = clean
        .split(RegExp(r'\s+'))
        .where((e) => e.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return "U";
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return "${parts.first[0]}${parts.last[0]}".toUpperCase();
  }

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

              final initials = _initialsFromName(p.elderFullName);

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 130),
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
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
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
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
                            onTap: () => _open(context, const VitalsShowPage()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
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
                          elevation: 0,
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
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: tColor,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}