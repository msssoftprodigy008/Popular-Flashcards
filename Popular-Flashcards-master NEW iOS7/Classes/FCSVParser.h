//
//  FCSVParser.h
//  flashCards
//
//  Created by Ruslan on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FCSVParser : NSObject {

}
+(NSMutableArray*)parseCSVFile:(NSString*)filePath;
+(NSMutableArray*)parseApiString:(NSString*)apiStr;
@end
