import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/splash/splash_screen.dart';
import 'features/reminders/meals_reminder_screen.dart';
import 'core/alarm/native_alarm_bridge.dart';
import 'core/notifications/elder_fcm_manager.dart';
import 'core/notifications/elder_notification_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

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

  if (type == "APPT_REMINDER") {
    await ElderNotificationService.showAppointmentNotificationFromMessage(
      message,
    );
    return;
  }

  if (type == "HYDRATION_REMINDER") {
    await ElderNotificationService.showHydrationNotificationFromMessage(
      message,
    );
    return;
  }

  if (type == "MEAL_REMINDER") {
    await ElderNotificationService.showMealNotificationFromMessage(message);
    return;
  }

  if (type == "DAILY_CHECKING_REMINDER") {
    await ElderNotificationService.showDailyCheckingNotificationFromMessage(
      message,
    );
    return;
  }
}

void _openMealPageFromMessage(RemoteMessage message) {
  final data = message.data;
  final type = data["type"] ?? "";

  if (type != "MEAL_REMINDER") return;

  final mealTime = data["mealTime"]?.toString();
  final scheduledFor = data["scheduledFor"]?.toString();

  Future.delayed(const Duration(milliseconds: 300), () {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => MealsReminderScreen(
          initialMealTime: mealTime,
          initialScheduledFor: scheduledFor,
        ),
      ),
    );
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await ElderNotificationService.init();
  await ElderFCMManager.initAndGetToken();

  // foreground messages
  FirebaseMessaging.onMessage.listen((message) async {
    await _handleIncomingMessage(message);
  });

  // app opened from background notification tap
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _openMealPageFromMessage(message);
  });

  // app opened from terminated state by notification tap
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  runApp(const MyApp());

  if (initialMessage != null) {
    _openMealPageFromMessage(initialMessage);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}