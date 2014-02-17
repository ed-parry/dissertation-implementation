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
@end

@implementation CoreDataManager

- (void)saveCSVToCoreData:(NSString *)csvFileLocation
{
    [self makeArrayFromCSVFile:csvFileLocation];
    int counter = 0;
    for (NSArray *singleAttractionArray in _attractions){
        [self makeAttractionObjectFromArray:singleAttractionArray :counter];
        counter++;
    }
}

- (void)addAttractionToCoreData:(Attraction *)attraction
{

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
    newAttraction.longtitude = [[singleAttractionArray objectAtIndex:8] doubleValue];
    
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
        tempAttractions =  [self removeEmptyLinesFromArray:tempAttractions];
        return tempAttractions;
    }
    
    return tempAttractions;
}

@end
