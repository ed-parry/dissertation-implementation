//
//  CVSDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CSVDataManager.h"
#import "AppDelegate.h"

@interface CSVDataManager ()
@property NSMutableData *dataReceived;
@property NSString *baseServerURL;
@property NSString *attractionsURL;
@property NSString *calendarURL;
@property NSString *dataURL;
@end

@implementation CSVDataManager

- (id)init
{
    _baseServerURL = @"http://www.cardigan.cc/app/";
    
    // append the locations.csv to the base URL.
    _attractionsURL = [NSString stringWithFormat:@"%@locations.csv", _baseServerURL];
    return self;
}

- (bool)isConnectionAvailable
{
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:_baseServerURL] encoding:NSUTF8StringEncoding error:nil];
    if(URLString != NULL){
        return YES;
    }
    return NO;
}

- (NSDate *)getLastUpdatedDateOfServerCSV:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Has to be mutable, to be able to set HTTP Method.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    if(response){
        NSDate *lastModifiedDate;
        NSString *lastModifiedString = [[response allHeaderFields] objectForKey:@"Last-Modified"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";

        lastModifiedDate = [dateFormatter dateFromString:lastModifiedString];
        
        NSDateFormatter *secondaryFormatter = [[NSDateFormatter alloc]init];
        [secondaryFormatter setDateFormat:@"dd-MM-yyyy"];
        
        lastModifiedString = [secondaryFormatter stringFromDate:lastModifiedDate];
        lastModifiedDate = [secondaryFormatter dateFromString:lastModifiedString];
        
        return lastModifiedDate;
    }
    else{
        return nil;
    }
}

- (NSDate *)getLastFetchedDate
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Application_Settings" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    
    if(fetchedObjects.count > 0){
        NSMutableArray *elementsFromColumn = [[NSMutableArray alloc] init];
        [elementsFromColumn addObject:[[fetchedObjects objectAtIndex:0] valueForKey:@"csv_last_fetched"]];
        
        NSString *lastFetchedDateString = [elementsFromColumn objectAtIndex: 0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *lastFetchedDate = [dateFormatter dateFromString:lastFetchedDateString];
        
        return lastFetchedDate;
    }
    else{
        return nil;
    }
}

- (void)removeExistingFetchedDate
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest * allDates = [[NSFetchRequest alloc] init];
    [allDates setEntity:[NSEntityDescription entityForName:@"Application_Settings" inManagedObjectContext:context]];
    [allDates setIncludesPropertyValues:NO]; // don't get everything, just the ID field.
    
    NSArray * dates = [context executeFetchRequest:allDates error:&error];
    for (NSManagedObject * date in dates) {
        [context deleteObject:date];
    }
    [context save:&error];
}

- (void)saveLastFetchedDate:(NSString *)date
{
    [self removeExistingFetchedDate];
    // connect to Core Data, and save the date
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    NSManagedObject *newFetchedDate;
    newFetchedDate = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Application_Settings"
                     inManagedObjectContext:context];
    
    [newFetchedDate setValue: date forKey:@"csv_last_fetched"];

    [context save:&error];
}

- (bool)recentFileExists
{
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullFileName = [NSString stringWithFormat:@"attractions-data-%@.csv", [self getTodaysDate]];
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", documentFolder, fullFileName];
    
    bool fileExists = [[NSFileManager defaultManager] fileExistsAtPath:fullFilePath];
    
    return fileExists;
}

- (NSString *)getTodaysDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    return date;
}

@end
