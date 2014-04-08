//
//  SingleAttractionEventViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 20/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "SingleAttractionEventViewController.h"
#import "EventAndDateFormatManager.h"
#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <EventKitUI/EventKitUI.h>

@interface SingleAttractionEventViewController () <EKEventEditViewDelegate, GMSMapViewDelegate>
@property (strong, nonatomic) Attraction *thisAttraction;
@property (strong, nonatomic) Event *thisEvent;

@property (strong, nonatomic) IBOutlet UILabel *firstTextFieldLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstTextField;
@property (strong, nonatomic) IBOutlet UILabel *secondTextFieldLabel;
@property (strong, nonatomic) IBOutlet UIButton *secondTextField;
@property (strong, nonatomic) IBOutlet UILabel *thirdTextField;

@property (strong, nonatomic) IBOutlet UIButton *showAttractionOnMapViewButton;
@property (strong, nonatomic) IBOutlet UIButton *addToCalendarButton;
@property (strong, nonatomic) IBOutlet UIButton *visitWebsiteButton;

@property UIImage *attractionImage;
@property GMSMapView *eventMap;

// Extra views
@property (strong, nonatomic) IBOutlet UIView *imageLoadingOrMapView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *imageLoadingSpinner;
@property (strong, nonatomic) IBOutlet UIImageView *attractionImageView;

- (IBAction)phoneNumberClicked:(UIButton *)sender;
- (IBAction)addToCalendarTapped:(id)sender;
- (IBAction)visitWebsiteTapped:(id)sender;
@end

@implementation SingleAttractionEventViewController

- (void)startWithAttraction:(Attraction *)currentAttraction
{
    _thisAttraction = [[Attraction alloc] init];
    _thisAttraction = currentAttraction;

    _attractionImageView.hidden = YES;
    _imageLoadingOrMapView.hidden = NO;
    [_imageLoadingSpinner startAnimating];
}

