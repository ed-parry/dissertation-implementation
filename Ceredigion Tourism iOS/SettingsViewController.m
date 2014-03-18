//
//  SettingsViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 19/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "SettingsViewController.h"
#import "MapViewController.h"
#import "CoreDataManager.h"
#import "CSVDataManager.h"
#import "AttractionsCSVDataManager.h"
#import "MapDataManager.h"
#import "GroupDataManager.h"
#import "Attraction.h"

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *groupTableView;

@property (strong, nonatomic) IBOutlet UIView *groupSettingView;
@property (strong, nonatomic) IBOutlet UIView *mappingSettingView;
@property (strong, nonatomic) IBOutlet UIView *dataSettingView;

@property NSArray *attractionGroups;

@property MapDataManager *mapDataManager;
@property CoreDataManager *coreDataManager;
@property GroupDataManager *groupDataManager;

@property (strong, nonatomic) IBOutlet UISegmentedControl *groupRadiusSegmentControl;

@property (strong, nonatomic) IBOutlet UISlider *mapRadiusSlider;
@property (strong, nonatomic) IBOutlet UILabel *mapRadiusValueLabel;
- (IBAction)settingsSegmentControl:(UISegmentedControl *)sender;
- (IBAction)radiusSliderValueChanged:(UISlider *)sender;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSegmentControlColour];

    _groupTableView.dataSource = self;
    _groupTableView.delegate = self;
    
    [self setActiveSettingsMenu:@"group"];
    [self setRadiusSettingsValue];
    [self setGroupSelectionValues];
    
    // get array of all groups
    _coreDataManager = [[CoreDataManager alloc] init];
    _attractionGroups = [_coreDataManager getAllAttractionGroupTypes];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(animated == FALSE){
//        [self setGroupSelectionValues];
//        [_groupTableView reloadData];
    }
}

- (void)setSegmentControlColour
{
    _groupRadiusSegmentControl.tintColor = [UIColor colorWithRed:35.0/255.0
                                                           green:164.0/255.0
                                                            blue:219.0/255.0
                                                           alpha:1.0];
    _groupRadiusSegmentControl.backgroundColor = [UIColor whiteColor];
}

- (void)setActiveSettingsMenu:(NSString *) menu
{
    if([menu isEqualToString:@"group"]){
        _groupSettingView.hidden = NO;
        _mappingSettingView.hidden = YES;
    }
    else if([menu isEqualToString:@"mapping"]){
        _groupSettingView.hidden = YES;
        _mappingSettingView.hidden = NO;
    }
    else{
        // the default is just to show the groupings
        _groupSettingView.hidden = NO;
        _mappingSettingView.hidden = YES;
    }
}

- (IBAction)settingsSegmentControl:(UISegmentedControl *)sender {
    if(sender.selectedSegmentIndex == 0){
        [self setActiveSettingsMenu:@"group"];
    }
    else if(sender.selectedSegmentIndex == 1){
        // mapping
        [self setActiveSettingsMenu:@"mapping"];
    }
    else{
        // should never get here, but treat it as default: group
        [self setActiveSettingsMenu:@"group"];
    }
}

- (void)setGroupSelectionValues
{
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionGroups = [dataManager getAllAttractionGroupTypes];
}

- (void)setRadiusSettingsValue
{
    _mapDataManager = [[MapDataManager alloc] init];
    double mapRadius = [_mapDataManager getMapRadiusMetersFromPlist];
    
    int mapRadiusInt = (int)mapRadius;
    if(mapRadiusInt == 0){
        _mapRadiusValueLabel.text = [NSString stringWithFormat:@"No map radius set"];
    }
    else{
        _mapRadiusValueLabel.text = [NSString stringWithFormat:@"Map Radius: %i miles", mapRadiusInt];
    }
    _mapRadiusSlider.value = mapRadiusInt;
}

- (IBAction)radiusSliderValueChanged:(UISlider *)sender
{
    int radiusValue = (int)sender.value;
    if(radiusValue == 0){
        _mapRadiusValueLabel.text = [NSString stringWithFormat:@"No map radius set"];
    }
    else{
        _mapRadiusValueLabel.text = [NSString stringWithFormat:@"Map Radius: %i miles", radiusValue];
    }
    if(_mapDataManager){
        [_mapDataManager storeMapRadiusMetersInPlist:radiusValue];
    }
    else{
        _mapDataManager = [[MapDataManager alloc] init];
        [_mapDataManager storeMapRadiusMetersInPlist:radiusValue];
    }
}

- (void)toggleGroup:(NSString *)group
{
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    [groupDataManager toggleGroupInAllowedGroups:group];
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
    NSString *CellIdentifier = @"groupsList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_attractionGroups objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    cell.imageView.image = [self returnColorImageFromAttractionGroup:[_attractionGroups objectAtIndex:indexPath.row]];
    
    UISwitch *accessorySwitch = [[UISwitch alloc]initWithFrame:CGRectZero];

    _groupDataManager = [[GroupDataManager alloc] init];
    NSString *thisGroup = [_attractionGroups objectAtIndex:indexPath.row];
        if([_groupDataManager isGroupInAllowedGroups:thisGroup]){
            [accessorySwitch setOn:YES animated:YES];
        }
        else{
            [accessorySwitch setOn:NO animated:YES];
        }


    [accessorySwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = accessorySwitch;
    
    return cell;
}

- (void)changeSwitch:(UISwitch *)sender{
    CGPoint center= sender.center;
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:_groupTableView];
    NSIndexPath *indexPath = [_groupTableView indexPathForRowAtPoint:rootViewPoint];

    NSString *selectedGroup = [_attractionGroups objectAtIndex:indexPath.row];
    
    [self toggleGroup:selectedGroup];
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    return [colourAttractionObj getAttractionGroupImage:group];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [self toggleGroup:cell.textLabel.text];
}

@end
