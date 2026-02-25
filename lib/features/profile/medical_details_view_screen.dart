import 'package:flutter/material.dart';
import '../theme.dart';

class MedicalDetailsViewScreen extends StatelessWidget {
  const MedicalDetailsViewScreen({super.key});

  // Same font sizes as Profile
  static const double kLabelSize = 18;
  static const double kValueSize = 19;
  static const double kTitleSize = 22;

  @override
  Widget build(BuildContext context) {
    // Dummy data
    const bloodType = "O+";
    const allergies = "Penicillin, Peanuts";
    const chronic = "Diabetes, Hypertension";
    const notes = "Avoid cold drinks. Monitor sugar daily.";
    const surgeries = "Appendectomy (1995)";
    const doctor = "Dr. Silva (Cardiologist)";

    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Medical Details"),
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

                  // ✅ nice border
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
                    // ✅ Box topic/title
                    Text(
                      "User Medical History",
                      style: TextStyle(
                        fontSize: kTitleSize,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ translucent divider
                    Container(
                      height: 1.2,
                      width: double.infinity,
                      color: AppColors.sectionSeparator.withValues(alpha:0.65),
                    ),
                    const SizedBox(height: 16),

                    const _DetailRow(label: "Blood Type", value: bloodType),
                    const _DetailRow(label: "Allergies", value: allergies),
                    const _DetailRow(
                        label: "Chronic Conditions", value: chronic),
                    const _DetailRow(label: "Important Notes", value: notes),
                    const _DetailRow(label: "Past Surgeries", value: surgeries),
                    const _DetailRow(label: "Preferred Doctor", value: doctor),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  static const double kLabelSize = MedicalDetailsViewScreen.kLabelSize;
  static const double kValueSize = MedicalDetailsViewScreen.kValueSize;

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