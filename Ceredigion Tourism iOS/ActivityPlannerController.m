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

- (NSArray *)generateActivityList
{
    NSMutableArray *activityList = [[NSMutableArray alloc] init];
    _allAttractionsInGroupArrays = [_coreDataManager getAllAttractionsInGroupArrays];
    
    NSArray *activityListForLocation = [[NSArray alloc] initWithArray:[self generateAttractionsForLocation:_thisPlan.locationCoordinates]];

    
    
    // Things to check for:
    // * DONE location (10 miles of coordinates)
    // * DONE activity group // done automatically, when fetching X number of each group
    // * adrenaline level
    // * any events that match location and within days
    // * DONE total number
    
    
    int totalActivities = [_thisPlan.numberOfActivities intValue];
    int totalGroups = [_thisPlan.selectedGroups count];
    
    int activitiesPerGroup = totalActivities / totalGroups;
    
    for(NSString *group in _thisPlan.selectedGroups){
        // this adds to the activityList array a collection of objects that are:
        //  - within 10 miles of their chosen location
        //  - are the correct number of activities, for each of their chosen groups
        [activityList addObjectsFromArray:[self getNumberOfAttractions:activitiesPerGroup ofGroup:group usingActivityArray:activityListForLocation]];
    }
    return activityList;
}



- (NSArray *)getNumberOfAttractions:(int)number ofGroup:(NSString *)group usingActivityArray:(NSArray *)activitiesArray
{
    NSMutableArray *attractionsForThisGroup = [[NSMutableArray alloc] init];
    NSMutableArray *returnedAttractions = [[NSMutableArray alloc] init];
    
    for(Attraction *temp in activitiesArray){
        if([temp.group isEqualToString:group]){
            [attractionsForThisGroup addObject:temp];
        }
    }
    
    for(int i = 0; i <= number; i++){
        int randomIndex = [self getRandomNumberLessThan:[attractionsForThisGroup count]];
        Attraction *randomAttraction = [attractionsForThisGroup objectAtIndex:randomIndex];
        [returnedAttractions addObject:randomAttraction];
    }
    
    return returnedAttractions;
}

-(int)getRandomNumberLessThan:(int)max {
    
    return (int)1 + arc4random() % (max-1+1);
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

- (NSArray *)generateSuitableEvents
{
    NSMutableArray *suitableEvents = [[NSMutableArray alloc] init];
    // called by generateActivityList, to include any suitable events
    return suitableEvents;
}

@end