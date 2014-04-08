//
//  AttractionsCSVDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 12/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionsCSVDataManager.h"
#import "CoreDataManager.h"

@interface AttractionsCSVDataManager ()
@property NSMutableData *dataReceived;
@property NSString *baseServerURL;
@property NSString *attractionsURL;
@property NSOperationQueue *queue;
@end

@implementation AttractionsCSVDataManager

- (id)init
{
    _baseServerURL = @"http://www.cardigan.cc/app/";
    _queue = [[NSOperationQueue alloc] init];
    // append the locations.csv to the base URL.
    _attractionsURL = [NSString stringWithFormat:@"%@locations.csv", _baseServerURL];
    return self;
}

- (void)saveDataFromURL
{
    // Start the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSDate *lastFetched = [super getLastFetchedDate];
    NSDate *lastModified = [super getLastUpdatedDateOfServerCSV:_attractionsURL];
    
    if(lastModified == nil){
        // give it a second chance to get the HTTP header.
        lastModified = [super getLastUpdatedDateOfServerCSV:_attractionsURL];
    }
    
    // If the file was last modifed since we last fetched it, or we've never fetched a file before, grab it.
    if((lastFetched == nil) || ([lastModified compare: lastFetched] == NSOrderedDescending))
    {

        NSURL *url = [NSURL URLWithString:_attractionsURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:25.0];
        
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [connection setDelegateQueue:_queue];
        [connection start];
    }
    else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        // Already have the latest version.
    }
}

// only to be called from the settings menu
// TODO - may be removed at a later date.
- (void)saveDataFromURLReset
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *url = [NSURL URLWithString:_attractionsURL];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // called when there's no network connection, or the timeout is hit. In this case, we should just carry on and use the data that's already in the DB.
    NSLog(@"Error fetching the attractions CSV file. Will use the existing Core Data datasource.");
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
    
    // stop the network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
    [coreDataManager saveCSVToCoreData:fullFilePath ofType:@"attractions"];
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

@end
