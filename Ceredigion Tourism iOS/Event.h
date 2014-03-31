//
//  Event.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 12/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
@property (nonatomic) int id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *descriptionText;
@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSString *endDate;
@property (strong, nonatomic) NSString *startTime;
@property (strong, nonatomic) NSString *endTime;
@property (strong, nonatomic) NSDate *startDateTime;
@property (strong, nonatomic) NSDate *endDateTime;
@property (nonatomic) int allDay;

- (NSDate *) getStartAsNSDate;
- (NSDate *) getEndAsNSDate;
@end
