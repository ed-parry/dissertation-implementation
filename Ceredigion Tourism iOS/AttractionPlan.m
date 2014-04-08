//
//  AttractionPlan.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionPlan.h"

@implementation AttractionPlan
- (bool)isComplete
{
    if(([self.location length] > 0) && ([self.startDate length] > 0) && ([self.adrenalineLevel length] > 0) && ([self.selectedGroups count] > 0)){
        if((self.days > 0) && (self.numberOfActivities > 0)){
            if(self.locationCoordinates.latitude != 0.000000){
                return YES;
            }
            else{
                return NO;
            }
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}

@end