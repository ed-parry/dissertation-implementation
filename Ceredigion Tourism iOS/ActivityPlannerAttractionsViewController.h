//
//  ActivityPlannerAttractionsViewController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityPlan.h"

@interface ActivityPlannerAttractionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
- (void)continuePlannerWithPlan:(ActivityPlan *)currentPlan;
@end
