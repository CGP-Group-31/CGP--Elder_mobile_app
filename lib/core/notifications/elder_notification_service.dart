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

  static bool _inited = false;

  /// Call once at startup + inside background handler
  static Future<void> init() async {
    if (_inited) return;

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
      playSound: true,
      enableVibration: true,
    );

    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _inited = true;
  }

  ///  Use this as fallback notification (if user misses alarm)
  static Future<void> showFallbackNotificationFromMessage(RemoteMessage message) async {
    await init();

    final d = message.data;

    if ((d["type"] ?? "") != "MED_REMINDER") return;

    final scheduleId = d["scheduleId"]?.toString() ?? "";
    final elderId = d["elderId"]?.toString() ?? "";
    final scheduledFor = d["scheduledFor"]?.toString() ?? "";

    final medicationName = d["medicationName"]?.toString() ?? "Medicine";
    final dosage = d["dosage"]?.toString() ?? "";
    final instructions = d["instructions"]?.toString() ?? "";

    //  Human friendly notification text
    final title = "Medicine Reminder";
    final body = _buildBody(
      medicationName: medicationName,
      dosage: dosage,
      instructions: instructions,
    );

    //  Pack everything for button tap
    final payload = jsonEncode({
      "type": "MED_REMINDER",
      "scheduleId": scheduleId,
      "elderId": elderId,
      "scheduledFor": scheduledFor,
    });

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,

      //  make it strong
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,

      playSound: true,
      sound: const RawResourceAndroidNotificationSound("med_alarm"),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 700, 400, 700, 400, 900]),

      // keep until user acts
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
          'DISMISS_ACTION',
          'DISMISS',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    final int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _local.show(id, title, body, details, payload: payload);
  }

  static String _buildBody({
    required String medicationName,
    required String dosage,
    required String instructions,
  }) {
    final doseText = dosage.trim().isEmpty ? "-" : dosage.trim();
    final insText = instructions.trim().isEmpty ? "Follow your normal instructions." : instructions.trim();

    return "$medicationName\nDose: $doseText\n$insText";
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

    if (response.actionId == "DISMISS_ACTION") {
      return;
    }
  }

  /// no auth token in  system, so plain POST
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
        options: Options(headers: {"Content-Type": "application/json"}),
      );
    } catch (_) {
      // silent for now
    }
  }
}