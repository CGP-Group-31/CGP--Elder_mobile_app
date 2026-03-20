import 'package:firebase_messaging/firebase_messaging.dart';
import '../session/elder_session_manager.dart';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';

class ElderFCMManager {
  static Future<String?> initAndGetToken() async {
    final messaging = FirebaseMessaging.instance;

    // Android 13+ permission
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // Get token
    final token = await messaging.getToken();
    if (token != null) {
      await ElderSessionManager.saveFCMToken(token);
    }

    // Refresh listener
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await ElderSessionManager.saveFCMToken(newToken);

      // If already logged in, can sync automatically
      final loggedIn = await ElderSessionManager.isLoggedIn();
      if (loggedIn) {
        await syncTokenToBackend(newToken);
      }
    });

    return token;
  }



  static Future<void> syncTokenToBackend(String token) async {
    try {
      final Dio dio = DioClient.dio;
      final elderUserId = await ElderSessionManager.getElderUserId();
      if (elderUserId == null) return;



      await dio.post(
        "/api/v1/elder/elder/fcm",
        data: {
          "user_id": elderUserId,
          "fcm_token": token,
          "app_type": (await ElderSessionManager.getAppType()) ?? "elder",
          "device_model": (await ElderSessionManager.getDeviceModel()) ?? "unknown",
        },
      );
    } catch (_) {
      // Silent fail
    }
  }
}