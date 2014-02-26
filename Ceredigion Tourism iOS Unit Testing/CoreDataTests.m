//
//  DataTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreDataManager.h"

@interface CoreDataTests : XCTestCase

@end

@implementation CoreDataTests

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

- (void)testStripHTMLFromString
{
    NSString *textWithHtml = @"Hello<p>world!</p>";
    CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
    NSString *textWithoutHtml = [coreDataManager stripHTMLFromString:textWithHtml];
    
    XCTAssertEqualObjects(textWithoutHtml, @"Hello world! ", @"Testing the removal of HTML from a string");
}

@end
