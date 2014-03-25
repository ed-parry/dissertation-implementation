//
//  DateFormatManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "DateFormatManager.h"

@implementation DateFormatManager


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


@end
