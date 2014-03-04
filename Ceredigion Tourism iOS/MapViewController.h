//
//  MapViewController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapViewController : UIViewController
- (void)useSearchedAddress:(NSString *)address;
- (void)useCurrentLocationPosition:(CLLocationManager *)locationManager;
- (void)toggleGroupOnMap:(NSString *)group;
@end
