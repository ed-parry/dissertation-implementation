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
@property (strong, nonatomic) IBOutlet UIButton *viewEventsButton;
@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_viewEventsButton setHidden:YES];

    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate = self;
    
    [self.view addSubview:calendar];
}

- (bool)isDateWithinEventsArray:(NSDate *)date
{
    [self addEventsToLocalArray];
    for(NSDate *arrayDate in _allEventDates){
        if([date isEqualToDate:arrayDate]){
            return TRUE;
        }
    }
    return NO;
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{
    bool showEventButton = [self isDateWithinEventsArray:date];
    if(showEventButton){
        [_viewEventsButton setHidden:NO];
    }
    else{
        [_viewEventsButton setHidden:YES];
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
    _allEventDates = [self stripTimeFromDatesArray:_allEventDates];
}

- (NSArray *)stripTimeFromDatesArray:(NSArray *)datesArray
{
    NSMutableArray *newDatesArray = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    
    for(NSDate *date in datesArray){
        NSString *dateString = [NSString stringWithFormat:@"%@", date];
        NSString *dateSegment = [dateString substringToIndex:10];
        dateSegment = [self switchDateStringOrder:dateSegment];

        NSDate *newDate = [dateFormatter dateFromString:dateSegment];
        [newDatesArray addObject:newDate];
    }
    return newDatesArray;
}

- (NSString *)switchDateStringOrder:(NSString *)date
{
    NSRange yearRange = NSMakeRange(0, 4);
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10-8);
    
    NSString *yearSegment = [date substringWithRange:yearRange];
    NSString *monthSegment = [date substringWithRange:monthRange];
    NSString *daySegment = [date substringWithRange:dayRange];
    
    return [NSString stringWithFormat:@"%@-%@-%@", daySegment, monthSegment, yearSegment];
}

// Bit of a hack to fix the clear navigation bar.
- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}
- (void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
