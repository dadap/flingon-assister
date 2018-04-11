#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    FlutterViewController* flutterController = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel methodChannelWithName: @"platform" binaryMessenger: flutterController];
    [methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"openURL" isEqualToString: call.method]) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: (NSString *) call.arguments]];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    FlutterBasicMessageChannel *messageChannel = [FlutterBasicMessageChannel messageChannelWithName:@"load" binaryMessenger: (FlutterViewController *) self.window.rootViewController codec: [FlutterStringCodec sharedInstance]];
    [messageChannel sendMessage: url.absoluteString];
    return YES;
}

@end
