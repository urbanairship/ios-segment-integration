iOS Segment Integration Changelog
=================================

Version 2.1.0 - August 9, 2019
==============================
- Update track integration to set the transaction ID.
- Update identify to also set boolean attributes as tags in the tag group `segment-integration`

Version 2.0.0 - July 17, 2019
=============================
- Update Airship SDK dependency to 11.1.0

Version 1.3.0 - Feb 27, 2019
============================
- Enable passive registration
- Update Urban Airship SDK dependency to 10.2.0

Version 1.2.0 - May 22, 2018
============================
- Update Urban Airship SDK dependency to 9.1.0

Version 1.1.0 - April 18, 2017
==============================
- Remove extra dispatch_once call to prevent possible segment_wait_trap.
- Update Urban Airship SDK dependency to 8.2.2

Version 1.0.3 - Oct 12, 2016
============================
- Automatically call takeOff during didFinishLaunching with previous segment settings to
  ensure the UrbanAirship SDK is ready to handle incoming notifications.

Version 1.0.2 - Sep 30, 2016
============================
- Updated minimum library version

Version 1.0.1 - May 11, 2016
============================
- Example uses the integration
- Improved Airship take off
