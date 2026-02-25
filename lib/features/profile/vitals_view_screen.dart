import 'package:flutter/material.dart';
import '../theme.dart';

class VitalsViewScreen extends StatelessWidget {
  const VitalsViewScreen({super.key});

  // Same font sizes as Profile
  static const double kLabelSize = 18;
  static const double kValueSize = 19;
  static const double kTitleSize = 22;

  @override
  Widget build(BuildContext context) {
    // Dummy data
    const bp = "120/80 mmHg";
    const sugar = "110 mg/dL";
    const heartRate = "72 bpm";
    const weight = "68 kg";
    const hydration = "Good";
    const lastUpdated = "Today, 9:20 AM";

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Vitals"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(22),

                  
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha:0.55),
                    width: 1.6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "User Latest Vitals",
                      style: TextStyle(
                        fontSize: kTitleSize,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),


                    Text(
                      "Last updated: $lastUpdated",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.descriptionText,
                      ),
                    ),
                    const SizedBox(height: 10),


                    Container(
                      height: 1.2,
                      width: double.infinity,
                      color: AppColors.sectionSeparator.withValues(alpha:0.65),
                    ),
                    const SizedBox(height: 16),

                    const _VitalRow(label: "Blood Pressure", value: bp),
                    const _VitalRow(label: "Blood Sugar", value: sugar),
                    const _VitalRow(label: "Heart Rate", value: heartRate),
                    const _VitalRow(label: "Weight", value: weight),
                    const _VitalRow(label: "Hydration", value: hydration),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _VitalRow extends StatelessWidget {
  final String label;
  final String value;

  const _VitalRow({required this.label, required this.value});

  static const double kLabelSize = VitalsViewScreen.kLabelSize;
  static const double kValueSize = VitalsViewScreen.kValueSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 170,
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