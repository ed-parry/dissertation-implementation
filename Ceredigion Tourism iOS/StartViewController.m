//
//  StartViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "StartViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AttractionsCSVDataManager.h"
#import "EventsCSVDataManager.h"
#import "MapViewController.h"
#import "MapDataManager.h"
#import "CoreDataManager.h"

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) bool shouldMove;
@property CLLocationManager *locationManager;
- (IBAction)useCurrentLocationButton:(id)sender;
- (IBAction)viewAboutInfoButton:(id)sender;
- (IBAction)activityPlannerButton:(id)sender;

- (IBAction)searchTextFieldReturn:(id)sender;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = TRUE;
    [self.view setBackgroundColor:[UIColor colorWithRed:35.0/255.0
                                                  green:164.0/255.0
                                                   blue:219.0/255.0
                                                  alpha:1.0]];

    // Listen out for any new data available from Core Data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataSavedInCoreData)
                                                 name:@"attractionsDataUpdated"
                                               object:nil];

    _shouldMove = YES;
    [_loadingSpinner startAnimating];
    
    [self startDataFetch]; // start the process of fetching/checking for new data from the server
    [self startLocationManager]; // start the process of finding a GPS signal, to use with "current location" map option.

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)startDataFetch
{
    CoreDataManager *coreDataManager = [[CoreDataManager alloc] init];
    // if there are attractions already, work in the background, start using the app.
    if([coreDataManager doesCoreDataEntityHaveData:@"Attractions"]){
        [_loadingSpinner stopAnimating];
        _loadingView.hidden = YES;
    }

    //check for new content in a background thread, keep the UI responsive.
    [self performSelectorInBackground:@selector(setUpDataManager) withObject:nil];
}

- (void)dataSavedInCoreData
{
    [_loadingSpinner stopAnimating];
    _loadingView.hidden = YES;
}

- (void)setUpDataManager
{
    CSVDataManager *dataManager = [[CSVDataManager alloc] init];
    if([dataManager isConnectionAvailable]){
        // need to fetch both attractions and events
        AttractionsCSVDataManager *attractionsDataManager = [[AttractionsCSVDataManager alloc] init];
        EventsCSVDataManager *eventsDataManager = [[EventsCSVDataManager alloc] init];

        [attractionsDataManager saveDataFromURL];
        [eventsDataManager saveDataFromURL];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"This application works better with an active network connection to fetch the latest tourism attraction information. Please check your connection."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)startLocationManager
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [_locationManager startUpdatingLocation];
}

- (void)dismissKeyboard
{
    _shouldMove = NO;
    [_searchTextField resignFirstResponder];
}

- (IBAction)useCurrentLocationButton:(id)sender
{
    _shouldMove = YES;
}

- (IBAction)viewAboutInfoButton:(id)sender
{
    _shouldMove = YES;
}

- (IBAction)activityPlannerButton:(id)sender
{
    _shouldMove = YES;
}

- (IBAction)searchTextFieldReturn:(id)sender {
    _shouldMove = YES;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"currentLocationSegue"]){
        CLAuthorizationStatus mapAuthorised = [CLLocationManager authorizationStatus];
        if(mapAuthorised != kCLAuthorizationStatusAuthorized){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No GPS Access"
                                                            message:@"This application does not currently have permission to access your current location. You can change this option, if you wish, from the Privacy section in the Settings app."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }
    if(_shouldMove){
        _shouldMove = NO;
        return YES;
    }
    _shouldMove = YES;
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"searchBarSegue"]){
        UITabBarController *tabBarController = segue.destinationViewController;
        MapViewController *mapView = [tabBarController.viewControllers objectAtIndex:0];
        [mapView useSearchedAddress:_searchTextField.text];
    }
    else if([segue.identifier isEqualToString:@"currentLocationSegue"]){
        UITabBarController *tabBarController = segue.destinationViewController;
        MapViewController *mapView = [tabBarController.viewControllers objectAtIndex:0];
        [mapView useCurrentLocationPosition:_locationManager];
    }
}

// Small delegate methods to hide and show the nav bar on the home display.
- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = FALSE;
}
- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
