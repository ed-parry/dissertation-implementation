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
    return self;
}

- (bool)isConnectionAvailable
{
    NSString *URLString = [NSString stringWithContentsOfURL:[NSURL URLWithString:_baseServerURL]
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
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
    [request setTimeoutInterval:10];
    
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
    NSArray *lastFetchedArray;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self getPlistFilePath:@"last_fetched_csv"]]) {
        lastFetchedArray = [[NSArray alloc] initWithContentsOfFile:[self getPlistFilePath:@"last_fetched_csv"]];
    }
    
    NSString *lastFetched = [lastFetchedArray objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *lastFetchedDate = [dateFormatter dateFromString:lastFetched];
    
    return lastFetchedDate;
}

- (void)saveLastFetchedDate:(NSString *)date
{
    // Storing this into a Plist, rather than Core Data.
    NSArray *lastFetchedArray = [[NSArray alloc] initWithObjects:date, nil];
    [lastFetchedArray writeToFile:[self getPlistFilePath:@"last_fetched_csv"] atomically:YES];
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

- (NSString *)getPlistFilePath:(NSString *)fileName
{
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [filePaths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end