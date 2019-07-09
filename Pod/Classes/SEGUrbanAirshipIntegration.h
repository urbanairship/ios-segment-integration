/* Copyright Airship and Contributors */

#import <Foundation/Foundation.h>
#import <Analytics/SEGIntegration.h>

@interface SEGUrbanAirshipIntegration : NSObject <SEGIntegration>

@property (nonatomic, strong) NSDictionary *settings;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end
