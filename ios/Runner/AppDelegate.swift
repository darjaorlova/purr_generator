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
                self.play()
                result("Playing")
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
        
        let sound = Bundle.main.path(forResource: "purr", ofType: "mp3")
        self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath:sound!))
        audioPlayer.delegate = self
        
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
    
    func play() {
        try! AVAudioSession.sharedInstance().setActive(true)
        audioPlayer.play()
        startProgressTimer()
    }
    
    func stop() {
        audioPlayer.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
        stopProgressTimer()
        eventSink?(nil)
    }
    
    func setLooping(isLooping: Bool) {
        audioPlayer.numberOfLoops = isLooping ? -1 : 0
    }

    func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }

    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    @objc func updateProgress() {
        let currentTime = audioPlayer.currentTime
        let progress = currentTime / audioPlayer.duration
        eventSink?("progress:\(progress)")
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
