//
//  MapViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "MapViewController.h"
#import "MapDataManager.h"
#import "CoreDataManager.h"
#import "GroupDataManager.h"
#import "SingleAttractionEventViewController.h"

@interface MapViewController () <GMSMapViewDelegate, UIAlertViewDelegate>
- (void)buildMapMarkers;

// Core Features
@property CLLocationManager *locationManager;
@property GMSMapView *mapView;
@property NSArray *attractionPositions;

// Map Data Manager
@property MapDataManager *mapDataManager;

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

- (void)createMapDataManager
{
    // initialize the Map Data Manager with the latest values for the radius center and distance.
    _mapDataManager = [[MapDataManager alloc] initWithCurrentRadiusCenter:_currentRadiusCenter andRadiusInMeters:_currentRadiusInMeters];
}

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];
    
    // Listen out for any new data available from Core Data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coreDataChanged)
                                                 name:@"attractionsDataUpdated"
                                               object:nil];
}

- (void)coreDataChanged
{
    [_mapView clear];
    [self createMapDataManager];
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionPositions = [dataManager getAllAttractionPositions];
    [self setMapRadiusView:_currentRadiusInMeters withCenter:_currentRadiusCenter];
    [self buildMapMarkers];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Map";

    [_mapLoadSpinner startAnimating];
    if(animated == FALSE){
        [self createMapDataManager];
        double mapRadius = [_mapDataManager getMapRadiusMetersFromPlist];
        _currentRadiusInMeters = mapRadius;
        
        [_mapView clear];
        [self setUpMapView];
    }
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

- (void)setUpMapWithAttraction:(Attraction *)attraction
{
    float latitude = [attraction.latitude doubleValue];
    float longitude = [attraction.longitude doubleValue];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:12];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _currentRadiusCenter = CLLocationCoordinate2DMake(latitude, longitude);
    
    MapDataManager *dataManager = [[MapDataManager alloc] init];
    _currentRadiusInMeters = [dataManager getMapRadiusMetersFromPlist];
    
    GMSMarker *attractionMarker = [[GMSMarker alloc] init];
    
    attractionMarker.position = CLLocationCoordinate2DMake(latitude, longitude);
    attractionMarker.title = attraction.name;
    attractionMarker.snippet = attraction.group;
    
    // Make a new Attraction object to grab the correct group colour.
    Attraction *colourAttractionObj = [[Attraction alloc] init];
    attractionMarker.icon = [colourAttractionObj getAttractionGroupImage:attraction.group];
    
    attractionMarker.map = _mapView;
    
    [_mapView setSelectedMarker:attractionMarker];

    [self putMapOnView];
}

- (void)setUpMapWithCurrentLocation
{
    double lat = _locationManager.location.coordinate.latitude;
    double longitude = _locationManager.location.coordinate.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:longitude zoom:12];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    _currentRadiusCenter = _locationManager.location.coordinate;
    
    MapDataManager *dataManager = [[MapDataManager alloc] init];
    _currentRadiusInMeters = [dataManager getMapRadiusMetersFromPlist];

    [self performSelectorInBackground:@selector(setUpMapView) withObject:nil];
    [self performSelectorOnMainThread:@selector(putMapOnView) withObject:nil waitUntilDone:NO];
}

- (void)useSearchedAddress:(NSString *)address
{
    [_mapLoadSpinner startAnimating];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            [self showUIAlertView:address forProblem:@"Not Found"];
            NSLog(@"%@", error);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];

            if([placemark.administrativeArea isEqualToString:@"Wales"]){
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude zoom:12];
                _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
                
                _currentRadiusCenter = placemark.location.coordinate;
                MapDataManager *dataManager = [[MapDataManager alloc] init];
                double mapRadius = [dataManager getMapRadiusMetersFromPlist];
                _currentRadiusInMeters = mapRadius;
                
                [self performSelectorInBackground:@selector(setUpMapView) withObject:nil];
                [self performSelectorOnMainThread:@selector(putMapOnView) withObject:nil waitUntilDone:NO];
            }
            else{
                [self showUIAlertView:address forProblem:@"Not In Area"];
            }
        }
    }];
}

