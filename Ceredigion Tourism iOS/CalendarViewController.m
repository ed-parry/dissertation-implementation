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
#import "EventAndDateFormatManager.h"

@interface CalendarViewController () <VRGCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource>
    @property NSArray *allEventDates;
    @property CoreDataManager *dataManager;
    @property EventAndDateFormatManager *dateManager;
    @property (strong, nonatomic) IBOutlet UITableView *dayEventsTable;
    @property (strong, nonatomic) NSString *selectedDay;

    @property float currentTargetHeight;
    @property (strong, nonatomic) VRGCalendarView *currentCalendarView;
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
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        // add a day if required.
        dayComponent.day = 1;
        
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        date = [theCalendar dateByAddingComponents:dayComponent toDate:date options:0];
    }
    _selectedDay = [NSString stringWithFormat:@"%@", date];
    [_dayEventsTable reloadData];
}

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month withYear:(int)year targetHeight:(float)targetHeight animated:(BOOL)animated
{
    _currentTargetHeight = targetHeight;
    _currentCalendarView = calendarView;
    
    [self positionEventsTableWithTargetHeight:targetHeight andCalendarView:calendarView withAnimation:animated];
    
    [self addEventsToLocalArray];
    NSArray *allEventsForActiveMonth = [[NSArray alloc] initWithArray:[self removeEventsNotInActiveMonth:month orYear:year]];
    

    [calendarView markDates:allEventsForActiveMonth];
}

- (void)positionEventsTableWithTargetHeight:(float)targetHeight andCalendarView:(VRGCalendarView *)calendarView withAnimation:(bool)animated
{
    NSTimeInterval animationDuration = animated ? 0.3 :0.0;
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect frame = _dayEventsTable.frame;
        frame.origin.y = CGRectGetMinX(calendarView.frame) + targetHeight;
        if(targetHeight == 0.000000){
            frame.size.height = self.view.frame.size.height - frame.origin.y - 64;
        }
        else{
            frame.size.height = self.view.frame.size.height - frame.origin.y;
        }
        _dayEventsTable.frame = frame;
    }];
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
    _dateManager = [[EventAndDateFormatManager alloc] init];
    if(!_selectedDay){
        // shouldn't reach this, but give a default day in case.
        return [NSString stringWithFormat:@"Events on %@", [_dateManager getTextualDate:@"2014-01-01" forCalendar:YES]];
    }
    else{
        NSString *date = [NSString stringWithFormat:@"%@", _selectedDay];
        return [NSString stringWithFormat:@"Events on %@", [_dateManager getTextualDate:date forCalendar:YES]];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!_dateManager){
        _dateManager = [[EventAndDateFormatManager alloc] init];
    }
    NSArray *thisDaysEvents = [[NSArray alloc] initWithArray:[_dateManager returnEventsForSelectedDay:_selectedDay]];
    return [thisDaysEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get event title, and start/end date here.
    
    static NSString *CellIdentifier = @"eventTableCells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(!_dateManager){
        _dateManager = [[EventAndDateFormatManager alloc] init];
    }
    NSArray *thisDaysEvents = [_dateManager returnEventsForSelectedDay:_selectedDay];
    
    Event *thisEvent = [thisDaysEvents objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisEvent.title;
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Light" size:17];
    return cell;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(!_dateManager){
        _dateManager = [[EventAndDateFormatManager alloc] init];
    }
    NSIndexPath *path = [self.dayEventsTable indexPathForSelectedRow];
    NSArray *thisDaysEvents = [_dateManager returnEventsForSelectedDay:_selectedDay];
    Event *thisEvent = [thisDaysEvents objectAtIndex:path.row];

    [segue.destinationViewController startWithEvent:thisEvent];
}

// Bit of a hack to fix the clear navigation bar.
- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Calendar of Events";
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self positionEventsTableWithTargetHeight:_currentTargetHeight andCalendarView:_currentCalendarView withAnimation:YES];
    [[[self.tabBarController.viewControllers objectAtIndex:3] tabBarItem] setEnabled:NO]; // disable the settings tab item.
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
    _currentCalendarView = nil;
    [[[self.tabBarController.viewControllers objectAtIndex:3] tabBarItem] setEnabled:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    _currentCalendarView = nil;
}
@end
