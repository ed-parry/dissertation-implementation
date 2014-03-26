//
//  ActivityPlan.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 25/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ActivityPlan : NSObject
@property (strong, nonatomic) NSString *location;
@property CLLocationCoordinate2D locationCoordinates;
@property (strong, nonatomic) NSString *startDate;
@property (strong, nonatomic) NSNumber *days;
@property (strong, nonatomic) NSArray *selectedGroups;
@property (strong, nonatomic) NSString *adrenalineLevel;
@property (strong, nonatomic) NSNumber *numberOfActivities;
@end
