//
//  Attraction.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "Attraction.h"

@implementation Attraction
- (UIImage *)getAttractionGroupImage:(NSString *)group
{
    // Have to use if/else rather than switch, because
    // Obj-C only supports switch on int/bool/double, not
    // strings.
    if([group isEqualToString:@"Accommodation"]){
        return [UIImage imageNamed:@"Accommodation Icon"];
    }
    else if([group isEqualToString:@"Activity"]){
        return [UIImage imageNamed:@"Activity Icon"];
    }
    else if([group isEqualToString:@"Attraction"]){
        return [UIImage imageNamed:@"Attraction Icon"];
    }
    else if([group isEqualToString:@"Food & drink"]){
        return [UIImage imageNamed:@"Food and Drink Icon"];
    }
    else if([group isEqualToString:@"Retail"]){
        return [UIImage imageNamed:@"Retail Icon"];
    }
    else if([group isEqualToString:@"Camp & caravan"]){
        return [UIImage imageNamed:@"Camp and Caravan Icon"];
    }
    else if([group isEqualToString:@"Arts & crafts"]){
        return [UIImage imageNamed:@"Arts and Crafts Icon"];
    }
    else{
        return [UIImage imageNamed:@"Accommodation Icon"];
    }
}

- (UIColor *)getAttractionGroupColour:(NSString *)group withAlpha:(CGFloat)alpha
{
    if([group isEqualToString:@"Accommodation"]){
        // Green
        return [UIColor colorWithRed:38.0f/255.0f green:186.0f/255.0f blue:56.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Activity"]){
        // Red
        return [UIColor colorWithRed:210.0f/255.0f green:34.0f/255.0f blue:59.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Attraction"]){
        // Purple
        return [UIColor colorWithRed:113.0f/255.0f green:44.0f/255.0f blue:177.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Food & drink"]){
        // Light Blue
        return [UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:229.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Retail"]){
        // Pink
        return [UIColor colorWithRed:208.0f/255.0f green:78.0f/255.0f blue:200.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Camp & caravan"]){
        // Yellow
        return [UIColor colorWithRed:219.0f/255.0f green:206.0f/255.0f blue:4.0f/255.0f alpha:alpha];
    }
    else if([group isEqualToString:@"Arts & crafts"]){
        // Brown
        return [UIColor colorWithRed:122.0f/255.0f green:64.0f/255.0f blue:7.0f/255.0f alpha:alpha];
    }
    else{
        // Dark Blue
        return [UIColor colorWithRed:50.0f/255.0f green:82.0f/255.0f blue:189.0f/255.0f alpha:alpha];
    }
}
@end


