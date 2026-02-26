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
  State<MedicalDetailsViewScreen> createState() => _MedicalDetailsViewScreenState();
}

class _MedicalDetailsViewScreenState extends State<MedicalDetailsViewScreen> {
  late Future<dynamic> _medicalFuture;

  @override
  void initState() {
    super.initState();
    _medicalFuture = _fetchMedical();
  }

  Future<dynamic> _fetchMedical() async {
    final elderId = await ElderSessionManager.getElderUserId();
    if (elderId == null) throw Exception("No elder_id found. Please login again.");

    try {
      final res = await DioClient.dio.get("/api/v1/caregiver/elder/medical-profile/$elderId");
      return res.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? "Failed to fetch medical profile");
    }
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
            onPressed: () => setState(() => _medicalFuture = _fetchMedical()),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: FutureBuilder<dynamic>(
              future: _medicalFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return _LoadingCard(title: "User Medical History");
                }
                if (snap.hasError) {
                  return _ErrorCard(
                    title: "User Medical History",
                    message: snap.error.toString(),
                    onRetry: () => setState(() => _medicalFuture = _fetchMedical()),
                  );
                }

                final data = snap.data;
                return _PrettyDataCard(
                  title: "User Medical History",
                  data: data,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PrettyDataCard extends StatelessWidget {
  final String title;
  final dynamic data;

  const _PrettyDataCard({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    final content = _renderDataToWidgets(data);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            title,
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
            color: AppColors.sectionSeparator.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 16),
          ...content,
        ],
      ),
    );
  }

  List<Widget> _renderDataToWidgets(dynamic d) {
    // If backend returns a map with fields -> show rows
    if (d is Map) {
      final map = Map<String, dynamic>.from(d);
      if (map.isEmpty) {
        return [_bigText("-", muted: true)];
      }
      return map.entries.map((e) {
        return _row(e.key.toString(), (e.value ?? "-").toString());
      }).toList();
    }

    // If backend returns a list -> show each item as row
    if (d is List) {
      if (d.isEmpty) return [_bigText("-", muted: true)];
      return d.asMap().entries.map((e) {
        return _row("Item ${e.key + 1}", e.value.toString());
      }).toList();
    }

    // If backend returns a plain string -> show as paragraph
    final text = (d ?? "").toString().trim();
    if (text.isEmpty) return [_bigText("-", muted: true)];
    return [
      _bigText(text),
    ];
  }

  Widget _row(String label, String value) {
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
                fontSize: MedicalDetailsViewScreen.kLabelSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textShade,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              softWrap: true,
              style: TextStyle(
                fontSize: MedicalDetailsViewScreen.kValueSize,
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

  Widget _bigText(String v, {bool muted = false}) {
    return Text(
      v,
      style: TextStyle(
        fontSize: MedicalDetailsViewScreen.kValueSize,
        fontWeight: FontWeight.w900,
        color: muted ? AppColors.descriptionText : AppColors.primaryText,
        height: 1.25,
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final String title;
  const _LoadingCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: MedicalDetailsViewScreen.kTitleSize,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.emergencyBackground, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: MedicalDetailsViewScreen.kTitleSize,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
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
    );
  }
}