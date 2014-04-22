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

@end

@implementation AboutViewController

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

@end
