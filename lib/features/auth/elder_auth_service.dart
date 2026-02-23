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

  /// LOGIN elder
  /// POST /api/v1/elder/elder/login
  static Future<Map<String, dynamic>> loginElder({
    required String email,
    required String password,
  }) async {
    try {
      final fcmToken = await ElderFCMManager.initAndGetToken();
      const appType = "elder";
      final deviceModel = await _getDeviceModel();

      // store meta early (useful for later sync)
      await ElderSessionManager.saveAppType(appType);
      await ElderSessionManager.saveDeviceModel(deviceModel);

      final response = await _dio.post(
        "/api/v1/elder/elder/login",
        data: {
          "email": email,
          "password": password,
          "fcm_token": fcmToken ?? "",
          "app_type": appType,
          "device_model": deviceModel,
        },
      );

      final data = Map<String, dynamic>.from(response.data);

      // Expected response:
      // {
      //   "user_id": 0,
      //   "role_id": 0,
      //   "full_name": "...",
      //   "email": "...",
      //   "phone": "...",
      //   "address": "...",
      //   "date_of_birth": "YYYY-MM-DD",
      //   "gender": "...",
      //   "created_at": "..."
      // }

      final userId = data["user_id"];
      final roleId = data["role_id"];

      if (userId is int) {
        await ElderSessionManager.saveElderUserId(userId);
      } else {
        // if backend sends string, handle it
        final parsed = int.tryParse(userId?.toString() ?? "");
        if (parsed != null) await ElderSessionManager.saveElderUserId(parsed);
      }

      if (roleId is int) {
        await ElderSessionManager.saveRoleId(roleId);
      } else {
        final parsed = int.tryParse(roleId?.toString() ?? "");
        if (parsed != null) await ElderSessionManager.saveRoleId(parsed);
      }

      await ElderSessionManager.saveProfile(
        fullName: (data["full_name"] ?? "").toString(),
        email: (data["email"] ?? "").toString(),
        phone: (data["phone"] ?? "").toString(),
        address: (data["address"] ?? "").toString(),
        dateOfBirth: (data["date_of_birth"] ?? "").toString(),
        gender: (data["gender"] ?? "").toString(),
      );

      // Optional: sync token after successful login
      final savedToken = await ElderSessionManager.getFCMToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        await ElderFCMManager.syncTokenToBackend(savedToken);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}