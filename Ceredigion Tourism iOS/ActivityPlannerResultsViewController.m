//
//  ActivityPlannerResultsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerResultsViewController.h"
#import "ActivityPlannerController.h"
#import "Attraction.h"

@interface ActivityPlannerResultsViewController ()
@property (strong, nonatomic) NSArray *plannerResults;
@property (strong, nonatomic) IBOutlet UITableView *activityResultsTableView;

@end

@implementation ActivityPlannerResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _activityResultsTableView.delegate = self;
    _activityResultsTableView.dataSource = self;
}

- (void)completedSetupWithActivityPlan:(ActivityPlan *)plan
{
    NSLog(@"Here with a plan for a location: %@", plan.location);
    ActivityPlannerController *planController = [[ActivityPlannerController alloc] initWithPlan:plan];
    
    _plannerResults = [[NSArray alloc] init];
    _plannerResults = [planController generateActivityList];
    NSLog(@"Number of planner results are: %i", [_plannerResults count]);
    [_activityResultsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Only want a single section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _plannerResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Attraction *thisAttraction = [_plannerResults objectAtIndex:indexPath.row];
    NSLog(@"This is called");
    NSLog(@"With the attraction: %@", thisAttraction.name);
    NSString *CellIdentifier = @"activityPlannerResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = thisAttraction.name;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    cell.imageView.image = [self returnColorImageFromAttractionGroup:thisAttraction.group];
    
    // add in the cell accessory view
    
    return cell;
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    return [colourAttractionObj getAttractionGroupImage:group];
}

@end
