//
//  CVSDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CSVDataManager.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"

@interface CSVDataManager ()
@property NSMutableData *dataReceived;
@end

@implementation CSVDataManager

- (void)saveDataFromURL:(NSString *)urlString
{
    // get the last fetched date from core data
    NSDate *lastFetched = [self getLastFetchedDate];
    // get the last modified date from the server
    NSDate *lastModified = [self getLastUpdatedDateOfServerCSV:urlString];
    
    // if the last modified is more recent than the last fetched, go ahead
    NSLog(@"Last Fetched: %@", lastFetched);
    NSLog(@"Last Modified: %@", lastModified);

    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:30.0];
        
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
    [connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0) {
        // Tried to access the CSV, but password is required
        NSURLCredential *newCredential = [NSURLCredential credentialWithUser:@"authors"
                                                                    password:@"5eQqEti5"
                                                                 persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        // Trying again with new credentials
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // if we have all of the data from the URL, save it to file
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Append today's date to the file name, so we know how old the data is in the future.
    NSString *fullFileName = [NSString stringWithFormat:@"attractions-data-%@.csv", [self getTodaysDate]];
    
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", documentFolder, fullFileName];
    
    [_dataReceived writeToFile:fullFilePath atomically:YES];

    // Save today's date into Core Data for future reference.
    [self saveLastFetchedDate:[self getTodaysDate]];
    
    CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
    [coreDataManager saveCSVToCoreData:fullFilePath];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_dataReceived){
        [_dataReceived appendData:data];
    }
    else{
        // if there isn't any data already here, make a new object
        // with this first set of data.
        _dataReceived = [[NSMutableData alloc] initWithData:data];
    }
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
    NSError *error;
    
    NSFetchRequest * lastFetchedDateRequest = [[NSFetchRequest alloc] init];
    [lastFetchedDateRequest setEntity:[NSEntityDescription entityForName:@"CSV_Settings" inManagedObjectContext:context]];
    [lastFetchedDateRequest setIncludesPropertyValues:YES];
    
    NSArray *lastDateArray = [context executeFetchRequest:lastFetchedDateRequest error:&error];
    
    [context save:&error];

    if(lastDateArray.count > 0){
        // get the date string and send it back!
        NSLog(@"Number of dates in Core Data: %i", lastDateArray.count);
        return nil; // change this
    }
    else{
        NSLog(@"Error: There's no date available.");
        return nil;
    }
}

- (void)removeExistingFetchedDate
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    
    NSFetchRequest * allDates = [[NSFetchRequest alloc] init];
    [allDates setEntity:[NSEntityDescription entityForName:@"CSV_Settings" inManagedObjectContext:context]];
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
                     insertNewObjectForEntityForName:@"CSV_Settings"
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
