//
//  ActivityPlanObjectTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 27/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ActivityPlan.h"

@interface ActivityPlanObjectTests : XCTestCase
    @property ActivityPlan *plan;
@end

@implementation ActivityPlanObjectTests

- (void)setUp
{
    [super setUp];
    _plan = [[ActivityPlan alloc] init];
    
    _plan.location = @"";
    _plan.locationCoordinates = CLLocationCoordinate2DMake(0.00000, 0.00000);
    _plan.startDate = @"2014-03-26";
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

- (void)testIsComplete
{
    XCTAssertTrue([_plan isComplete], @"There's a full and complete Activity Plan.");
}

@end
