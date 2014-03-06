//
//  MapDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 05/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "MapDataManager.h"
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

- (BOOL)isCoordinatesWithinRadius:(CLLocationCoordinate2D)coordinates
{
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

- (double)getDistanceInMetersFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint
{
    CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstPoint.latitude longitude:firstPoint.longitude];
    CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondPoint.latitude longitude:secondPoint.longitude];
    
    double distanceInMeters = [firstLocation distanceFromLocation:secondLocation];
    
    return distanceInMeters;
}

- (double) getMapRadiusFromPlist
{
    NSString *filePath = [self mapSettingsPlistFilePath];
    NSArray *mapRadiusArray;
    
    // get the file contents
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        mapRadiusArray = [[NSArray alloc] initWithContentsOfFile:filePath];
    }
    NSString *mapRadiusString = [mapRadiusArray objectAtIndex:0];
    double mapRadius = [mapRadiusString doubleValue];
    
    return mapRadius;
}

- (void) storeDefaultMapRadiusInPlist
{
    [self storeMapRadiusInPlist:10];
}

- (void) storeMapRadiusInPlist:(double)mapRadius
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
    
    [mapRadiusArray writeToFile:[self mapSettingsPlistFilePath] atomically:YES];
}

- (NSString *)mapSettingsPlistFilePath {
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"map_settings"];
}

@end
