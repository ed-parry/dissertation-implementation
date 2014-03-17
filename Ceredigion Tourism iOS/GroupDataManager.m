//
//  GroupDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "GroupDataManager.h"
#import "CoreDataManager.h"
#import "Attraction.h"

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
    NSArray *allowedGroups = [self getAllowedGroupsFromPlist];
    
    for(NSString *group in allowedGroups){
        if([group isEqualToString:attraction.group]){
            return YES;
        }
    }
    return NO;
}

- (void)storeDefaultAllowedGroupsInPlist
{
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    NSArray *defaultGroups = [dataManager getAllAttractionGroupTypes];
    [self storeAllowedGroupsInPlist:defaultGroups];
}

- (void)toggleGroupInAllowedGroups:(NSString *)group
{
    NSArray *currentGroups = [self getAllowedGroupsFromPlist];
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
    
    [self storeAllowedGroupsInPlist:currentMutableGroups];
}

- (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups
{
    [allowedGroups writeToFile:_filePath atomically:YES];
}

- (NSArray *)getAllowedGroupsFromPlist
{
    NSArray *allowedGroups;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        allowedGroups = [[NSArray alloc] initWithContentsOfFile:_filePath];
    }
    
    return allowedGroups;
}

- (NSString *)getPlistFilePath:(NSString *)fileName
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}
@end
