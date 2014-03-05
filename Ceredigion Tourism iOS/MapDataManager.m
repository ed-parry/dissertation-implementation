//
//  MapDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 05/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "MapDataManager.h"

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

@end
