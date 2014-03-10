//
//  ViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "StartViewController.h"
#import "CSVDataManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "MapViewController.h"
#import "MapDataManager.h"
#import "GroupDataManager.h"

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) bool shouldMove;
@property CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)searchTextFieldReturn:(id)sender;
@end

@implementation StartViewController

- (void)viewDidLoad
{
    [self.view setBackgroundColor:[UIColor colorWithRed:35.0/255.0
                                                  green:164.0/255.0
                                                   blue:219.0/255.0
                                                  alpha:1.0]];
    [super viewDidLoad];
    [_loadingIndicator startAnimating];
    _shouldMove = YES;
    
    MapDataManager *mapDataManager = [[MapDataManager alloc] init];
    GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
    [mapDataManager storeDefaultMapRadiusMetersInPlist];
    [groupDataManager storeDefaultAllowedGroupsInPlist];
    
    [self startLocationManager];
    [self setUpDataManager];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setUpDataManager
{
    CSVDataManager *dataManager = [[CSVDataManager alloc] init];
    [dataManager saveDataFromURL];
    [_loadingIndicator stopAnimating];
    _loadingView.hidden = YES;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
