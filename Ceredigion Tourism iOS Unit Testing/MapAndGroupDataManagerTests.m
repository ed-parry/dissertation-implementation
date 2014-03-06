//
//  MapAndGroupDataManagerTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface MapAndGroupDataManagerTests : XCTestCase

@end

@implementation MapAndGroupDataManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

/* Functions to test from GroupDataManager
 *
 - (void)storeDefaultAllowedGroupsInPlist;
 - (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups;
 - (void)toggleGroupInAllowedGroups:(NSString *)group;
 - (NSArray *)getAllowedGroupsFromPlist;
 
 */

/* Functions from MapDataManager
 *
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
 
 */

@end
