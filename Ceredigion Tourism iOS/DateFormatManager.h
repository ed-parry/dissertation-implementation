//
//  DateFormatManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 22/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatManager : NSObject
- (NSString *)getTextualDate:(NSString *)date;
- (NSString *)switchDateStringOrder:(NSString *)date;
@end
