//
//  ActivityPlannerAttractionsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerAttractionsViewController.h"
#import "CoreDataManager.h"
#import "Attraction.h"

@interface ActivityPlannerAttractionsViewController ()
@property ActivityPlan *thisPlan;
@property NSArray *attractionGroups;
@property (strong, nonatomic) IBOutlet UITableView *attractionsGroupTable;
- (IBAction)adrenalineLevelSelector:(UISegmentedControl *)sender;
- (IBAction)activityNumberSelector:(UISlider *)sender;

@property (strong, nonatomic) IBOutlet UILabel *activityNumberLabel;
@end

@implementation ActivityPlannerAttractionsViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    CoreDataManager *coreData = [[CoreDataManager alloc] init];
    _attractionGroups = [coreData getAllAttractionGroupTypes];
}

- (void)continuePlannerWithPlan:(ActivityPlan *)currentPlan
{
    _thisPlan = currentPlan;
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

    [accessorySwitch setOn:YES animated:YES];

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
}

- (IBAction)adrenalineLevelSelector:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex == 0){
        // low
        _thisPlan.adrenalineLevel = @"low";
    }
    else if(sender.selectedSegmentIndex == 1){
        // medium
        _thisPlan.adrenalineLevel = @"medium";
    }
    else if(sender.selectedSegmentIndex == 2){
        // high
        _thisPlan.adrenalineLevel = @"high";
    }
    else{
        // shouldn't get here, but we'll treat is as medium just in case.
        _thisPlan.adrenalineLevel = @"medium";
    }
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

@end