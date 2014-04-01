//
//  CalendarViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 10/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CalendarViewController.h"
#import "CoreDataManager.h"
#import "SingleAttractionEventViewController.h"
#import "VRGCalendarView.h"
#import "DateFormatManager.h"

@interface CalendarViewController () <VRGCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property NSArray *allEventDates;
@property CoreDataManager *dataManager;
@property DateFormatManager *dateManager;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *dayEventsTable;
@property (strong, nonatomic) NSString *selectedDay;
@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];
    
    // Listen out for any new data available from Core Data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coreDataChanged)
                                                 name:@"eventsDataUpdated"
                                               object:nil];

    _selectedDay = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    _dayEventsTable.delegate = self;
    _dayEventsTable.dataSource = self;

    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];

    calendar.delegate = self;
    
    [self.view addSubview:calendar];
}

- (void)coreDataChanged
{
    [self addEventsToLocalArray];
}

- (bool)isDateWithinEventsArray:(NSDate *)date
{
    [self addEventsToLocalArray];
    for(NSDate *arrayDate in _allEventDates){
        if([date isEqualToDate:arrayDate]){
            return TRUE;
        }
    }
    return FALSE;
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date
{

    // Required timezone changes to update dates for DST.
    NSTimeZone *thisTZ = [NSTimeZone systemTimeZone];
    if([thisTZ isDaylightSavingTimeForDate:date]){
        NSString *thisDate = [NSString stringWithFormat:@"%@", date];
        
        NSRange yearRange = NSMakeRange(0, 4-0);
        NSRange monthRange = NSMakeRange(5, 7- 5);
        NSRange dayRange = NSMakeRange(8, 10-8);

        NSString *thisDay = [thisDate substringWithRange:dayRange];
        NSString *thisMonth = [thisDate substringWithRange:monthRange];
        NSString *thisYear = [thisDate substringWithRange:yearRange];
        
        int dayInt = [thisDay intValue];
        dayInt = dayInt + 2;
        
        thisDay = [NSString stringWithFormat:@"%i", dayInt];
        
        NSString *updatedDate = [NSString stringWithFormat:@"%@-%@-%@", thisYear, thisMonth, thisDay];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        date = [dateFormatter dateFromString:updatedDate];
    }
    _selectedDay = [NSString stringWithFormat:@"%@", date];
    [_dayEventsTable reloadData];
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month withYear:(int)year targetHeight:(float)targetHeight animated:(BOOL)animated
{
    [self addEventsToLocalArray];
    NSArray *allEventsForActiveMonth = [[NSArray alloc] initWithArray:[self removeEventsNotInActiveMonth:month orYear:year]];
    NSTimeInterval animationDuration = animated ? 0.3 :0.0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = _dayEventsTable.frame;
        frame.origin.y = CGRectGetMinX(calendarView.frame) + targetHeight;
        frame.size.height = self.view.frame.size.height - frame.origin.y;
        _dayEventsTable.frame = frame;
    }];
    [calendarView markDates:allEventsForActiveMonth];
}

- (NSArray *)removeEventsNotInActiveMonth:(int)month orYear:(int)year
{
    NSMutableArray *newEventsArray = [[NSMutableArray alloc] init];
    for(NSDate *date in _allEventDates){
        NSString *dateString = [NSString stringWithFormat:@"%@", date];
        NSRange monthRange = NSMakeRange(5, 7- 5);
        NSRange yearRange = NSMakeRange(0, 4-0);
        NSString *monthString = [dateString substringWithRange:monthRange];
        NSString *yearString = [dateString substringWithRange:yearRange];
        int thisMonth = [monthString intValue];
        int thisYear = [yearString intValue];
        
        if((thisMonth == month) && (thisYear == year)){
            [newEventsArray addObject:date];
        }
    }
    return newEventsArray;
}

