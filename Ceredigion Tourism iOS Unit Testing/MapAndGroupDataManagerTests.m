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
    [_groupDataManager storeDefaultAllowedGroupsInPlistForAttractionPlanner:NO];
    
    // fetch what was stored, and fetch the absolute default to check.
    NSArray *returnedDefaultGroups = [_groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:NO];
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
    [_groupDataManager storeAllowedGroupsInPlist:groupsToStore forAttractionPlanner:NO];
    
    // get the contents of the stored Plist
    NSArray *returnedGroupsFromPlist = [_groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:NO];
    
    // put the two arrays into sets to compare them
    NSSet *storedGroupsSet = [NSSet setWithArray:groupsToStore];
    NSSet *returnedGroupsSet = [NSSet setWithArray:returnedGroupsFromPlist];
    
    XCTAssert([storedGroupsSet isEqualToSet:returnedGroupsSet], @"The selected groups are stored to Plist correctly.");
}

- (void)testToggleGroupInAllowedGroups
{
    NSArray *expectedAllowedGroups = @[@"Accommodation", @"Arts & crafts", @"Attraction", @"Camp & caravan", @"Food & drink", @"Retail"];
    // store the default
    [_groupDataManager storeDefaultAllowedGroupsInPlistForAttractionPlanner:NO];
    
    // toggle one (remove)
    [_groupDataManager toggleGroupInAllowedGroups:@"Activity" forAttractionPlanner:NO];
    
    NSArray *allowedGroupsResult = [_groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:NO];
    
    bool isArrayTheSame = [allowedGroupsResult isEqualToArray:expectedAllowedGroups];
    
    XCTAssertTrue(isArrayTheSame, @"The returned array matches the expect array reuslt.");
}

- (void)testGetAllowedGroupsFromPlist
{
    NSArray *expectedAllowedGroups = @[@"Accommodation", @"Activity", @"Arts & crafts", @"Attraction", @"Camp & caravan", @"Food & drink", @"Retail"];
    // store the default
    [_groupDataManager storeDefaultAllowedGroupsInPlistForAttractionPlanner:NO];
    
    NSArray *allowedGroupsResult = [_groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:NO];
    
    bool isArrayTheSame = [allowedGroupsResult isEqualToArray:expectedAllowedGroups];
    
    XCTAssertTrue(isArrayTheSame, @"The returned array from getAllowedGroups... matches the expect array reuslt.");
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
    int expectedMeters = 48341;
    
    CLLocationCoordinate2D firstPoint = CLLocationCoordinate2DMake(52.125529, -4.589009);
    CLLocationCoordinate2D secondPoint = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    
    double returnedDistance = [_mapDataManager getDistanceInMetersFrom:firstPoint to:secondPoint];
    int returnedDistanceInt = (int)returnedDistance;
    
    XCTAssertEqual(expectedMeters, returnedDistanceInt, @"The returned distance matches the expected value");
}

- (void)testStoreGetMapRadiusCoordinatesFromPlist
{
    CLLocationCoordinate2D coordinatesToStore = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    [_mapDataManager storeMapRadiusCoordinatesInPlist:coordinatesToStore];
    
    CLLocationCoordinate2D receivedCoordinatesFromPlist = [_mapDataManager getMapRadiusCoordinatesFromPlist];
    
    bool isSuccessful = FALSE;
    
    double sentLat = coordinatesToStore.latitude;
    double sentLong = coordinatesToStore.longitude;
    double receivedLat = receivedCoordinatesFromPlist.latitude;
    double receivedLong = receivedCoordinatesFromPlist.longitude;

    // can't really compare floating point numbers due to accuracy.
    // so use fabs to make sure the difference between them is a minute number that doesn't affect the coordinate accuracy.
    if((fabs(sentLat - receivedLat) <= 0.000001) && (fabs(sentLong - receivedLong) <= 0.000001)){
        isSuccessful = TRUE;
    }

    XCTAssertTrue(isSuccessful, @"The coordinates from the Plist match those that were sent to be stored.");
}

// WARNING - this test will fail if the application is removed from the iPhone Simulator.
- (void)testGetPlistFilePath
{
    NSString *expectedFilePath = @"/Users/edparry/Library/Application Support/iPhone Simulator/7.1/Applications/98043B10-2092-4F7B-B331-7933084B918D/Documents/allowed_groups";
    
    NSString *returnedFilePath = [_mapDataManager getPlistFilePath:@"allowed_groups"];
    NSLog(@"File path: %@", returnedFilePath);
    
    bool isFilePathEqual = [returnedFilePath isEqualToString:expectedFilePath];
    XCTAssertTrue(isFilePathEqual, @"The returned file path matches the expected value");
}

@end