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
#import "AppDelegate.h"


@interface CoreDataManager ()
@property NSArray *attractions;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation CoreDataManager

- (void)saveCSVToCoreData:(NSString *)csvFileLocation
{
    [self makeArrayFromCSVFile:csvFileLocation];
    [self cleanCoreData];
    int counter = 0;
    for (NSArray *singleAttractionArray in _attractions){
        [self makeAttractionObjectFromArray:singleAttractionArray :counter];
        counter++;
    }
}

// Removes all existing data from the database, incase of duplicates coming from the CSV file.
- (void)cleanCoreData
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest * allAttractions = [[NSFetchRequest alloc] init];
    [allAttractions setEntity:[NSEntityDescription entityForName:@"Attractions" inManagedObjectContext:context]];
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
    [newAttraction setValue: attraction.imageLocationURL forKey:@"image"];
    [newAttraction setValue: attraction.website forKey:@"website"];
    [newAttraction setValue: attraction.latitude forKey:@"latitude"];
    [newAttraction setValue: attraction.longitude forKey:@"longitude"];
    [newAttraction setValue: attractionHide forKey:@"hide"];

    [context save:&error];
}

- (void)makeArrayFromCSVFile:(NSString *)csvFileLocation
{
    _attractions = [NSArray arrayWithContentsOfCSVFile:csvFileLocation
                                               options:CHCSVParserOptionsRecognizesBackslashesAsEscapes
                                             delimiter:'\t'];
    
    // remove the first item, because that's the "heading" line from the CSV file.
    // also remove all blank items because they can't become Attraction objects.
    NSMutableArray *tempAttractions = [_attractions mutableCopy];
    [tempAttractions removeObjectAtIndex:0];
    
    tempAttractions = [self removeEmptyLinesFromArray:tempAttractions];
    
    _attractions = [tempAttractions mutableCopy];
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
    return attractionsManagedObj;
}

- (NSArray *) getAllAttractionGroupTypes
{
    NSArray *allAttractions = [self getAllAttractionPositions];
    NSMutableSet *allGroups = [[NSMutableSet alloc] init];
    
    for(Attraction *currentAttraction in allAttractions){
        [allGroups addObject:currentAttraction.group];
    }
    NSArray *allGroupsArray = [[NSArray alloc] initWithArray:[allGroups allObjects]];
    return allGroupsArray;
}

@end
