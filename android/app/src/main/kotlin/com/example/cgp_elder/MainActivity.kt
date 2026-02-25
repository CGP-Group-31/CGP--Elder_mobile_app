package com.example.cgp_elder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.cgp_elder.alarm.AlarmPayload
import com.example.cgp_elder.alarm.AlarmScheduler

class MainActivity : FlutterActivity() {
    private val CHANNEL = "elder_alarm_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startAlarm") {
                    val args = call.arguments as Map<*, *>

                    val payload = AlarmPayload(
                        scheduleId = (args["scheduleId"] as Number).toInt(),
                        elderId = (args["elderId"] as Number).toInt(),
                        scheduledFor = args["scheduledFor"].toString(),
                        medicationName = args["medicationName"].toString(),
                        dosage = args["dosage"].toString(),
                        instructions = args["instructions"].toString(),
                        durationSec = (args["durationSec"] as Number).toInt()
                    )

                    AlarmScheduler.scheduleNow(this, payload)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }
}