//
//  GroupDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Attraction.h"

@interface GroupDataManager : NSObject
- (void)storeDefaultAllowedGroupsInPlistForAttractionPlanner:(bool)attractionPlanner;
- (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups forAttractionPlanner:(bool)attractionPlanner;
- (void)toggleGroupInAllowedGroups:(NSString *)group forAttractionPlanner:(bool)attractionPlanner;

- (bool)isAttractionInAllowedGroups:(Attraction *)attraction;
- (bool)isGroupInAllowedGroups:(NSString *)group forAttractionPlanner:(bool)attractionPlanner;

- (NSArray *)getAllowedGroupsFromPlistForAttractionPlanner:(bool)attractionPlanner;
- (NSArray *)getAlphabeticallyOrderedArray:(NSArray *)unsortedArray;
@end
