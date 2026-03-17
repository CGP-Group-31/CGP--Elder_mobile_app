import 'package:dio/dio.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class SOSService {
  static final Dio _dio = DioClient.dio;

  static Future<void> triggerSOSAndCall({int triggerTypeId = 1}) async {
    final elderId = await ElderSessionManager.getElderUserId();
    final relationshipId = await ElderSessionManager.getRelationshipId();
    final emergencyPhone = await ElderSessionManager.getEmergencyPhone();

    if (elderId == null) throw Exception("elder_id not found. Login again.");
    if (relationshipId == null) throw Exception("relationship_id not found. Login again.");
    if (emergencyPhone == null || emergencyPhone.trim().isEmpty) {
      throw Exception("Emergency contact number not found.");
    }

    // 1) trigger backend log FIRST
    final res = await _dio.post(
      "/api/v1/elder/sos/trigger",
      data: {
        "elder_id": elderId,
        "relationship_id": relationshipId,
        "trigger_type_id": triggerTypeId,
      },
      options: Options(headers: {"Content-Type": "application/json"}),
    );

    final data = res.data is Map ? Map<String, dynamic>.from(res.data) : {};
    if (data["status"] != "ok") {
      throw Exception("SOS trigger failed.");
    }

    // 2) request CALL permission
    final status = await Permission.phone.request();
    if (!status.isGranted) {
      throw Exception("Phone permission denied.");
    }

    // 3) DIRECT CALL
    final phone = emergencyPhone.trim();
    final bool? called = await FlutterPhoneDirectCaller.callNumber(phone);

    if (called != true) {
      throw Exception("Direct call failed.");
    }
  }
}