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
#import "MapDataManager.h"
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
- (IBAction)mapRadiusSettingBar:(UISegmentedControl *)sender;

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
    CSVDataManager *csvFetch = [[CSVDataManager alloc] init];
    [csvFetch saveDataFromURLReset];
}

- (void)setRadiusSettingsValue
{
    _mapDataManager = [[MapDataManager alloc] init];
    double mapRadius = [_mapDataManager getMapRadiusMetersFromPlist];
    
    _mapRadiusSettingsSegment.selectedSegmentIndex = [self getMapSegmentPositionFromRadius:mapRadius];
}

- (int)getMapSegmentPositionFromRadius:(int)mapRadius
{
    NSLog(@"Contents of Map Radius: %i", mapRadius);
    if(mapRadius == 0){
        return 0;
    }
    else if(mapRadius == 1){
        return 1;
    }
    else if(mapRadius == 5){
        return 2;
    }
    else if(mapRadius == 10){
        return 3;
    }
    else if(mapRadius == 20){
        return 4;
    }
    else if(mapRadius == 25){
        return 5;
    }
    else{
        return 0;
    }
}

- (IBAction)mapRadiusSettingBar:(UISegmentedControl *)sender
{
    int mapRadiusValue = sender.selectedSegmentIndex;
    _mapDataManager = [[MapDataManager alloc] init];
    
    if(mapRadiusValue == 0){
        [_mapDataManager storeMapRadiusMetersInPlist:0];
    }
    else if(mapRadiusValue == 1){
        [_mapDataManager storeMapRadiusMetersInPlist:1];
        // 1 mile
    }
    else if(mapRadiusValue == 2){
        [_mapDataManager storeMapRadiusMetersInPlist:5];
        // 5 mile
    }
    else if(mapRadiusValue == 3){
        [_mapDataManager storeMapRadiusMetersInPlist:10];
        // 10 mile
    }
    else if(mapRadiusValue == 4){
        [_mapDataManager storeMapRadiusMetersInPlist:20];
        // 20 mile
    }
    else if(mapRadiusValue == 5){
        [_mapDataManager storeMapRadiusMetersInPlist:25];
        // 25 mile
    }
    else{
        // something went wrong, don't set a radius.
        [_mapDataManager storeMapRadiusMetersInPlist:0];
    }
}

- (void)toggleGroupOnMapView:(NSString *)group
{
    // need to figure out how to build this, with a data structure that's available all over.
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
    cell.textLabel.text = [_attractionGroups objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // Added colour-based image as a key explanation.
    cell.imageView.image = [self returnColorImageFromAttractionGroup:[_attractionGroups objectAtIndex:indexPath.row]];
    cell.imageView.layer.cornerRadius = 25.0;
    cell.imageView.layer.masksToBounds = YES;
    
    return cell;
}

- (UIImage *)returnColorImageFromAttractionGroup:(NSString *)group
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    
    CGRect rect = CGRectMake(0, 0, 25, 25);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   [[colourAttractionObj getAttractionGroupColor:group] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *colorImage = UIGraphicsGetImageFromCurrentImageContext();
    return colorImage;
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
