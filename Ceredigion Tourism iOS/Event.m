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
    NSString *tempStartDateTime = [NSString stringWithFormat:@"%@ %@",self.startDate,self.startTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM-dd-yy hh:mm a"];
    
    NSDate* startDateTime = [dateFormatter dateFromString:tempStartDateTime];
    
    return startDateTime;
}

- (NSDate *) getEndAsNSDate
{
    NSString *tempEndDateTime = [NSString stringWithFormat:@"%@ %@",self.startDate,self.startTime];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"MM-dd-yy hh:mm a"];
    
    NSDate* endDateTime = [dateFormatter dateFromString:tempEndDateTime];
    
    return endDateTime;
}

@end
