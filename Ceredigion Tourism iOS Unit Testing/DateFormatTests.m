//
//  DateFormatTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EventAndDateFormatManager.h"

@interface DateFormatTests : XCTestCase
@property EventAndDateFormatManager *dateManager;
@end

@implementation DateFormatTests

- (void)setUp
{
    [super setUp];
    _dateManager = [[EventAndDateFormatManager alloc] init];
}

- (void)tearDown
{
    _dateManager = nil;
    [super tearDown];
}

- (void)testGetTextualDateWithoutYear
{
    NSString *numericalDate = @"2014-01-02";
    NSString *receivedTextualDate = [_dateManager getTextualDate:numericalDate withYear:NO];
    NSLog(@"Returned string date: %@", receivedTextualDate);
    
    BOOL areStringsEqual = NO;
    
    if([receivedTextualDate isEqualToString:@"2nd of January"]){
        areStringsEqual = YES;
    }
    
    XCTAssertTrue(areStringsEqual, @"The returned textual date matches the string expected.");
}

- (void)testGetTextualDateWithYear
{
    NSString *numericalDate = @"2014-01-02";
    NSString *receivedTextualDate = [_dateManager getTextualDate:numericalDate withYear:YES];
    NSLog(@"Returned string date: %@", receivedTextualDate);
    
    BOOL areStringsEqual = NO;
    
    if([receivedTextualDate isEqualToString:@"2nd of January, 2014"]){
        areStringsEqual = YES;
    }
    
    XCTAssertTrue(areStringsEqual, @"The returned textual date matches the string expected.");
}

- (void)testSwitchDateStringOrder
{
    NSString *originalDate = @"2014-10-01";
    NSString *returnedSwitchedDate = [_dateManager switchDateStringOrder:originalDate];
    BOOL areStringsEqual = NO;
    
    if([returnedSwitchedDate isEqualToString:@"01-10-2014"]){
        areStringsEqual = YES;
    }
    
    XCTAssertTrue(areStringsEqual, @"The returned switch date matches the string expected.");

}

@end
