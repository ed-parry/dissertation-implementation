//
//  ViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "StartViewController.h"
#import "CSVDataManager.h"
#import "MapViewController.h"

@interface StartViewController ()
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic) bool shouldMove;
- (IBAction)searchTextFieldReturn:(id)sender;

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _shouldMove = YES;
    
    // This needs to happen in a different thread
    [self setUpDataManager];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)setUpDataManager
{
    CSVDataManager *dataManager = [[CSVDataManager alloc] init];
    [dataManager saveDataFromURL:@"http://edparry.com/dissertation/locations.csv"];
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
    // This is confusing logic, maybe need to clean it up.
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
        NSLog(@"Works kinda");
        UITabBarController *tabBarController = segue.destinationViewController;
        MapViewController *mapView = [tabBarController.viewControllers objectAtIndex:0];
        [mapView useCurrentLocationPosition];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
