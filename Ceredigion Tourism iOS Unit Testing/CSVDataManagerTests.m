//
//  CSVDataManagerTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/04/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSVDataManager.h"

@interface CSVDataManagerTests : XCTestCase
@property CSVDataManager *csvManager;
@end

@implementation CSVDataManagerTests

- (void)setUp
{
    [super setUp];
    _csvManager = [[CSVDataManager alloc] init];
}

- (void)tearDown
{
    _csvManager = nil;
    [super tearDown];
}

- (void)testSaveAndGetLastFetchedDate
{
// - (void)saveLastFetchedDate:(NSString *)date;
    NSString *dateToSave = @"2014-03-20";
    
    [_csvManager saveLastFetchedDate:dateToSave];
    
    NSDate *returnedDate = [_csvManager getLastFetchedDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *returnedDateString = [dateFormatter stringFromDate:returnedDate];
    
    bool isReturnedDateCorrect = [returnedDateString isEqualToString:dateToSave];
    
    XCTAssertTrue(isReturnedDateCorrect, @"The returned date matches that that was saved as the last fetched date");
}

- (void)testGetTodaysDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dateToCompare = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *returnedDate = [_csvManager getTodaysDate];
    
    bool isReturnedDateToday = [returnedDate isEqualToString:dateToCompare];
    
    XCTAssertTrue(isReturnedDateToday, @"The returned date matches the expected value");
}

@end
