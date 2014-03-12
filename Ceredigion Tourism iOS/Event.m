//
//  Event.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 12/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "Event.h"

@implementation Event

- (NSDate *) getStartAsNSDate
{
    if([self.startTime length] == 0){
        self.startTime = @"00:00";
    }
    NSString *tempStartDateTime = [NSString stringWithFormat:@"%@ %@",self.startDate,self.startTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
    NSDate* startDateTime = [dateFormatter dateFromString:tempStartDateTime];
    
    return startDateTime;
}

- (NSDate *) getEndAsNSDate
{
    if([self.endTime length] == 0){
        self.endTime = @"00:00";
    }
    NSString *tempEndDateTime = [NSString stringWithFormat:@"%@ %@",self.startDate,self.startTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
    NSDate* endDateTime = [dateFormatter dateFromString:tempEndDateTime];
    
    return endDateTime;
}

@end
