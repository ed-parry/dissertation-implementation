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
    // set up for the tests.
    _groupDataManager = [[GroupDataManager alloc] init];
    _dataManager = [[CoreDataManager alloc] init];
    _mapDataManager = [[MapDataManager alloc] init];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

// Group Data Manager
- (void)testStoreDefaultAllowedGroupsInPlist
{


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
    
    // create a test array to store to the plist.
    NSArray *groupsToStore = @[@"Retail", @"Activities", @"Accommodation"];
    
    // store the array to the Plist
    [_groupDataManager storeAllowedGroupsInPlist:groupsToStore];
    
    // get the contents of the stored Plist
    NSArray *returnedGroupsFromPlist = [_groupDataManager getAllowedGroupsFromPlist];
    
    // put the two arrays into sets to compare them
    NSSet *storedGroupsSet = [NSSet setWithArray:groupsToStore];
    NSSet *returnedGroupsSet = [NSSet setWithArray:returnedGroupsFromPlist];
    
    XCTAssert([storedGroupsSet isEqualToSet:returnedGroupsSet], @"The selected groups are stored to Plist correctly.");
}

- (void)testToggleGroupInAllowedGroups
{
// - (void)toggleGroupInAllowedGroups:(NSString *)group;
}

- (void)testGetAllowedGroupsFromPlist
{
    
    
    
// - (NSArray *)getAllowedGroupsFromPlist;
}

- (void)testMilesToMeters
{
    double miles = 10;
    double metersExpectedResult = 16093.44;
    
    double metersReceivedResult = [_mapDataManager changeMilesToMeters:miles];
    
    XCTAssertEqual(metersReceivedResult, metersExpectedResult, @"The converted meters matches the expected result.");
}

- (void)testMetersToMiles
{
    double meters = 33796.224;
    double milesExpectedResult = 21;
    
    double milesReceivedResult = [_mapDataManager changeMetersToMiles:meters];
    
    XCTAssertEqual(milesReceivedResult, milesExpectedResult, @"The converted miles matches the expected result.");
}

- (void)testStoreAndGetMapRadiusCoordinatesFromPlist
{
    // store a value in the Plist
    double mapRadiusValue = 12;
    [_mapDataManager storeMapRadiusMilesInPlist:mapRadiusValue];

    // get it back and compare
    double returnedMapRadiusValue = [_mapDataManager getMapRadiusMilesFromPlist];
    
    XCTAssertEqual(mapRadiusValue, returnedMapRadiusValue, @"The returned map radius from the Plist is the expected value.");
}

- (void)testStoreDefaultMapRadiusMetersInPlist
{
    [_mapDataManager storeDefaultMapRadiusMilesInPlist];
    double defaultRadiusMilesValue = 10;
    
    double returnedMapRadiusValue = [_mapDataManager getMapRadiusMilesFromPlist];
    
    XCTAssertEqual(defaultRadiusMilesValue, returnedMapRadiusValue, @"The returned map radius is the default value expected.");
}

- (void)testIsCoordinatesWithinRadius
{
    CLLocationCoordinate2D radiusCenter = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    
    // 16093.44 meters = 10 miles, default value.
    _mapDataManager = [[MapDataManager alloc] initWithCurrentRadiusCenter:radiusCenter andRadiusInMeters:16093.44];
    
    CLLocationCoordinate2D newPointCoordinates = CLLocationCoordinate2DMake(52.355979, -4.0321255);
    
    bool isWithinRadius = [_mapDataManager isCoordinatesWithinRadius:newPointCoordinates];
    
    XCTAssertTrue(isWithinRadius, @"The supplied coordinates are within the set radius.");
}

- (void)testIsCoordinatesOutsideRadius
{
    CLLocationCoordinate2D radiusCenter = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    
    // 16093.44 meters = 10 miles, default value.
    _mapDataManager = [[MapDataManager alloc] initWithCurrentRadiusCenter:radiusCenter andRadiusInMeters:16093.44];
    
    // this point is about 22 miles away from the location center.
    CLLocationCoordinate2D newPointCoordinates = CLLocationCoordinate2DMake(52.125529, -4.589009);
    
    bool isWithinRadius = [_mapDataManager isCoordinatesWithinRadius:newPointCoordinates];
    
    XCTAssertFalse(isWithinRadius, @"The supplied coordinates are outside of the set radius.");
}

- (void)testGetDistanceInMetersFromXToY
{
//  - (double)getDistanceInMetersFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint;
}

- (void)testStoreGetMapRadiusCoordinatesFromPlist
{
//    - (CLLocationCoordinate2D) getMapRadiusCoordinatesFromPlist;
//    - (void)storeMapRadiusCoordinatesInPlist:(CLLocationCoordinate2D)coordinates;
}

- (void)testGetPlistFilePath
{
//     - (NSString *)getPlistFilePath:(NSString *)fileName;
}

@end