//
//  AttractionTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 26/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Attraction.h"

@interface AttractionObjectTests : XCTestCase
@property Attraction *testAttraction;
@end

@implementation AttractionObjectTests

- (void)setUp
{
    [super setUp];
    _testAttraction = [[Attraction alloc] init];
    _testAttraction.id = 1;
    _testAttraction.group = @"Activity";
    _testAttraction.name = @"Aberystwyth Arts Centre";
    _testAttraction.imageLocationURL = @"http://google.com/image-url.jpg";
    _testAttraction.descriptionText = @"The description field of the Aberystwyth Arts Centre location";
    _testAttraction.address = @"Aberystwyth Arts Centre, Aberystwyth University Campus, Aberystywth, Ceredigion, SY23 2ET";
    _testAttraction.telephone = @"01782 398338";
    _testAttraction.website = @"http://google.com";
    _testAttraction.latitude = @"0.402731";
    _testAttraction.longitude = @"-1.323723";
    _testAttraction.hide = NO;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAttractionId
{
    XCTAssertEqual(_testAttraction.id, 1, @"Check the Attraction ID value");
}

- (void)testAttractionGroup
{
    XCTAssertEqual(_testAttraction.group, @"Activity", @"Check the Attraction Group value");
}

- (void)testAttractionName
{
    XCTAssertEqual(_testAttraction.name, @"Aberystwyth Arts Centre", @"Check the Attraction Name value");
}

- (void)testAttractionImageLocationURL
{
    XCTAssertEqual(_testAttraction.imageLocationURL, @"http://google.com/image-url.jpg", @"Check the Attraction Image Location URL value");
}

- (void)testAttractionAddress
{
    XCTAssertEqual(_testAttraction.address, @"Aberystwyth Arts Centre, Aberystwyth University Campus, Aberystywth, Ceredigion, SY23 2ET", @"Check the Attraction Address value");
}

- (void)testAttractionTelephone
{
    XCTAssertEqual(_testAttraction.telephone, @"01782 398338", @"Check the Attraction Telephone value");
}

- (void)testAttractionURL
{
    XCTAssertEqual(_testAttraction.website, @"http://google.com", @"Check the Attraction URL value");
}

- (void)testAttractionLatitude
{
    XCTAssertEqual(_testAttraction.latitude, @"0.402731", @"Check the Attraction Latitude value");
}

- (void)testAttractionLongitude
{
    XCTAssertEqual(_testAttraction.longitude, @"-1.323723", @"Check the Attraction Longitude value");
}

- (void)testAttractionHide
{
    int hideValue = 0;
    if(_testAttraction.hide == NO){
        hideValue = 1;
    }
    
    XCTAssertEqual(hideValue, 1, @"Check the Attraction Hide value");
}

- (void)testGetAttractionGroupImage
{
    UIImage *attractionImage = [UIImage imageNamed:@"Attraction Icon"];
    UIImage *receivedImage = [_testAttraction getAttractionGroupImage:@"Attraction"];
    
    // convert to NSData to compare
    NSData *setImageData = UIImagePNGRepresentation(attractionImage);
    NSData *receivedImageData = UIImagePNGRepresentation(receivedImage);
    
    bool areImagesEqual = [setImageData isEqual:receivedImageData];
    
    XCTAssertTrue(areImagesEqual, @"The returned image is equal to the image expected.");
}

- (void)testGetAttractionGroupColour
{
    /*
     Below is the code that is ran in this method, so explains what we would expect to see.
     
     else if([group isEqualToString:@"Food & drink"]){
     // Light Blue
     return [UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:229.0f/255.0f alpha:alpha];
     }
     
     */
}
@end
