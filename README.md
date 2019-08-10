# Segment-UrbanAirship

The Segment and Airship partnership is growing and we have recently launched a new bi-directional server-side integration. You can read about this [new integration here](https://docs.airship.com/partners/segment/).

The Segment platform has a limitation and only allows a single Destination endpoint per integration. This SDK integration and the new Server-side integration cannot be options on the Segment website under Airship.

For the immediate future, this integration will be moved to a Private-Beta within Segment. Customers will not see an interruption in service and Airship will continue to maintain this repo with each SDK release. Customers that have already been configured for the SDK integration will still be able to see the required elements for that integration within Segment.

The Segment and Airship teams are working together to identify a path forward for supporting both Destination integrations. In the meantime, we do not suggest that existing users configure both Destinations. This will result in duplicate events.

If you have any concerns or questions, please reach out to our Partner Integration Team <partner-integration-ua@airship.com>

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
