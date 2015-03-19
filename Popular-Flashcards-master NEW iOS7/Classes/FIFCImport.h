//
//  FIFCImport.h
//  flashCards
//
//  Created by Ruslan on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FIFCImport : NSObject {

}

//imports set to database and returns set_id
+(NSString*)importFCFileWithPath:(NSString*)path;
+(NSString*)importFCFile:(NSString*)filename;
+(NSString*)importZipToApp:(NSString*)zipPath;
+(NSString*)findCSVFileinDir:(NSString*)dir;
+(NSSet*)supportedExtensions;
+(NSSet*)supportedCSVExt;

@end
