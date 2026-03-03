import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../theme.dart';
import '../../core/session/elder_session_manager.dart';
import '../../core/network/dio_client.dart';

class MedicalDetailsViewScreen extends StatefulWidget {
  const MedicalDetailsViewScreen({super.key});

  static const double kLabelSize = 18;
  static const double kValueSize = 19;
  static const double kTitleSize = 22;

  @override
  State<MedicalDetailsViewScreen> createState() =>
      _MedicalDetailsViewScreenState();
}

class _MedicalDetailsViewScreenState
    extends State<MedicalDetailsViewScreen> {
  late Future<Map<String, dynamic>> _medicalFuture;

  @override
  void initState() {
    super.initState();
    _medicalFuture = _fetchMedical();
  }

  Future<Map<String, dynamic>> _fetchMedical() async {
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) {
      throw Exception("No elder_id found. Please login again.");
    }

    try {
      final res = await DioClient.dio.get(
          "/api/v1/caregiver/elder/medical-profile/$elderId");

      if (res.data is Map) {
        return Map<String, dynamic>.from(res.data);
      }

      return {};
    } on DioException catch (e) {
      // ✅ If medical record not found → return empty map instead of error
      if (e.response?.statusCode == 404) {
        return {};
      }

      throw Exception(
          e.response?.data ?? "Failed to fetch medical profile");
    }
  }

  String _safe(dynamic v) {
    final s = (v ?? "").toString().trim();
    return s.isEmpty ? "-" : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text("Medical Details"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: () =>
                setState(() => _medicalFuture = _fetchMedical()),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _medicalFuture,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const _LoadingCard();
            }

            if (snap.hasError) {
              return _ErrorCard(
                message: snap.error.toString(),
                onRetry: () =>
                    setState(() => _medicalFuture = _fetchMedical()),
              );
            }

            final data = snap.data ?? {};

            return SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(18, 30, 18, 18),
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 520),
                child: _MedicalCard(
                  bloodType: _safe(data["BloodType"]),
                  allergies: _safe(data["Allergies"]),
                  chronic: _safe(data["ChronicConditions"]),
                  medications: _safe(data["CurrentMedications"]),
                  surgeries: _safe(data["Surgeries"]),
                  notes: _safe(data["Notes"]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MedicalCard extends StatelessWidget {
  final String bloodType;
  final String allergies;
  final String chronic;
  final String medications;
  final String surgeries;
  final String notes;

  const _MedicalCard({
    required this.bloodType,
    required this.allergies,
    required this.chronic,
    required this.medications,
    required this.surgeries,
    required this.notes,
  });

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                fontSize: MedicalDetailsViewScreen.kLabelSize,
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
                fontSize: MedicalDetailsViewScreen.kValueSize,
                fontWeight: FontWeight.w900,
                color: value == "-"
                    ? AppColors.descriptionText
                    : AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.55),
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Medical History",
            style: TextStyle(
              fontSize: MedicalDetailsViewScreen.kTitleSize,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1.2,
            width: double.infinity,
            color: AppColors.sectionSeparator
                .withValues(alpha: 0.65),
          ),
          const SizedBox(height: 18),
          _row("Blood Type", bloodType),
          _row("Allergies", allergies),
          _row("Chronic Conditions", chronic),
          _row("Current Medications", medications),
          _row("Surgeries", surgeries),
          _row("Notes", notes),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: AppColors.emergencyBackground),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Could not load medical profile",
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
                color: AppColors.descriptionText,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}