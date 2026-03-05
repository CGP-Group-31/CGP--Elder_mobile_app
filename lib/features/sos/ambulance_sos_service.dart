import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';
import '../../features/theme.dart';

class AmbulanceSOSService {
  static final Dio _dio = DioClient.dio;

  static const String _ambulanceNumber = "119191";

  static Future<void> triggerAmbulanceSOS(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.emergencyBackground.withValues(alpha: 0.95),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.emergencyBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 34,
                    color: AppColors.sosButton,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Confirm ambulance call",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Do you want to call an ambulance now?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: AppColors.descriptionText,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryText,
                            side: BorderSide(
                              color: AppColors.sectionSeparator.withValues(alpha: 0.9),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.sosButton,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          child: const Text("Call Ambulance"),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final elderId = await ElderSessionManager.getElderUserId();
    final relationshipId = await ElderSessionManager.getRelationshipId();

    if (elderId == null) {
      throw Exception("elder_id not found. Please login again.");
    }

    if (relationshipId == null) {
      throw Exception("relationship_id not found.");
    }

    //  Log to backend first
    final res = await _dio.post(
      "/api/v1/elder/sos/trigger",
      data: {
        "elder_id": elderId,
        "relationship_id": relationshipId,
        "trigger_type_id": 2,
      },
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    final data = res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    if (data["status"] != "ok") {
      throw Exception("SOS log failed.");
    }

    //  Request call permission
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      throw Exception("Phone permission denied.");
    }

    //  Direct call ambulance
    final bool? called =
    await FlutterPhoneDirectCaller.callNumber(_ambulanceNumber);

    if (called != true) {
      throw Exception("Ambulance call failed.");
    }
  }
}