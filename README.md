# Segment-UrbanAirship

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Passive Registration Mode

The Airship Segment integration enables passive registration by default. This default setting allows Airship push services to properly function when push registration occurs independently of the Airship SDK. 

## Installation

Segment-UrbanAirship is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Segment-UrbanAirship"
```

### Setup

Use the Airship Integration:

    SEGAnalyticsConfiguration *config = [SEGAnalyticsConfiguration configurationWithWriteKey:@"YOUR_WRITE_KEY"];

    [config use:[SEGUrbanAirshipIntegrationFactory instance]];

    [SEGAnalytics setupWithConfiguration:config];


#### Enabling user notifications

The Airship integration will listen to system authorization and registration events and register automatically when authorization is given.


#### Listening for ready state

To listen for when the Airship integration is ready, listen for the `io.segment.analytics.integration.did.start` NSNotification event:

    ...

    [[[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(airshipReady)
                                                  name:@"io.segment.analytics.integration.did.start"
                                                object:[SEGUrbanAirshipIntegrationFactory instance].key];

## Author

Airship

## License

Segment-UrbanAirship is available under Apache License, Version 2.0. See the LICENSE file for more info.
