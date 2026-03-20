package com.example.cgp_elder.alarm

import android.content.Context
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager

object AlarmTakenApi {

    private const val BASE_URL = "http://159.65.158.217:8000"

    fun enqueueTaken(context: Context, scheduleId: Int, elderId: Int, scheduledFor: String) {
        val data = Data.Builder()
            .putInt("scheduleId", scheduleId)
            .putInt("elderId", elderId)
            .putString("scheduledFor", scheduledFor)
            .putString("baseUrl", BASE_URL)
            .build()

        val req = OneTimeWorkRequestBuilder<MarkTakenWorker>()
            .setInputData(data)
            .build()

        WorkManager.getInstance(context).enqueue(req)
    }
}