- (void)startWithEvent:(Event *)currentEvent
{
    _thisEvent = [[Event alloc] init];
    _thisEvent = currentEvent;
    
    _attractionImageView.hidden = YES;
    _imageLoadingOrMapView.hidden = NO;
    [_imageLoadingSpinner stopAnimating];
    
    _showAttractionOnMapViewButton.hidden = YES;
    [self addMapToViewForEvent:currentEvent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];
    [_imageLoadingSpinner startAnimating];
    [self setUpViewContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setUpViewContent
{
    if(_thisAttraction){
        self.navigationItem.title = _thisAttraction.name;
        self.navigationController.navigationBar.topItem.title = @"";
        
        // Address
        if([_thisAttraction.address length] > 1) {
            _firstTextField.text = [NSString stringWithFormat:@"%@", _thisAttraction.address];
        }
        else{
            _firstTextField.text = [NSString stringWithFormat:@"No address was provided for %@.", _thisAttraction.name];
        }
        
        // Telephone
        if([_thisAttraction.telephone length] > 1){
            [_secondTextField setTitle:_thisAttraction.telephone forState:UIControlStateNormal];
        }
        else{
            [_secondTextField setTitle:@"No phone number is available." forState:UIControlStateNormal];
            _secondTextField.enabled = NO;
        }
        
        // Description
        _thirdTextField.text = _thisAttraction.descriptionText;
        
        if([_thisAttraction.group isEqual: @"Accommodation"] || [_thisAttraction.group isEqual:@"Camp & caravan"]){
            _addToCalendarButton.enabled = FALSE;
        }
        
        if([_thisAttraction.website length] < 1){
            _visitWebsiteButton.enabled = FALSE;
        }
        
        if([_thisAttraction.imageLocationURL length] > 1){
            [self performSelectorInBackground:@selector(fetchImageFromUrl:) withObject:_thisAttraction.imageLocationURL];
        }
        else{
            UIImage *attractionImage = [UIImage imageNamed:@"No Attraction Image (Placeholder)"];
            _attractionImage = attractionImage;
            [_imageLoadingSpinner stopAnimating];
            _imageLoadingOrMapView.hidden = YES;
            _attractionImageView.hidden = NO;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self performSelectorOnMainThread:@selector(putImageOnView) withObject:nil waitUntilDone:NO];

        }
        
        [self setPageColorForGroup:_thisAttraction.group];
    }
    else if(_thisEvent){
        self.navigationItem.title = _thisEvent.title;
        self.navigationController.navigationBar.topItem.title = @"";
        
        _firstTextFieldLabel.text = @"Event Location";
        _secondTextFieldLabel.text = @"Date & Time";
        
        // This is DateTime not Telephone, so don't need a button
        _secondTextField.enabled = NO;

        // Address/Location
        if([_thisEvent.location length] > 1) {
            _firstTextField.text = [NSString stringWithFormat:@"%@", _thisEvent.location];
        }
        else{
            _firstTextField.text = [NSString stringWithFormat:@"No location was provided for %@.", _thisEvent.title];
        }
        
        // Date and Time
        NSString *textualDateTime;
        if([_thisEvent.startTime isEqualToString:@"00:00"]){
            // just dates
            textualDateTime = [self returnTextualDate:_thisEvent.startDate andTime:nil];
            if(![_thisEvent.startDate isEqualToString:_thisEvent.endDate]){
                textualDateTime = [NSString stringWithFormat:@"%@ until %@", textualDateTime, [self returnTextualDate:_thisEvent.endDate andTime:nil]];
            }
        }
        else{
            textualDateTime = [self returnTextualDate:_thisEvent.startDate andTime:_thisEvent.startTime];
            textualDateTime = [NSString stringWithFormat:@"%@ until %@", textualDateTime, _thisEvent.endTime];
        }

        [_secondTextField setTitle:textualDateTime forState:UIControlStateNormal];
        
        // Description
        _thirdTextField.text = _thisEvent.descriptionText;
        
        _visitWebsiteButton.enabled = FALSE;
        
        [self setPageColorForGroup:@"Event"];

    }
    else{
        NSLog(@"There's no Attraction or Event object to use. Try again.");
    }
}

- (void)addMapToViewForEvent:(Event *)event
{
    double latitude = [event.latitude doubleValue];
    double longitude = [event.longitude doubleValue];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude longitude:longitude zoom:12];
    
    // position the map correctly.
    CGRect frame = CGRectMake(0, 0, 320, 149);
    frame.origin.x = 0;
    frame.origin.y = self.view.frame.size.height - 149;
    
    _eventMap = [GMSMapView mapWithFrame:frame camera:camera];

    // add the pin
    GMSMarker *eventMarker = [[GMSMarker alloc] init];
    eventMarker.position = CLLocationCoordinate2DMake(latitude, longitude);
    eventMarker.title = event.title;
    eventMarker.icon = [UIImage imageNamed:@"Event Icon"];
    eventMarker.map = _eventMap;
    
    [self.view addSubview:_eventMap];
}

- (NSString *)returnTextualDate:(NSString *)date andTime:(NSString *)time
{
    EventAndDateFormatManager *dateManager = [[EventAndDateFormatManager alloc] init];
    NSString *textualDate = [dateManager getTextualDate:date forCalendar:NO];
    if(time == nil){
        return [NSString stringWithFormat:@"%@", textualDate];
    }
    else{
        return [NSString stringWithFormat:@"%@ at %@", textualDate, time];
    }

}

