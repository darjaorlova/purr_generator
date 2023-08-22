import UIKit
import Flutter
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var eventSink: FlutterEventSink?
    private var progressTimer: Timer?
    private var audioPlayer: AVAudioPlayer!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        
        let flutterPurrChannel = FlutterMethodChannel(name: "flutter_purr_channel", binaryMessenger: controller.binaryMessenger)
        let flutterPurrEventChannel = FlutterEventChannel(name: "flutter_purr_event_channel", binaryMessenger: controller.binaryMessenger)
        
        flutterPurrChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "play":
                if let args = call.arguments as? [String: Any], let fileName = args["file_name"] as? String {
                        self.play(fileName: fileName)
                        result("Playing")
                    } else {
                        result("Error: File name not provided")
                    }
            case "stop":
                self.stop()
                result("Paused")
            case "loop":
                if let args = call.arguments as? [String: Any], let isLooping = args["looping"] as? Bool {
                    self.setLooping(isLooping: isLooping)
                    result("Looping set")
                }
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        flutterPurrEventChannel.setStreamHandler(self)
        
        setAudioSession()
        
        GeneratedPluginRegistrant.register(with: self)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func setAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback,
                mode: AVAudioSession.Mode.default,
                options: [
                    AVAudioSession.CategoryOptions.duckOthers
                ]
            )
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func play(fileName: String) {
        let sound = Bundle.main.path(forResource: fileName, ofType: nil)
        do {
            if let soundPath = sound {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: soundPath))
                audioPlayer?.delegate = self
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer?.play()
                startProgressTimer()
            } else {
                print("Sound file not found!")
            }
        } catch {
            print("Error playing file: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
        try? AVAudioSession.sharedInstance().setActive(false)
        stopProgressTimer()
        eventSink?(nil)
    }

    func setLooping(isLooping: Bool) {
        audioPlayer?.numberOfLoops = isLooping ? -1 : 0
    }

    @objc func updateProgress() {
        if let currentPlayer = audioPlayer {
            let currentTime = currentPlayer.currentTime
            let progress = currentTime / currentPlayer.duration
            eventSink?("progress:\(progress)")
        }
    }

    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }

    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
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
