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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
    _startDateTime = [dateFormatter dateFromString:[self startDateTimeString]];

    return _startDateTime;
}

- (NSDate *) getEndAsNSDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
    _endDateTime = [dateFormatter dateFromString:[self endDateTimeString]];

    return _endDateTime;
}



@end