- (IBAction)addToCalendarTapped:(id)sender
{
    // called to add a new calendar event.
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(granted){
            EKEventEditViewController *eventController = [[EKEventEditViewController alloc] init];
            eventController.eventStore = eventStore;
            eventController.editViewDelegate = self;
            
            EKEvent *attractionEvent = [EKEvent eventWithEventStore:eventStore];

            // set the start date and time and the end date and time.
            if(_thisEvent){
                attractionEvent.title = _thisEvent.title;
                attractionEvent.location = _thisEvent.location;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];

                NSString *startDateTime = [NSString stringWithFormat:@"%@ %@", _thisEvent.startDate, _thisEvent.startTime];
                NSString *endDateTime = [NSString stringWithFormat:@"%@ %@", _thisEvent.endDate, _thisEvent.endTime];
                
                [dateFormatter setDateFormat:@"dd/MM/yy HH:mm"];
                NSDate *startDate = [dateFormatter dateFromString:startDateTime];
                NSDate *endDate = [dateFormatter dateFromString:endDateTime];

                attractionEvent.startDate = startDate;
                attractionEvent.endDate = endDate;
                
                if([_thisEvent.startTime isEqualToString:@"00:00"]){
                    attractionEvent.allDay = YES;
                }
                
                attractionEvent.notes = _thisEvent.descriptionText;
            }
            else{
                attractionEvent.title = _thisAttraction.name;
                attractionEvent.location = _thisAttraction.address;
                attractionEvent.notes = _thisAttraction.descriptionText;
            }
            
            eventController.event = attractionEvent;
            [self presentViewController:eventController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to access calendar"
                                                            message:@"You have chosen to not enable calendar access to this application. If you change your mind, you can update your privacy options in the Settings app"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    // EventKitUI creates the event for me, so just close the view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)phoneNumberClicked:(UIButton *)sender
{
    NSString *phoneNumber = [_thisAttraction.telephone stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@", phoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Unable to call" message:@"Unfortunately you are unable to call this number on your device from this application." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (IBAction)visitWebsiteTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_thisAttraction.website]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"attractionMapLocation"]){
        [segue.destinationViewController setUpMapWithAttraction:_thisAttraction];
    }
}

- (void)setPageColorForGroup:(NSString *)group
{
    Attraction *colourAttraction = [[Attraction alloc] init];

    _firstTextFieldLabel.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.2f];
    _secondTextFieldLabel.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.2f];
    _thirdTextField.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.2f];
}

// 320 x 128
- (void)fetchImageFromUrl:(NSString *)URL
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *imageUrl = [NSURL URLWithString:URL];
    NSData *attractionImageData = [NSData dataWithContentsOfURL:imageUrl];
        
    // if there's something available to grab
    if(attractionImageData){
        UIImage *attractionImage = [[UIImage alloc] initWithData:attractionImageData];
        _attractionImage = attractionImage;
        [self performSelectorOnMainThread:@selector(putImageOnView) withObject:nil waitUntilDone:NO];
    }
    else{
        // no image found
        UIImage *attractionImage = [UIImage imageNamed:@"No Attraction Image (Placeholder)"];
        _attractionImage = attractionImage;
        [self performSelectorOnMainThread:@selector(putImageOnView) withObject:nil waitUntilDone:NO];
                
        return;
    }
}

- (void)putImageOnView
{
    _attractionImageView.image = _attractionImage;
    _attractionImageView.contentMode = UIViewContentModeScaleToFill;
    [_imageLoadingSpinner stopAnimating];
    _imageLoadingOrMapView.hidden = YES;
    _attractionImageView.hidden = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)cleanUpMemory
{
    _thisAttraction = nil;
    _thisEvent = nil;
    
    _firstTextField = nil;
    _firstTextFieldLabel = nil;
    _secondTextFieldLabel = nil;
    _secondTextField = nil;
    _thirdTextField = nil;
    
    [_eventMap clear];
    _eventMap = nil;
    
    _imageLoadingOrMapView = nil;
    [_imageLoadingOrMapView removeFromSuperview];
    
    _attractionImageView = nil;
    _attractionImage = nil;
    [_attractionImageView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self cleanUpMemory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self cleanUpMemory];
}

@end
