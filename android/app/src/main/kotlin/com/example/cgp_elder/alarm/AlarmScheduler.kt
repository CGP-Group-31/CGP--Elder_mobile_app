package com.example.cgp_elder.alarm

import android.content.Context
import android.content.Intent

object AlarmScheduler {
    fun scheduleNow(context: Context, payload: AlarmPayload) {
        val i = Intent(context, AlarmActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("scheduleId", payload.scheduleId)
            putExtra("elderId", payload.elderId)
            putExtra("scheduledFor", payload.scheduledFor)
            putExtra("medicationName", payload.medicationName)
            putExtra("dosage", payload.dosage)
            putExtra("instructions", payload.instructions)
            putExtra("durationSec", payload.durationSec)
        }
        context.startActivity(i)
    }
}