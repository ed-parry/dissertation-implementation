//
//  ActivityPlannerController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerController.h"

@interface ActivityPlannerController ()
@property ActivityPlan *thisPlan;
@end

@implementation ActivityPlannerController

- (id)initWithPlan:(ActivityPlan *)plan
{
    if(self){
        _thisPlan = [[ActivityPlan alloc] init];
        _thisPlan = plan;
    }
    
    return self;
}

- (NSArray *)generateActivityList
{
    NSMutableArray *activityList = [[NSMutableArray alloc] init];
    
    // need to figure out how to work this...should we fetch all activities/attractions, and then process in here? Or just grab what we want from Core Data from that manager?
    
    // EP - think from here.
    
    return activityList;
}


@end
