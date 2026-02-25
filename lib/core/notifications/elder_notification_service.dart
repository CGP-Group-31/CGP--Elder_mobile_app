import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/dio_client.dart';

class ElderNotificationService {
  ElderNotificationService._();

  static final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();

  static const String channelId = "med_reminders";
  static const String channelName = "Medication Reminders";
  static const String channelDesc = "High priority medication reminders";

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: _onNotificationResponseBackground,
    );

    const AndroidNotificationChannel androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDesc,
      importance: Importance.max,
    );

    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showMedicationAlertFromMessage(RemoteMessage message) async {
    final data = message.data;

    final title = message.notification?.title ?? "Medicine Reminder";
    final body = message.notification?.body ?? "";

    final payload = jsonEncode({
      "type": data["type"] ?? "MED_REMINDER",
      "scheduleId": data["scheduleId"] ?? "",
      "elderId": data["elderId"] ?? "",
      "scheduledFor": data["scheduledFor"] ?? "",
    });

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,

      importance: Importance.max,
      priority: Priority.high,

      // Full screen (alarm-like)
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,

      // Sound + vibration
      playSound: true,
      sound: const RawResourceAndroidNotificationSound("med_alarm"),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1500]),

      // Keep until user interacts (optional)
      ongoing: true,
      autoCancel: false,

      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'TAKEN_ACTION',
          'TAKEN',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        const AndroidNotificationAction(
          'SNOOZE_ACTION',
          'SNOOZE',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    // ✅ must be int
    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _local.show(id, title, body, details, payload: payload);
  }

  static Future<void> _onNotificationResponse(NotificationResponse response) async {
    await _handleResponse(response);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationResponseBackground(NotificationResponse response) async {
    await _handleResponse(response);
  }

  static Future<void> _handleResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final decoded = jsonDecode(payload);
    final scheduleId = decoded["scheduleId"];
    final elderId = decoded["elderId"];
    final scheduledFor = decoded["scheduledFor"];

    if (response.actionId == "TAKEN_ACTION") {
      await _markTaken(scheduleId, elderId, scheduledFor);
      return;
    }

    if (response.actionId == "SNOOZE_ACTION") {
      // optional: implement snooze later
      return;
    }

    // Normal tap: you can navigate in UI if needed
  }

  static Future<void> _markTaken(dynamic scheduleId, dynamic elderId, dynamic scheduledFor) async {
    try {
      final dio = DioClient.dio;

      await dio.post(
        "/api/v1/elder/medication-adherence/taken",
        data: {
          "scheduleId": int.parse(scheduleId.toString()),
          "elderId": int.parse(elderId.toString()),
          "scheduledFor": scheduledFor.toString(),
        },
        options: Options(
          headers: {"Content-Type": "application/json"},
        ),
      );
    } catch (_) {
      // keep silent for now
    }
  }
}
