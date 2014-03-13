//
//  Attraction.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "Attraction.h"

@implementation Attraction
- (UIImage *)getAttractionGroupColor:(NSString *)group
{
    // Have to use if/else rather than switch, because
    // Obj-C only supports switch on int/bool/double, not
    // strings.
    if([group isEqualToString:@"Accommodation"]){
        return [UIImage imageNamed:@"Accommodation Icon"];
        //return [UIColor greenColor];
    }
    else if([group isEqualToString:@"Activity"]){
        return [UIImage imageNamed:@"Activity Icon"];
        //return [UIColor redColor];
    }
    else if([group isEqualToString:@"Attraction"]){
        return [UIImage imageNamed:@"Attraction Icon"];
        //return [UIColor purpleColor];
    }
    else if([group isEqualToString:@"Food & drink"]){
        return [UIImage imageNamed:@"Food and Drink Icon"];
        //return [UIColor blueColor]; // need to change to teal
    }
    else if([group isEqualToString:@"Retail"]){
        return [UIImage imageNamed:@"Retail Icon"];
        // RGB Pink
        //return [UIColor colorWithRed:255.0f/255.0f green:51.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Camp & caravan"]){
        return [UIImage imageNamed:@"Camp and Caravan Icon"];
        // RGB Yellow
        //return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Arts & crafts"]){
        return [UIImage imageNamed:@"Arts and Crafts Icon"];
        //return [UIColor brownColor];
    }
    else{
        return [UIImage imageNamed:@"Accommodation Icon"];
        //return [UIColor redColor];
    }
}
@end


