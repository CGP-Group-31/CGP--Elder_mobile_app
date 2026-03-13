package com.example.cgp_elder.alarm

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject

class MarkTakenWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            val scheduleId = inputData.getInt("scheduleId", 0)
            val elderId = inputData.getInt("elderId", 0)
            val scheduledFor = inputData.getString("scheduledFor") ?: ""
            val baseUrl = inputData.getString("baseUrl") ?: ""

            val json = JSONObject().apply {
                put("scheduleId", scheduleId)
                put("elderId", elderId)
                put("scheduledFor", scheduledFor)
            }.toString()

            val client = OkHttpClient()
            val body = json.toRequestBody("application/json".toMediaType())

            val request = Request.Builder()
                .url("$baseUrl/api/v1/elder/medication-adherence/taken")
                .post(body)
                .build()

            val response = client.newCall(request).execute()
            if (response.isSuccessful) Result.success() else Result.retry()
        } catch (e: Exception) {
            Result.retry()
        }
    }
}