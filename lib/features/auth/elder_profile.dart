import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart'; // Uses your AppColors

class ElderProfileScreen extends StatelessWidget {
  const ElderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      body: Stack(
        children: [
          /// 1. TOP DECORATIVE GRADIENT
          Positioned(
            top: -100,
            right: -50,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),

          CustomScrollView(
            slivers: [
              /// PREMIUM SLIVER APP BAR
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                backgroundColor: AppColors.mainBackground.withOpacity(0.8),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryText, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: const Text(
                  "ELDER PROFILE",
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      /// SECTION A: PREMIUM ELDER SUMMARY CARD [cite: 28]
                      _buildPremiumProfileCard(),

                      const SizedBox(height: 40),

                      /// SECTION B: THE THREE NAV BUTTONS [cite: 33]
                      _buildPremiumNavTile(
                        context,
                        title: "Health Details",
                        description: "Vitals, History & Meds",
                        icon: Icons.favorite_outline_rounded,
                        onTap: () {},
                      ),
                      _buildPremiumNavTile(
                        context,
                        title: "Weekly Reports",
                        description: "AI Health Analysis",
                        icon: Icons.auto_graph_rounded,
                        onTap: () {},
                      ),
                      _buildPremiumNavTile(
                        context,
                        title: "Location",
                        description: "Live Tracking & History",
                        icon: Icons.near_me_outlined,
                        onTap: () {},
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // User Avatar with "Premium Glow"
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary,
              child: Text(
                "JD", // [cite: 29]
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "John Doe", // [cite: 29]
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryText),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.mainBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Father • 75 Years", // [cite: 29, 31]
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),

          // Address Info with Edit Trigger [cite: 30, 32]
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FBFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "123 Healthcare Ave, NY", // [cite: 30]
                    style: TextStyle(color: AppColors.descriptionText, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () {}, // Edit pop-up [cite: 32]
                  child: const Text(
                    "EDIT",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumNavTile(BuildContext context,
      {required String title, required String description, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primaryText, letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: AppColors.descriptionText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textShade),
            ],
          ),
        ),
      ),
    );
  }
}