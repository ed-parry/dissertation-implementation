//
//  CVSDataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CSVDataManager.h"
#import "CoreDataManager.h"

@interface CSVDataManager ()
- (NSString *)getTodaysDate;
- (bool)recentFileExists;
- (bool)compareCSVFiles:(NSString *)fullFilePathOne :(NSString *)fullFilePathTwo;

@property NSMutableData *dataReceived;
@end

@implementation CSVDataManager

- (void)saveDataFromURL:(NSString *)urlString
{
    // only do it if there's not an existing file with today's date.
    if(![self recentFileExists]){
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    // otherwise, we already have a recent file (within 24 hours)
    // so let's just use that instead.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // if we have all of the data from the URL, save it to file
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Append today's date to the file name, so we know how old the data is in the future.
    NSString *fullFileName = [NSString stringWithFormat:@"attractions-data-%@.csv", [self getTodaysDate]];
    
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", documentFolder, fullFileName];
    
    [_dataReceived writeToFile:fullFilePath atomically:YES];
    
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

- (bool)areFilesTheSame:(NSString *)fullFilePathOne :(NSString *)fullFilePathTwo
{
    // This method will check the two incoming CSV files to see whether they are the same
    // or whether they are different. If they're the same, we don't bother going forward
    // to process it into the database. But if they're different, we remove the old one
    // and process the new one into Core Data.
    return NO;
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
