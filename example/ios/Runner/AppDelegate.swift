import UIKit
import Flutter
import TPDirect

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    TPDSetup.setWithAppId(0, withAppKey: "", with: TPDServerType.sandBox)
//    TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
    
    TPDSetup.shareInstance().serverSync()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
