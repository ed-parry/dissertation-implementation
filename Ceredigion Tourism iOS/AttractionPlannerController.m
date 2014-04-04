//
//  ActivityPlannerController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionPlannerController.h"
#import "CoreDataManager.h"
#import "MapDataManager.h"
#import "EventAndDateFormatManager.h"
#import "Attraction.h"

@interface AttractionPlannerController ()
@property AttractionPlan *thisPlan;
@property CoreDataManager *coreDataManager;
@property MapDataManager *mapDataManager;

@property NSMutableArray *workingAttractionList;
@end

@implementation AttractionPlannerController

- (id)initWithPlan:(AttractionPlan *)plan
{
    if(self){
        _thisPlan = [[AttractionPlan alloc] init];
        _thisPlan = plan;
        
        _coreDataManager = [[CoreDataManager alloc] init];
    }
    return self;
}

- (NSArray *)generateActivityList
{
    NSMutableArray *activityList = [[NSMutableArray alloc] init];
    
    // get all attractions in group arrays
    NSArray *allAttractionsInGroupArrays = [_coreDataManager getAllAttractionsInGroupArrays];
    
    // get all attractions in user selected groups
    _workingAttractionList = [[NSMutableArray alloc] initWithArray:[self getAllAttractionsInSelectedGroups:_thisPlan.selectedGroups fromArray:allAttractionsInGroupArrays]];
    
    // remove all attractions of a higher adrenaline level
    _workingAttractionList = [self removeAttractionsWithHigherAdrenalineLevelThan:_thisPlan.adrenalineLevel fromArray:_workingAttractionList];
    
    // get suitable amount of attractions within x miles of location
    float startDistance = 16093.44; // 10 miles in meters
    _workingAttractionList = [self getAllAttractionsWithin:startDistance ofLocation:_thisPlan.locationCoordinates usingArray:_workingAttractionList];
    
    // shuffle array
    _workingAttractionList = [self shuffleArrayContents:_workingAttractionList];
    
    // order by adrenaline level
    _workingAttractionList = [self orderArrayByAdrenalineLevelWithArray:_workingAttractionList];
    
    // select top number from array
    _workingAttractionList = [self returnTopNumber:_thisPlan.numberOfActivities fromArray:_workingAttractionList];
    
    // return!
    return _workingAttractionList;
}

- (NSArray *)getAllAttractionsInSelectedGroups:(NSArray *)selectedGroups fromArray:(NSArray *)array
{
    NSMutableArray *attractionsInSelectedGroups = [[NSMutableArray alloc] init];
    
    for(NSArray *singleGroupArray in array){
        Attraction *tempAttraction = [singleGroupArray objectAtIndex:0];
        if([selectedGroups containsObject:tempAttraction.group]){
            [attractionsInSelectedGroups addObjectsFromArray:singleGroupArray];
        }
    }
    
    return attractionsInSelectedGroups;
}

- (NSMutableArray *)removeAttractionsWithHigherAdrenalineLevelThan:(NSString *)adrenalineLevel fromArray:(NSArray *)array
{
    NSMutableArray *attractionsOfSuitableAdrenalineLevel = [[NSMutableArray alloc] initWithArray:array];
    NSArray *adrenalineLevelsToRemove = [[NSArray alloc] initWithArray:[self returnHigherAdrenalineLevelsThan:adrenalineLevel]];

    for(Attraction *tempAttraction in attractionsOfSuitableAdrenalineLevel){
        if([adrenalineLevelsToRemove containsObject:tempAttraction.adrenalineLevel]){
            [attractionsOfSuitableAdrenalineLevel removeObject:tempAttraction];
        }
    }
    
    return attractionsOfSuitableAdrenalineLevel;
}

- (NSArray *)returnHigherAdrenalineLevelsThan:(NSString *)adrenalineLevel
{
    NSArray *adrenalineLevelsToRemove;
    if([adrenalineLevel isEqualToString:@"high"]){
        // keep the array empty
        adrenalineLevelsToRemove = [[NSArray alloc] init];
    }
    else if([adrenalineLevel isEqualToString:@"medium"]){
        adrenalineLevelsToRemove = [[NSArray alloc] initWithObjects:@"high", nil];
    }
    else if([adrenalineLevel isEqualToString:@"low"]){
        adrenalineLevelsToRemove = [[NSArray alloc] initWithObjects:@"high", @"medium", nil];
    }
    
    return adrenalineLevelsToRemove;
}

