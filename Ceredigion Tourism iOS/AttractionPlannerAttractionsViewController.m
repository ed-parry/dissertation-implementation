//
//  AttractionPlannerAttractionsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionPlannerAttractionsViewController.h"
#import "AttractionPlannerResultsViewController.h"
#import "CoreDataManager.h"
#import "GroupDataManager.h"
#import "Attraction.h"

@interface AttractionPlannerAttractionsViewController ()
@property AttractionPlan *thisPlan;
@property GroupDataManager *groupDataManager;
@property NSArray *attractionGroups;
@property NSArray *activityPlanGroups;
@property (strong, nonatomic) IBOutlet UISegmentedControl *adrenalineSegmentControl;
@property (strong, nonatomic) IBOutlet UITableView *attractionsGroupTable;
- (IBAction)adrenalineLevelSelector:(UISegmentedControl *)sender;
- (IBAction)activityNumberSelector:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *activityNumberLabel;
@end

@implementation AttractionPlannerAttractionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:(35.0/256.0)
                                                  green:(164.0/256.0)
                                                   blue:(219.0/256.0)
                                                  alpha:(1.0)]];
    
    _attractionsGroupTable.backgroundColor = [UIColor colorWithRed:(35.0/256.0)
                                                             green:(164.0/256.0)
                                                              blue:(219.0/256.0)
                                                             alpha:(1.0)];
    
    _attractionsGroupTable.tintColor = [UIColor whiteColor];
    
    _attractionsGroupTable.dataSource = self;
    _attractionsGroupTable.delegate = self;
    
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    [groupDataManager storeDefaultAllowedGroupsInPlistForAttractionPlanner:YES];
}

- (void)getAttractionGroupsArray
{
    CoreDataManager *coreData = [[CoreDataManager alloc] init];
    _attractionGroups = [coreData getAllAttractionGroupTypes];
    _activityPlanGroups = _attractionGroups;
}

- (void)continuePlannerWithPlan:(AttractionPlan *)currentPlan
{
    _thisPlan = [[AttractionPlan alloc] init];
    _thisPlan = currentPlan;
    // setup the current plan with the default values from this view.
    [self getAttractionGroupsArray];
    _thisPlan.selectedGroups = _activityPlanGroups;
    _thisPlan.adrenalineLevel = @"amber";
    _thisPlan.numberOfActivities = [NSNumber numberWithInt:8];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    return [colourAttractionObj getAttractionGroupImage:group];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Only want a single section
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _attractionGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"plannerAttractionTypes";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_attractionGroups objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    cell.imageView.image = [self returnColorImageFromAttractionGroup:[_attractionGroups objectAtIndex:indexPath.row]];
    
    UISwitch *accessorySwitch = [[UISwitch alloc]initWithFrame:CGRectZero];

    
    if(!_groupDataManager){
        _groupDataManager = [[GroupDataManager alloc] init];
    }
    NSString *thisGroup = [_attractionGroups objectAtIndex:indexPath.row];
    if([_groupDataManager isGroupInAllowedGroups:thisGroup forAttractionPlanner:YES]){
        [accessorySwitch setOn:YES animated:YES];
    }
    else{
        [accessorySwitch setOn:NO animated:YES];
    }

    [accessorySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = accessorySwitch;
    
    cell.backgroundColor = [UIColor colorWithRed:(35.0/256.0)
                                           green:(164.0/256.0)
                                            blue:(219.0/256.0)
                                           alpha:(1.0)];
    cell.tintColor = [UIColor whiteColor];
    
    return cell;
}

- (void)changeSwitch:(UISwitch *)sender{
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:_attractionsGroupTable];
    NSIndexPath *indexPath = [_attractionsGroupTable indexPathForRowAtPoint:rootViewPoint];
    NSString *selectedGroup = [_attractionGroups objectAtIndex:indexPath.row];

    [self toggleGroupFromArray:selectedGroup];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UISwitch *accessorySwitch = [[UISwitch alloc]initWithFrame:CGRectZero];
    accessorySwitch = (UISwitch *)cell.accessoryView;
    
    if(accessorySwitch.on){
        [accessorySwitch setOn:NO animated:YES];
    }
    else{
        [accessorySwitch setOn:YES animated:YES];
    }
    
    NSString *selectedGroup = [_attractionGroups objectAtIndex:indexPath.row];
    [self toggleGroupFromArray:selectedGroup];
}

- (IBAction)adrenalineLevelSelector:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0){
        // green
        _thisPlan.adrenalineLevel = @"green";
    }
    else if(sender.selectedSegmentIndex == 1){
        // amber
        _thisPlan.adrenalineLevel = @"amber";
    }
    else if(sender.selectedSegmentIndex == 2){
        // red
        _thisPlan.adrenalineLevel = @"red";
    }
    else{
        // shouldn't get here, but we'll treat is as medium just in case.
        _thisPlan.adrenalineLevel = @"none";
    }
}

- (void)toggleGroupFromArray:(NSString *)group
{
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    [groupDataManager toggleGroupInAllowedGroups:group forAttractionPlanner:YES];
}

- (IBAction)activityNumberSelector:(UISlider *)sender
{
    int activities = (int)sender.value;
    if(activities == 1){
        _activityNumberLabel.text = [NSString stringWithFormat:@"%i activity", activities];
    }
    else{
        _activityNumberLabel.text = [NSString stringWithFormat:@"%i activities", activities];
    }
    _thisPlan.numberOfActivities = [NSNumber numberWithInt:activities];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // check that we have a complete ActivityPlan object.
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    _thisPlan.selectedGroups = [groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:YES];
    
    _thisPlan.numberOfActivities = [NSNumber numberWithInt:[_activityNumberLabel.text intValue]];
    
    if([_thisPlan isComplete]){
        return YES;
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More information required"
                                                        message:@"Please ensure that you have entered in all available information before continuing."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController completedSetupWithActivityPlan:_thisPlan];
}

@end