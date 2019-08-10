/* Copyright Airship and Contributors */

#import "SEGUrbanAirshipIntegration.h"
#import "SEGUrbanAirshipAutopilot.h"
#import "AirshipLib.h"


#define kUrbanAirshipAppKey @"appKey"
#define kUrbanAirshipAppSecret @"appSecret"

/**
 * Airship Segment integration.
 */
@implementation SEGUrbanAirshipIntegration

- (instancetype)initWithSettings:(NSDictionary *)settings {
    if (self = [super init]) {
        self.settings = settings;
        [SEGUrbanAirshipAutopilot takeOff:settings storeConfig:YES];
    }

    return self;
}

- (void)identify:(SEGIdentifyPayload *)payload {
    [UAirship namedUser].identifier = payload.userId;

    NSMutableArray *addTags = [NSMutableArray array];
    NSMutableArray *removeTags = [NSMutableArray array];

    for (NSString *key in payload.traits) {
        id value = payload.traits[key];
        if (![value isKindOfClass:[NSNumber class]]) {
            continue;
        }

        CFTypeID type = CFGetTypeID((__bridge CFTypeRef)(value));
        if (type != CFBooleanGetTypeID()) {
            continue;
        }

        if ([value boolValue]) {
            [addTags addObject:key];
        } else {
            [removeTags addObject:key];
        }
    }

    [[UAirship namedUser] addTags:addTags group:@"segment-integration"];
    [[UAirship namedUser] removeTags:removeTags group:@"segment-integration"];
    [[UAirship namedUser] updateTags];
}

- (void)screen:(SEGScreenPayload *)payload {
    [[[UAirship shared] analytics] trackScreen:(payload.name ?: payload.category)];
}

- (void)track:(SEGTrackPayload *)payload {
    UACustomEvent *customEvent = [UACustomEvent eventWithName:payload.event];
    customEvent.transactionID = @"cdp";

    NSNumber *value = [SEGUrbanAirshipIntegration extractRevenue:payload.properties withKey:@"revenue"];
    if (!value) {
        value = [SEGUrbanAirshipIntegration extractRevenue:payload.properties withKey:@"value"];
    }

    if (value) {
        customEvent.eventValue = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
    }

    for (NSString *key in payload.properties) {
        id value = payload.properties[key];

        if ([value isKindOfClass:[NSString class]]) {
            [customEvent setStringProperty:value forKey:key];
        }

        if ([value isKindOfClass:[NSNumber class]]) {
            [customEvent setNumberProperty:value forKey:key];
        }
    }

    [[UAirship shared].analytics addEvent:customEvent];
}

- (void)group:(SEGGroupPayload *)payload {
    if (payload.groupId) {
        [[UAirship push] addTag:payload.groupId];
        [[UAirship push] updateRegistration];
    }
}

// Reset is invoked when the user logs out, and any data saved about the user should be cleared.
- (void)reset {
    [UAirship namedUser].identifier = nil;
    [UAirship push].tags = @[];
    [[UAirship push] updateRegistration];
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
