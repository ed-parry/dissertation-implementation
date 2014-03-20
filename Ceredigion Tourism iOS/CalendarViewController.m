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

@interface CalendarViewController () <VRGCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property NSArray *allEventDates;
@property CoreDataManager *dataManager;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *dayEventsTable;
@property (strong, nonatomic) NSString *selectedDay;
@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
        self.navigationItem.title = @"Calendar of Events";
    _selectedDay = [NSString stringWithFormat:@"%@", [NSDate date]];
    
    //[_dayEventsTable setHidden:YES];
    
    _dayEventsTable.delegate = self;
    _dayEventsTable.dataSource = self;

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
    _selectedDay = [NSString stringWithFormat:@"%@", date];
    [_dayEventsTable reloadData];
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated
{
    [self addEventsToLocalArray];
    NSArray *allEventsForActiveMonth = [[NSArray alloc] initWithArray:[self removeEventsNotInActiveMonth:month]];
    NSTimeInterval animationDuration = animated ? 0.3 :0.0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = _dayEventsTable.frame;
        frame.origin.y = CGRectGetMinX(calendarView.frame) + targetHeight;
        frame.size.height = self.view.frame.size.height - frame.origin.y;
        _dayEventsTable.frame = frame;
    }];
    [calendarView markDates:allEventsForActiveMonth];
}

- (NSArray *)removeEventsNotInActiveMonth:(int)month
{
    NSMutableArray *newEventsArray = [[NSMutableArray alloc] init];
    for(NSDate *date in _allEventDates){
        NSString *dateString = [NSString stringWithFormat:@"%@", date];
        NSRange monthRange = NSMakeRange(5, 7- 5);
        NSString *monthString = [dateString substringWithRange:monthRange];
        int thisMonth = [monthString intValue];
        if(thisMonth == month){
            [newEventsArray addObject:date];
        }
    }
    return newEventsArray;
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

- (NSString *)getTextualDate:(NSString *)date
{
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10- 8);
    
    NSInteger monthNumber = [[date substringWithRange:monthRange] integerValue];
    NSInteger dayNumber = [[date substringWithRange:dayRange] integerValue];

    dayNumber--; // current bug with the Vurig framework. This is the easiest fix.
    
    NSString *monthText = [self getTextMonthFromNumber:monthNumber];
    NSString *dayText = [self getTextDayFromNumber:dayNumber];
    
    return [NSString stringWithFormat:@"%@ of %@", dayText, monthText];
}

- (NSString *)getTextDayFromNumber:(NSInteger)day
{

    day++;
    NSInteger remainder = day % 10;
    if (remainder == 1 && day != 11) {
        return [NSString stringWithFormat:@"%list", (long)day];
    }
    if (remainder == 2 && day != 12) {
        return [NSString stringWithFormat:@"%lind", (long)day];
    }
    if (remainder == 3 && day != 13) {
        return [NSString stringWithFormat:@"%lird", (long)day];
    }
    return [NSString stringWithFormat:@"%lith", (long)day];
}

- (NSString *)getTextMonthFromNumber:(NSInteger)month
{
    switch(month)
    {
        case 1:
            return @"January";
            break;
        case 2:
            return @"February";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 12:
            return @"December";
            break;
        default:
            return nil;
            break;
    }
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(!_selectedDay){
        return [NSString stringWithFormat:@"Events on %@", [self getTextualDate:@"2014-01-01"]];
    }
    else{
        NSString *date = [NSString stringWithFormat:@"%@", _selectedDay];
        return [NSString stringWithFormat:@"Events on %@", [self getTextualDate:date]];
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
    
    NSRange monthRange = NSMakeRange(5, 7- 5);
    NSRange dayRange = NSMakeRange(8, 10-8);
    
    NSString *thisMonthSegment = [date substringWithRange:monthRange];
    NSString *thisDaySegment = [date substringWithRange:dayRange];
    
    // TODO - There's a bug with the calendar that forces dates from April to be one day behind the shown values.
    NSInteger thisDayInt = [thisDaySegment integerValue];

    thisDaySegment = [NSString stringWithFormat:@"%li", (long)thisDayInt];
    
    if(_dataManager){
        allEvents = [[NSArray alloc] initWithArray:[_dataManager getAllEvents]];
    }
    else{
        _dataManager = [[CoreDataManager alloc] init];
        allEvents = [[NSArray alloc] initWithArray:[_dataManager getAllEvents]];
    }

    for(Event *tempEvent in allEvents){
        NSString *tempDate = [NSString stringWithFormat:@"%@", tempEvent.startDateTime];
        NSString *tempMonthSegment = [tempDate substringWithRange:monthRange];
        NSString *tempDaySegment = [tempDate substringWithRange:dayRange];
        
        if(([tempDaySegment isEqualToString:thisDaySegment]) && ([tempMonthSegment isEqualToString:thisMonthSegment])){
            [daysEvents addObject:tempEvent];
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
- (void)viewDidAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Calendar of Events";
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
