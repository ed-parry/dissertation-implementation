//
//  AttractionPlannerSelectViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 24/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AttractionPlannerLocationViewController.h"
#import "RMDateSelectionViewController.h"
#import "MBProgressHUD.h"
#import "AttractionPlannerAttractionsViewController.h"
#import "EventAndDateFormatManager.h"
#import "MapDataManager.h"
#import "AttractionPlan.h"

@interface AttractionPlannerLocationViewController () <RMDateSelectionViewControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property RMDateSelectionViewController *dateSelectionVC;

- (IBAction)useCurrentLocation:(id)sender;
- (IBAction)arrivalDateFieldTapped:(UITextField *)sender;
- (IBAction)locationTextFieldTapped:(UITextField *)sender;

- (IBAction)dayValueChanged:(UIStepper *)sender;

@property (strong, nonatomic) IBOutlet UITextField *arrivalDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) NSString *locationText;
@property (strong, nonatomic) NSString *arrivalDateText;
@property (strong, nonatomic) NSString *arrivalDateNoFormat;
@property CLLocationCoordinate2D locationCoordinates;
@property CLLocationManager *locationManager;
@property MapDataManager *mapDataManager;

@property (strong, nonatomic) IBOutlet UILabel *dayNumberField;
@property (strong, nonatomic) IBOutlet UILabel *dayWordField;

@end

@implementation AttractionPlannerLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:(35.0/256.0)
                                                  green:(164.0/256.0)
                                                   blue:(219.0/256.0)
                                                  alpha:(1.0)]];
    
    _locationTextField.delegate = self;
    _locationManager.delegate = self;
    
    // Hide keyboard
    UIView* hiddenView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _arrivalDateTextField.inputView = hiddenView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (IBAction)arrivalDateFieldTapped:(UITextField *)sender
{
    _dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    _dateSelectionVC.delegate = self;
    _dateSelectionVC.hideNowButton = YES;

    [_dateSelectionVC show];
    
    UIDatePicker *arrivalPicker = [_dateSelectionVC datePicker];
    arrivalPicker.datePickerMode = UIDatePickerModeDate; // only pick the date, not time.
}

- (IBAction)locationTextFieldTapped:(UITextField *)sender
{
    NSLog(@"inside");

}

#pragma mark - RMDateSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    EventAndDateFormatManager *dateFormatManager = [[EventAndDateFormatManager alloc] init];
    NSString *date = [NSString stringWithFormat:@"%@", aDate];
    
    NSString *textualDate = [dateFormatManager getTextualDate:date forCalendar:YES];
    _arrivalDateTextField.text = textualDate;
    _arrivalDateText = textualDate;
    
    // store the original formatting locally, to use later in the object.
    _arrivalDateNoFormat = date;
    
    [self.view endEditing:YES];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    [_dateSelectionVC dismiss];
    [self.view endEditing:YES];
}

- (void)showTodaysDateAsArrivalDate
{
    NSDate *today = [NSDate date];
    EventAndDateFormatManager *dateFormatManager = [[EventAndDateFormatManager alloc] init];
    NSString *textualDate = [dateFormatManager getTextualDate:[NSString stringWithFormat:@"%@", today] forCalendar:YES];
    _arrivalDateNoFormat = [NSString stringWithFormat:@"%@", today];
    _arrivalDateTextField.text = textualDate;
    _arrivalDateText = textualDate;
}

- (IBAction)useCurrentLocation:(id)sender
{
    
    CLAuthorizationStatus mapAuthorised = [CLLocationManager authorizationStatus];
    if(mapAuthorised == kCLAuthorizationStatusAuthorized){
        double lat = _locationManager.location.coordinate.latitude;
        double longitude = _locationManager.location.coordinate.longitude;
        
        // wasn't enough time to fetch coords, so let's try again
        if((lat == 0.000000) && (longitude == 0.000000)){
            CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];
            newLocationManager.distanceFilter = kCLDistanceFilterNone;
            newLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // best possible accuracy level
            
            [newLocationManager startUpdatingLocation];
            _locationManager = newLocationManager;
            [self useCurrentLocation:self];
        }
        else{
            _locationCoordinates = CLLocationCoordinate2DMake(lat, longitude);
            [self showCurrentLocationOnView];
            [self showTodaysDateAsArrivalDate];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No GPS Access"
                                                        message:@"This application does not currently have permission to access your current location. You can change this option, if you wish, from the Privacy section in the Settings app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)showCurrentLocationOnView
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    CLLocation *pointToGeocode = [[CLLocation alloc] initWithLatitude:_locationCoordinates.latitude longitude:_locationCoordinates.longitude];
    
    [geocoder reverseGeocodeLocation:pointToGeocode completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"%@", error);
        }
        else{
            CLPlacemark *placemark = [placemarks lastObject];
            _locationTextField.text = [NSString stringWithFormat:@"%@", placemark.locality];
        }
    }];
}

- (IBAction)dayValueChanged:(UIStepper *)sender
{
    int dayValueInt = (int)[sender value];

    _dayNumberField.text = [NSString stringWithFormat:@"%i", dayValueInt];
    
    if(dayValueInt > 1){
        _dayWordField.text = [NSString stringWithFormat:@"days"];
    }
    else{
        _dayWordField.text = [NSString stringWithFormat:@"day"];
    }
}

- (bool)allDataComplete
{
    // check all data fields and make sure we've got something for all of them.
    // fields to check: location, start date.
    // dont check number of days, as always a value anyway.
    if(!_mapDataManager){
        _mapDataManager = [[MapDataManager alloc] init];
    }
    if(_locationCoordinates.latitude == 0.000000){
        _locationCoordinates = [_mapDataManager getCoordinatesForAddressLocation:_locationText];
    }
    
    NSString *location = _locationText;
    NSString *startDate = _arrivalDateText;
    if(([location length] > 0) && ([startDate length] > 0) && ([_arrivalDateNoFormat length] > 0))
    {
        if(_locationCoordinates.latitude != 0.000000){
            return YES;
        }
        // call itself again until we have coordinate fix.
        [self allDataComplete];
    }
    NSLog(@"Okay with coordinates, problem is with location: %@ or the start date: %@ or the unformatted date: %@", location, startDate, _arrivalDateNoFormat);
    return NO;
}

- (AttractionPlan *)returnDataAsActivityPlan
{
    NSString *location = _locationTextField.text;
    NSString *startDate = _arrivalDateNoFormat;
    
    AttractionPlan *plan = [[AttractionPlan alloc] init];
    
    plan.location = location;
    plan.locationCoordinates = _locationCoordinates;
    plan.startDate = startDate;
    plan.days = [NSNumber numberWithInt:[_dayNumberField.text intValue]];
    
    return plan;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if([self allDataComplete]){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return YES;
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More information required"
                                                        message:@"Please ensure that you have entered in all available information before continuing."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        return NO;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AttractionPlan *planToSend = [self returnDataAsActivityPlan];
    [segue.destinationViewController continuePlannerWithPlan:planToSend];
}

- (void)dismissKeyboard
{
    [_locationTextField resignFirstResponder];
    if([_locationTextField.text length] > 0){
        if(!_mapDataManager){
            _mapDataManager = [[MapDataManager alloc] init];
        }
        // there's a chance we have some data, so let's try and fetch the coordinates now, ahead of time.
        _locationCoordinates = [_mapDataManager getCoordinatesForAddressLocation:_locationTextField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _locationText = _locationTextField.text;
    return [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
