//
//  FCSVgen.h
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FCSVgen : NSObject {

}

+(BOOL)createCSVFileAtPathFromCategory:(NSString*)path forCategory:(NSString*)category;
+(BOOL)createCSVFileAtPathFromCategoryAsAnki:(NSString*)path forCategory:(NSString*)category;
@end
