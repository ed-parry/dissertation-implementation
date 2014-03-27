//
//  ActivityPlannerResultsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerResultsViewController.h"
#import "ActivityPlannerController.h"

@interface ActivityPlannerResultsViewController ()
@property (strong, nonatomic) NSArray *plannerResults;

@end

@implementation ActivityPlannerResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)completedSetupWithActivityPlan:(ActivityPlan *)plan
{
    NSLog(@"Here with a plan for a location: %@", plan.location);
    ActivityPlannerController *planController = [[ActivityPlannerController alloc] initWithPlan:plan];
    
    _plannerResults = [[NSArray alloc] init];
    _plannerResults = [planController generateActivityList];
    
    [self showResults];
}

- (void)showResults
{
    // set up the table here.
    // maybe have subtitles, of the group, and adrenaline levels?
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
