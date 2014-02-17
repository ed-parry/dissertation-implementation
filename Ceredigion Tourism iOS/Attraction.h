//
//  Attraction.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 17/02/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Attraction : NSObject

@property (nonatomic) int id;
@property (strong, nonatomic) NSString *group;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) NSURL *imageLocation;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *telephone;
@property (nonatomic) NSURL *url;
@property (nonatomic) double latitude;
@property (nonatomic) double longtitude;
@property (nonatomic) BOOL hide;

@end
