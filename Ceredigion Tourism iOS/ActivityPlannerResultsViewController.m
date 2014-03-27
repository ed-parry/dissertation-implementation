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
    NSString *CellIdentifier = @"activityPlannerResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_plannerResults objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    cell.imageView.image = [self returnColorImageFromAttractionGroup:[_plannerResults objectAtIndex:indexPath.row]];
    
    // add in the cell accessory view
    
    return cell;
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    return [colourAttractionObj getAttractionGroupImage:group];
}

@end
