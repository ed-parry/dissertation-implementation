//
//  DataManager.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()
- (NSString *)getTodaysDate;
- (void)saveDataToCoreData:(NSString *)fullFilePath;

@property NSMutableData *dataReceived;
@end

@implementation DataManager

- (void)saveDataToCoreData:(NSString *)fullFilePath;
{
    
}

- (void)saveDataFromURL:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // if we have all of the data from the URL, save it to file
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Append today's date to the file name, so we know how old the data is in the future.
    NSString *fullFileName = [NSString stringWithFormat:@"attractions-data-%@.csv", [self getTodaysDate]];
    
    NSString *fullFilePath = [NSString stringWithFormat:@"%@/%@", documentFolder, fullFileName];
    
    [_dataReceived writeToFile:fullFilePath atomically:YES];
    
    // We now have a local CSV file to use, let's store it in Core Data
    [self saveDataToCoreData:fullFilePath];
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

- (NSString *)getTodaysDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    
    return date;
}

@end
