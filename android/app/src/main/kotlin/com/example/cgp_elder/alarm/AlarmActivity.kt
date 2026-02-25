package com.example.cgp_elder.alarm

import android.media.MediaPlayer
import android.os.*
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.cgp_elder.R

class AlarmActivity : AppCompatActivity() {

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ✅ Wake + show over lockscreen
        setShowWhenLocked(true)
        setTurnScreenOn(true)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        setContentView(R.layout.activity_alarm)

        // Read extras
        val scheduleId = intent.getIntExtra("scheduleId", 0)
        val elderId = intent.getIntExtra("elderId", 0)
        val scheduledFor = intent.getStringExtra("scheduledFor") ?: ""
        val medicationName = intent.getStringExtra("medicationName") ?: "Medicine"
        val dosage = intent.getStringExtra("dosage") ?: ""
        val instructions = intent.getStringExtra("instructions") ?: ""
        val durationSec = intent.getIntExtra("durationSec", 60)

        // UI
        findViewById<TextView>(R.id.txtTitle).text = medicationName
        findViewById<TextView>(R.id.txtDosage).text = "Dosage: $dosage"
        findViewById<TextView>(R.id.txtInstructions).text = instructions

        // ✅ Start sound + vibration
        startAlarmSound()
        startVibration()

        // Auto stop after duration
        handler.postDelayed({
            stopAll()
            finish()
        }, durationSec * 1000L)

        findViewById<Button>(R.id.btnTaken).setOnClickListener {
            // ✅ Later: call backend with WorkManager or PendingIntent service
            // For now just close
            stopAll()
            finish()
        }

        findViewById<Button>(R.id.btnDismiss).setOnClickListener {
            stopAll()
            finish()
        }
    }

    private fun startAlarmSound() {
        // ✅ Put your sound in android/app/src/main/res/raw/med_alarm.mp3
        mediaPlayer = MediaPlayer.create(this, R.raw.med_alarm)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()
    }

    private fun startVibration() {
        vibrator = getSystemService(VIBRATOR_SERVICE) as Vibrator
        val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1500)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun stopAll() {
        try { mediaPlayer?.stop() } catch (_: Exception) {}
        try { mediaPlayer?.release() } catch (_: Exception) {}
        mediaPlayer = null

        vibrator?.cancel()
        vibrator = null
    }

    override fun onDestroy() {
        stopAll()
        super.onDestroy()
    }
}