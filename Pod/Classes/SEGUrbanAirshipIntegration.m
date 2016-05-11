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

#import "SEGUrbanAirshipIntegration.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UACustomEvent.h"
#import "UAAnalytics.h"
#import "UAConfig.h"

#define kUrbanAirshipAppKey @"appKey"
#define kUrbanAirshipAppSecret @"appSecret"

/**
 * Urban Airship Segment integration.
 */
@implementation SEGUrbanAirshipIntegration

- (instancetype)initWithSettings:(NSDictionary *)settings {
    if (self = [super init]) {
        self.settings = settings;

        // Set log level for debugging config loading (optional)
        // It will be set to the value in the loaded config upon takeOff
        [UAirship setLogLevel:UALogLevelTrace];

        UAConfig *config = [UAConfig defaultConfig];

        config.productionAppKey = settings[kUrbanAirshipAppKey];
        config.productionAppSecret = settings[kUrbanAirshipAppSecret];

        if (!config.inProduction && !config.developmentAppKey && !config.developmentAppSecret) {
            config.developmentAppKey = settings[kUrbanAirshipAppKey];
            config.developmentAppSecret = settings[kUrbanAirshipAppSecret];
        }

        if (![[NSThread currentThread] isEqual:[NSThread mainThread]]) {
            // Call takeOff on main thread (which creates the UAirship singleton)
            dispatch_sync(dispatch_get_main_queue(), ^{
                [UAirship takeOff:config];
            });
        } else {
            [UAirship takeOff:config];
        }
    }

    return self;
}

- (void)identify:(SEGIdentifyPayload *)payload {
    [UAirship push].namedUser.identifier = payload.userId;
    [[UAirship push] updateRegistration];
}

- (void)screen:(SEGScreenPayload *)payload {
    [[[UAirship shared] analytics] trackScreen:(payload.name ?: payload.category)];
}

- (void)track:(SEGTrackPayload *)payload {
    [self addEvent:payload.event properties:payload.properties];
}

- (void)group:(SEGGroupPayload *)payload {
    if (payload.groupId) {
        [[UAirship push] addTag:payload.groupId];
        [[UAirship push] updateRegistration];
    }
}

// Reset is invoked when the user logs out, and any data saved about the user should be cleared.
- (void)reset {
    [UAirship push].namedUser.identifier = nil;
    [UAirship push].tags = @[];
    [[UAirship push] updateRegistration];
}

/**
 * Creates a Custom Event from Segment track and screen calls.
 *
 * @param eventName The event name.
 * @param properties The event properties.
 */
-(void)addEvent:(NSString *)eventName properties:(NSDictionary *)properties {

    UACustomEvent *customEvent = [UACustomEvent eventWithName:eventName];

    if (properties[@"revenue"]) {
        customEvent.eventValue = properties[@"revenue"];
    } else if (properties[@"value"]) {
        customEvent.eventValue = properties[@"value"];
    }

    // Try to extract a "revenue" or "value" property.
    NSNumber *value = [SEGUrbanAirshipIntegration extractRevenue:properties withKey:@"revenue"];
    NSNumber *valueFallback = [SEGUrbanAirshipIntegration extractRevenue:properties withKey:@"value"];
    if (!value && valueFallback) {
        // fall back to the "value" property
        value = valueFallback;
    }

    if (value) {
        customEvent.eventValue = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
    }

    for (NSString *key in properties) {
        id value = properties[key];

        if ([value isKindOfClass:[NSString class]]) {
            [customEvent setStringProperty:value forKey:key];
        }

        if ([value isKindOfClass:[NSNumber class]]) {
            [customEvent setNumberProperty:value forKey:key];
        }
    }

    [[UAirship shared].analytics addEvent:customEvent];
}

+ (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey {
    id revenueProperty;

    for (NSString *key in dictionary) {
        if ([key caseInsensitiveCompare:revenueKey] == NSOrderedSame) {
            revenueProperty = dictionary[key];
            break;
        }
    }

    if (revenueProperty) {
        if ([revenueProperty isKindOfClass:[NSString class]]) {
            // Format the revenue.
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
            return [formatter numberFromString:revenueProperty];
        } else if ([revenueProperty isKindOfClass:[NSNumber class]]) {
            return revenueProperty;
        }
    }
    return nil;
}

@end
