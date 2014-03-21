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

@property (strong, nonatomic) IBOutlet UILabel *firstTextField;
@property (strong, nonatomic) IBOutlet UIButton *secondTextField;
@property (strong, nonatomic) IBOutlet UILabel *thirdTextField;

@property (strong, nonatomic) IBOutlet UIButton *addToCalendarButton;
@property (strong, nonatomic) IBOutlet UIButton *visitWebsiteButton;

@property (strong, nonatomic) IBOutlet UILabel *firstTextFieldLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondTextFieldLabel;

// These string variables are used to link either an
// Attraction or Event to the View itself.
@property bool isAttraction;

@property (strong, nonatomic) NSString *firstTextFieldContent;
@property (strong, nonatomic) NSString *secondTextFieldContent;
@property (strong, nonatomic) NSString *thirdTextFieldContent;
@property (strong, nonatomic) NSString *thisTitle;
@property (strong, nonatomic) NSString *thisGroup;
@property (strong, nonatomic) NSString *thisWebsite;
@property (strong, nonatomic) NSString *thisImageURL;
@property UIImage *attractionImage;

// the start date is already in "secondTextFieldContent"
@property (strong, nonatomic) NSString *eventEndDate;

@property (strong, nonatomic) IBOutlet UIImageView *attractionImageView;

- (IBAction)phoneNumberClicked:(UIButton *)sender;
- (IBAction)addToCalendarTapped:(id)sender;
- (IBAction)visitWebsiteTapped:(id)sender;
@end

@implementation SingleAttractionEventViewController

- (void)startWithAttraction:(Attraction *)currentAttraction
{
    _isAttraction = YES;
    _thisTitle = currentAttraction.name;
    _thisGroup = currentAttraction.group;
    _firstTextFieldContent = currentAttraction.address;
    _secondTextFieldContent = currentAttraction.telephone;
    _thirdTextFieldContent = currentAttraction.descriptionText;
    _thisWebsite = currentAttraction.website;
    _thisImageURL = currentAttraction.imageLocationURL;

}

- (void)startWithEvent:(Event *)currentEvent
{
    _isAttraction = NO;
    _thisTitle = currentEvent.title;
    _thisGroup = @"Event";
    _firstTextFieldContent = currentEvent.location;
    _secondTextFieldContent = [NSString stringWithFormat:@"%@", currentEvent.startDateTime];
    _thirdTextFieldContent = currentEvent.descriptionText;
    
    _eventEndDate = [NSString stringWithFormat:@"%@", currentEvent.endDateTime];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpViewContent];
}

- (void)setUpViewContent
{
    if(_thisTitle != nil){
        // populate the attraction or event
        
        // hide the word "back" from the navigation bar, and set the title.
        self.navigationItem.title = _thisTitle;
        self.navigationController.navigationBar.topItem.title = @"";
        
        _thirdTextField.text = [NSString stringWithFormat:@"%@", _thirdTextFieldContent];
        
        if([_firstTextFieldContent length] > 1) {
            _firstTextField.text = [NSString stringWithFormat:@"%@", _firstTextFieldContent];
        }
        else{
            _firstTextField.text = [NSString stringWithFormat:@"No address was provided for %@.", _thisTitle];
        }
        
        if([_secondTextFieldContent length] > 1){
            [_secondTextField setTitle:_secondTextFieldContent forState:UIControlStateNormal];
        }
        else{
            [_secondTextField setTitle:@"No phone number is available." forState:UIControlStateNormal];
            _secondTextField.enabled = NO;
        }
        
        
        if([_thisGroup isEqual: @"Accommodation"] || [_thisGroup isEqual:@"Camp & caravan"]){
            _addToCalendarButton.enabled = FALSE;
        }
        if([_thisWebsite length] < 1){
            _visitWebsiteButton.enabled = FALSE;
        }
        
        [self performSelectorInBackground:@selector(fetchImageFromUrl:) withObject:_thisImageURL];
        [self performSelectorOnMainThread:@selector(putImageOnView) withObject:nil waitUntilDone:NO];
        
        [self setPageColorForGroup:_thisGroup];
    }
    else{
        NSLog(@"There's no Attraction or Event object to use. Try again.");
    }
    
    if(!_isAttraction){
        // we're dealing with an event, so change the labels accordingly.
        _firstTextFieldLabel.text = @"Event Location";
        _secondTextFieldLabel.text = @"Date & Time";
        
        // we now use this to store the start date and time, so shouldn't be a button.
        _secondTextField.enabled = NO;
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
            attractionEvent.title = _thisTitle;
            attractionEvent.location = _firstTextFieldContent;

            // set the start date and time and the end date and time.
            if(!_isAttraction){
                NSString *startDateString = _secondTextFieldContent;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                
                startDateString = [startDateString substringToIndex:16];
                _eventEndDate = [_eventEndDate substringToIndex:16];
                
                NSDate *startDate = [dateFormatter dateFromString:startDateString];
                NSDate *endDate = [dateFormatter dateFromString:_eventEndDate];
                
                attractionEvent.startDate = startDate;
                attractionEvent.endDate = endDate;
            }
            
            attractionEvent.notes = _thirdTextFieldContent;
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

- (IBAction)phoneNumberClicked:(UIButton *)sender
{
    NSString *phoneNumber = [_secondTextFieldContent stringByReplacingOccurrencesOfString:@" " withString:@""];

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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_thisWebsite]];
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
    }
}

- (void)putImageOnView
{
    _attractionImageView.image = _attractionImage;
    _attractionImageView.contentMode = UIViewContentModeScaleToFill;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
