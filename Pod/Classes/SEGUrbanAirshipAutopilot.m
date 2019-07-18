/* Copyright Airship and Contributors */

#import "SEGUrbanAirshipAutopilot.h"
#import "AirshipLib.h"


@implementation SEGUrbanAirshipAutopilot

NSString *const SEGUrbanAirshipAutopilotSettings = @"SEGUrbanAirshipAutopilotSettings";
NSString *const SEGUrbanAirshipAutopilotAppKey = @"appKey";
NSString *const SEGUrbanAirshipAutopilotAppSecret = @"appSecret";

+ (void)load {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:[SEGUrbanAirshipAutopilot class]
               selector:@selector(didFinishLaunching)
                   name:UIApplicationDidFinishLaunchingNotification
                 object:nil];
}

+(void)takeOff:(NSDictionary *)settings storeConfig:(BOOL)storeConfig {
    UAConfig *config = [UAConfig defaultConfig];
    config.productionAppKey = settings[SEGUrbanAirshipAutopilotAppKey];
    config.productionAppSecret = settings[SEGUrbanAirshipAutopilotAppSecret];

    // Enable passive APNS registration
    config.requestAuthorizationToUseNotifications = NO;

    if (!config.inProduction && !config.developmentAppKey && !config.developmentAppSecret) {
        config.developmentAppKey = settings[SEGUrbanAirshipAutopilotAppKey];
        config.developmentAppSecret = settings[SEGUrbanAirshipAutopilotAppSecret];
    }

    if (!config.validate) {
        return;
    }

    // Store the config
    if (storeConfig) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] setValue:settings forKey:SEGUrbanAirshipAutopilotSettings];
        });
    }

    if ([UAirship shared]) {
        // TakeOff already called
        return;
    }

    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [UAirship takeOff:config];
            // Enable push by default for passive registration
            UAirship.push.userPushNotificationsEnabledByDefault = YES;
        });
    } else {
        [UAirship takeOff:config];
    }
}


+ (void)didFinishLaunching {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults valueForKey:SEGUrbanAirshipAutopilotSettings]) {
        [self takeOff:[defaults valueForKey:SEGUrbanAirshipAutopilotSettings] storeConfig:NO];
    }
}

@end
