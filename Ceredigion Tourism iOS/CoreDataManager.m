//
//  CoreDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CoreDataManager.h"
#import "CHCSVParser.h"
#import "Attraction.h"
#import "Event.h"
#import "GroupDataManager.h"
#import "EventAndDateFormatManager.h"
#import "AppDelegate.h"

@interface CoreDataManager ()
@property (nonatomic, strong) NSArray *attractions;
@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSString *currentDataType;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation CoreDataManager

- (void)saveCSVToCoreData:(NSString *)csvFileLocation ofType:(NSString *)type
{
    _currentDataType = type;
    [self makeArrayFromCSVFile:csvFileLocation ofType:type];

    if([_currentDataType isEqualToString:@"attractions"]){
        [self cleanCoreData:@"Attractions"];
        int counter = 0;
        for (NSArray *singleAttractionArray in _attractions){
            [self makeAttractionObjectFromArray:singleAttractionArray :counter];
            counter++;
        }
        // Store the default groups, taken from the list of attractions
        GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
        [groupDataManager storeDefaultAllowedGroupsInPlistForAttractionPlanner:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"attractionsDataUpdated" object:self];
    }
    else if([_currentDataType isEqualToString:@"events"]){
        [self cleanCoreData:@"Events"];
        int counter = 0;
        for (NSArray *singleEventArray in _events){
            [self makeEventObjectFromArray:singleEventArray :counter];
            counter++;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"eventsDataUpdated" object:self];
    }
}

- (BOOL)doesCoreDataEntityHaveData:(NSString *)entity
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *allAttractions = [[NSFetchRequest alloc] init];
    [allAttractions setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
    NSUInteger count = [context countForFetchRequest:allAttractions error:&error];
    
    if (count == 0){
        return NO;
    }
    else{
        return YES;
    }
}

- (void)cleanCoreData:(NSString *)entity
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest * allAttractions = [[NSFetchRequest alloc] init];
    [allAttractions setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:context]];
    [allAttractions setIncludesPropertyValues:NO]; // don't get everything, just the ID field.

    NSArray * attractions = [context executeFetchRequest:allAttractions error:&error];
    for (NSManagedObject * attraction in attractions) {
        [context deleteObject:attraction];
    }
    [context save:&error];
}

- (void)addAttractionToCoreData:(Attraction *)attraction
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    NSManagedObject *newAttraction;
    newAttraction = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Attractions"
                  inManagedObjectContext:context];
    
    NSNumber *attractionId = [NSNumber numberWithInt:attraction.id];
    NSNumber *attractionHide = [NSNumber numberWithInt:attraction.hide];
    
    [newAttraction setValue: attractionId forKey:@"id"];
    [newAttraction setValue: attraction.group forKey:@"group"];
    [newAttraction setValue: attraction.name forKey:@"name"];
    [newAttraction setValue: attraction.descriptionText forKey:@"descriptionText"];
    [newAttraction setValue: attraction.address forKey:@"address"];
    [newAttraction setValue: attraction.telephone forKey:@"telephone"];
    [newAttraction setValue: attraction.imageLocationURL forKey:@"imageLocationURL"];
    [newAttraction setValue: attraction.website forKey:@"website"];
    [newAttraction setValue: attraction.latitude forKey:@"latitude"];
    [newAttraction setValue: attraction.longitude forKey:@"longitude"];
    [newAttraction setValue: attractionHide forKey:@"hide"];
    [newAttraction setValue: attraction.adrenalineLevel forKey:@"adrenalineLevel"];

    [context save:&error];
}

- (void)addEventToCoreData:(Event *)event
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error; // maybe pull this out?
    NSManagedObject *newEvent;
    newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Events" inManagedObjectContext:context];
    
    NSNumber *eventId = [NSNumber numberWithInt:event.id];
    NSNumber *eventAllDay = [NSNumber numberWithInt:event.allDay];
    
    [newEvent setValue: eventId forKey:@"id"];
    [newEvent setValue: event.title forKey:@"title"];
    [newEvent setValue: event.descriptionText forKey:@"descriptionText"];
    [newEvent setValue: event.location forKey:@"location"];
    [newEvent setValue: event.latitude forKey:@"latitude"];
    [newEvent setValue: event.longitude forKey:@"longitude"];
    [newEvent setValue: event.startDate forKey:@"startDate"];
    [newEvent setValue: event.startTime forKey:@"startTime"];
    [newEvent setValue: event.endDate forKey:@"endDate"];
    [newEvent setValue: event.endTime forKey:@"endTime"];
    [newEvent setValue: eventAllDay forKey:@"allDay"];
    
    [context save:&error];
}

- (void)makeArrayFromCSVFile:(NSString *)csvFileLocation ofType:(NSString *)type
{
    NSArray *dataArray;
    dataArray = [NSArray arrayWithContentsOfCSVFile:csvFileLocation
                                               options:CHCSVParserOptionsRecognizesBackslashesAsEscapes
                                             delimiter:'\t'];
    
    // remove the first item, because that's the "heading" line from the CSV file.
    // also remove all blank items because they can't become Attraction objects.
    NSMutableArray *tempDataArray = [dataArray mutableCopy];
    [tempDataArray removeObjectAtIndex:0];
    
    tempDataArray = [self removeEmptyLinesFromArray:tempDataArray];
    
    dataArray = [tempDataArray mutableCopy];
    
    if([type isEqualToString:@"attractions"]){
        _attractions = dataArray;
    }
    else if([type isEqualToString:@"events"]){
        _events = dataArray;
    }
}

