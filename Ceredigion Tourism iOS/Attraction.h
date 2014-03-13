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
@property (strong, nonatomic) NSString *imageLocationURL;
@property (strong, nonatomic) NSString *descriptionText;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *telephone;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (nonatomic) BOOL hide;

- (UIImage *)getAttractionGroupColor:(NSString *)group;

@end
