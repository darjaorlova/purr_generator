package com.example.purr_generator

import android.media.MediaPlayer
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "flutter_purr_channel"
    private var mediaPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            // This method is invoked on the main thread.
            when (call.method) {
                "play" -> {
                    play()
                    result.success("Playing")
                }
                "pause" -> {
                    pause()
                    result.success("Paused")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun play() {
        mediaPlayer = MediaPlayer.create(this, R.raw.purr)
        mediaPlayer?.start()
    }

    private fun pause() {
        mediaPlayer?.pause()
    }
}
