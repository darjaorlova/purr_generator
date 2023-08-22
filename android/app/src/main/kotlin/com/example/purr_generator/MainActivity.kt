package com.example.purr_generator

import MediaPlayerApi
import MediaPlayerProgressApi
import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity(), MediaPlayerApi {
    private val mediaPlayer = PurrMediaPlayer(this)
    private lateinit var mediaPlayerProgressApi: MediaPlayerProgressApi

    init {
        mediaPlayer.onProgressUpdate = { progress ->
            mediaPlayerProgressApi.onProgress(progress.toDouble()) {
                println("Progress message sent to Flutter.")
            }
        }

        mediaPlayer.onCompletion = {
            mediaPlayerProgressApi.complete {
                println("Complete message sent to Flutter.")
            }
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

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        mediaPlayerProgressApi = MediaPlayerProgressApi(flutterEngine.dartExecutor.binaryMessenger)
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
    var onCompletion: (() -> Unit)? = null

    private val updateRunnable = object : Runnable {
        override fun run() {
            mediaPlayer?.let {
                if (!it.isPlaying) {
                    return
                }
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
                setOnCompletionListener {
                    onCompletion?.invoke()
                }
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