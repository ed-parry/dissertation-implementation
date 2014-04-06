//
//  CoreDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@interface CoreDataManager : NSObject
- (void)saveCSVToCoreData:(NSString *)csvFileLocation ofType:(NSString *)type;
- (NSArray *) getAllAttractionPositions;
- (NSArray *) getAllAttractionGroupTypes;
- (NSArray *) getAllAttractionsInGroupArrays;
- (NSString *)stripHTMLFromString:(NSString *)stringToStrip;
- (NSArray *)getAlphabeticallyOrderedArray:(NSArray *)unsortedArray forArrayType:(NSString *)arrayType;

- (NSArray *)getAllEvents;
- (Event *)getSingleEventByTitle:(NSString *)title;
- (NSArray *)getAllEventDates;

- (BOOL)doesCoreDataEntityHaveData:(NSString *)entity;

// for testing
- (void)addEventToCoreData:(Event *)event;
@end
