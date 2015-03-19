//
//  FPrepareToExport.h
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FPrepareToExport : NSObject {

}

+(BOOL)makeZipFromCategoryAtPath:(NSString*)path forResultsPath:(NSString*)resPath fromCategory:(NSString*)category;
+(BOOL)makeZipFromCategoryAtPathAsAnki:(NSString*)path fromCategory:(NSString*)category;
+(BOOL)makeZipFromFileAtPath:(NSString*)resource forPath:(NSString*)path forNewPath:(NSString*)newFile;
@end
