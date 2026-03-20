import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../core/network/dio_client.dart';
import '../../core/session/elder_session_manager.dart';
import '../../core/notifications/elder_fcm_manager.dart';

class ElderAuthService {
  static final Dio _dio = DioClient.dio;

  static Future<String> _getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.model ?? "unknown";
  }

  static String _formatOffset(Duration offset) {
    final totalMinutes = offset.inMinutes;
    final sign = totalMinutes >= 0 ? "+" : "-";
    final absMinutes = totalMinutes.abs();
    final hh = (absMinutes ~/ 60).toString().padLeft(2, "0");
    final mm = (absMinutes % 60).toString().padLeft(2, "0");
    return "$sign$hh:$mm"; // ex: +05:30
  }

  static Exception _handleError(DioException e) {
    final responseData = e.response?.data;
    if (responseData != null && responseData["detail"] != null) {
      if (responseData["detail"] is List) {
        final error = responseData["detail"][0];
        final field = error["loc"][1];
        final message = error["msg"];
        return Exception('$field: $message');
      } else {
        return Exception(responseData["detail"].toString());
      }
    }
    return Exception("Request failed");
  }

  static Future<Map<String, dynamic>> loginElder({
    required String email,
    required String password,
  }) async {
    try {
      final fcmToken = await ElderFCMManager.initAndGetToken();
      const appType = "elder";
      final deviceModel = await _getDeviceModel();

      final now = DateTime.now();
      final tzName = now.timeZoneName; // ex: "IST" (varies)
      final tzOffset = _formatOffset(now.timeZoneOffset); // ex: "+05:30"

      // await ElderSessionManager.saveAppType(appType);
      // await ElderSessionManager.saveDeviceModel(deviceModel);
     // await ElderSessionManager.saveTimezone("$tzName $tzOffset"); // store readable

      final response = await _dio.post(
        "/api/v1/elder/elder/login",
        data: {
          "email": email,
          "password": password,
          "fcm_token": fcmToken ?? "",
          "app_type": appType,
          "device_model": deviceModel,
          "timezone_name": tzName,
          "timezone_offset": tzOffset,
        },
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      final data = Map<String, dynamic>.from(response.data);

      await ElderSessionManager.saveLoginResponse(data);
      await ElderSessionManager.debugPrintAll(); // dev dump

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}