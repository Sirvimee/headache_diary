package ee.meeli.migreenipaevik

import android.media.AudioManager
import android.media.ToneGenerator
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.headache_diary/speech_feedback"
    private val addSymptomAction = "com.example.headache_diary.ADD_SYMPTOM"
    private var addSymptomRequested = false

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        addSymptomRequested = intent?.action == addSymptomAction
        super.onCreate(savedInstanceState)
    }

    override fun onNewIntent(intent: android.content.Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.action == addSymptomAction) {
            addSymptomRequested = true
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playRecognitionFailure" -> {
                        val tone = ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100)
                        tone.startTone(ToneGenerator.TONE_SUP_ERROR, 350)
                        Handler(Looper.getMainLooper()).postDelayed(
                            { tone.release() },
                            450,
                        )
                        result.success(null)
                    }
                    "consumeAddSymptomShortcut" -> {
                        val requested = addSymptomRequested
                        addSymptomRequested = false
                        result.success(requested)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
