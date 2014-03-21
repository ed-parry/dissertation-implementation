//
//  ListViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 19/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ListViewController.h"
#import "Attraction.h"
#import "SingleAttractionEventViewController.h"
#import "MapViewController.h"
#import "GroupDataManager.h"
#import "MapDataManager.h"
#import "GroupDataManager.h"
#import "CoreDataManager.h"

@interface ListViewController ()
@property NSArray *allAttractionsByGroup;
@property NSArray *attractionGroups;
@property NSArray *attractionPositions;
@property MapDataManager *mapDataManagerWithCoords;
@property CoreDataManager *dataManager;
@property GroupDataManager *groupDataManager;
@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.navigationItem.title = @"List View";
    _dataManager = [[CoreDataManager alloc] init];
    _groupDataManager = [[GroupDataManager alloc] init];
    _allAttractionsByGroup = [_dataManager getAllAttractionsInGroupArrays];
    _attractionGroups = [_groupDataManager getAllowedGroupsFromPlist];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"List of Attractions";
    if(animated == FALSE){
        if(!_groupDataManager){
            _groupDataManager = [[GroupDataManager alloc] init];
        }
        _attractionGroups = [_groupDataManager getAllowedGroupsFromPlist];
        [self applyGroupSettings];
        [self applyRadiusSettings];
        [self updateAttractionGroupsArray];
        [self.tableView reloadData];
    }
}

- (void)applyRadiusSettings
{
    MapDataManager *mapDataManager = [[MapDataManager alloc] init];
    double radiusMeters = [mapDataManager getMapRadiusMetersFromPlist];
    CLLocationCoordinate2D radiusCoordinates = [mapDataManager getMapRadiusCoordinatesFromPlist];

    // get a fresh copy of the data
    _dataManager = [[CoreDataManager alloc] init];
    _allAttractionsByGroup = [_dataManager getAllAttractionsInGroupArrays];

    _mapDataManagerWithCoords = [[MapDataManager alloc] initWithCurrentRadiusCenter:radiusCoordinates
                                                                  andRadiusInMeters:radiusMeters];
    NSMutableArray *allAttractionsByGroupInRadius = [[NSMutableArray alloc] init];
    
    for(NSArray *singleGroupAttractions in _allAttractionsByGroup){
        NSMutableArray *allAttractionsInGroupInRadius = [[NSMutableArray alloc] init];
        
        for(Attraction *tempAttraction in singleGroupAttractions){
            CLLocationDegrees tempLat = [tempAttraction.latitude doubleValue];
            CLLocationDegrees tempLong = [tempAttraction.longitude doubleValue];
            
            CLLocationCoordinate2D tempCoords = CLLocationCoordinate2DMake(tempLat, tempLong);

            if([_mapDataManagerWithCoords isCoordinatesWithinRadius:tempCoords])
            {
                [allAttractionsInGroupInRadius addObject:tempAttraction];
            }
        }
        [allAttractionsByGroupInRadius addObject:allAttractionsInGroupInRadius];
    }
    _allAttractionsByGroup = allAttractionsByGroupInRadius;
}

- (void)applyGroupSettings
{
    if(!_dataManager){
        _dataManager = [[CoreDataManager alloc] init];
    }
    _allAttractionsByGroup = [_dataManager getAllAttractionsInGroupArrays];
    
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    
    NSMutableArray *allAttractionsBySelectedGroup = [[NSMutableArray alloc] init];
    
    for(NSArray *tempGroup in _allAttractionsByGroup){
        Attraction *tempAttraction = [tempGroup objectAtIndex:0];
        NSString *group = tempAttraction.group;
        
        if([groupDataManager isGroupInAllowedGroups:group]){
            [allAttractionsBySelectedGroup addObject:tempGroup];
        }
    }
    
    _allAttractionsByGroup = allAttractionsBySelectedGroup;
}

- (void)updateAttractionGroupsArray
{
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    _attractionGroups = [groupDataManager getAllowedGroupsFromPlist];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _attractionGroups.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *sectionHeadingLabel = [[UILabel alloc] init];
    sectionHeadingLabel.frame = CGRectMake(0, 0, 340, 20);
    sectionHeadingLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:18];

    
    NSString *group = [_attractionGroups objectAtIndex:section];
    sectionHeadingLabel.backgroundColor = [self returnColorForAttractionGroup:group withAlpha:1.0f];
    sectionHeadingLabel.text = [NSString stringWithFormat:@"   %@",[self tableView:tableView titleForHeaderInSection:section]];
    sectionHeadingLabel.textColor = [UIColor whiteColor];
    
    CGRect newFrame;
    
    UIView *headerView = [[UIView alloc] initWithFrame:newFrame];
    
    [headerView addSubview:sectionHeadingLabel];
    
    headerView.backgroundColor = [self returnColorForAttractionGroup:group withAlpha:1.0f];
    
    return headerView;
}

- (UIColor *)returnColorForAttractionGroup:(NSString *)group withAlpha:(CGFloat)alpha
{
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    
    return [colourAttractionObj getAttractionGroupColour:group withAlpha:alpha];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_attractionGroups objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *allAttractionsInSingleGroup = [_allAttractionsByGroup objectAtIndex:section];
    
    return [allAttractionsInSingleGroup count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *thisGroupAttractions = [_allAttractionsByGroup objectAtIndex:indexPath.section];
    
    Attraction *cellAttraction = [thisGroupAttractions objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"attractionListViewCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [self returnColorForAttractionGroup:cellAttraction.group withAlpha:0.1f];

    cell.textLabel.text = cellAttraction.name;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    NSArray *thisGroupAttractions = [_allAttractionsByGroup objectAtIndex:path.section];
    Attraction *tappedAttraction = [thisGroupAttractions objectAtIndex:path.row];
    
    [segue.destinationViewController startWithAttraction:tappedAttraction];
}

@end
