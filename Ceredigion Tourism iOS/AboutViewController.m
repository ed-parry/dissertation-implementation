//
//  AboutViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 18/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "AboutViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *openSourceLicences;
@property bool viewingLegal;
@property (strong, nonatomic) IBOutlet UIButton *helpViewButton;

- (IBAction)AboutButtonTapped:(id)sender;
@end

@implementation AboutViewController

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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];
    
    _viewingLegal = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"About This App";
    _openSourceLicences = _textView.text;
    [self showHelpText];
}

- (IBAction)AboutButtonTapped:(id)sender
{
    if(_viewingLegal){
        [self showHelpText];
        [_helpViewButton setTitle:@"View Legal Information" forState:UIControlStateNormal];
        _viewingLegal = NO;
    }
    else{
        [self showLegalText];
        [_helpViewButton setTitle:@"View Help Information" forState:UIControlStateNormal];
        _viewingLegal = YES;
    }
}

- (void)showLegalText
{
    _textView.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0];
    _textView.text = [NSString stringWithFormat:@"%@\n%@",[GMSServices openSourceLicenseInfo], _openSourceLicences];
}

- (void)showHelpText
{
    _textView.font = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
    _textView.text = @"How to use the application...";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
