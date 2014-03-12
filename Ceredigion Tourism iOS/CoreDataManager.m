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
#import "AppDelegate.h"


@interface CoreDataManager ()
@property NSArray *attractions;
@property NSArray *events;
@property NSString *currentDataType;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation CoreDataManager

- (void)saveCSVToCoreData:(NSString *)csvFileLocation ofType:(NSString *)type
{
    _currentDataType = type; // may not need this.
    [self makeArrayFromCSVFile:csvFileLocation ofType:type];


    if([_currentDataType isEqualToString:@"attractions"]){
        [self cleanCoreData:@"Attractions"];
        int counter = 0;
        for (NSArray *singleAttractionArray in _attractions){
            [self makeAttractionObjectFromArray:singleAttractionArray :counter];
            counter++;
        }
    }
    else if([_currentDataType isEqualToString:@"events"]){
        [self cleanCoreData:@"Events"];
        int counter = 0;
        for (NSArray *singleEventArray in _events){
            [self makeEventObjectFromArray:singleEventArray :counter];
            counter++;
        }
    }
}

// Removes all existing data from the database, incase of duplicates coming from the CSV file.
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
    newAttraction.name = [singleAttractionArray objectAtIndex:1];
    newAttraction.imageLocationURL = [singleAttractionArray objectAtIndex:2];
    newAttraction.descriptionText = [self stripHTMLFromString:[singleAttractionArray objectAtIndex:3]];
    newAttraction.address = [singleAttractionArray objectAtIndex:4];
    newAttraction.telephone = [singleAttractionArray objectAtIndex:5];
    newAttraction.website = [singleAttractionArray objectAtIndex:6];
    
    newAttraction.latitude = [singleAttractionArray objectAtIndex:7];
    newAttraction.longitude = [singleAttractionArray objectAtIndex:8];
    
    NSString *hideValue = [singleAttractionArray objectAtIndex:9];
    if([hideValue isEqualToString:@""])
    {
        newAttraction.hide = NO;
    }
    else{
        newAttraction.hide = YES;
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
    newEvent.startDate = [singleEventArray objectAtIndex:0];
    newEvent.startTime = [singleEventArray objectAtIndex:2];
    newEvent.endDate = [singleEventArray objectAtIndex:1];
    newEvent.endTime = [singleEventArray objectAtIndex:3];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Attractions" inManagedObjectContext:context];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name==%@",name];
    [singleAttraction setEntity:entity];
    [singleAttraction setPredicate:predicate];
    [singleAttraction setIncludesPropertyValues:YES];
    
    NSArray *entities = [[context executeFetchRequest:singleAttraction error:&error] mutableCopy];
    
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
    NSArray *allGroups = [self getAllAttractionGroupTypes];
    NSMutableArray *allAttractionsByGroupArrays = [[NSMutableArray alloc] init];
    
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

@end
