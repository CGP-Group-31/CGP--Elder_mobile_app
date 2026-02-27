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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const double kLabelSize = 18;
  static const double kValueSize = 19;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<_ElderProfileDto> _profileFuture;

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

  void _refresh() {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }

  static String _toStr(dynamic v) => (v ?? "").toString().trim();
  static int? _toInt(dynamic v) => int.tryParse((v ?? "").toString());
  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    final s = (v ?? "").toString().toLowerCase();
    return s == "true" || s == "1";
  }

  String _safe(String v) => v.trim().isEmpty ? "-" : v;

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
        body: FutureBuilder<_ElderProfileDto>(
          future: _profileFuture,
          builder: (context, snap) {
            // Loading
            if (snap.connectionState == ConnectionState.waiting) {
              return const _ProfileLoadingView();
            }

            // Error
            if (snap.hasError) {
              return _ProfileErrorView(
                message: snap.error.toString(),
                onRetry: _refresh,
              );
            }

            final p = snap.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                        _InfoRow(label: "Name", value: _safe(p.elderFullName)),
                        _InfoRow(label: "Mobile Number", value: _safe(p.phone)),
                        _InfoRow(label: "Date of Birth", value: _safe(p.dob)),
                        _InfoRow(label: "Gender", value: _safe(p.gender)),
                        _InfoRow(label: "Address", value: _safe(p.address)),
                        _InfoRow(label: "Email", value: _safe(p.email)),
                        _InfoRow(
                          label: "Caregiver Name",
                          value: _safe(p.caregiverFullName),
                        ),
                        _InfoRow(
                          label: "Relationship",
                          value: _safe(p.relationshipType),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 1.15,
                    ),
                    children: [
                      _ActionTile(
                        title: "Medical\nDetails",
                        icon: Icons.medical_information_rounded,
                        bg: AppColors.alertNonCritical,
                        onTap: () => _open(context, const MedicalDetailsViewScreen()),
                      ),
                      _ActionTile(
                        title: "Vitals",
                        icon: Icons.monitor_heart_rounded,
                        bg: AppColors.primary,
                        onTap: () => _open(context, const VitalsViewScreen()),
                        textColor: Colors.white,
                        iconColor: AppColors.primaryText,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
// DTO Model
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

  _ElderProfileDto({
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
// UI Pieces
// --------------------------
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  static const double kLabelSize = ProfileScreen.kLabelSize;
  static const double kValueSize = ProfileScreen.kValueSize;

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                fontSize: kValueSize,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bg;
  final VoidCallback onTap;

  final Color? textColor;
  final Color? iconColor;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.bg,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color tColor = textColor ?? AppColors.primaryText;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 34,
                color: iconColor ?? AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: tColor,
                  height: 1.12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------
// Loading / Error Views
// --------------------------
class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.emergencyBackground, width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Could not load profile",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.descriptionText,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}