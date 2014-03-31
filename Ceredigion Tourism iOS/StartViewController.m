//
//  ViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "StartViewController.h"
#import "CSVDataManager.h"
#import "AttractionsCSVDataManager.h"
#import "EventsCSVDataManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MapViewController.h"
#import "MapDataManager.h"
#import "GroupDataManager.h"

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) bool shouldMove;
@property CLLocationManager *locationManager;
- (IBAction)useCurrentLocationButton:(id)sender;
- (IBAction)viewAboutInfoButton:(id)sender;
- (IBAction)activityPlannerButton:(id)sender;

- (IBAction)searchTextFieldReturn:(id)sender;
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

    NSLog(@"gets here before fetching the data");
//    [_loadingIndicator startAnimating];
    _shouldMove = YES;
    
    
    CSVDataManager *dataManager = [[CSVDataManager alloc] init];
    if([dataManager isConnectionAvailable]){
        [self performSelectorInBackground:@selector(setUpDataManager) withObject:nil];
        [self performSelectorOnMainThread:@selector(dataIsReady) withObject:nil waitUntilDone:NO];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"This application requires an active network connection to fetch the tourism information. Please check your connection."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self startLocationManager];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
//    [_loadingIndicator stopAnimating];
//    _loadingView.hidden = YES;
}

- (void)dataIsReady
{
    NSLog(@"Data is ready!");
}

- (void)setUpDataManager
{
    // need to fetch both attractions and events
    AttractionsCSVDataManager *attractionsDataManager = [[AttractionsCSVDataManager alloc] init];
    EventsCSVDataManager *eventsDataManager = [[EventsCSVDataManager alloc] init];

    [attractionsDataManager saveDataFromURL];
    [eventsDataManager saveDataFromURL];
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
    // Dispose of any resources that can be recreated.
}
@end
