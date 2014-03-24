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

- (IBAction)legalNoticesButtonTapped:(id)sender;
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.navigationItem.title = @"About This App";
}

- (IBAction)legalNoticesButtonTapped:(id)sender
{
    _textView.text = [GMSServices openSourceLicenseInfo];
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
