//
//  MapDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 05/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface MapDataManager : NSObject
- (id)initWithCurrentRadiusCenter:(CLLocationCoordinate2D)currentRadiusCenter andRadiusInMeters:(double)radiusInMeters;

- (double)changeMilesToMeters:(double)miles;
- (BOOL)isCoordinatesWithinRadius:(CLLocationCoordinate2D)coordinates;
- (double)getDistanceInMetersFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint;

- (double) getMapRadiusMetersFromPlist;
- (void) storeDefaultMapRadiusMetersInPlist;
- (void) storeMapRadiusMetersInPlist:(double)mapRadius;

- (CLLocationCoordinate2D) getMapRadiusCoordinatesFromPlist;
- (void)storeMapRadiusCoordinatesInPlist:(CLLocationCoordinate2D)coordinates;

- (NSString *)getPlistFilePath:(NSString *)fileName;
@end
