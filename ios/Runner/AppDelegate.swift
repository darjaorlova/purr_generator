import UIKit
import Flutter
import AVKit


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  private var isPurring = false
  var audioPlayer: AVAudioPlayer!
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      let rootController = window?.rootViewController
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let flutterPurrChannel = FlutterMethodChannel(name: "flutter_purr_channel", binaryMessenger: controller.binaryMessenger)
      
      flutterPurrChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        // This method is invoked on the UI thread.
          if call.method == "play" {
              self.play()
              result("Playing")
          } else if call.method == "pause" {
              self.pause()
              result("Paused")
          } else {
              result(FlutterMethodNotImplemented)
              return
          }
      })
        
      setAudioSession()
      let sound = Bundle.main.path(forResource: "purr", ofType: "mp3")
      self.audioPlayer = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath:sound!))
      self.audioPlayer.numberOfLoops = -1 // Infinite
      
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
        self.audioPlayer.play()
    }

    func pause() {
        self.audioPlayer.pause()
        try! AVAudioSession.sharedInstance().setActive(false)
    }
}
