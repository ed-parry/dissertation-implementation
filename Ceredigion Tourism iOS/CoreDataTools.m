//
//  CoreDataTools.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 04/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CoreDataTools.h"
#import "Attraction.h"
#import "AppDelegate.h"

@implementation CoreDataTools

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

@end
