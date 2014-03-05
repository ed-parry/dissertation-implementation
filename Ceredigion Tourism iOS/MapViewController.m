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
@property CLLocationManager *locationManager;

@property GMSMapView *mapView;

@property NSArray *attractionPositions;

@property GMSMarker *tappedMarker;
@property (strong, nonatomic) IBOutlet UIView *customMapMarker;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerName;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerGroup;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mapLoadSpinner;
@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)useCurrentLocationPosition:(CLLocationManager *)locationManager
{
    [_mapLoadSpinner startAnimating];
    _locationManager = locationManager;
    [self getActualLocationCoordinates];
}

- (void)getActualLocationCoordinates
{
    double lat = _locationManager.location.coordinate.latitude;
    double longitude = _locationManager.location.coordinate.longitude;
    
    // wasn't enough time to fetch coords, so let's try again
    if((lat == 0.000000) && (longitude == 0.000000)){
        CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];
        newLocationManager.distanceFilter = kCLDistanceFilterNone;
        newLocationManager.desiredAccuracy = kCLLocationAccuracyBest; // best possible accuracy level
        
        [newLocationManager startUpdatingLocation];
        _locationManager = newLocationManager;
        [self getActualLocationCoordinates];
    }
    else{
        [self setUpMapWithCurrentLocation];
    }
}

- (void)setUpMapWithCurrentLocation
{
    double lat = _locationManager.location.coordinate.latitude;
    double longitude = _locationManager.location.coordinate.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:longitude zoom:12];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    [self performSelectorInBackground:@selector(setUpMapView) withObject:nil];
    [self performSelectorOnMainThread:@selector(putMapOnView) withObject:nil waitUntilDone:NO];
}

- (void)useSearchedAddress:(NSString *)address
{
    [_mapLoadSpinner startAnimating];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude zoom:12];
            _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            [self performSelectorInBackground:@selector(setUpMapView) withObject:nil];
            [self performSelectorOnMainThread:@selector(putMapOnView) withObject:nil waitUntilDone:NO];
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
    
    // Map Radius Testing
    [self changeMapRadiusView:10];
    
    _mapView.delegate = (id)self;
}

- (void)putMapOnView
{
    [_mapLoadSpinner stopAnimating];
    self.view = _mapView;
}

- (void)changeMapRadiusView:(double)miles
{
    double latitude = _locationManager.location.coordinate.latitude;
    double longitude = _locationManager.location.coordinate.longitude;
    
    double meters = [self changeMilesToMeters:miles];
    
    CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(latitude, longitude);
    GMSCircle *circ = [GMSCircle circleWithPosition:circleCenter
                                             radius:meters];
    circ.fillColor = [UIColor colorWithRed:0 green:0 blue:0.25 alpha:0.10];
    circ.strokeColor = [UIColor blueColor];
    circ.strokeWidth = 2;
    circ.map = _mapView;
    [self putMapOnView];
}

- (double)changeMilesToMeters:(double)miles
{
    if(miles > 0){
        double km = miles * 1.609344;
        double meters = km * 1000;
        
        return meters;
    }
    else{
        return 0;
    }
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
