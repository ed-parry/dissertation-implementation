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
@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate = self;
    
    _allEventDates = [dataManager getAllEventDates];
    
    NSArray *tempDates = [[NSArray alloc] initWithObjects:[NSDate date], nil];
    
    NSArray *markerColours = [[NSArray alloc] initWithObjects:[UIColor redColor], [UIColor blueColor], nil];
    
    [calendar markDates:tempDates withColors:markerColours];
    
    [self.view addSubview:calendar];
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{
    
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated
{
    
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
