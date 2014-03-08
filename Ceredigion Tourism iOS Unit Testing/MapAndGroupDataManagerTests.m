//
//  MapAndGroupDataManagerTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GroupDataManager.h"
#import "MapDataManager.h"
#import "CoreDataManager.h"

@interface MapAndGroupDataManagerTests : XCTestCase
@property GroupDataManager *groupDataManager;
@property MapDataManager *mapDataManager;
@property CoreDataManager *dataManager;
@property NSArray *defaultGroups;
@end

@implementation MapAndGroupDataManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

// Group Data Manager
- (void)testStoreDefaultAllowedGroupsInPlist
{
    // set up for the test.
    _groupDataManager = [[GroupDataManager alloc] init];
    _dataManager = [[CoreDataManager alloc] init];

    // run the method, to store the defaults.
    [_groupDataManager storeDefaultAllowedGroupsInPlist];
    
    // fetch what was stored, and fetch the absolute default to check.
    NSArray *returnedDefaultGroups = [_groupDataManager getAllowedGroupsFromPlist];
    NSArray *defaultGroups = [_dataManager getAllAttractionGroupTypes];
    
    // check that the returned array is equal to the default groups array.
    NSSet *defaultGroupsSet = [NSSet setWithArray:defaultGroups];
    NSSet *returnedDefaultGroupsSet = [NSSet setWithArray:returnedDefaultGroups];

    XCTAssert([defaultGroupsSet isEqualToSet:returnedDefaultGroupsSet], @"The stored array is working correctly.");
}

- (void)testStoreAllowedGroupsInPlist
{
// - (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups;
}

- (void)testToggleGroupInAllowedGroups
{
// - (void)toggleGroupInAllowedGroups:(NSString *)group;
}

- (void)testGetAllowedGroupsFromPlist
{
    
    
    
// - (NSArray *)getAllowedGroupsFromPlist;
}


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
