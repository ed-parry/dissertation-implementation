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
#import "CoreDataManager.h"

@interface ListViewController ()
@property NSArray *allAttractionsByGroup;
@property NSArray *attractionGroups;
@property NSArray *attractionPositions;
@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _allAttractionsByGroup = [dataManager getAllAttractionsInGroupArrays];
    _attractionPositions = [dataManager getAllAttractionPositions];
    _attractionGroups = [dataManager getAllAttractionGroupTypes];
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
    
    // Need to change this to have multiple arrays used, depending on the section...tough one to code on the fly. Break time.
    static NSString *CellIdentifier = @"attractionListViewCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = cellAttraction.name;

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
