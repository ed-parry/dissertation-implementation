//
//  GroupDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupDataManager : NSObject
- (void)storeDefaultAllowedGroupsInPlist;
- (void)storeAllowedGroupsInPlist:(NSArray *)allowedGroups;
- (NSArray *)getAllowedGroupsFromPlist;
@end
