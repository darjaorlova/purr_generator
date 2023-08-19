package com.example.purr_generator

import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// TODO: Clean code and add comments
class MainActivity : FlutterActivity() {
    private val CHANNEL = "flutter_purr_channel"
    private lateinit var channel: MethodChannel
    private var mediaPlayer: MediaPlayer? = null
    private val updateHandler = Handler(Looper.getMainLooper())

    private val updateRunnable = object : Runnable {
        override fun run() {
            if (mediaPlayer == null) {
                return
            }
            val progress =
                mediaPlayer!!.currentPosition.toFloat() / mediaPlayer!!.duration.toFloat()
            channel.invokeMethod("updateProgress", progress)
            updateHandler.postDelayed(this, 1000)
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel =
            MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            )
        channel.setMethodCallHandler { call, result ->
            // This method is invoked on the main thread.
            when (call.method) {
                "play" -> {
                    play()
                    result.success(null)
                }

                "stop" -> {
                    stop()
                    result.success(null)
                }

                "loop" -> {
                    val isLooping = call.argument<Boolean>("looping")
                    isLooping?.let {
                        loop(it)
                        result.success(null)
                    } ?: result.error("INVALID", "looping is null", null)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun play() {
        mediaPlayer?.release()
        mediaPlayer = null
        mediaPlayer = MediaPlayer.create(this, R.raw.purr)
        mediaPlayer?.setOnCompletionListener {
            channel.invokeMethod("complete", null)
        }
        updateHandler.post(updateRunnable)
        mediaPlayer?.start()
    }

    // TODO: rename to stop
    private fun stop() {
        mediaPlayer?.stop()
        updateHandler.removeCallbacks(updateRunnable)
    }

    private fun loop(isLooping: Boolean) {
        mediaPlayer?.isLooping = isLooping
    }

    override fun onDestroy() {
        super.onDestroy()
        updateHandler.removeCallbacks(updateRunnable)
        mediaPlayer?.release()
        mediaPlayer = null
    }
}
