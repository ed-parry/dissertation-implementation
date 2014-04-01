//
//  DateFormatManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "EventAndDateFormatManager.h"
#import "CoreDataManager.h"

@interface EventAndDateFormatManager ()
@property CoreDataManager *dataManager;
@end

@implementation EventAndDateFormatManager


- (NSString *)getTextualDate:(NSString *)date withYear:(bool)withYear
{
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10- 8);
 
    NSInteger yearNumber = [[date substringToIndex:4] integerValue];
    NSInteger monthNumber = [[date substringWithRange:monthRange] integerValue];
    NSInteger dayNumber = [[date substringWithRange:dayRange] integerValue];
    
    dayNumber--; // current bug with the Vurig framework. This is the easiest fix.
    
    NSString *monthText = [self getTextMonthFromNumber:monthNumber];
    NSString *dayText = [self getTextDayFromNumber:dayNumber];
    
    if(withYear){
        return [NSString stringWithFormat:@"%@ of %@, %i", dayText, monthText, yearNumber];
    }
    else{
        return [NSString stringWithFormat:@"%@ of %@", dayText, monthText];
    }

}

- (NSString *)getTextDayFromNumber:(NSInteger)day
{
    
    day++;
    NSInteger remainder = day % 10;
    if (remainder == 1 && day != 11) {
        return [NSString stringWithFormat:@"%list", (long)day];
    }
    if (remainder == 2 && day != 12) {
        return [NSString stringWithFormat:@"%lind", (long)day];
    }
    if (remainder == 3 && day != 13) {
        return [NSString stringWithFormat:@"%lird", (long)day];
    }
    return [NSString stringWithFormat:@"%lith", (long)day];
}

- (NSString *)getTextMonthFromNumber:(NSInteger)month
{
    switch(month)
    {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)switchDateStringOrder:(NSString *)date
{
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10-8);
    
    NSString *yearSegment = [date substringWithRange:yearRange];
    NSString *monthSegment = [date substringWithRange:monthRange];
    NSString *daySegment = [date substringWithRange:dayRange];
    
    return [NSString stringWithFormat:@"%@-%@-%@", daySegment, monthSegment, yearSegment];
}

// EVENTS MANAGEMENT
- (NSArray *)returnEventsForSelectedDay:(NSString *)date
{
    NSMutableArray *daysEvents = [[NSMutableArray alloc] init];
    NSArray *allEvents;
    
    if(!_dataManager){
        _dataManager = [[CoreDataManager alloc] init];
    }
    allEvents = [[NSArray alloc] initWithArray:[_dataManager getAllEvents]];
    
    NSRange yearRange = NSMakeRange(2, 4-2);
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10-8);
    
    NSString *selectedDateDay = [date substringWithRange:dayRange];
    NSString *selectedDateMonth = [date substringWithRange:monthRange];
    NSString *selectedDateYear = [date substringWithRange:yearRange];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    
    for(Event *tempEvent in allEvents){
        
        if([tempEvent.startDate isEqualToString:tempEvent.endDate]){
            NSRange tempEventMonthRange = NSMakeRange(3, 5-3);
            NSRange tempEventYearRange = NSMakeRange(6, 8-6);
            NSString *tempEventDateDay = [tempEvent.startDate substringToIndex:2];
            NSString *tempEventDateMonth = [tempEvent.startDate substringWithRange:tempEventMonthRange];
            NSString *tempEventDateYear = [tempEvent.startDate substringWithRange:tempEventYearRange];
            
            if(([selectedDateDay isEqualToString:tempEventDateDay]) && ([selectedDateMonth isEqualToString:tempEventDateMonth]) && ([selectedDateYear isEqualToString:tempEventDateYear])){
                [daysEvents addObject:tempEvent];
            }
        }
        else{
            NSDate *startDate = [dateFormatter dateFromString:tempEvent.startDate];
            NSDate *endDate = [dateFormatter dateFromString:tempEvent.endDate];
            

            NSMutableArray *fillerDates = [[NSMutableArray alloc] initWithArray:[self getAllEventFillerDatesBetween:startDate and:endDate]];
            
            [fillerDates addObject:endDate];
            
            if([fillerDates count] == 2){
                for(NSDate *fillerTempDate in fillerDates){
                    NSString *fillerTempDateString = [NSString stringWithFormat:@"%@", fillerTempDate];
                    NSString *fillerTempDay = [fillerTempDateString substringWithRange:dayRange];
                    int fillerDay = [fillerTempDay intValue];
                    fillerDay++;
                    fillerTempDay = [NSString stringWithFormat:@"%i", fillerDay];
                    NSString *fillerTempMonth = [fillerTempDateString substringWithRange:monthRange];
                    if(([selectedDateDay isEqualToString:fillerTempDay]) && ([selectedDateMonth isEqualToString:fillerTempMonth])){
                        [daysEvents addObject:tempEvent];
                    }
                }
            }
            // deal with long events
            else if([fillerDates count] > 2){
                // the first date is wrong, so remove it
                [fillerDates removeObjectAtIndex:0];
                
                // add a new last date, because the actual last date is off by 1hour.
                NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
                dayComponent.day = 1;
                NSCalendar *theCalendar = [NSCalendar currentCalendar];
                NSDate *lastDate = [fillerDates lastObject];
                NSDate *dateToBeIncremented = [theCalendar dateByAddingComponents:dayComponent toDate:lastDate options:0];
                
                [fillerDates addObject:dateToBeIncremented];
                
                for(NSDate *fillerTempDate in fillerDates){
                    NSString *fillerTempDateString = [NSString stringWithFormat:@"%@", fillerTempDate];
                    NSString *fillerTempDay = [fillerTempDateString substringWithRange:dayRange];
                    
                    NSString *fillerTempMonth = [fillerTempDateString substringWithRange:monthRange];
                    if(([selectedDateDay isEqualToString:fillerTempDay]) && ([selectedDateMonth isEqualToString:fillerTempMonth])){
                        [daysEvents addObject:tempEvent];
                    }
                }
            }
            else{
                for(NSDate *fillerTempDate in fillerDates){
                    NSString *fillerTempDateString = [NSString stringWithFormat:@"%@", fillerTempDate];
                    NSString *fillerTempDay = [fillerTempDateString substringWithRange:dayRange];
                    NSString *fillerTempMonth = [fillerTempDateString substringWithRange:monthRange];
                    if(([selectedDateDay isEqualToString:fillerTempDay]) && ([selectedDateMonth isEqualToString:fillerTempMonth])){
                        [daysEvents addObject:tempEvent];
                    }
                }
            }
        }
    }
    
    return daysEvents;
}

- (NSArray *)makeArrayOfDatesStartingFrom:(NSString *)date forNumberOfDays:(int)days
{
    NSMutableArray *datesArray = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *startDate = [dateFormatter dateFromString:date];
    
    for(int i = 1; i < days; i++){
        [datesArray addObject:[startDate dateByAddingTimeInterval:60*60*24*i]];
    }

    return datesArray;
}

// this method should return a complete list of all NSDate's that have an event on them
// including the days between the start and end dates.
- (NSArray *)getAllEventFillerDatesBetween :(NSDate *)startDate and :(NSDate *)endDate
{
    NSMutableArray *fillerDates = [[NSMutableArray alloc] init];
    NSDate *nextDate;
    for ( nextDate = startDate ; [nextDate compare:endDate] < 0 ; nextDate = [nextDate dateByAddingTimeInterval:24*60*60] ) {
        [fillerDates addObject:nextDate];
    }
    
    return fillerDates;
}


@end