- (NSArray *)returnLowerAdrenalineLevelsThan:(NSString *)adrenalineLevel
{
    NSArray *adrenalineLevelsToKeep;
    if([adrenalineLevel isEqualToString:@"high"]){
        // keep the array empty
        adrenalineLevelsToKeep = [[NSArray alloc] initWithObjects:@"high", @"medium", @"low", nil];
    }
    else if([adrenalineLevel isEqualToString:@"medium"]){
        adrenalineLevelsToKeep = [[NSArray alloc] initWithObjects:@"medium", @"low", nil];
    }
    else if([adrenalineLevel isEqualToString:@"low"]){
        adrenalineLevelsToKeep = [[NSArray alloc] initWithObjects:@"low", nil];
    }
    
    return adrenalineLevelsToKeep;
}

- (NSMutableArray *)getAllAttractionsWithin:(float)startDistance ofLocation:(CLLocationCoordinate2D)location usingArray:(NSArray *)array
{
    float fiveMiles = 8046.72; // half the starting distance to add if we need to
    NSMutableArray *attractionsWithinLocation = [[NSMutableArray alloc] init];
    
    _mapDataManager = [[MapDataManager alloc] initWithCurrentRadiusCenter:location andRadiusInMeters:startDistance];

    for(Attraction *thisAttraction in array){
        CLLocationCoordinate2D attractionCoordinates = CLLocationCoordinate2DMake([thisAttraction.latitude doubleValue], [thisAttraction.longitude doubleValue]);
        
        if([_mapDataManager isCoordinatesWithinRadius:attractionCoordinates]){
            [attractionsWithinLocation addObject:thisAttraction];
        }
    }
    
    int numberOfActivities = [_thisPlan.numberOfActivities intValue];
    if([attractionsWithinLocation count] > numberOfActivities){
        return attractionsWithinLocation;
    }
    else{
        startDistance = startDistance + fiveMiles;
        [self getAllAttractionsWithin:startDistance ofLocation:location usingArray:array];
    }
    NSLog(@"Something is seriously wrong, should never reach this point");
    return nil;
}

- (NSMutableArray *)shuffleArrayContents:(NSArray *)arrayToShuffle
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:arrayToShuffle];
    NSUInteger count = [array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return array;
}

- (NSMutableArray *)orderArrayByAdrenalineLevelWithArray:(NSArray *) array
{
    NSMutableArray *orderedArrayByAdrenalineLevel = [[NSMutableArray alloc] init];
    
    NSArray *adrenalineLevels = [[NSArray alloc] initWithArray:[self returnLowerAdrenalineLevelsThan:_thisPlan.adrenalineLevel]];
    
    for(NSString *adrenalineLevel in adrenalineLevels){
        for(Attraction *thisAttraction in array){
            if([thisAttraction.adrenalineLevel isEqualToString:adrenalineLevel]){
                [orderedArrayByAdrenalineLevel addObject:thisAttraction];
            }
        }
    }
    return orderedArrayByAdrenalineLevel;
}

- (NSMutableArray *)returnTopNumber:(NSNumber *)number fromArray:(NSArray *)array
{
    int numberInt = [number intValue];
    
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] initWithArray:[array subarrayWithRange:NSMakeRange(0, numberInt)]];
    
    return arrayToReturn;
}

- (NSArray *)generateEventsList
{
    NSMutableArray *relevantEvents = [[NSMutableArray alloc] init];
    
    NSString *startDate = _thisPlan.startDate;
    int days = [_thisPlan.days intValue];
    
    EventAndDateFormatManager *eventManager = [[EventAndDateFormatManager alloc] init];
    
    NSArray *datesArray = [[NSArray alloc] initWithArray:[eventManager makeArrayOfDatesStartingFrom:startDate forNumberOfDays:days]];
    
    for(NSDate *date in datesArray){
        NSString *selectedDate = [NSString stringWithFormat:@"%@", date];
        NSArray *tempDateEvents = [[NSArray alloc] initWithArray:[eventManager returnEventsForSelectedDay:selectedDate]];
        if([tempDateEvents count] > 0){
            for(Event *thisEvent in tempDateEvents){
                // only add it if it isn't already there.
                if(![relevantEvents containsObject:thisEvent]){
                    [relevantEvents addObject:thisEvent];
                }
            }
        }
    }
    return relevantEvents;
}

@end