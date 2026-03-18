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

  // Channels
  static const String medChannelId = "med_reminders";
  static const String medChannelName = "Medication Reminders";
  static const String medChannelDesc = "High priority medication reminders";

  static const String apptChannelId = "appt_reminders";
  static const String apptChannelName = "Appointment Reminders";
  static const String apptChannelDesc = "Doctor appointment reminders";

  static const String hydrationChannelId = "hydration_reminders";
  static const String hydrationChannelName = "Hydration Reminders";
  static const String hydrationChannelDesc = "Drink water reminders";

  static const String mealChannelId = "meal_reminders";
  static const String mealChannelName = "Meal Reminders";
  static const String mealChannelDesc = "Breakfast/Lunch/Dinner reminders";

  static const String checkingChannelId = "daily_checking_reminders";
  static const String checkingChannelName = "Daily AI Check-In Reminders";
  static const String checkingChannelDesc = "Morning and evening AI daily check-in reminders";

  static bool _inited = false;

  /// Call once at startup + inside background handler
  static Future<void> init() async {
    if (_inited) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
      _onNotificationResponseBackground,
    );

    const AndroidNotificationChannel medChannel = AndroidNotificationChannel(
      medChannelId,
      medChannelName,
      description: medChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel apptChannel = AndroidNotificationChannel(
      apptChannelId,
      apptChannelName,
      description: apptChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel hydrationChannel =
    AndroidNotificationChannel(
      hydrationChannelId,
      hydrationChannelName,
      description: hydrationChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel mealChannel = AndroidNotificationChannel(
      mealChannelId,
      mealChannelName,
      description: mealChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel checkingChannel =
    AndroidNotificationChannel(
      checkingChannelId,
      checkingChannelName,
      description: checkingChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin =
    _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(medChannel);
    await androidPlugin?.createNotificationChannel(apptChannel);
    await androidPlugin?.createNotificationChannel(hydrationChannel);
    await androidPlugin?.createNotificationChannel(mealChannel);
    await androidPlugin?.createNotificationChannel(checkingChannel);

    _inited = true;
  }

  static String _readTitle(Map<String, dynamic> d, String fallback) {
    final value = d["title"]?.toString().trim() ?? "";
    return value.isNotEmpty ? value : fallback;
  }

  static String _readBody(Map<String, dynamic> d, String fallback) {
    final value = d["body"]?.toString().trim() ?? "";
    return value.isNotEmpty ? value : fallback;
  }

  // Appointment notification
  static Future<void> showAppointmentNotificationFromMessage(
      RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "APPT_REMINDER") return;

    final reminderType = d["reminderType"]?.toString() ?? "";
    final doctorName = d["doctorName"]?.toString() ?? "-";
    final location = d["location"]?.toString() ?? "-";
    final date = d["appointmentDate"]?.toString() ?? "";
    final rawTime = d["appointmentTime"]?.toString() ?? "";
    final time = rawTime.length >= 5 ? rawTime.substring(0, 5) : rawTime;

    final whenText = reminderType == "24H"
        ? "Tomorrow"
        : reminderType == "6H"
        ? "In 6 hours"
        : "Upcoming";

    final notifTitle =
    (d["title"]?.toString().trim().isNotEmpty == true)
        ? d["title"].toString()
        : "Appointment Reminder";

    final notifBody =
    (d["body"]?.toString().trim().isNotEmpty == true)
        ? d["body"].toString()
        : "$whenText • $date $time\nDoctor: $doctorName\nPlace: $location";

    final payload = jsonEncode({
      "type": "APPT_REMINDER",
      "appointmentId": d["appointmentId"]?.toString() ?? "",
      "elderId": d["elderId"]?.toString() ?? "",
    });

    final androidDetails = AndroidNotificationDetails(
      apptChannelId,
      apptChannelName,
      channelDescription: apptChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(""),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notifTitle,
      notifBody,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // Medication fallback notification with TAKEN button
  static Future<void> showFallbackNotificationFromMessage(
      RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "MED_REMINDER") return;

    final scheduleId = d["scheduleId"]?.toString() ?? "";
    final elderId = d["elderId"]?.toString() ?? "";
    final scheduledFor = d["scheduledFor"]?.toString() ?? "";

    final medicationName = d["medicationName"]?.toString() ?? "Medicine";
    final dosage = d["dosage"]?.toString() ?? "";
    final instructions = d["instructions"]?.toString() ?? "";

    final title = _readTitle(d, "Medicine Reminder");
    final body = _readBody(
      d,
      _buildMedBody(
        medicationName: medicationName,
        dosage: dosage,
        instructions: instructions,
      ),
    );

    final payload = jsonEncode({
      "type": "MED_REMINDER",
      "scheduleId": scheduleId,
      "elderId": elderId,
      "scheduledFor": scheduledFor,
    });

    final androidDetails = AndroidNotificationDetails(
      medChannelId,
      medChannelName,
      channelDescription: medChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound("med_alarm"),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 700, 400, 700, 400, 900]),
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
      styleInformation: const BigTextStyleInformation(""),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  static String _buildMedBody({
    required String medicationName,
    required String dosage,
    required String instructions,
  }) {
    final doseText = dosage.trim().isEmpty ? "-" : dosage.trim();
    final insText = instructions.trim().isEmpty
        ? "Follow your normal instructions."
        : instructions.trim();
    return "$medicationName\nDose: $doseText\n$insText";
  }

  // Hydration notification
  static Future<void> showHydrationNotificationFromMessage(
      RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "HYDRATION_REMINDER") return;

    final title = _readTitle(d, "Hydration Reminder");
    final body = _readBody(
      d,
      "Time to drink some water \nTake a few sips now.",
    );

    final payload = jsonEncode({
      "type": "HYDRATION_REMINDER",
    });

    final androidDetails = AndroidNotificationDetails(
      hydrationChannelId,
      hydrationChannelName,
      channelDescription: hydrationChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 400, 250, 400]),
      styleInformation: const BigTextStyleInformation(""),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // Meal notification
  static Future<void> showMealNotificationFromMessage(
      RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "MEAL_REMINDER") return;

    final mealTime = (d["mealTime"]?.toString() ?? "").toUpperCase();
    final elderId = d["elderId"]?.toString() ?? "";
    final scheduledFor = d["scheduledFor"]?.toString() ?? "";

    String fallbackTitle;
    switch (mealTime) {
      case "BREAKFAST":
        fallbackTitle = "Breakfast Reminder";
        break;
      case "LUNCH":
        fallbackTitle = "Lunch Reminder";
        break;
      case "DINNER":
        fallbackTitle = "Dinner Reminder";
        break;
      default:
        fallbackTitle = "Meal Reminder";
    }

    final fallbackBody =
        "Please open the app and update your meal status.\n(Taken / Missed + Diet)";

    final title = _readTitle(d, fallbackTitle);
    final body = _readBody(d, fallbackBody);

    final payload = jsonEncode({
      "type": "MEAL_REMINDER",
      "elderId": elderId,
      "mealTime": mealTime,
      "scheduledFor": scheduledFor,
    });

    final androidDetails = AndroidNotificationDetails(
      mealChannelId,
      mealChannelName,
      channelDescription: mealChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(""),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // Daily AI checking notification
  static Future<void> showDailyCheckingNotificationFromMessage(
      RemoteMessage message) async {
    await init();

    final d = message.data;
    if ((d["type"] ?? "") != "DAILY_CHECKING_REMINDER") return;

    final session = (d["session"]?.toString() ?? "").toUpperCase();

    String fallbackTitle;
    String fallbackBody;
 // backend meesage is working, no need this
    if (session == "MORNING") {
      fallbackTitle = "Morning AI Check-In";
      fallbackBody =
      "Good morning. Your AI daily check-in has started now and will be open until 11:50 AM. Please share how you are feeling";
    } else {
      fallbackTitle = "Evening AI Check-In";
      fallbackBody =
      "Good afternoon. Your AI daily check-in has started now and will be open until 11:50 PM. Please share your day with your AI companion and complete your daily behavior form.";
    }

    final title = _readTitle(d, fallbackTitle);
    final body = _readBody(d, fallbackBody);

    final payload = jsonEncode({
      "type": "DAILY_CHECKING_REMINDER",
      "userId": d["userId"]?.toString() ?? "",
      "session": d["session"]?.toString() ?? "",
      "localTime": d["localTime"]?.toString() ?? "",
      "localDate": d["localDate"]?.toString() ?? "",
    });

    final androidDetails = AndroidNotificationDetails(
      checkingChannelId,
      checkingChannelName,
      channelDescription: checkingChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: const BigTextStyleInformation(""),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  // Notification tap / actions
  static Future<void> _onNotificationResponse(
      NotificationResponse response) async {
    await _handleResponse(response);
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationResponseBackground(
      NotificationResponse response) async {
    await _handleResponse(response);
  }

  static Future<void> _handleResponse(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    final decoded = jsonDecode(payload);
    final type = decoded["type"]?.toString() ?? "";

    if (type == "MED_REMINDER" && response.actionId == "TAKEN_ACTION") {
      await _markMedTaken(
        decoded["scheduleId"],
        decoded["elderId"],
        decoded["scheduledFor"],
      );
      return;
    }

    if (type == "MED_REMINDER" && response.actionId == "DISMISS_ACTION") {
      return;
    }

    _lastPayload = decoded;
  }

  static Map<String, dynamic>? _lastPayload;

  static Map<String, dynamic>? consumeLastPayload() {
    final p = _lastPayload;
    _lastPayload = null;
    return p;
  }

  static Future<void> _markMedTaken(
      dynamic scheduleId, dynamic elderId, dynamic scheduledFor) async {
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
    } catch (_) {}
  }
}