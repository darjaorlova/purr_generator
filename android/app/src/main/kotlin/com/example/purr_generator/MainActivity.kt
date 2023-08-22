package com.example.purr_generator

import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
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
            try {
                if (mediaPlayer != null && mediaPlayer!!.isPlaying) {
                    val progress = mediaPlayer!!.currentPosition.toFloat() / mediaPlayer!!.duration.toFloat()
                    eventSink?.success("progress:$progress")
                    updateHandler.postDelayed(this, 1000)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up the MethodChannel
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "play" -> {
                    val fileName = call.argument<String>("file_name")
                    fileName?.let {
                        play(it)
                        result.success(null)
                    } ?: result.error("INVALID", "file name is null", null)
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

    private fun play(fileName: String) {
        mediaPlayer?.release()
        mediaPlayer = MediaPlayer()
        try {
            val descriptor: AssetFileDescriptor = assets.openFd(fileName)
            mediaPlayer?.apply {
                setDataSource(descriptor.fileDescriptor, descriptor.startOffset, descriptor.length)
                descriptor.close()

                prepare()

                setOnCompletionListener {
                    eventSink?.success("complete")
                    updateHandler.removeCallbacks(updateRunnable)
                    it?.release()
                }

                start()
                updateHandler.post(updateRunnable)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stop() {
        updateHandler.removeCallbacks(updateRunnable)
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
        }
        mediaPlayer = null
    }

    private fun loop(isLooping: Boolean) {
        mediaPlayer?.isLooping = isLooping
    }

    override fun onDestroy() {
        updateHandler.removeCallbacks(updateRunnable)
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
        }
        mediaPlayer = null
        super.onDestroy()
    }
}
