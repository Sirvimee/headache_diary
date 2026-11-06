import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let shortcutType = "com.example.headache_diary.ADD_SYMPTOM"
  private var addSymptomRequested = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem,
       shortcutItem.type == shortcutType {
      addSymptomRequested = true
    }

    GeneratedPluginRegistrant.register(with: self)
    let result = super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "com.example.headache_diary/speech_feedback",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "consumeAddSymptomShortcut" else {
          result(FlutterMethodNotImplemented)
          return
        }

        let requested = self?.addSymptomRequested ?? false
        self?.addSymptomRequested = false
        result(requested)
      }
    }

    return result
  }

  override func application(
    _ application: UIApplication,
    performActionFor shortcutItem: UIApplicationShortcutItem,
    completionHandler: @escaping (Bool) -> Void
  ) {
    if shortcutItem.type == shortcutType {
      addSymptomRequested = true
      completionHandler(true)
      return
    }
    completionHandler(false)
  }
}
