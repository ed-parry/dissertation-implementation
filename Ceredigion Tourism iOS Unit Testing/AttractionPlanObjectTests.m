//
//  ActivityPlanObjectTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 27/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ActivityPlan.h"

@interface AttractionPlanObjectTests : XCTestCase
    @property ActivityPlan *plan;
@end

@implementation AttractionPlanObjectTests

- (void)setUp
{
    [super setUp];
    _plan = [[ActivityPlan alloc] init];
    
    _plan.location = @"Aberaeron Harbour";
    _plan.locationCoordinates = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    _plan.startDate = @"26-03-14";
    _plan.days = [NSNumber numberWithInt:3];
    _plan.selectedGroups = @[@"Activity", @"Accommodation", @"Retail"];
    _plan.adrenalineLevel = @"medium";
    _plan.numberOfActivities = [NSNumber numberWithInt:8];
}

- (void)tearDown
{
    _plan = nil;
    [super tearDown];
}

- (void)testAttractionPlanLocation
{
    XCTAssertEqual(_plan.location, @"Aberaeron Harbour", @"Check the Attraction Plan location value");
}

- (void)testAttractionPlanLocationCoordinates
{
    bool areCoordinatesEqual;
    // can't really compare floating point numbers due to accuracy.
    // so use fabs to make sure the difference between them is a minute number that doesn't affect the coordinate accuracy.
    if((fabs(52.4162226 - _plan.locationCoordinates.latitude) <= 0.000001) && (fabs(-4.0627321 - _plan.locationCoordinates.longitude) <= 0.000001)){
        areCoordinatesEqual = TRUE;
    }
    
    XCTAssertTrue(areCoordinatesEqual, @"Check the Attraction Plan location coordinates");
}

- (void)testAttractionPlanStartDate
{
    XCTAssertEqual(_plan.startDate, @"26-03-14", @"Check the Attraction Plan start date");
}

- (void)testAttractionPlanDays
{
    XCTAssertEqual(_plan.days, [NSNumber numberWithInt:3], @"Check the Attraction Plan number of days");
}

- (void)testAttractionPlanSelectedGroups
{
    NSArray *expectedGroups = @[@"Activity", @"Accommodation", @"Retail"];

    bool areArraysEqual = [expectedGroups isEqualToArray:_plan.selectedGroups];
    
    XCTAssertTrue(areArraysEqual, @"Check the Attraction Plan selected groups");
}

- (void)testAttractionPlanAdrenalineLevels
{
    XCTAssertEqual(_plan.adrenalineLevel, @"medium", @"Check the Attraction Plan adrenaline level");
}

- (void)testAttractionPlanNumberOfActivities
{
    XCTAssertEqual(_plan.numberOfActivities, [NSNumber numberWithInt:8], @"Check the Attraction Plan number of activities");
}

@end
