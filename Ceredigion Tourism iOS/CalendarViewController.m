//
//  CalendarViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 10/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CalendarViewController.h"
#import "CoreDataManager.h"
#import "VRGCalendarView.h"


@interface CalendarViewController () <VRGCalendarViewDelegate>
@property NSArray *allEventDates;
@property CoreDataManager *dataManager;
@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
}

- (bool)isDateWithinEventsArray:(NSDate *)date
{
    [self addEventsToLocalArray];
    if([_allEventDates containsObject:date]){
        return YES;
    }
    return NO;
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{
    bool showEventButton = [self isDateWithinEventsArray:date];
    if(showEventButton){
        // show the event button.
    }
    else{
        // don't show the event button, maybe hide it by force.
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated
{
    [self addEventsToLocalArray];
    [calendarView markDates:_allEventDates];
}

- (void)addEventsToLocalArray
{
    _dataManager = [[CoreDataManager alloc] init];
    _allEventDates = [_dataManager getAllEventDates];
}

// Bit of a hack to fix the clear navigation bar.
- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
