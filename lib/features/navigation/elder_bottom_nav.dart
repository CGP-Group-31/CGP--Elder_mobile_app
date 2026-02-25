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
    fontSize: 12,
    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
    color: active ? AppColors.primary : AppColors.textShade,
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: "Home",
              active: activeTab == ElderTab.home,
              iconColor: _iconColor(activeTab == ElderTab.home),
              labelStyle: _labelStyle(activeTab == ElderTab.home),
              onTap: onHome,
            ),

            // SOS (center big button)
            GestureDetector(
              onTap: onSos,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.sosButton,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.sosButton.withValues(alpha:0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  "SOS",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            _NavItem(
              icon: Icons.person_rounded,
              label: "Profile",
              active: activeTab == ElderTab.profile,
              iconColor: _iconColor(activeTab == ElderTab.profile),
              labelStyle: _labelStyle(activeTab == ElderTab.profile),
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
        width: 84,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 4),
            Text(label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}