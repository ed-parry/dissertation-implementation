//
//  LegalInfoViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/04/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "LegalInfoViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface LegalInfoViewController ()
@property (strong, nonatomic) IBOutlet UITextView *textView;

    @property (strong, nonatomic) NSString *openSourceLicences;
@end

@implementation LegalInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];

}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"Legal Information";
    _openSourceLicences = _textView.text;
    [self showLegalText];
}

- (void)showLegalText
{
    _textView.font = [UIFont fontWithName:@"Avenir-Medium" size:10.0];
    _textView.text = [NSString stringWithFormat:@"%@\n%@",[GMSServices openSourceLicenseInfo], _openSourceLicences];
    _textView.userInteractionEnabled = TRUE;
    [_textView sizeToFit];
}
@end
