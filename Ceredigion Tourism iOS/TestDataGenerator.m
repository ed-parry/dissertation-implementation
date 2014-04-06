//
//  TestDataGenerator.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/04/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "TestDataGenerator.h"
#import "CoreDataManager.h"
#import "Event.h"
#import "Attraction.h"

@interface TestDataGenerator ()
    @property CoreDataManager *coreDataManager;
@end

@implementation TestDataGenerator

// only produces events with an id, title, description and start/end dates, because that's what we care about for the calendar.
- (void)generateTestEvents:(int)numberToGenerate
{
    _coreDataManager = [[CoreDataManager alloc] init];
    for(int i = 0; i < numberToGenerate; i++){
        Event *testEvent = [[Event alloc] init];
        testEvent.id = i+5;
        testEvent.title = [NSString stringWithFormat:@"Test Event %i", i];
        testEvent.descriptionText = [NSString stringWithFormat:@"Test event description for event number %i", i];
        
        NSDate *today = [NSDate date];
        int daysToAddToStart = arc4random_uniform(90) + 1;
        int daysToAddToEnd = arc4random_uniform(5) + 1;
        NSDate *testStartDate = [today dateByAddingTimeInterval:60*60*24*daysToAddToStart];
        NSDate *testEndDate = [testStartDate dateByAddingTimeInterval:60*60*24*daysToAddToEnd];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yy"];
        NSString *startDate = [dateFormatter stringFromDate:testStartDate];
        NSString *endDate = [dateFormatter stringFromDate:testEndDate];
        
        testEvent.startDate = startDate;
        testEvent.endDate = endDate;
        
        [_coreDataManager addEventToCoreData:testEvent];
    }
}

- (void)generateTestAttractions:(int)numberToGenerate
{
    
}
@end
