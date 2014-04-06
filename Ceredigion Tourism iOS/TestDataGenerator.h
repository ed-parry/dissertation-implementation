//
//  TestDataGenerator.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 06/04/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestDataGenerator : NSObject
- (void)generateTestEvents:(int)numberToGenerate;
- (void)generateTestAttractions:(int)numberToGenerate;
@end
