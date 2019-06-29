/* Copyright Airship and Contributors */

#import "SEGUrbanAirshipIntegrationFactory.h"
#import "SEGUrbanAirshipIntegration.h"

@implementation SEGUrbanAirshipIntegrationFactory

+ (instancetype)instance {
    static dispatch_once_t once;
    static SEGUrbanAirshipIntegrationFactory *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    return self;
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics {
    return [[SEGUrbanAirshipIntegration alloc] initWithSettings:settings];
}

- (NSString *)key {
    return @"Urban Airship";
}

@end
