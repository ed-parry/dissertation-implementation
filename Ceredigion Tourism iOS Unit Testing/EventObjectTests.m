//
//  EventObjectTests.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 27/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Event.h"

@interface EventObjectTests : XCTestCase
@property Event *event;
@end

@implementation EventObjectTests

- (void)setUp
{
    [super setUp];
    _event = [[Event alloc] init];
    
    _event.id = 4;
    _event.title = @"Barley Saturday";
    _event.descriptionText = @"Description text for the event, Barley Saturday";
    _event.location = @"Aberystwyth";
    _event.latitude = @"52.4162226";
    _event.longitude = @"-4.0627321";
    _event.startDate = @"23-04-14";
    _event.startTime = @"08:00";
    _event.endDate = @"23-04-14";
    _event.endTime = @"17:00";
    _event.allDay = 0;
}

- (void)tearDown
{
    _event = nil;
    [super tearDown];
}

- (void)testEventId
{
    XCTAssertEqual(_event.id, 4, @"Check the Event ID value");
}

- (void)testEventTitle
{
    XCTAssertEqual(_event.title, @"Barley Saturday", @"Check the Event title value");
}

- (void)testEventDescriptionText
{
    XCTAssertEqual(_event.descriptionText, @"Description text for the event, Barley Saturday", @"Check the Event description text value");
}

- (void)testEventLocation
{
    XCTAssertEqual(_event.location, @"Aberystwyth", @"Check the Event location value");
}

- (void)testEventLatitude
{
    XCTAssertEqual(_event.latitude, @"52.4162226", @"Check the Event latitude value");
}

- (void)testEventLongitude
{
    XCTAssertEqual(_event.longitude, @"-4.0627321", @"Check the Event longitude value");
}

- (void)testEventStartDate
{
    XCTAssertEqual(_event.startDate, @"23-04-14", @"Check the Event start date value");
}

- (void)testEventStartTime
{
    XCTAssertEqual(_event.startTime, @"08:00", @"Check the Event start time value");
}

- (void)testEventEndDate
{
    XCTAssertEqual(_event.endDate, @"23-04-14", @"Check the event end date value");
}

- (void)testEventEndTime
{
    XCTAssertEqual(_event.endTime, @"17:00", @"Check the event end time value");
}

- (void)testEventAllDay
{
    XCTAssertEqual(_event.allDay, 0, @"Check the event all day value");
}

@end
