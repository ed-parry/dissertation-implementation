//
//  ActivityPlannerResultsViewController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActivityPlan.h"

@interface AttractionPlannerResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
- (void)completedSetupWithActivityPlan:(ActivityPlan *)plan;
@end
