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
    
    NSFetchRequest * allAttractions = [[NSFetchRequest alloc] init];
    [allAttractions setEntity:[NSEntityDescription entityForName:@"Attractions" inManagedObjectContext:context]];
    [allAttractions setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * attractions = [context executeFetchRequest:allAttractions error:&error];
    // [allAttractions release]; // figure out why this doesn't work
    //error handling goes here
    for (NSManagedObject * attraction in attractions) {
        [context deleteObject:attraction];
    }
    NSError *saveError = nil;
    [context save:&saveError];
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
    NSString *attractionLat = [NSString stringWithFormat:@"%f", attraction.latitude];
    NSString *attractionLong = [NSString stringWithFormat:@"%f", attraction.longitude];
    NSNumber *attractionHide = [NSNumber numberWithInt:attraction.hide];
    
    [newAttraction setValue: attractionId forKey:@"id"];
    [newAttraction setValue: attraction.group forKey:@"group"];
    [newAttraction setValue: attraction.name forKey:@"name"];
    [newAttraction setValue: attraction.description forKey:@"descriptionText"];
    [newAttraction setValue: attraction.address forKey:@"address"];
    [newAttraction setValue: attraction.telephone forKey:@"telephone"];
    [newAttraction setValue: attraction.imageLocationURL forKey:@"image"];
    [newAttraction setValue: attractionLat forKey:@"latitude"];
    [newAttraction setValue: attractionLong forKey:@"longitude"];
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
    newAttraction.description = [singleAttractionArray objectAtIndex:3];
    newAttraction.address = [singleAttractionArray objectAtIndex:4];
    newAttraction.telephone = [singleAttractionArray objectAtIndex:5];
    newAttraction.URL = [singleAttractionArray objectAtIndex:6];
    
    newAttraction.latitude = [[singleAttractionArray objectAtIndex:7] doubleValue];
    newAttraction.longitude = [[singleAttractionArray objectAtIndex:8] doubleValue];
    
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

- (NSMutableArray *) removeEmptyLinesFromArray:(NSMutableArray *)tempAttractions
{
    NSArray *tempObject = [tempAttractions objectAtIndex:tempAttractions.count-1];
    
    NSString *firstItem = [tempObject objectAtIndex:0];
    if([firstItem  isEqual: @""]){
        [tempAttractions removeObjectAtIndex:tempAttractions.count-1];
        //tempAttractions =  [self removeEmptyLinesFromArray:tempAttractions];
        return tempAttractions;
    }
    
    return tempAttractions;
}

@end