- (void)addEventsToLocalArray
{
    _dataManager = [[CoreDataManager alloc] init];
    _allEventDates = [_dataManager getAllEventDates];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    _dateManager = [[DateFormatManager alloc] init];
    if(!_selectedDay){
        return [NSString stringWithFormat:@"Events on %@", [_dateManager getTextualDate:@"2014-01-01" withYear:NO]];
    }
    else{
        NSString *date = [NSString stringWithFormat:@"%@", _selectedDay];
        return [NSString stringWithFormat:@"Events on %@", [_dateManager getTextualDate:date withYear:NO]];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *thisDaysEvents = [[NSArray alloc] initWithArray:[self returnEventsForSelectedDay:_selectedDay]];
    return [thisDaysEvents count];
}

- (NSArray *)returnEventsForSelectedDay:(NSString *)date
{
    NSMutableArray *daysEvents = [[NSMutableArray alloc] init];
    NSArray *allEvents;

    if(!_dataManager){
        _dataManager = [[CoreDataManager alloc] init];
    }
    allEvents = [[NSArray alloc] initWithArray:[_dataManager getAllEvents]];
    
    NSRange yearRange = NSMakeRange(2, 4-2);
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10-8);
    
    NSString *selectedDateDay = [date substringWithRange:dayRange];
    NSString *selectedDateMonth = [date substringWithRange:monthRange];
    NSString *selectedDateYear = [date substringWithRange:yearRange];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yy"];

    for(Event *tempEvent in allEvents){
        
        if([tempEvent.startDate isEqualToString:tempEvent.endDate]){
            NSRange tempEventMonthRange = NSMakeRange(3, 5-3);
            NSRange tempEventYearRange = NSMakeRange(6, 8-6);
            NSString *tempEventDateDay = [tempEvent.startDate substringToIndex:2];
            NSString *tempEventDateMonth = [tempEvent.startDate substringWithRange:tempEventMonthRange];
            NSString *tempEventDateYear = [tempEvent.startDate substringWithRange:tempEventYearRange];

            if(([selectedDateDay isEqualToString:tempEventDateDay]) && ([selectedDateMonth isEqualToString:tempEventDateMonth]) && ([selectedDateYear isEqualToString:tempEventDateYear])){
                [daysEvents addObject:tempEvent];
            }
        }
        else{
            NSDate *startDate = [dateFormatter dateFromString:tempEvent.startDate];
            NSDate *endDate = [dateFormatter dateFromString:tempEvent.endDate];
            
            NSMutableArray *fillerDates = [[NSMutableArray alloc] initWithArray:[_dataManager getAllEventFillerDatesBetween:startDate and:endDate]];
            
            [fillerDates addObject:endDate];
            if([fillerDates count] == 2){
                NSLog(@"Called for event %@", tempEvent.title);
                
                for(NSDate *fillerTempDate in fillerDates){
                    NSString *fillerTempDateString = [NSString stringWithFormat:@"%@", fillerTempDate];
                    NSString *fillerTempDay = [fillerTempDateString substringWithRange:dayRange];
                    int fillerDay = [fillerTempDay intValue];
                    fillerDay++;
                    fillerTempDay = [NSString stringWithFormat:@"%i", fillerDay];
                    NSString *fillerTempMonth = [fillerTempDateString substringWithRange:monthRange];
                    if(([selectedDateDay isEqualToString:fillerTempDay]) && ([selectedDateMonth isEqualToString:fillerTempMonth])){
                        [daysEvents addObject:tempEvent];
                    }
                }
            }
            else{
                for(NSDate *fillerTempDate in fillerDates){
                    NSString *fillerTempDateString = [NSString stringWithFormat:@"%@", fillerTempDate];
                    NSString *fillerTempDay = [fillerTempDateString substringWithRange:dayRange];
                    NSString *fillerTempMonth = [fillerTempDateString substringWithRange:monthRange];
                    if(([selectedDateDay isEqualToString:fillerTempDay]) && ([selectedDateMonth isEqualToString:fillerTempMonth])){
                        [daysEvents addObject:tempEvent];
                    }
                }
            }
        }
    }
    
    return daysEvents;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get event title, and start/end date here.
    
    static NSString *CellIdentifier = @"eventTableCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSArray *thisDaysEvents = [self returnEventsForSelectedDay:_selectedDay];
    
    Event *thisEvent = [thisDaysEvents objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisEvent.title;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *path = [self.dayEventsTable indexPathForSelectedRow];
    NSArray *thisDaysEvents = [self returnEventsForSelectedDay:_selectedDay];
    Event *thisEvent = [thisDaysEvents objectAtIndex:path.row];

    [segue.destinationViewController startWithEvent:thisEvent];
}

// Bit of a hack to fix the clear navigation bar.
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Calendar of Events";
    self.navigationController.navigationBar.translucent = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    //self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
