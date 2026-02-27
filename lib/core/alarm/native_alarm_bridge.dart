import 'package:flutter/services.dart';
import '../session/elder_session_manager.dart';

class NativeAlarmBridge {
  static const MethodChannel _channel = MethodChannel("elder_alarm_channel");

  static Future<void> startAlarm({
    required int scheduleId,
    required int elderId,
    required String scheduledFor,
    required String medicationName,
    required String dosage,
    required String instructions,
    int durationSec = 60,
  }) async {
    final fullName = (await ElderSessionManager.getFullName()) ?? "there";

    await _channel.invokeMethod("startAlarm", {
      "scheduleId": scheduleId,
      "elderId": elderId,
      "scheduledFor": scheduledFor,
      "medicationName": medicationName,
      "dosage": dosage,
      "instructions": instructions,
      "durationSec": durationSec,
      "fullName": fullName,
    });
  }
}