import 'package:flutter/services.dart';

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
    await _channel.invokeMethod("startAlarm", {
      "scheduleId": scheduleId,
      "elderId": elderId,
      "scheduledFor": scheduledFor,
      "medicationName": medicationName,
      "dosage": dosage,
      "instructions": instructions,
      "durationSec": durationSec,
    });
  }
}