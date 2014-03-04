//
//  MapViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>
#import <dispatch/dispatch.h>
#import "MapViewController.h"
#import "CoreDataManager.h"
#import "Attraction.h"
#import "SingleAttractionEventViewController.h"

@interface MapViewController () <GMSMapViewDelegate>
- (void)buildMapMarkers;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property GMSMapView *mapView;
@property NSArray *attractionPositions;
@property NSString *disallowedGroup;

@property GMSMarker *tappedMarker;

@property (strong, nonatomic) IBOutlet UIView *customMapMarker;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerName;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerGroup;
- (IBAction)customMarkerButton:(id)sender;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)useCurrentLocationPosition:(CLLocationManager *)locationManager
{
    double lat = locationManager.location.coordinate.latitude;
    double longitude = locationManager.location.coordinate.longitude;
    
    // wasn't enough time to fetch coords, so let's try again
    if((lat == 0.000000) && (longitude == 0.000000)){
        CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];
        newLocationManager.distanceFilter = kCLDistanceFilterNone;
        newLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // best possible accuracy level
        
        [newLocationManager startUpdatingLocation];
        [self useCurrentLocationPosition:newLocationManager];
    }
    else{
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:longitude zoom:12];
        _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        [self setUpMapView];
    }
}

- (void)useSearchedAddress:(NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude zoom:12];
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

    _mapView.delegate = (id)self;
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
//            attractionMarker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
        
            // Make a new Attraciton object to grab the correct group colour.
            Attraction *colourAttractionObj = [[Attraction alloc] init];
            attractionMarker.icon = [GMSMarker markerImageWithColor:[colourAttractionObj getAttractionGroupColor:currentAttraction.group]];
            
            attractionMarker.map = _mapView;
    }
}

// Develop a custom view for the marker overlays.
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    _customMapMarker = [[[NSBundle mainBundle] loadNibNamed:@"CustomMarkerView" owner:self options:nil] objectAtIndex:0];

    _customMarkerName.text = marker.title;
    _customMarkerGroup.text = marker.snippet;

    return _customMapMarker;
}

- (void) mapView:(GMSMapView *) mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    _tappedMarker = marker;
    [self performSegueWithIdentifier:@"tappedMapAttractionSegue" sender: self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"tappedMapAttractionSegue"]){
        for(Attraction *tempAttraction in _attractionPositions){
            if((tempAttraction.name == _tappedMarker.title) && (tempAttraction.group == _tappedMarker.snippet)){
                [segue.destinationViewController startWithAttraction:tempAttraction];
                break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)customMarkerButton:(id)sender {
}
@end