- (void)setUpMapView
{
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    _attractionPositions = [dataManager getAllAttractionPositions];
    [self setMapRadiusView:_currentRadiusInMeters withCenter:_currentRadiusCenter];
    [self buildMapMarkers];
}

- (void)putMapOnView
{
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    [_mapLoadSpinner stopAnimating];
    _mapView.delegate = (id)self;
    self.view = _mapView;
}

- (void)setMapRadiusView:(double)meters withCenter:(CLLocationCoordinate2D)centerCoordinates
{
    if(meters == 0){
        _currentRadiusInMeters = 0;
    }
    else{
        _currentRadiusCenter = centerCoordinates;
        
        double latitude = centerCoordinates.latitude;
        double longitude = centerCoordinates.longitude;
        
        CLLocationCoordinate2D circleCenter = CLLocationCoordinate2DMake(latitude, longitude);
        GMSCircle __block *circleRadius;
        dispatch_async(dispatch_get_main_queue(), ^{
            circleRadius = [GMSCircle circleWithPosition:circleCenter
                                                         radius:meters];
            circleRadius.fillColor = [UIColor colorWithRed:35.0/255.0
                                                 green:164.0/255.0
                                                  blue:219.0/255.0
                                                 alpha:0.1];
            circleRadius.strokeColor = [UIColor colorWithRed:35.0/255.0
                                                   green:164.0/255.0
                                                    blue:219.0/255.0
                                                   alpha:1.0];
            circleRadius.strokeWidth = 2;

            circleRadius.map = _mapView;
        });
        [self storeRadiusCenterCoordinatesInPlist:circleCenter];
    }
}

- (void)buildMapMarkers{
    for(Attraction *currentAttraction in _attractionPositions){
        
        CLLocationCoordinate2D attractionCoordinates;
        attractionCoordinates.latitude = [currentAttraction.latitude doubleValue];
        attractionCoordinates.longitude = [currentAttraction.longitude doubleValue];
        
        [self createMapDataManager];
        
        GroupDataManager *groupDataManager = [[GroupDataManager alloc] init];
        
        if(([_mapDataManager isCoordinatesWithinRadius:attractionCoordinates]) && ([groupDataManager isAttractionInAllowedGroups:currentAttraction]))
        {
            double attractionLat = [currentAttraction.latitude doubleValue];
            double attractionLong = [currentAttraction.longitude doubleValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                GMSMarker *attractionMarker = [[GMSMarker alloc] init];
                attractionMarker.position = CLLocationCoordinate2DMake(attractionLat, attractionLong);
                attractionMarker.title = currentAttraction.name;
                attractionMarker.snippet = currentAttraction.group;
            
                // Make a new Attraciton object to grab the correct group colour.
                Attraction *colourAttractionObj = [[Attraction alloc] init];
                attractionMarker.icon = [colourAttractionObj getAttractionGroupImage:currentAttraction.group];
            
                attractionMarker.map = _mapView;
            });
        }
        else{
            // The marker is outside of the current radius, so we shouldn't show it.
        }
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

- (void)storeRadiusCenterCoordinatesInPlist:(CLLocationCoordinate2D)coordinates
{
    _mapDataManager = [[MapDataManager alloc] init];
    [_mapDataManager storeMapRadiusCoordinatesInPlist:coordinates];
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

- (void)showUIAlertView:(NSString *)searchText forProblem:(NSString *)problem
{
    UIAlertView *alert;
    if([problem isEqualToString:@"Not Found"]){
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"'%@' Not Found", searchText]
                                                        message:@"Your search cannot be found on the map. Please try again, or search using your current location."
                                                       delegate:self
                                              cancelButtonTitle:@"Search Again"
                                              otherButtonTitles:@"Current Location", nil];
    }
    else if([problem isEqualToString:@"Not In Area"]){
        alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"'%@' Not in Wales", searchText]
                                           message:@"Your search is not within the area of Wales. Please try again, or search using your current location."
                                          delegate:self
                                 cancelButtonTitle:@"Search Again"
                                 otherButtonTitles:@"Current Location", nil];
    }

    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        [self.tabBarController.navigationController popViewControllerAnimated:YES];
    }
    else if(buttonIndex == 1){
        [self getActualLocationCoordinates];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