- (void)makeAttractionObjectFromArray:(NSArray *)singleAttractionArray :(int)counter
{
    Attraction *newAttraction = [[Attraction alloc] init];
    
    newAttraction.id = counter;
    newAttraction.group = [singleAttractionArray objectAtIndex:0];
    newAttraction.name = [singleAttractionArray objectAtIndex:2];
    newAttraction.imageLocationURL = [singleAttractionArray objectAtIndex:3];
    newAttraction.descriptionText = [self stripHTMLFromString:[singleAttractionArray objectAtIndex:4]];
    newAttraction.address = [singleAttractionArray objectAtIndex:5];
    newAttraction.telephone = [singleAttractionArray objectAtIndex:6];
    newAttraction.website = [singleAttractionArray objectAtIndex:7];
    
    newAttraction.latitude = [singleAttractionArray objectAtIndex:8];
    newAttraction.longitude = [singleAttractionArray objectAtIndex:9];
    
    NSString *hideValue = [singleAttractionArray objectAtIndex:10];
    if([hideValue isEqualToString:@""])
    {
        newAttraction.hide = NO;
    }
    else{
        newAttraction.hide = YES;
    }

    // set the new adrenaline levels: green, amber, red.
    NSString *adrenalineLevel = [singleAttractionArray objectAtIndex:1];
    if([adrenalineLevel isEqualToString:@""]){
        newAttraction.adrenalineLevel = @"none";
    }
    else{
        newAttraction.adrenalineLevel = adrenalineLevel;
    }
    
    [self addAttractionToCoreData:newAttraction];
}

- (void)makeEventObjectFromArray:(NSArray *)singleEventArray :(int)counter
{
    Event *newEvent = [[Event alloc] init];
    newEvent.id = counter;
    newEvent.title = [singleEventArray objectAtIndex:4];
    newEvent.descriptionText = [singleEventArray objectAtIndex:5];
    newEvent.location = [singleEventArray objectAtIndex:6];
    newEvent.latitude = [singleEventArray objectAtIndex:7];
    newEvent.longitude = [singleEventArray objectAtIndex:8];

    NSString *startDate = [singleEventArray objectAtIndex:0];
    NSString *startTime = [singleEventArray objectAtIndex:2];
    NSString *endDate = [singleEventArray objectAtIndex:1];
    NSString *endTime = [singleEventArray objectAtIndex:3];
    
    if([startTime length] == 0){
        startTime = @"00:00";
        newEvent.allDay = 1;
    }
    if([endTime length] == 0){
        endTime = @"00:00";
        newEvent.allDay = 1;
    }
    
    newEvent.startDate = startDate;
    newEvent.startTime = startTime;
    newEvent.endDate = endDate;
    newEvent.endTime = endTime;

    [self addEventToCoreData:newEvent];
}

