//
//  CVSDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVDataManager : NSObject

- (bool)isConnectionAvailable;
- (NSDate *)getLastUpdatedDateOfServerCSV:(NSString *)urlString;
- (NSDate *)getLastFetchedDate;
- (void)saveLastFetchedDate:(NSString *)date;
- (bool)recentFileExists;
- (NSString *)getTodaysDate;

@end
