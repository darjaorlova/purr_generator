import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MediaPlayerApi{
    private var eventSink: FlutterEventSink?
    private var progressTimer: Timer?
    private var mediaPlayer = PurrMediaPlayer()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let flutterPurrEventChannel = FlutterEventChannel(name: "flutter_purr_event_channel", binaryMessenger: controller.binaryMessenger)
        flutterPurrEventChannel.setStreamHandler(self)
        
        MediaPlayerApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
        
        mediaPlayer.onProgressUpdate = { [weak self] progress in
            self?.eventSink?("progress:\(progress)")
        }

        mediaPlayer.onFinish = { [weak self] in
            self?.eventSink?("complete")
        }
        
        setAudioSession()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func setAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }
    }
    
    func play(fileName: String) {
        mediaPlayer.play(fileName: fileName)
        startProgressTimer()
    }
    
    func stop() {
        mediaPlayer.stop()
        stopProgressTimer()
    }
    
    func loop(looping: Bool) {
        mediaPlayer.loop(looping: looping)
    }

    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: mediaPlayer, selector: #selector(mediaPlayer.updateProgress), userInfo: nil, repeats: true)
    }

    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    @objc func updateProgress() {
        if let currentPlayer = mediaPlayer.audioPlayer {
            let currentTime = currentPlayer.currentTime
            let progress = currentTime / currentPlayer.duration
            eventSink?("progress:\(progress)")
        }
    }
}

extension AppDelegate: FlutterStreamHandler {
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

extension AppDelegate: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        eventSink?("complete")
    }
}

class PurrMediaPlayer: NSObject, AVAudioPlayerDelegate  {
    var audioPlayer: AVAudioPlayer?
    var onProgressUpdate: ((Double) -> Void)?
    var onFinish: (() -> Void)?
    
    func play(fileName: String) {
        guard let soundPath = Bundle.main.path(forResource: fileName, ofType: nil) else {
            return
        }
        audioPlayer = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
        audioPlayer?.delegate = self
        audioPlayer?.play()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0.0
    }
    
    func loop(looping: Bool) {
        audioPlayer?.numberOfLoops = looping ? -1 : 0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish?()
    }
    
    @objc func updateProgress() {
        if let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration {
            onProgressUpdate?(currentTime / duration)
        }
    }

}
