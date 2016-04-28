# Segment-UrbanAirship

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Segment-UrbanAirship is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Segment-UrbanAirship"
```

### Setup

Use the Urban Airship Integration:

    SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:@"YOUR_WRITE_KEY"];

    [config use:[SEGUrbanAirshipIntegration instance]];

    [SEGAnalytics setupWithConfiguration:config];


#### Enabling user notifications

Once the Urban Airship integration is ready, you can enable user notifications with the following:

    [UAirship push].userPushNotificationsEnabled = YES;


To listen for when the Urban Airship integration is ready, listen for the SEGAnalyticsIntegrationDidStart NSNotification event:


    ...

    [[NSNotificationCenter defaultCenter]
          addObserver:self
             selector:@selector(airshipReady)
                 name:SEGAnalyticsIntegrationDidStart
               object:@"UrbanAirship"];

## Author

Urban Airship, support@urbanairship.com

## License

Segment-UrbanAirship is available under Apache License, Version 2.0. See the LICENSE file for more info.
