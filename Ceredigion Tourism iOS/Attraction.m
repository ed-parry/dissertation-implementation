//
//  Attraction.m
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "Attraction.h"

@implementation Attraction
- (UIColor *)getAttractionGroupColor:(NSString *)group
{
    // Have to use if/else rather than switch, because
    // Obj-C only supports switch on int/bool/double, not
    // strings.
    if([group isEqualToString:@"Accommodation"]){
        return [UIColor greenColor];
    }
    else if([group isEqualToString:@"Activity"]){
        return [UIColor redColor];
    }
    else if([group isEqualToString:@"Attraction"]){
        return [UIColor purpleColor];
    }
    else if([group isEqualToString:@"Food & drink"]){
        return [UIColor blueColor]; // need to change to teal
    }
    else if([group isEqualToString:@"Retail"]){
        // RGB Pink
        return [UIColor colorWithRed:255.0f/255.0f green:51.0f/255.0f blue:153.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Camp & caravan"]){
        // RGB Yellow
        return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    }
    else if([group isEqualToString:@"Arts & crafts"]){
        return [UIColor brownColor];
    }
    else{
        return [UIColor redColor];
    }
}
@end


