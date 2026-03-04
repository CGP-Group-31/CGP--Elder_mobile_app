import 'package:dio/dio.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';

class AmbulanceSOSService {
  static final Dio _dio = DioClient.dio;

  static const String _ambulanceNumber = "119191";

  static Future<void> triggerAmbulanceSOS() async {
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