import 'package:flutter/material.dart';
import '../theme.dart';

enum ElderTab { home, sos, profile }

class ElderBottomNav extends StatelessWidget {
  final ElderTab activeTab;
  final VoidCallback onHome;
  final VoidCallback onSos;
  final VoidCallback onProfile;

  const ElderBottomNav({
    super.key,
    required this.activeTab,
    required this.onHome,
    required this.onSos,
    required this.onProfile,
  });

  Color _iconColor(bool active) =>
      active ? AppColors.primary : AppColors.textShade;

  TextStyle _labelStyle(bool active) => TextStyle(
    fontSize: 14, // ✅ bigger label
    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
    color: active ? AppColors.primary : AppColors.textShade,
  );

  @override
  Widget build(BuildContext context) {
    final bool homeActive = activeTab == ElderTab.home;
    final bool profileActive = activeTab == ElderTab.profile;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: "Home",
              active: homeActive,
              iconColor: _iconColor(homeActive),
              labelStyle: _labelStyle(homeActive),
              onTap: onHome,
            ),

            // ✅ SOS: larger center button
            GestureDetector(
              onTap: onSos,
              child: Container(
                width: 72, // ✅ bigger
                height: 72, // ✅ bigger
                decoration: BoxDecoration(
                  color: AppColors.sosButton,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sosButton.withValues(alpha:0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16, // ✅ bigger SOS text
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            _NavItem(
              icon: Icons.person_rounded,
              label: "Profile",
              active: profileActive,
              iconColor: _iconColor(profileActive),
              labelStyle: _labelStyle(profileActive),
              onTap: onProfile,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color iconColor;
  final TextStyle labelStyle;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.iconColor,
    required this.labelStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 92, // ✅ slightly wider to fit bigger text
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32, // ✅ bigger icon
            ),
            const SizedBox(height: 6),
            Text(label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}