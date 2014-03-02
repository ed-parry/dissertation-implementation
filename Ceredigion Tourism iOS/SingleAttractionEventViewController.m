//
//  SingleAttractionEventViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 20/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "SingleAttractionEventViewController.h"

@interface SingleAttractionEventViewController ()
@property (strong, nonatomic) IBOutlet UILabel *descriptionField;
@property (strong, nonatomic) IBOutlet UILabel *addressFIeld;
@property (strong, nonatomic) IBOutlet UILabel *telephoneField;
@property (strong, nonatomic) IBOutlet UIButton *visitWebsiteButton;
@property (strong, nonatomic) IBOutlet UIButton *addToCalendarButton;

@property Attraction *thisAttraction;
@end

@implementation SingleAttractionEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)startWithAttraction:(Attraction *)currentAttraction
{
    _thisAttraction = [[Attraction alloc] init];
    _thisAttraction = currentAttraction;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_thisAttraction){
        // populate the content
        self.navigationItem.title = _thisAttraction.name;
        _descriptionField.text = [NSString stringWithFormat:@"%@", _thisAttraction.descriptionText];
        _addressFIeld.text = [NSString stringWithFormat:@"%@", _thisAttraction.address];
        _telephoneField.text = [NSString stringWithFormat:@"%@", _thisAttraction.telephone];
    }
    else{
        NSLog(@"There's no Attraction object to use");
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
