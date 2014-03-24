//
//  SingleAttractionEventViewController.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 20/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Attraction.h"
#import "Event.h"

@interface SingleAttractionEventViewController : UIViewController
- (void)startWithAttraction:(Attraction *)currentAttraction;
- (void)startWithEvent:(Event *)currentEvent;
@end
