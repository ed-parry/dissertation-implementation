//
//  SingleAttractionEventViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 20/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "SingleAttractionEventViewController.h"
#import <EventKitUI/EventKitUI.h>

@interface SingleAttractionEventViewController () <EKEventEditViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *descriptionField;
@property (strong, nonatomic) IBOutlet UILabel *addressField;
@property (strong, nonatomic) IBOutlet UILabel *telephoneField;
@property (strong, nonatomic) IBOutlet UIButton *addToCalendarButton;
@property (strong, nonatomic) IBOutlet UIButton *visitWebsiteButton;
@property (strong, nonatomic) IBOutlet UIImageView *attractionImageView;

@property Attraction *thisAttraction;
@property Event *thisEvent;

- (IBAction)addToCalendarTapped:(id)sender;
- (IBAction)visitWebsiteTapped:(id)sender;
@end

@implementation SingleAttractionEventViewController

- (void)startWithAttraction:(Attraction *)currentAttraction
{
    _thisAttraction = [[Attraction alloc] init];
    _thisAttraction = currentAttraction;
}

- (void)startWithEvent:(Event *)currentEvent
{
    _thisEvent = [[Event alloc] init];
    _thisEvent = currentEvent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(_thisAttraction.name != nil){
        // populate the attraction
        self.navigationItem.title = _thisAttraction.name;
        _descriptionField.text = [NSString stringWithFormat:@"%@", _thisAttraction.descriptionText];
        _addressField.text = [NSString stringWithFormat:@"%@", _thisAttraction.address];
        _telephoneField.text = [NSString stringWithFormat:@"%@", _thisAttraction.telephone];
        if([_thisAttraction.group  isEqual: @"Accommodation"]){
            _addToCalendarButton.enabled = FALSE;
        }
        if([_thisAttraction.website length] < 1){
            _visitWebsiteButton.enabled = FALSE;
        }
        _attractionImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_attractionImageView setImage:[self fetchImageFromUrl:_thisAttraction.imageLocationURL]];
        [self setPageColorForGroup:_thisAttraction.group];
    }
    else if(_thisEvent.title != nil){
        // populate the event
        self.navigationItem.title = _thisEvent.title;
        // TODO - finish this
    }
    else{
        NSLog(@"There's no Attraction or Event object to use. Try again.");
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
            attractionEvent.title = _thisAttraction.name;
            attractionEvent.location = _thisAttraction.address;
            
            eventController.event = attractionEvent;
            
            [self presentViewController:eventController animated:YES completion:nil];
        }
        else{
            NSLog(@"Not granted access");
            // Need to display an error message saying we don't have access.
            // Users can re-enable access from Privacy Settings on their device.
        }
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action
{
    // EventKitUI creates the event for me, so just close the view.
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)visitWebsiteTapped:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_thisAttraction.website]];
}

- (void)setPageColorForGroup:(NSString *)group
{
    Attraction *colourAttraction = [[Attraction alloc] init];

    _addressField.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.8f];
    _telephoneField.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.6f];
    _descriptionField.backgroundColor = [colourAttraction getAttractionGroupColour:group withAlpha:0.4f];
}

// 320 x 128
- (UIImage *)fetchImageFromUrl:(NSString *)URL
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *imageUrl = [NSURL URLWithString:URL];
    NSData *attractionImageData = [NSData dataWithContentsOfURL:imageUrl];
        
    // if there's something available to grab
    if(attractionImageData){
        UIImage *attractionImage = [[UIImage alloc] initWithData:attractionImageData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return attractionImage;
    }
    else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
