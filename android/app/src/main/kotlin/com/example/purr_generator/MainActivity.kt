package com.example.purr_generator

import MediaPlayerApi
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity(), MediaPlayerApi {
    private val EVENT_CHANNEL = "flutter_purr_event_channel"
    private lateinit var eventChannel: EventChannel

    private val mediaPlayer = PurrMediaPlayer(this)

    init {
        mediaPlayer.onProgressUpdate = { progress ->
            eventSink?.success("progress:$progress")
        }
    }

    override fun play(fileName: String) {
        mediaPlayer.play(fileName)
    }

    override fun stop() {
        mediaPlayer.stop()
    }

    override fun loop(looping: Boolean) {
        mediaPlayer.loop(looping)
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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

        MediaPlayerApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }

    override fun onDestroy() {
        mediaPlayer.release()
        super.onDestroy()
    }
}

class PurrMediaPlayer(private val context: Context) {
    private var mediaPlayer: MediaPlayer? = null
    private val updateHandler = Handler(Looper.getMainLooper())
    var onProgressUpdate: ((Float) -> Unit)? = null

    private val updateRunnable = object : Runnable {
        override fun run() {
            mediaPlayer?.let {
                val progress = it.currentPosition.toFloat() / it.duration.toFloat()
                onProgressUpdate?.invoke(progress)
                updateHandler.postDelayed(this, 1000)
            }
        }
    }

    fun play(fileName: String) {
        stop()
        try {
            val descriptor: AssetFileDescriptor = context.assets.openFd(fileName)
            mediaPlayer = MediaPlayer().apply {
                setDataSource(descriptor.fileDescriptor, descriptor.startOffset, descriptor.length)
                descriptor.close()
                prepare()
                start()
            }
            updateHandler.post(updateRunnable)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun stop() {
        mediaPlayer?.stop()
        mediaPlayer?.release()
        mediaPlayer = null
        updateHandler.removeCallbacks(updateRunnable)
    }

    fun loop(isLooping: Boolean) {
        mediaPlayer?.isLooping = isLooping
    }

    fun release() {
        stop()
    }
}

