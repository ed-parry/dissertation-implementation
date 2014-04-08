//
//  EventAndDateFormatManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventAndDateFormatManager : NSObject
- (NSString *)getTextualDate:(NSString *)date forCalendar:(bool)calendar;
- (NSString *)switchDateStringOrder:(NSString *)date;
- (NSArray *)returnEventsForSelectedDay:(NSString *)date;
- (NSArray *)makeArrayOfDatesStartingFrom:(NSString *)date forNumberOfDays:(int)days;
- (NSArray *)getAllEventFillerDatesBetween :(NSDate *)startDate and :(NSDate *)endDate;
@end
