//
//  MapDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 05/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "MapDataManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"

@interface MapDataManager ()
    @property CLLocationCoordinate2D currentRadiusCenter;
    @property double currentRadiusInMeters;
@end

@implementation MapDataManager

- (id)initWithCurrentRadiusCenter:(CLLocationCoordinate2D)currentRadiusCenter andRadiusInMeters:(double)radiusInMeters
{
    _currentRadiusCenter = currentRadiusCenter;
    _currentRadiusInMeters = radiusInMeters;
    return self;
}

- (double)changeMilesToMeters:(double)miles
{
    if(miles > 0){
        double km = miles * 1.609344;
        double meters = km * 1000;
        
        return meters;
    }
    else{
        return 0;
    }
}

- (double)changeMetersToMiles:(double)meters
{
    double km = meters / 1000;
    double miles = km / 1.609344;
    return miles;
}

- (BOOL)isCoordinatesWithinRadius:(CLLocationCoordinate2D)coordinates
{
    if(_currentRadiusInMeters == 0){
        return YES;
    }
    else{
        CLLocationCoordinate2D circleCenter = _currentRadiusCenter;
        double circleRadius = _currentRadiusInMeters;
        
        double distanceFromMiddle = [self getDistanceInMetersFrom:circleCenter to:coordinates];
        
        if(distanceFromMiddle <= circleRadius){
            // It's inside the radius
            return YES;
        }
        else{
            // It's outside of the radius.
            return NO;
        }
    }
}

- (double)getDistanceInMetersFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint
{
    CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstPoint.latitude longitude:firstPoint.longitude];
    CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondPoint.latitude longitude:secondPoint.longitude];
    
    double distanceInMeters = [firstLocation distanceFromLocation:secondLocation];
    
    return distanceInMeters;
}

- (double) getMapRadiusMetersFromPlist
{
    NSString *filePath = [self getPlistFilePath:@"map_radius_miles"];
    NSArray *mapRadiusArray;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        mapRadiusArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    }
    NSString *mapRadiusString = [mapRadiusArray objectAtIndex:0];
    
    double mapRadiusInMiles = [mapRadiusString doubleValue];
    double mapRadiusInMeters = [self changeMilesToMeters:mapRadiusInMiles];
    
    return mapRadiusInMeters;
}

// Only used for the settings view controller
- (double) getMapRadiusMilesFromPlist
{
    double mapRadiusMeters = [self getMapRadiusMetersFromPlist];
    double mapRadiusInMiles = [self changeMetersToMiles:mapRadiusMeters];
    
    return mapRadiusInMiles;
}

- (CLLocationCoordinate2D) getMapRadiusCoordinatesFromPlist
{
    CLLocationCoordinate2D mapRadiusCoordinates;
    
    NSString *filePath = [ self getPlistFilePath:@"map_radius_coordinates"];
    NSArray *mapRadiusCoordinatesArray;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        mapRadiusCoordinatesArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    }
    
    NSString *coordLat = [mapRadiusCoordinatesArray objectAtIndex:0];
    NSString *coordLong = [mapRadiusCoordinatesArray objectAtIndex: 1];
    
    mapRadiusCoordinates.latitude = [coordLat doubleValue];
    mapRadiusCoordinates.longitude = [coordLong doubleValue];
    
    return mapRadiusCoordinates;
}

- (void)storeMapRadiusCoordinatesInPlist:(CLLocationCoordinate2D)coordinates
{
    NSArray *radiusCoordinatesArray;
    NSString *coordinateLat = [NSString stringWithFormat:@"%f", coordinates.latitude];
    NSString *coordinateLong = [NSString stringWithFormat:@"%f", coordinates.longitude];
    
    radiusCoordinatesArray = [[NSArray alloc] initWithObjects:coordinateLat, coordinateLong, nil];
    
    [radiusCoordinatesArray writeToFile:[self getPlistFilePath:@"map_radius_coordinates"] atomically:YES];
}

- (void) storeDefaultMapRadiusMilesInPlist
{
    [self storeMapRadiusMilesInPlist:10.0];
}

- (void) storeMapRadiusMilesInPlist:(double)mapRadius
{
    NSString *mapRadiusString;
    NSArray *mapRadiusArray;

    if(mapRadius == 0){
        mapRadiusString = [NSString stringWithFormat:@"none"];
        mapRadiusArray = [[NSArray alloc] initWithObjects:mapRadiusString, nil];
    }
    else{
        mapRadiusString = [NSString stringWithFormat:@"%f", mapRadius];
        mapRadiusArray = [[NSArray alloc] initWithObjects:mapRadiusString, nil];
    }
    [mapRadiusArray writeToFile:[self getPlistFilePath:@"map_radius_miles"] atomically:YES];
}

- (NSString *)getPlistFilePath:(NSString *)fileName
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

#pragma mark Coordinates and Location methods
- (CLLocationCoordinate2D)getCoordinatesForAddressLocation:(NSString *)location
{
    // accessible from within the block.
    __block CLLocationCoordinate2D locationCoordinates;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            locationCoordinates = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
        }
    }];
    return locationCoordinates;
}

@end