- (NSString *)stripHTMLFromString:(NSString *)stringToStrip
{
    NSRange r;
    while ((r = [stringToStrip rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        stringToStrip = [stringToStrip stringByReplacingCharactersInRange:r withString:@" "]; // replace with a space.
    return stringToStrip;
}

- (NSMutableArray *) removeEmptyLinesFromArray:(NSMutableArray *)tempAttractions
{
    NSArray *tempObject = [tempAttractions objectAtIndex:tempAttractions.count-1];
    
    NSString *firstItem = [tempObject objectAtIndex:0];
    if([firstItem  isEqual: @""]){
        [tempAttractions removeObjectAtIndex:tempAttractions.count-1];
        return tempAttractions;
    }
    return tempAttractions;
}

- (Attraction *)getSingleAttractionFromName:(NSString *)name
{
    Attraction *returnedAttraction = [[Attraction alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *singleAttraction = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attractions"
                                              inManagedObjectContext:context];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name==%@",name];
    [singleAttraction setEntity:entity];
    [singleAttraction setPredicate:predicate];
    [singleAttraction setIncludesPropertyValues:YES];
    
    NSArray *entities = [[context executeFetchRequest:singleAttraction
                                                error:&error] mutableCopy];
    
    returnedAttraction = [entities objectAtIndex:0];
    
    return returnedAttraction;
}

- (NSArray *) getAllAttractionPositions
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest * allAttractions = [[NSFetchRequest alloc] init];
    [allAttractions setEntity:[NSEntityDescription entityForName:@"Attractions" inManagedObjectContext:context]];
    [allAttractions setIncludesPropertyValues:YES];
    
    NSArray * attractionsManagedObj = [context executeFetchRequest:allAttractions error:&error];
    
    [context save:&error];
    return [self checkAndRemoveHiddenAttractions:attractionsManagedObj];
}

- (NSArray *) getAllAttractionGroupTypes
{
    NSArray *allAttractions = [self getAllAttractionPositions];
    NSMutableSet *allGroups = [[NSMutableSet alloc] init];
    
    for(Attraction *currentAttraction in allAttractions){
        [allGroups addObject:currentAttraction.group];
    }
    NSArray *allGroupsArray = [[NSArray alloc] initWithArray:[allGroups allObjects]];

    return [self getAlphabeticallyOrderedArray:allGroupsArray forArrayType:@"groups"];
}

- (NSArray *) getAllAttractionsInGroupArrays
{
//    NSArray *allGroups = [self getAllAttractionGroupTypes];
    NSMutableArray *allAttractionsByGroupArrays = [[NSMutableArray alloc] init];
    
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    NSArray *allGroups = [groupDataManager getAllowedGroupsFromPlistForAttractionPlanner:NO];
    
    for(NSString *group in allGroups){
        NSArray *allSingleGroupAttractions = [self getAllAttractionsForGroup:group];
        [allAttractionsByGroupArrays addObject:allSingleGroupAttractions];
    }
    NSArray *allAttractionsInGroupArrays = [[NSArray alloc] initWithArray:allAttractionsByGroupArrays];
    return allAttractionsInGroupArrays;
}

- (NSArray *)getAllAttractionsForGroup:(NSString *)group
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *singleAttraction = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attractions" inManagedObjectContext:context];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"group==%@",group];
    [singleAttraction setEntity:entity];
    [singleAttraction setPredicate:predicate];
    [singleAttraction setIncludesPropertyValues:YES];
    
    NSArray *allAttractions = [[context executeFetchRequest:singleAttraction error:&error] mutableCopy];
    
    NSArray *allOrderedAttractions = [self getAlphabeticallyOrderedArray:allAttractions forArrayType:@"attractions"];
    
    return [self checkAndRemoveHiddenAttractions:allOrderedAttractions];
}

- (NSArray *)checkAndRemoveHiddenAttractions:(NSArray *)attractions
{
    NSMutableArray *mutableAttractions = [[NSMutableArray alloc] initWithArray:attractions];
    
    for(Attraction *temp in attractions){
        if(temp.hide == 1){
            [mutableAttractions removeObject:temp];
        }
    }
    
    NSArray *correctAttractions = [[NSArray alloc]initWithArray:mutableAttractions];
    
    return correctAttractions;
}

- (NSArray *)getAlphabeticallyOrderedArray:(NSArray *)unsortedArray forArrayType:(NSString *)arrayType
{
    NSArray *sortedArray;
    
    if([arrayType isEqualToString:@"groups"]){
        sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(NSString *)obj1 compare:(NSString *)obj2 options:NSNumericSearch];
        }];
    }
    else if([arrayType isEqualToString:@"attractions"]){
        sortedArray = [unsortedArray sortedArrayUsingComparator:^NSComparisonResult(Attraction *obj1, Attraction *obj2) {
            return [(NSString *)obj1.name compare:(NSString *)obj2.name options:NSNumericSearch];
        }];
    }
    return sortedArray;
}


// EVENTS RETRIEVAL CODE
- (NSArray *)getAllEvents
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *allEventsRequest = [[NSFetchRequest alloc] init];
    [allEventsRequest setEntity:[NSEntityDescription entityForName:@"Events" inManagedObjectContext:context]];
    [allEventsRequest setIncludesPropertyValues:YES];
    
    NSArray *allEventsArray = [context executeFetchRequest:allEventsRequest error:&error];
    
    [context save:&error];
    return allEventsArray;
}

- (NSArray *)getAllEventDates
{
    NSArray *allEvents = [self getAllEvents];
    NSMutableArray *allEventDates = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];
    
    for (Event *event in allEvents){

        NSDate *startDate = [dateFormatter dateFromString:event.startDate];
        [allEventDates addObject:startDate];
        
        if([event.startDate isEqualToString:event.endDate]){
            // don't add the end date - it's the same as the start date anyway.
        }
        else{
            NSDate *endDate = [dateFormatter dateFromString:event.endDate];
            [allEventDates addObject:endDate];
            // get the filler dates and add them, too.
            EventAndDateFormatManager *dateManager = [[EventAndDateFormatManager alloc] init];
            [allEventDates addObjectsFromArray:[dateManager getAllEventFillerDatesBetween:startDate and:endDate]];
        }
    }
    NSArray *allReturnedEventDates = [[NSArray alloc] initWithArray:allEventDates];
    return allReturnedEventDates;
}

- (Event *)getSingleEventByTitle:(NSString *)title
{
    Event *singleEvent = [[Event alloc] init];
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest *singleEventRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Events" inManagedObjectContext:context];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"title==%@",title];
    [singleEventRequest setEntity:entity];
    [singleEventRequest setPredicate:predicate];
    [singleEventRequest setIncludesPropertyValues:YES];
    
    NSArray *returnedEvents = [[context executeFetchRequest:singleEventRequest error:&error] mutableCopy];
    if([returnedEvents count] > 0){
        singleEvent = [returnedEvents objectAtIndex:0];
    }
    else{
        singleEvent = nil;
    }
    return singleEvent;
}

@end
