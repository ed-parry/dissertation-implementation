//
//  AttractionsDataManager.h
//  Ceredigion Tourism iOS
//
//  Created by Ed Parry on 12/03/2014.
//  Copyright (c) 2014 Aberystwyth University. All rights reserved.
//

#import "CSVDataManager.h"

@interface AttractionsCSVDataManager : CSVDataManager
- (void)saveDataFromURL;
- (void)saveDataFromURLReset;
@end
