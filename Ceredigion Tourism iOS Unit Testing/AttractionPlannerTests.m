//
//  AttractionPlannerTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 04/04/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Attraction.h"
#import "AttractionPlan.h"
#import "AttractionPlannerController.h"

@interface AttractionPlannerTests : XCTestCase
@property AttractionPlan *plan;
@property AttractionPlannerController *plannerController;
@end

@implementation AttractionPlannerTests

- (void)setUp
{
    [super setUp];
    _plan = [[AttractionPlan alloc] init];
    
    _plan.location = @"Aberaeron";
    _plan.locationCoordinates = CLLocationCoordinate2DMake(52.4162226, -4.0627321);
    _plan.startDate = @"04-06-14";
    _plan.days = [NSNumber numberWithInt:10];
    _plan.selectedGroups = @[@"Activity", @"Accommodation", @"Retail"];
    _plan.adrenalineLevel = @"amber";
    _plan.numberOfActivities = [NSNumber numberWithInt:7];
    
    _plannerController = [[AttractionPlannerController alloc] initWithPlan:_plan];
}

- (void)tearDown
{
    [super tearDown];
    _plan = nil;
    _plannerController = nil;
}

- (void)testGenerateActivityList
{
    // this test will only check that the returned list is:
    //  - of the correct length
    //  - doesn't have any of the higher adrenaline levels
    //  - doesn't have any attractions of groups not selected
    
    NSArray *activityList = [_plannerController generateActivityList];
    
    bool isListOfCorrectLength = ([activityList count] == [_plan.numberOfActivities intValue]);
    
    bool isListOfCorrectAdrenalineLevels = YES;
    bool isListFreeOfUnselectedGroups = YES;
    for(Attraction *temp in activityList){
        if([temp.adrenalineLevel isEqualToString:@"red"]){
            isListOfCorrectAdrenalineLevels = NO;
        }
        if(![_plan.selectedGroups containsObject:temp.group]){
            isListFreeOfUnselectedGroups = NO;
        }
    }
    
    bool generatedListIsCorrect;
    if((isListOfCorrectLength) && (isListOfCorrectAdrenalineLevels) && (isListFreeOfUnselectedGroups)){
        generatedListIsCorrect = TRUE;
    }
    
    XCTAssertTrue(generatedListIsCorrect, @"The returned activity list is suitably correct.");
}

-(void)testGenerateEventsList
{
    // this test will only check to see that events are being returned
    NSArray *eventsList = [_plannerController generateEventsList];
    
    bool generatedListIsCorrect;
    if([eventsList count] >= 1){
        generatedListIsCorrect = true;
    }
    XCTAssertTrue(generatedListIsCorrect, @"The returned events list is suitably correct.");
}

- (void)testReturnLowerAndIncludedAdrenalineLevelsThanLevel
{
    NSString *selectedChosenAdrenalineLevel = @"amber";
    NSArray *expectedAdrenalineLevels = [[NSArray alloc] initWithObjects:@"amber", @"green", @"none", nil];
    
    NSArray *receivedResults = [[NSArray alloc] initWithArray:[_plannerController returnLowerAndIncludedAdrenalineLevelsThan:selectedChosenAdrenalineLevel]];
    
    bool areArraysTheSame = [receivedResults isEqualToArray:expectedAdrenalineLevels];
    
    XCTAssertTrue(areArraysTheSame, @"The returned array matches the expected results for the 'returnLowerAndIncludedAdrenalineLevels' function");
    
}

- (void)testReturnHigherAdrenalineLevelsThanLevel
{
    NSString *selectedChosenAdrenalineLevel = @"green";
    NSArray *expectedAdrenalineLevels = [[NSArray alloc] initWithObjects:@"red", @"amber", nil];
    
    NSArray *receivedResults = [[NSArray alloc] initWithArray:[_plannerController returnHigherAdrenalineLevelsThan:selectedChosenAdrenalineLevel]];
    
    bool areArraysTheSame = [receivedResults isEqualToArray:expectedAdrenalineLevels];
    
    XCTAssertTrue(areArraysTheSame, @"The returned array matches the expected results for the 'returnHigherAdrenalineLevels' function");
}

- (void)testReturnTopNumberFromArray
{
    NSArray *providedArray = [[NSArray alloc] initWithObjects:@"first", @"second", @"third", @"fourth", @"fifth", @"sixth", @"seventh", nil];
    NSArray *expectedResult = [[NSArray alloc] initWithObjects:@"first", @"second", @"third", @"fourth", nil];
    
    NSArray *returnedArray = [[NSArray alloc] initWithArray:[_plannerController returnTopNumber:[NSNumber numberWithInt:4] fromArray:providedArray]];

    bool areArraysTheSame = [returnedArray isEqualToArray:expectedResult];
    
    XCTAssertTrue(areArraysTheSame, @"The returned array matches the expected results for the 'returnTopNumberFromArray' function");
}

@end
