//
//  AttractionPlannerResultsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionPlannerResultsViewController.h"
#import "AttractionPlannerController.h"
#import "SingleAttractionEventViewController.h"
#import "Attraction.h"

@interface AttractionPlannerResultsViewController ()
@property (strong, nonatomic) NSArray *plannerResults;
@property (strong, nonatomic) NSArray *plannerEvents;
@property AttractionPlan *thisPlan;
@property (strong, nonatomic) IBOutlet UITableView *activityResultsTableView;
@property int errorCount;

@end

@implementation AttractionPlannerResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _activityResultsTableView.delegate = self;
    _activityResultsTableView.contentInset = UIEdgeInsetsZero;
    _activityResultsTableView.dataSource = self;
    
    _errorCount = 0;
}

- (void)completedSetupWithActivityPlan:(AttractionPlan *)plan
{
    _thisPlan = plan;
    AttractionPlannerController *planController = [[AttractionPlannerController alloc] initWithPlan:plan];
    
    _plannerResults = [[NSArray alloc] init];
    _plannerResults = [planController generateActivityList];
    
    int numberOfActivities = [plan.numberOfActivities intValue];
    if([_plannerResults count] < numberOfActivities){
        [self showAlertViewWithOptionToTryAgain:YES];
    }
    
    _plannerEvents = [planController generateEventsList];

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
        
        NSString *firstLetter = [thisAttraction.adrenalineLevel substringToIndex:1];
        if([thisAttraction.adrenalineLevel isEqualToString:@"none"]){
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Adrenaline level: Unknown"];
        }
        else{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"Adrenaline level: %@%@", [firstLetter capitalizedString], [thisAttraction.adrenalineLevel substringFromIndex:1]];
        }
        cell.imageView.image = [self returnColorImageFromAttractionGroup:thisAttraction.group];
    }
    else if(indexPath.section == 1){
        Event *thisEvent = [_plannerEvents objectAtIndex:indexPath.row];
        cell.textLabel.text = thisEvent.title;
        cell.imageView.image = [UIImage imageNamed:@"Event Icon"];
        cell.detailTextLabel.text = thisEvent.location;
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
    if([segue.identifier isEqualToString:@"returnToSearchSegue"]){
        // don't do the below code, we don't need to do anything special for this
    }
    else{
        NSIndexPath *path = [_activityResultsTableView indexPathForSelectedRow];
        if(path.section == 0){
            Attraction *tappedAttraction = [_plannerResults objectAtIndex:path.row];
            [segue.destinationViewController startWithAttraction:tappedAttraction];
        }
        else if(path.section == 1){
            UITableViewCell *rowSelected = [_activityResultsTableView cellForRowAtIndexPath:[_activityResultsTableView indexPathForSelectedRow]];
            
            for(Event *thisEvent in _plannerEvents){
                if([thisEvent.title isEqualToString:rowSelected.textLabel.text]){
                    [segue.destinationViewController startWithEvent:thisEvent];
                }
            }
        }
    }
}



- (void)showAlertViewWithOptionToTryAgain:(bool)tryagain
{
    UIAlertView *alert;
    if(tryagain){
        alert = [[UIAlertView alloc] initWithTitle:@"Not Enough Results"
                                                        message:@"We were unable to find enough suitable attractions that matched your selection."
                                                       delegate:self
                                              cancelButtonTitle:@"Go back"
                                              otherButtonTitles:@"Show me fewer", nil];
    }
    else{
        alert = [[UIAlertView alloc] initWithTitle:@"No Available Results"
                                           message:@"We were unable to find suitable attractions that matched your selection."
                                          delegate:self
                                 cancelButtonTitle:@"Go back" otherButtonTitles:nil, nil];
    }


    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(buttonIndex == 1){
        [self tryToFetchResultsWithLessAmount];
    }
    else{
        _errorCount = 0;
        [_activityResultsTableView reloadData];
    }
}

- (void)tryToFetchResultsWithLessAmount
{
    int currentAmount = [_thisPlan.numberOfActivities intValue];
    int newAmount = currentAmount - 1;
    
    _thisPlan.numberOfActivities = [NSNumber numberWithInt:newAmount];
    AttractionPlannerController *planController = [[AttractionPlannerController alloc] initWithPlan:_thisPlan];
    
    _plannerResults = [[NSArray alloc] init];
    _plannerResults = [planController generateActivityList];
    _plannerEvents = [planController generateEventsList];
    
    int numberOfActivities = [_thisPlan.numberOfActivities intValue];
    if([_plannerResults count] < numberOfActivities){
        _errorCount++;
        if(_errorCount == 15){
            [self showAlertViewWithOptionToTryAgain:NO];
        }
        else{
            [self tryToFetchResultsWithLessAmount];
        }
    }
    else{
        _errorCount = 0;
        [_activityResultsTableView reloadData];
    }
}

@end
