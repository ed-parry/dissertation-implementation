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
@property NSArray *attractionGroups;
@property (strong, nonatomic) IBOutlet UIView *groupSettingView;
@property (strong, nonatomic) IBOutlet UIView *mappingSettingView;
@property (strong, nonatomic) IBOutlet UIView *dataSettingView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapRadiusSettingsSegment;
@property MapDataManager *mapDataManager;

- (IBAction)settingsSegmentControl:(UISegmentedControl *)sender;
- (IBAction)dataRefreshButton:(id)sender;

- (IBAction)radiusSliderValueChanged:(UISlider *)sender;
@property (strong, nonatomic) IBOutlet UISlider *mapRadiusSlider;
@property (strong, nonatomic) IBOutlet UILabel *mapRadiusValueLabel;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _groupTableView.dataSource = self;
    _groupTableView.delegate = self;
    
    [self setActiveSettingsMenu:@"group"];
    [self setRadiusSettingsValue];

    
    // get array of all groups
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionGroups = [dataManager getAllAttractionGroupTypes];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(animated == FALSE){
        // While this does somewhat work, it removes the items from the array entirely, and so they are removed from the list. We only need to set them as deselected, rather than remove them.
        [self setGroupSelectionValues];
    }
}

- (void)setActiveSettingsMenu:(NSString *) menu
{
    if([menu isEqualToString:@"group"]){
        _groupSettingView.hidden = NO;
        _mappingSettingView.hidden = YES;
        _dataSettingView.hidden = YES;
    }
    else if([menu isEqualToString:@"mapping"]){
        _groupSettingView.hidden = YES;
        _mappingSettingView.hidden = NO;
        _dataSettingView.hidden = YES;
    }
    else if([menu isEqualToString:@"data"]){
        _groupSettingView.hidden = YES;
        _mappingSettingView.hidden = YES;
        _dataSettingView.hidden = NO;
    }
    else{
        // the default is just to show the groupings
        _groupSettingView.hidden = NO;
        _mappingSettingView.hidden = YES;
        _dataSettingView.hidden = YES;
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
    else if(sender.selectedSegmentIndex == 2){
        // data
        [self setActiveSettingsMenu:@"data"];
    }
    else{
        // should never get here, but treat it as default: group
        [self setActiveSettingsMenu:@"group"];
    }
}

- (IBAction)dataRefreshButton:(id)sender {
    // call a function to reset the data
    AttractionsCSVDataManager *attractionsDataManager = [[AttractionsCSVDataManager alloc] init];
    [attractionsDataManager saveDataFromURLReset];
}

- (void)setGroupSelectionValues
{
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    _attractionGroups = [groupDataManager getAllowedGroupsFromPlist];

    // Fix this line
//    [_groupTableView reloadData];
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

- (void)toggleGroupOnMapView:(NSString *)group
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
    static NSString *CellIdentifier = @"groupsList";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [_attractionGroups objectAtIndex:indexPath.row]; // TODO - monitor this, error thrown in Crashlytics
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Added colour-based image as a key explanation.
    cell.imageView.image = [self returnColorImageFromAttractionGroup:[_attractionGroups objectAtIndex:indexPath.row]];
    
    return cell;
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    
    return [colourAttractionObj getAttractionGroupImage:group];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self toggleGroupOnMapView:cell.textLabel.text];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self toggleGroupOnMapView:cell.textLabel.text];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
