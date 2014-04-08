//
//  GroupDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "GroupDataManager.h"
#import "CoreDataManager.h"

@interface GroupDataManager ()
@property NSString *filePath;
@end

@implementation GroupDataManager

- (id)init{
    _filePath = [self getPlistFilePath:@"allowed_groups"];
    return self;
}

- (bool)isAttractionInAllowedGroups:(Attraction *)attraction
{
    NSArray *allowedGroups = [self getAllowedGroupsFromPlistForAttractionPlanner:NO];
    
    for(NSString *group in allowedGroups){
        if([group isEqualToString:attraction.group]){
            return YES;
        }
    }
    return NO;
}

- (bool)isGroupInAllowedGroups:(NSString *)group forAttractionPlanner:(bool)attractionPlanner
{
    NSArray *allowedGroups = [self getAllowedGroupsFromPlistForAttractionPlanner:attractionPlanner];
    
    for(NSString *allowedGroup in allowedGroups){
        if([allowedGroup isEqualToString:group]){
            return YES;
        }
    }
    return NO;
}

- (void)storeDefaultAllowedGroupsInPlistForAttractionPlanner:(bool)attractionPlanner
{
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    NSMutableArray *defaultGroups = [[NSMutableArray alloc] initWithArray:[dataManager getAllAttractionGroupTypes]];
    
    if([defaultGroups count] < 1){
        // a catch all if we get here before a slow network connection
        defaultGroups = [[NSMutableArray alloc] initWithArray:@[@"Accommodation", @"Activity", @"Arts & crafts", @"Attraction", @"Camp & caravan", @"Food & drink", @"Retail"]];
    }

    [self storeAllowedGroupsInPlist:defaultGroups forAttractionPlanner:attractionPlanner];
}

- (void)toggleGroupInAllowedGroups:(NSString *)group forAttractionPlanner:(bool)attractionPlanner
{
    NSArray *currentGroups;

    currentGroups = [self getAllowedGroupsFromPlistForAttractionPlanner:attractionPlanner];


    NSMutableArray *currentMutableGroups = [[NSMutableArray alloc] initWithArray:currentGroups];
    
    bool isFound = NO;
    for(NSString *tempGroup in currentGroups){
        if([tempGroup isEqualToString:group]){
            [currentMutableGroups removeObject:tempGroup];
            isFound = YES;
            break;
        }
    }
    
    if(isFound == NO){
        [currentMutableGroups addObject:group];
    }
    
    [self storeAllowedGroupsInPlist:currentMutableGroups forAttractionPlanner:attractionPlanner];
}

- (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups forAttractionPlanner:(bool)attractionPlanner
{
    if(attractionPlanner){
        [allowedGroups writeToFile:[self getPlistFilePath:@"attraction_planner-allowed-categories"] atomically:YES];
    }
    else{
        [allowedGroups writeToFile:_filePath atomically:YES];
    }
}

- (NSArray *)getAllowedGroupsFromPlistForAttractionPlanner:(bool)attractionPlanner
{
    NSArray *allowedGroups;
    if(!attractionPlanner){
        if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
            allowedGroups = [[NSArray alloc] initWithContentsOfFile:_filePath];
        }
    }
    else{
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self getPlistFilePath:@"attraction_planner-allowed-categories"]]) {
            allowedGroups = [[NSArray alloc] initWithContentsOfFile:[self getPlistFilePath:@"attraction_planner-allowed-categories"]];
        }
    }

    return [self getAlphabeticallyOrderedArray:allowedGroups];
}

- (NSArray *)getAlphabeticallyOrderedArray:(NSArray *)unsortedArray
{
    NSArray *sortedArray;

    sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
    }];

    return sortedArray;
}

- (NSString *)getPlistFilePath:(NSString *)fileName
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
@end
