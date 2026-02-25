import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'features/splash/splash_screen.dart';
import 'core/alarm/native_alarm_bridge.dart';
import 'core/notifications/elder_fcm_manager.dart'; // adjust import path to your file

/// MUST be top-level for background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _handleIncomingMessage(message);
}

/// Shared handler used by foreground + background
Future<void> _handleIncomingMessage(RemoteMessage message) async {
  final data = message.data;

  // Only handle medication reminder messages
  if ((data["type"] ?? "") != "MED_REMINDER") return;

  // These must be included in backend data payload
  final scheduleId = int.parse(data["scheduleId"].toString());
  final elderId = int.parse(data["elderId"].toString());
  final scheduledFor = data["scheduledFor"].toString();

  final medicationName = data["medicationName"]?.toString() ?? "Medicine";
  final dosage = data["dosage"]?.toString() ?? "";
  final instructions = data["instructions"]?.toString() ?? "";
  final durationSec =
      int.tryParse((data["durationSec"] ?? "60").toString()) ?? 60;

  // Trigger native alarm fullscreen activity
  await NativeAlarmBridge.startAlarm(
    scheduleId: scheduleId,
    elderId: elderId,
    scheduledFor: scheduledFor,
    medicationName: medicationName,
    dosage: dosage,
    instructions: instructions,
    durationSec: durationSec,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Token + permission + refresh sync
  await ElderFCMManager.initAndGetToken();

  // Background handler (terminated/background)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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