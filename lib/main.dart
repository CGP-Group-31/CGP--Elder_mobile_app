import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/splash/splash_screen.dart';
import 'core/alarm/native_alarm_bridge.dart';
import 'core/notifications/elder_fcm_manager.dart';
import 'core/notifications/elder_notification_service.dart';

/// MUST be top-level for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await ElderNotificationService.init();
  await _handleIncomingMessage(message);
}

/// Shared handler used by foreground + background
Future<void> _handleIncomingMessage(RemoteMessage message) async {
  final type = message.data["type"] ?? "";

  // MED: native alarm + fallback notif
  if (type == "MED_REMINDER") {
    final data = message.data;

    final scheduleId = int.tryParse(data["scheduleId"].toString()) ?? 0;
    final elderId = int.tryParse(data["elderId"].toString()) ?? 0;
    final scheduledFor = data["scheduledFor"]?.toString() ?? "";

    final medicationName = data["medicationName"]?.toString() ?? "Medicine";
    final dosage = data["dosage"]?.toString() ?? "";
    final instructions = data["instructions"]?.toString() ?? "";
    final durationSec =
        int.tryParse((data["durationSec"] ?? "60").toString()) ?? 60;

    if (scheduleId == 0 || elderId == 0 || scheduledFor.isEmpty) return;

    await NativeAlarmBridge.startAlarm(
      scheduleId: scheduleId,
      elderId: elderId,
      scheduledFor: scheduledFor,
      medicationName: medicationName,
      dosage: dosage,
      instructions: instructions,
      durationSec: durationSec,
    );

    await ElderNotificationService.showFallbackNotificationFromMessage(message);
    return;
  }

  // Appointment
  if (type == "APPT_REMINDER") {
    await ElderNotificationService.showAppointmentNotificationFromMessage(message);
    return;
  }

  // Hydration
  if (type == "HYDRATION_REMINDER") {
    await ElderNotificationService.showHydrationNotificationFromMessage(message);
    return;
  }

  // Meal
  if (type == "MEAL_REMINDER") {
    await ElderNotificationService.showMealNotificationFromMessage(message);
    return;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // register background handler EARLY
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // init notifications
  await ElderNotificationService.init();

  // token + permission + refresh sync
  await ElderFCMManager.initAndGetToken();

  // Foreground messages
  FirebaseMessaging.onMessage.listen((message) async {
    await _handleIncomingMessage(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}