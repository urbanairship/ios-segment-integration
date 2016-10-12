/*
 Copyright 2009-2016 Urban Airship Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE URBAN AIRSHIP INC ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL URBAN AIRSHIP INC OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SEGUrbanAirshipAutopilot.h"
#import "UAirship.h"
#import "UAConfig.h"

@implementation SEGUrbanAirshipAutopilot

NSString *const SEGUrbanAirshipAutopilotSettings = @"SEGUrbanAirshipAutopilotSettings";
NSString *const SEGUrbanAirshipAutopilotAppKey = @"appKey";
NSString *const SEGUrbanAirshipAutopilotAppSecret = @"appSecret";

+ (void)load {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:[SEGUrbanAirshipAutopilot class] selector:@selector(didFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

+(void)takeOff:(NSDictionary *)settings {
    UAConfig *config = [UAConfig defaultConfig];
    config.productionAppKey = settings[SEGUrbanAirshipAutopilotAppKey];
    config.productionAppSecret = settings[SEGUrbanAirshipAutopilotAppSecret];

    if (!config.inProduction && !config.developmentAppKey && !config.developmentAppSecret) {
        config.developmentAppKey = settings[SEGUrbanAirshipAutopilotAppKey];
        config.developmentAppSecret = settings[SEGUrbanAirshipAutopilotAppSecret];
    }

    if (!config.validate) {
        return;
    }

    // Store the valid config
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:settings forKey:SEGUrbanAirshipAutopilotSettings];

    // TakeOff
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // Set log level for debugging config loading (optional)
        // It will be set to the value in the loaded config upon takeOff
        [UAirship setLogLevel:UALogLevelTrace];


        if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
            // Call takeOff on main thread (which creates the UAirship singleton)
            dispatch_sync(dispatch_get_main_queue(), ^{
                [UAirship takeOff:config];
            });
        } else {
            [UAirship takeOff:config];
        }
    });
}


+ (void)didFinishLaunching {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults valueForKey:SEGUrbanAirshipAutopilotSettings]) {
        [self takeOff:[defaults valueForKey:SEGUrbanAirshipAutopilotSettings]];
    }
}

@end
