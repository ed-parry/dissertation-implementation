//
//  ActivityPlannerSelectViewController.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 24/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "ActivityPlannerSelectViewController.h"
#import "RMDateSelectionViewController.h"
#import "DateFormatManager.h"

@interface ActivityPlannerSelectViewController () <RMDateSelectionViewControllerDelegate>

@property RMDateSelectionViewController *dateSelectionVC;


- (IBAction)arrivalDateFieldClicked:(UITextField *)sender;
@property (strong, nonatomic) IBOutlet UITextField *arrivalDateTextField;
@property (strong, nonatomic) IBOutlet UITextField *locationTextField;

- (IBAction)dayValueChanged:(UIStepper *)sender;
@property (strong, nonatomic) IBOutlet UILabel *dayNumberField;
@property (strong, nonatomic) IBOutlet UILabel *dayWordField;


@end

@implementation ActivityPlannerSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:(35.0/256.0)
                                                  green:(164.0/256.0)
                                                   blue:(219.0/256.0)
                                                  alpha:(1.0)]];
    
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    _arrivalDateTextField.inputView = dummyView; // Hide keyboard, but show blinking cursor
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)arrivalDateFieldClicked:(UITextField *)sender
{
    _dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    _dateSelectionVC.delegate = self;
    _dateSelectionVC.hideNowButton = YES;

    [_dateSelectionVC show];
    
    UIDatePicker *arrivalPicker = [_dateSelectionVC datePicker];
    arrivalPicker.datePickerMode = UIDatePickerModeDate; // only pick the date, not time.
}


#pragma mark - RMDateSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    DateFormatManager *dateFormatManager = [[DateFormatManager alloc] init];
    NSString *date = [NSString stringWithFormat:@"%@", aDate];
    
    NSString *textualDate = [dateFormatManager getTextualDate:date withYear:YES];
    _arrivalDateTextField.text = textualDate;
    
    [self.view endEditing:YES];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    [_dateSelectionVC dismiss];
    [self.view endEditing:YES];
}

- (IBAction)dayValueChanged:(UIStepper *)sender
{
    int dayValueInt = (int)[sender value];

    _dayNumberField.text = [NSString stringWithFormat:@"%i", dayValueInt];
    
    if(dayValueInt > 1){
        _dayWordField.text = [NSString stringWithFormat:@"days"];
    }
    else{
        _dayWordField.text = [NSString stringWithFormat:@"day"];
    }
}

- (void)dismissKeyboard
{
    [_locationTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // we're going to have to check the fields are all used, and then package it into an obejct and pass it over in here.
    // could potentially do that in the shouldPrepareForSegue, though.
}


@end
