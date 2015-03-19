//
//  FAxilDefUtil.h
//  flashCards
//
//  Created by Ruslan on 7/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FAxilSpelDelegate

-(void)spellingWord:(NSString*)term;
-(void)spellingFailed;

@end


@interface FAxilDefUtil : NSObject {
	NSURLConnection *connection;
	NSMutableData *currentData;
	NSInteger curMode;
	NSInteger lastStatusCode;
}

+(id)sharedWordSpel:(id)Adelegate;
-(void)trueWordSpel:(NSString*)word;
-(void)cancelAllOperations;

@end
