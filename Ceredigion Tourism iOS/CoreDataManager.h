//
//  CoreDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataManager : NSObject
- (void)saveCSVToCoreData:(NSString *)csvFileLocation;
@end
