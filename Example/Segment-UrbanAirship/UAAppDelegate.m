/* Copyright Airship and Contributors */

#import "UAAppDelegate.h"
#import "SEGAnalytics.h"
#import "SEGUrbanAirshipIntegration.h"
#import "SEGUrbanAirshipIntegrationFactory.h"
#import "UAirship.h"
#import "UAPush.h"

@implementation UAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:@"API_KEY"];
    [config use:[SEGUrbanAirshipIntegrationFactory instance]];
    [SEGAnalytics setupWithConfiguration:config];

    [[SEGAnalytics sharedAnalytics] track:@"Hello World"];
    [[SEGAnalytics sharedAnalytics] group:@"segment"];
    [[SEGAnalytics sharedAnalytics] screen:@"home"];
    [[SEGAnalytics sharedAnalytics] identify:@"test-user"];
    [[SEGAnalytics sharedAnalytics] flush];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(airshipReady)
                                                 name:@"io.segment.analytics.integration.did.start"
                                               object:[SEGUrbanAirshipIntegrationFactory instance].key];

    // Override point for customization after application launch.
    return YES;
}

- (void)airshipReady {
    [UAirship push].userPushNotificationsEnabled = YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
