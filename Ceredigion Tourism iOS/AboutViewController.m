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
@property (strong, nonatomic) IBOutlet UILabel *titleContentView;
@property (strong, nonatomic) IBOutlet UITextView *textContentView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)pageChanged:(id)sender;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:35.0/255.0
                                                  green:164.0/255.0
                                                   blue:219.0/255.0
                                                  alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,[UIFont fontWithName:@"Avenir-Medium" size:18.0],
                                                                     NSFontAttributeName, nil]];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;

    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:swipeRight];
    [self showAppInstructions];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeRecogniser
{
    if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionLeft)
    {
        _pageControl.currentPage +=1;
    }
    else if ([swipeRecogniser direction] == UISwipeGestureRecognizerDirectionRight)
    {
        _pageControl.currentPage -=1;
    }
    [self changePageContent];
}

- (IBAction)pageChanged:(id)sender {
    [self changePageContent];
}

- (void)changePageContent
{
    int currentPage = _pageControl.currentPage + 1;
    switch (currentPage){
        case 1:
            [self showAppInstructions];
            break;
        case 2:
            [self showPlannerInstructions];
            break;
        case 3:
            [self showAboutApp];
            break;
        default:
            [self showAboutApp];
            break;
    }
}

- (void)showAppInstructions
{
    _titleContentView.text = @"How to use the application";
    _textContentView.text = @"Ceredigion Tourism can be used to discover attractions and events nearby, using either your current location or a particular location name, such as \"Aberystwyth\".\n\nThe application uses a radius of 10 miles as a default, however this can be changed on the settings screen, up to 25 miles.\n\nA lot of information is provided for each attraction, and in many cases more information is available through their own website or telephone number.";
}

- (void)showPlannerInstructions
{
    _titleContentView.text = @"How to use the Attraction Planner";
    _textContentView.text = @"The Attraction Planner enables you to be presented with a random selection of attractions and events that are happening nearby.\n\nThis feature will ask you some simple questions, such as how long you will be staying in an area, and what your preferred adrenaline level would be.\n\nAfter answering these questions, you will be presented with a list of nearby attractions for you to explore!";
}

- (void)showAboutApp
{
    _titleContentView.text = @"About Ceredigion Tourism iOS";
    
    NSString *partOne = @"Ceredigion Tourism iOS has been produced by Cardigan Coastal Cottages, developed with the technical assistance of Edward Parry, an undergraduate of Aberystwyth University.";
    NSString *partTwo = @"If you like the application, please feel free to write a review on the App Store!\n\nOpen Source contribution licences are below:";
    NSString *partThree = [GMSServices openSourceLicenseInfo];
    NSString *partFour = @"---\n\nMap, List Calendar, Settings and Map Marker icons provided by Icons8: http://icons8.com/free-ios-7-icons-in-vector/\n\n---\n\nMap Marker icon graphics and pins are provided by WebIconSet.com: http://webiconset.com\n\n---\n\nRMDateSelection\n\nCreated by Roland Moers on 26.10.13.\nCopyright (c) 2013 Roland Moers\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n---\n\nVurig\n\nCreated by in 't Veen Tjeerd on 5/8/12. \nCopyright (c) 2012 Vurig Media. All rights reserved.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\n\n---\n\nCHCSVParser\n\nCopyright (c) 2012 Dave DeLong \n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.";
    
    _textContentView.text = [NSString stringWithFormat:@"%@\n\n\n%@\n\n\n\n%@\n\n%@", partOne, partTwo, partThree, partFour];
}
@end
