#import "SEGUrbanAirshipIntegration.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UACustomEvent.h"
#import "UAAnalytics.h"

/**
 * Urban Airship Segment integration.
 */
@implementation SEGUrbanAirshipIntegration

- (id)initWithSettings:(NSDictionary *)settings
{
    if (self = [super init]) {
        self.settings = settings;
    }

    // Ensure takeoff
    if ([UAirship shared]) {
        return self;
    }

    return nil;
}

-(NSString *)key
{
    return kUrbanAirshipKey;
}

- (void)identify:(SEGIdentifyPayload *)payload {
    [UAirship push].namedUser.identifier = payload.userId;

}

- (void)screen:(SEGScreenPayload *)payload {
    NSString *screen = [NSString string];

    if (payload.category) {
        [screen stringByAppendingString:[NSString stringWithFormat:@"_%@", payload.category]];
    }

    if (payload.name) {
        [screen stringByAppendingString:[NSString stringWithFormat:@"_%@", payload.name]];
    }

    [self addEvent:screen properties:payload.properties];
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
    [[UAirship push] setTags:@[]];
}

/**
 * Creates a Custom Event from Segment track and screen calls.
 *
 * @param eventName The event name.
 * @param properties The event properties.
 */
-(void)addEvent:(NSString *)eventName properties:(NSDictionary *)properties  {

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

        //Best way to check for bool?
//        if () {
//
//        }
    }

    [[UAirship shared].analytics addEvent:customEvent];
}

+ (NSNumber *)extractRevenue:(NSDictionary *)dictionary withKey:(NSString *)revenueKey {
    id revenueProperty = nil;

    for (NSString *key in dictionary.allKeys) {
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
