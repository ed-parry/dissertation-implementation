//
//  ActivityPlannerResultsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerResultsViewController.h"
#import "ActivityPlannerController.h"
#import "SingleAttractionEventViewController.h"
#import "Attraction.h"

@interface ActivityPlannerResultsViewController ()
@property (strong, nonatomic) NSArray *plannerResults;
@property (strong, nonatomic) NSArray *plannerEvents;
@property (strong, nonatomic) IBOutlet UITableView *activityResultsTableView;

@end

@implementation ActivityPlannerResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _activityResultsTableView.delegate = self;
    _activityResultsTableView.contentInset = UIEdgeInsetsZero;
    _activityResultsTableView.dataSource = self;
}

- (void)completedSetupWithActivityPlan:(ActivityPlan *)plan
{
    ActivityPlannerController *planController = [[ActivityPlannerController alloc] initWithPlan:plan];
    
    _plannerResults = [[NSArray alloc] init];
    _plannerResults = [planController generateActivityList];
    _plannerEvents = [planController generateEventsList];
    
    NSLog(@"Number of events: %i", [_plannerEvents count]);

    [_activityResultsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_plannerEvents count] > 0){
        return 2;
    }
    else{
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return @"Attractions";
    }
    else if (section == 1){
        return @"Nearby Events";
    }
    else{
        return @"Attractions";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return _plannerResults.count;
    }
    else if(section == 1){
        return _plannerEvents.count;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"activityPlannerResultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    if(indexPath.section == 0){
        Attraction *thisAttraction = [_plannerResults objectAtIndex:indexPath.row];
        cell.textLabel.text = thisAttraction.name;
        cell.imageView.image = [self returnColorImageFromAttractionGroup:thisAttraction.group];
    }
    else if(indexPath.section == 1){
        Event *thisEvent = [_plannerEvents objectAtIndex:indexPath.row];
        cell.textLabel.text = thisEvent.title;
        //set a new custom event image icon
    }
    return cell;
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    return [colourAttractionObj getAttractionGroupImage:group];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [_activityResultsTableView indexPathForSelectedRow];
    Attraction *tappedAttraction = [_plannerResults objectAtIndex:path.row];
    
    [segue.destinationViewController startWithAttraction:tappedAttraction];
}

@end
