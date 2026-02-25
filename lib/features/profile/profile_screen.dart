import 'package:flutter/material.dart';
import '../theme.dart';
import '../navigation/elder_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../sos/sos_screen.dart';
import 'medical_details_view_screen.dart';
import 'vitals_view_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Unified elder-friendly text sizes (shared concept across screens)
  static const double kLabelSize = 18;
  static const double kValueSize = 19;

  void _goHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data (replace later with API/session)
    const elderName = "John";
    const mobile = "+94 77 123 4567";
    const dob = "1952-10-12";
    const address = "221B Baker Street, Colombo";
    const caregiverName = "Hesi";
    const relationship = "Son";
    const username = "john_elder";

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
        ),
        body: SingleChildScrollView(
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
                      color: Colors.black.withValues(alpha:0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: 60,
                  color: AppColors.primary.withValues(alpha:0.85),
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
                    color: AppColors.sectionSeparator.withValues(alpha:0.7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    _InfoRow(label: "Name", value: elderName),
                    _InfoRow(label: "Mobile Number", value: mobile),
                    _InfoRow(label: "Date of Birth", value: dob),
                    _InfoRow(label: "Address", value: address),
                    _InfoRow(label: "Caregiver Name", value: caregiverName),
                    _InfoRow(label: "Relationship", value: relationship),
                    _InfoRow(label: "Username", value: username),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Smaller tiles (so we have room for bigger text above)
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 18,
                  childAspectRatio: 1.15, // ✅ smaller/shorter tiles
                ),
                children: [
                  _ActionTile(
                    title: "Medical\nDetails",
                    icon: Icons.medical_information_rounded,
                    bg: AppColors.alertNonCritical,
                    onTap: () =>
                        _open(context, const MedicalDetailsViewScreen()),
                  ),
                  _ActionTile(
                    title: "Vitals",
                    icon: Icons.monitor_heart_rounded,

                    // ✅ More contrast (primary teal) since mint was too close to bg
                    bg: AppColors.primary,

                    onTap: () => _open(context, const VitalsViewScreen()),
                    textColor: Colors.white,
                    iconColor: AppColors.primaryText,
                  ),
                ],
              ),
            ],
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
          // label
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

          // value (wrap-safe)
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
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 14,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14), // ✅ slightly smaller padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, // ✅ smaller icon container
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.78),
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

            // title (overflow-safe)
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