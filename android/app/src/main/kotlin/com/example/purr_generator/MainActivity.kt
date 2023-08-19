package com.example.purr_generator

import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL = "flutter_purr_channel"
    private val EVENT_CHANNEL = "flutter_purr_event_channel"
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var mediaPlayer: MediaPlayer? = null
    private val updateHandler = Handler(Looper.getMainLooper())

    private val updateRunnable = object : Runnable {
        override fun run() {
            if (mediaPlayer == null) {
                return
            }
            val progress =
                mediaPlayer!!.currentPosition.toFloat() / mediaPlayer!!.duration.toFloat()
            eventSink?.success("progress:$progress")
            updateHandler.postDelayed(this, 1000)
        }
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
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

        // Set up the EventChannel
        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun play() {
        mediaPlayer?.release()
        mediaPlayer = null
        mediaPlayer = MediaPlayer.create(this, R.raw.purr)
        mediaPlayer?.setOnCompletionListener {
            eventSink?.success("complete")
        }
        updateHandler.post(updateRunnable)
        mediaPlayer?.start()
    }

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
