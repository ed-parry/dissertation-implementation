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

@interface SettingsViewController ()
@property (strong, nonatomic) IBOutlet UITableView *groupTableView;
@property NSArray *attractionGroups;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _groupTableView.dataSource = self;
    _groupTableView.delegate = self;
    
    // get array of all groups
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionGroups = [dataManager getAllAttractionGroupTypes];
}

- (void)toggleGroupOnMapView:(NSString *)group
{
    MapViewController *mapView = [[MapViewController alloc] init];
    [mapView toggleGroupOnMap:group];
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
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self toggleGroupOnMapView:cell.textLabel.text];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
