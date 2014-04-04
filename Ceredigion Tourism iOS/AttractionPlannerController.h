//
//  ActivityPlannerController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AttractionPlan.h"

@interface AttractionPlannerController : NSObject
- (id)initWithPlan:(AttractionPlan *)plan;
- (NSArray *)generateActivityList;
- (NSArray *)generateEventsList;

- (NSArray *)returnLowerAndIncludedAdrenalineLevelsThan:(NSString *)adrenalineLevel;
- (NSArray *)returnHigherAdrenalineLevelsThan:(NSString *)adrenalineLevel;
- (NSMutableArray *)returnTopNumber:(NSNumber *)number fromArray:(NSArray *)array;
@end
