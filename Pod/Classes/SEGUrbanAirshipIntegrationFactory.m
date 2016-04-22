#import "SEGUrbanAirshipIntegrationFactory.h"
#import "SEGUrbanAirshipIntegration.h"

@implementation SEGUrbanAirshipIntegrationFactory

+ (id)instance
{
    static dispatch_once_t once;
    static SEGUrbanAirshipIntegration *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    return self;
}

- (id<SEGIntegration>)createWithSettings:(NSDictionary *)settings forAnalytics:(SEGAnalytics *)analytics
{
    return [[SEGUrbanAirshipIntegration alloc] initWithSettings:settings];
}

- (NSString *)key
{
    return @"UrbanAirship";
}

@end
