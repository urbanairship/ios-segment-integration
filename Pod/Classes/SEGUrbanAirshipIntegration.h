#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>

@interface SEGUrbanAirshipIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;

- (id)initWithSettings:(NSDictionary *)settings;

#define kScreenPrefix @"VIEWED_"
#define kUrbanAirshipKey @"URBAN_AIRSHIP"

#define kUrbanAirshipAppKey @"appKey"
#define kUrbanAirshipAppSecret @"appSecret"

@end
