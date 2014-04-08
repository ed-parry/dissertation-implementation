//
//  AttractionPlannerAttractionsViewController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttractionPlan.h"

@interface AttractionPlannerAttractionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
- (void)continuePlannerWithPlan:(AttractionPlan *)currentPlan;
@end
