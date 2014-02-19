//
//  ListViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 19/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ListViewController.h"
#import "Attraction.h"
#import "CoreDataManager.h"

@interface ListViewController ()
@property NSArray *attractionPositions;
@property NSArray *attractionGroups;
@end

@implementation ListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
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
    NSString *attractionGroup = [_attractionGroups objectAtIndex:section];
    NSInteger counter = 0;
    
    for(Attraction *tempAttraction in _attractionPositions){
        if([tempAttraction.group isEqualToString:attractionGroup]){
            counter++;
        }
    }
    
    return counter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Need to change this to have multiple arrays used, depending on the section...tough one to code on the fly. Break time.
    static NSString *CellIdentifier = @"attractionListViewCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Attraction *cellAttraction = [[Attraction alloc] init];
    cellAttraction = [_attractionPositions objectAtIndex:indexPath.row];
    
    cell.textLabel.text = cellAttraction.name;
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
