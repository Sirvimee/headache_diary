package com.example.headache_diary

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.headache_diary/speech_feedback"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method != "playRecognitionFailure") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
                tone.startTone(ToneGenerator.TONE_SUP_ERROR, 350)
                Handler(Looper.getMainLooper()).postDelayed(
                    { tone.release() },
                    450,
                )
                result.success(null)
            }
    }
}
