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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
