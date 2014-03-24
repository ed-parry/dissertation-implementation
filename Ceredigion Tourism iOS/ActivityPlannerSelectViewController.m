//
//  ActivityPlannerSelectViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 24/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerSelectViewController.h"

@interface ActivityPlannerSelectViewController ()

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ActivityPlannerSelectViewController

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
    self.scrollView.contentSize = CGSizeMake(320, 1000);
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
