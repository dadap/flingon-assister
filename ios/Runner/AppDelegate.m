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
        } else if ([@"ttsAvailable" isEqualToString: call.method]) {
            result(@([UIApplication.sharedApplication canOpenURL: [NSURL URLWithString: @"klingontts://speak/"]]));
        } else if ([@"speak" isEqualToString: call.method]) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: [@"klingontts://speak/" stringByAppendingString:[(NSString *) call.arguments stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]]]];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)sendURI:(NSURL*) uri {
    FlutterBasicMessageChannel *channel = [FlutterBasicMessageChannel messageChannelWithName:@"load" binaryMessenger: (FlutterViewController *) self.window.rootViewController codec: [FlutterStringCodec sharedInstance]];

    __block bool replied = NO;
    [channel sendMessage: @"ping" reply:^(id  _Nullable reply) {
        replied = YES;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50000)), dispatch_get_main_queue(), ^{
        if (replied) {
            [channel sendMessage: uri.absoluteString];
        } else {
            // If the channel isn't responding yet, try again in a little bit.
            [self sendURI: uri];
        }
    });
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [self sendURI: url];
    return YES;
}

@end
