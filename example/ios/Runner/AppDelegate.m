#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <TPDirect/TPDirect.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    
  // set TapPay.
  [TPDSetup setWithAppId:123 withAppKey:@"AppKey" withServerType:TPDServer_SandBox];
//  [[TPDSetup shareInstance] setupIDFA:@""];
  [[TPDSetup shareInstance] serverSync];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
