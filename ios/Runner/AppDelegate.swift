import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MediaPlayerApi {
    private var progressTimer: Timer?
    private var mediaPlayer = PurrMediaPlayer()
    private var mediaPlayerProgressApi: MediaPlayerProgressApi?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        MediaPlayerApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
        mediaPlayerProgressApi = MediaPlayerProgressApi(binaryMessenger: controller.binaryMessenger)
        
        mediaPlayer.onProgressUpdate = { [weak self] progress in
            self?.mediaPlayerProgressApi?.onProgress(progress: progress, completion: {})
        }

        mediaPlayer.onFinish = { [weak self] in
            self?.mediaPlayerProgressApi?.complete(completion: {})
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
    
    func play(file: MediaFile) -> Bool {
        mediaPlayer.play(fileName: file.fileName)
        startProgressTimer()
        return true
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
    
    func complete() {
        self.mediaPlayerProgressApi?.complete(completion: {})
    }
}

extension AppDelegate: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        complete()
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
