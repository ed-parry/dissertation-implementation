//
//  DataTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface DataTests : XCTestCase

@end

@implementation DataTests

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

- (void)testTwelveNumber
{
    int twelve = 12;
    XCTAssertEqual(twelve, 12, @"check that twelve is equal to 12");
    // comment added here.
}

@end
