import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../theme.dart';
import '../../core/session/elder_session_manager.dart';
import '../../core/network/dio_client.dart';

class MedicalDetailsViewScreen extends StatefulWidget {
  const MedicalDetailsViewScreen({super.key});

  @override
  State<MedicalDetailsViewScreen> createState() =>
      _MedicalDetailsViewScreenState();
}

class _MedicalDetailsViewScreenState extends State<MedicalDetailsViewScreen> {
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
      final res = await DioClient.dio
          .get("/api/v1/caregiver/elder/medical-profile/$elderId");

      if (res.data is Map) {
        return Map<String, dynamic>.from(res.data);
      }

      return {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {};
      }
      throw Exception(e.response?.data ?? "Failed to fetch medical profile");
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
            onPressed: () => setState(() => _medicalFuture = _fetchMedical()),
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
                onRetry: () => setState(() => _medicalFuture = _fetchMedical()),
              );
            }

            final data = snap.data ?? {};

            final items = [
              _MedicalItem(title: "Blood Type", value: _safe(data["BloodType"])),
              _MedicalItem(title: "Allergies", value: _safe(data["Allergies"])),
              _MedicalItem(
                title: "Chronic Conditions",
                value: _safe(data["ChronicConditions"]),
              ),
              _MedicalItem(
                title: "Emergency Notes",
                value: _safe(data["EmergencyNotes"]),
              ),
              _MedicalItem(
                title: "Past Surgeries",
                value: _safe(data["PastSurgeries"]),
              ),
              _MedicalItem(
                title: "Preferred Doctor",
                value: _safe(data["DoctorName"]),
              ),
            ];

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _MedicalCard(item: items[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _MedicalItem {
  final String title;
  final String value;

  const _MedicalItem({
    required this.title,
    required this.value,
  });
}

class _MedicalCard extends StatefulWidget {
  final _MedicalItem item;

  const _MedicalCard({
    required this.item,
  });

  @override
  State<_MedicalCard> createState() => _MedicalCardState();
}

class _MedicalCardState extends State<_MedicalCard> {
  bool _expanded = false;

  bool _shouldShowToggle(String text) {
    return text.length > 55 || text.contains('\n');
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmptyValue = widget.item.value == "-";
    final bool showToggle =
        !isEmptyValue && _shouldShowToggle(widget.item.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.containerBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sectionSeparator),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 1.2,
            color: AppColors.sectionSeparator,
          ),
          const SizedBox(height: 12),
          Text(
            widget.item.value,
            textAlign: TextAlign.left,
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: isEmptyValue
                  ? AppColors.descriptionText
                  : AppColors.primaryText,
            ),
          ),
          if (showToggle) ...[
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _expanded ? "Read Less" : "Read More",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
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
          border: Border.all(color: AppColors.emergencyBackground),
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
              style: const TextStyle(
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