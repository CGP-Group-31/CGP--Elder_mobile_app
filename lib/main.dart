import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/notifications/elder_notification_service.dart';
import 'features/splash/splash_screen.dart'; // your first page

/// Background handler MUST be top-level (outside any class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await ElderNotificationService.init();
  await ElderNotificationService.showMedicationAlertFromMessage(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// init local notifications (channel, actions, full screen)
  await ElderNotificationService.init();

  ///  register background handler (works when app is closed/background)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  ///  foreground messages (app open)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await ElderNotificationService.showMedicationAlertFromMessage(message);
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elder App',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}