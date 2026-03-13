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

        // Wake + show over lockscreen
        setShowWhenLocked(true)
        setTurnScreenOn(true)
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        setContentView(R.layout.activity_alarm)

        val scheduleId = intent.getIntExtra("scheduleId", 0)
        val elderId = intent.getIntExtra("elderId", 0)
        val scheduledFor = intent.getStringExtra("scheduledFor") ?: ""

        val medicationName = intent.getStringExtra("medicationName") ?: "Medicine"
        val dosage = intent.getStringExtra("dosage") ?: ""
        val instructions = intent.getStringExtra("instructions") ?: ""
        val durationSec = intent.getIntExtra("durationSec", 60)

        val fullName = intent.getStringExtra("fullName") ?: ""

        // UI elements
        val txtTitle = findViewById<TextView>(R.id.txtTitle)
        val txtDosage = findViewById<TextView>(R.id.txtDosage)
        val txtInstructions = findViewById<TextView>(R.id.txtInstructions)

        // Greeting (safe)
        try {
            val txtGreeting = findViewById<TextView>(R.id.txtGreeting)
            val nameToShow = if (fullName.isNotBlank()) fullName else "there"
            txtGreeting.text = "Hi $nameToShow \nTime to take your medicine"
        } catch (_: Exception) {
            // txtGreeting not found -> ignore
        }

        // Improved message text
        txtTitle.text = medicationName

        txtDosage.text = if (dosage.isNotBlank()) {
            "Dose: $dosage"
        } else {
            "Dose: -"
        }

        txtInstructions.text = buildString {
            if (instructions.isNotBlank()) {
                append("Instructions: ")
                append(instructions.trim())
                append("\n\n")
            }
            append("Tap TAKEN after you take it.")
        }

        // Start sound + vibration
        startAlarmSound()
        startVibration()

        // Auto stop after duration
        handler.postDelayed({
            stopAll()
            finish()
        }, durationSec * 1000L)

        // Buttons
        findViewById<Button>(R.id.btnTaken).setOnClickListener {
            // Send backend update (WorkManager)
            AlarmTakenApi.enqueueTaken(applicationContext, scheduleId, elderId, scheduledFor)

            stopAll()
            finish()
        }

        findViewById<Button>(R.id.btnDismiss).setOnClickListener {
            stopAll()
            finish()
        }
    }

    private fun startAlarmSound() {
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