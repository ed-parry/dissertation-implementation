//
//  MapViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import "MapViewController.h"
#import "CoreDataManager.h"
#import "Attraction.h"

@interface MapViewController ()
- (void)buildMapMarkers;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property GMSMapView *mapView;
@property NSArray *attractionPositions;
@property NSString *disallowedGroup;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:_spinner];
    [_spinner startAnimating];
    // Do things that both options require
}

- (void)useCurrentLocationPosition
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:52.403578 longitude:-3.965031 zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [self setUpMapView];
}

- (void)useSearchedAddress:(NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude zoom:9];
            _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            [self setUpMapView];
        }
    }];
}

- (void)toggleGroupOnMap:(NSString *)group
{
    // The code called when a user removes a group from the settings page. All the markers of that group should then be removed from the map.
}

- (void)setUpMapView
{
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionPositions = [dataManager getAllAttractionPositions];
    [self buildMapMarkers];
    
    [_spinner stopAnimating];
    self.view = _mapView;
}

- (void)buildMapMarkers{
    for(Attraction *currentAttraction in _attractionPositions){
            GMSMarker *attractionMarker = [[GMSMarker alloc] init];
            double attractionLat = [currentAttraction.latitude doubleValue];
            double attractionLong = [currentAttraction.longitude doubleValue];
            
            attractionMarker.position = CLLocationCoordinate2DMake(attractionLat, attractionLong);
            attractionMarker.title = currentAttraction.name;
            attractionMarker.snippet = currentAttraction.group;
            
            attractionMarker.icon = [GMSMarker markerImageWithColor:[self getAttractionGroupColor:currentAttraction.group]];
            
            attractionMarker.map = _mapView;
    }
}

- (UIColor *)getAttractionGroupColor:(NSString *)group
{
    // Have to use if/else rather than switch, because
    // Obj-C only supports switch on int/bool/double, not
    // strings.
    if([group isEqualToString:@"Accommodation"]){
        return [UIColor greenColor];
    }
    else if([group isEqualToString:@"Activity"]){
        return [UIColor redColor];
    }
    else if([group isEqualToString:@"Attraction"]){
        return [UIColor purpleColor];
    }
    else if([group isEqualToString:@"Food & drink"]){
        return [UIColor blueColor]; // need to change to teal
    }
    else if([group isEqualToString:@"Retail"]){
        // RGB Pink
        return [UIColor colorWithRed:255.0f/255.0f green:51.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Camp & caravan"]){
        // RGB Yellow
        return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Arts & crafts"]){
        return [UIColor brownColor];
    }
    else{
            return [UIColor redColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
