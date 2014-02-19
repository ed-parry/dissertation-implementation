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
- (void)buildMapMarkers:(NSArray *)attractionPositions;

@property GMSMapView *mapView;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868 longitude:151.2085 zoom:6];
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
    self.view = _mapView;
    
    CoreDataManager *dataManager = [[CoreDataManager alloc] init];
    NSArray *attractionPositions = [dataManager getAllAttractionPositions];
    [self buildMapMarkers:attractionPositions];
}

- (void)buildMapMarkers:(NSArray *)attractionPositions
{
    for(Attraction *currentAttraction in attractionPositions){

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
        return [UIColor redColor]; // need to change to pink
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
