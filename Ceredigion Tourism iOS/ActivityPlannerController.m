//
//  ActivityPlannerController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerController.h"
#import "CoreDataManager.h"
#import "MapDataManager.h"
#import "EventAndDateFormatManager.h"
#import "Attraction.h"

@interface ActivityPlannerController ()
@property ActivityPlan *thisPlan;
@property CoreDataManager *coreDataManager;
@property NSArray *allAttractionsInGroupArrays;
@end

@implementation ActivityPlannerController

- (id)initWithPlan:(ActivityPlan *)plan
{
    if(self){
        _thisPlan = [[ActivityPlan alloc] init];
        _thisPlan = plan;
        
        _coreDataManager = [[CoreDataManager alloc] init];
    }
    return self;
}

// Things left to check for:
// * adrenaline level
// * any events that match location and within days

- (NSArray *)generateActivityList
{
    NSMutableArray *activityList = [[NSMutableArray alloc] init];
    _allAttractionsInGroupArrays = [_coreDataManager getAllAttractionsInGroupArrays];
    
    NSArray *activityListForLocation = [[NSArray alloc] initWithArray:[self generateAttractionsForLocation:_thisPlan.locationCoordinates]];

    int totalActivities = [_thisPlan.numberOfActivities intValue];
    int totalGroups = [_thisPlan.selectedGroups count];
    
    int activitiesPerGroup = totalActivities / totalGroups;
    
    NSArray *shuffledGroups = [[NSMutableArray alloc] initWithArray:[self shuffleArrayContents:_thisPlan.selectedGroups]];
    
    for(NSString *group in shuffledGroups){
        // this adds to the activityList array a collection of objects that are:
        //  - within 10 miles of their chosen location
        //  - are the correct number of activities, for each of their chosen groups
        [activityList addObjectsFromArray:[self getNumberOfAttractions:activitiesPerGroup ofGroup:group usingActivityArray:activityListForLocation]];
    }
    

    
    // because of whole point integer numbers, we might have some left over. Assignment them to the first three groups in the selected groups array.
    int numberAlreadyFound = [activityList count];
    int numberRemaining = totalActivities - numberAlreadyFound;
    if((numberRemaining > -1) && (numberRemaining < totalActivities)){
        for(int i = 0; i <= numberRemaining; i++){
            NSString *group = [shuffledGroups objectAtIndex:i];
            [activityList addObjectsFromArray:[self getNumberOfAttractions:1 ofGroup:group usingActivityArray:activityListForLocation]];
        }
    }
    
    // if we're only after one activity
    if(totalActivities == 1){
        NSString *group = [_thisPlan.selectedGroups objectAtIndex:0];
        [activityList removeAllObjects];
        [activityList addObjectsFromArray:[self getNumberOfAttractions:1 ofGroup:group usingActivityArray:activityListForLocation]];
    }

    return activityList;
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

- (NSArray *)shuffleArrayContents:(NSArray *)arrayToShuffle
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

- (NSArray *)getNumberOfAttractions:(int)number ofGroup:(NSString *)group usingActivityArray:(NSArray *)activitiesArray
{
    NSMutableArray *attractionsForThisGroup = [[NSMutableArray alloc] init];
    NSMutableArray *returnedAttractions = [[NSMutableArray alloc] init];
    for(Attraction *temp in activitiesArray){
        if([temp.group isEqualToString:group]){
            if(![attractionsForThisGroup containsObject:temp]){
                [attractionsForThisGroup addObject:temp];
            }
        }
    }
    
    if([attractionsForThisGroup count] == 0){
        return nil;
    }
    else{
        for(int i = 0; i < number; i++){
            int randomIndex = [self getRandomNumberLessThan:[attractionsForThisGroup count]];
            Attraction *randomAttraction = [attractionsForThisGroup objectAtIndex:randomIndex-1];
            if(![returnedAttractions containsObject:randomAttraction]){
                [returnedAttractions addObject:randomAttraction];
            }
        }
        attractionsForThisGroup = nil;
        return returnedAttractions;
    }
}

-(int)getRandomNumberLessThan:(int)max {
    if (max == 0){
        return 1;
    }
    else if(max == 1){
        return 1;
    }
    else{
        return (int)1 + arc4random() % (max-1+1);
    }
}

// Add's all attractions within 10 miles of the plan's location.
- (NSArray *)generateAttractionsForLocation:(CLLocationCoordinate2D)location
{
    NSMutableArray *attractionsInLocation = [[NSMutableArray alloc] init];
    
    MapDataManager *mapManager = [[MapDataManager alloc] initWithCurrentRadiusCenter:location
                                                                   andRadiusInMeters:16093.44];
    for(NSArray *group in _allAttractionsInGroupArrays){
        for(Attraction *tempAttraction in group){
            CLLocationCoordinate2D attractionCoordinates = CLLocationCoordinate2DMake([tempAttraction.latitude doubleValue], [tempAttraction.longitude doubleValue]);
            
            if([mapManager isCoordinatesWithinRadius:attractionCoordinates]){
                [attractionsInLocation addObject:tempAttraction];
            }
        }
    }
    return attractionsInLocation;
}

@end