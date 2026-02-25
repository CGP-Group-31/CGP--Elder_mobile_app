package com.example.cgp_elder.alarm

data class AlarmPayload(
    val scheduleId: Int,
    val elderId: Int,
    val scheduledFor: String,
    val medicationName: String,
    val dosage: String,
    val instructions: String,
    val durationSec: Int
)