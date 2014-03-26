//
//  ActivityPlannerController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityPlan.h"

@interface ActivityPlannerController : NSObject
- (NSArray *)generateActivityListFromPlan:(ActivityPlan *)plan;
@end
