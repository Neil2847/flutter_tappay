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
    
    TPDSetup.setWithAppId(15365, withAppKey: "app_6uJFBW6tnKWuC9oSJNyelqbl44ycRKgtzHJGQwaSCRv0wz2a0EysGLIirrW8", with: TPDServerType.sandBox)
//    TPDSetup.shareInstance().setupIDFA(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
    
    TPDSetup.shareInstance().serverSync()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
