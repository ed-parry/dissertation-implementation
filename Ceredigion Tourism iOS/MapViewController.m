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

// Core Features
@property CLLocationManager *locationManager;
@property GMSMapView *mapView;
@property NSArray *attractionPositions;

// Loading
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *mapLoadSpinner;

// Markers
@property GMSMarker *tappedMarker;
@property (strong, nonatomic) IBOutlet UIView *customMapMarker;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerName;
@property (strong, nonatomic) IBOutlet UILabel *customMarkerGroup;

// Radius
@property double currentRadiusInMeters;
@property CLLocationCoordinate2D currentRadiusCenter;
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
    
    [self setMapRadiusView:10 withCenter:_locationManager.location.coordinate];
    
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

            [self setMapRadiusView:10 withCenter:placemark.location.coordinate];
            
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
    
    _mapView.delegate = (id)self;
}

- (void)putMapOnView
{
    [_mapLoadSpinner stopAnimating];
    self.view = _mapView;
}

- (void)setMapRadiusView:(double)miles withCenter:(CLLocationCoordinate2D)centerCoordinates
{
    _currentRadiusCenter = centerCoordinates;
    
    double latitude = centerCoordinates.latitude;
    double longitude = centerCoordinates.longitude;
    
    double meters = [self changeMilesToMeters:miles];
    _currentRadiusInMeters = meters;
    
    CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(latitude, longitude);
    GMSCircle *circleRadius = [GMSCircle circleWithPosition:circleCenter
                                             radius:meters];
    circleRadius.fillColor = [UIColor colorWithRed:0 green:0 blue:0.25 alpha:0.10];
    circleRadius.strokeColor = [UIColor blueColor];
    circleRadius.strokeWidth = 2;
    circleRadius.map = _mapView;
    
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

        CLLocationCoordinate2D attractionCoordinates;
        attractionCoordinates.latitude = [currentAttraction.latitude doubleValue];
        attractionCoordinates.longitude = [currentAttraction.longitude doubleValue];
        
        if([self isCoordinatesWithinRadius:attractionCoordinates])
        {
            double attractionLat = [currentAttraction.latitude doubleValue];
            double attractionLong = [currentAttraction.longitude doubleValue];
            GMSMarker *attractionMarker = [[GMSMarker alloc] init];
            attractionMarker.position = CLLocationCoordinate2DMake(attractionLat, attractionLong);
            attractionMarker.title = currentAttraction.name;
            attractionMarker.snippet = currentAttraction.group;
            
            // Make a new Attraciton object to grab the correct group colour.
            Attraction *colourAttractionObj = [[Attraction alloc] init];
            attractionMarker.icon = [GMSMarker markerImageWithColor:[colourAttractionObj getAttractionGroupColor:currentAttraction.group]];
            
            attractionMarker.map = _mapView;
        }
        else{
            // The marker is outside of the current radius, so we shouldn't show it.
        }
    }
}

- (BOOL)isCoordinatesWithinRadius:(CLLocationCoordinate2D)coordinates
{
    CLLocationCoordinate2D circleCenter = _currentRadiusCenter;
    double circleRadius = _currentRadiusInMeters;
    
    double distanceFromMiddle = [self getDistanceInMetersFrom:circleCenter to:coordinates];
    
    if(distanceFromMiddle <= circleRadius){
        // It's inside the radius
        return YES;
    }
    else{
        // It's outside of the radius.
        return NO;
    }
}

- (double)getDistanceInMetersFrom:(CLLocationCoordinate2D)firstPoint to:(CLLocationCoordinate2D)secondPoint
{
    CLLocation *firstLocation = [[CLLocation alloc] initWithLatitude:firstPoint.latitude longitude:firstPoint.longitude];
    CLLocation *secondLocation = [[CLLocation alloc] initWithLatitude:secondPoint.latitude longitude:secondPoint.longitude];
    
    double distanceInMeters = [firstLocation distanceFromLocation:secondLocation];
    
    return distanceInMeters;
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

@end
