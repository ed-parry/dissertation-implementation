//
//  CoreDataTools.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 04/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreDataTools : NSObject
- (void)cleanCoreData;
- (NSString *)stripHTMLFromString:(NSString *)stringToStrip;
- (NSMutableArray *)removeEmptyLinesFromArray:(NSMutableArray *)tempAttractions;
- (NSArray *)checkAndRemoveHiddenAttractions:(NSArray *)attractions;
@end
