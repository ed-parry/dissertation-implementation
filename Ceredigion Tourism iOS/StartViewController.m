//
//  ViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "StartViewController.h"
#import "CSVDataManager.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CSVDataManager *dataManager = [[CSVDataManager alloc] init];
    [dataManager saveDataFromURL:@"http://edparry.com/dissertation/locations.csv"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
//    changed a line of code!
    // Dispose of any resources that can be recreated.
}

@end
