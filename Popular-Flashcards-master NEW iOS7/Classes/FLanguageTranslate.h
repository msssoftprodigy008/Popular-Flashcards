//
//  FLanguageTranslate.h
//  flashCards
//
//  Created by Ruslan on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLanguageDelegate
-(void)translatingFnished:(BOOL)result translated:(NSString*)translatedText; 

@end


@interface FLanguageTranslate : NSObject {
	
}

+(id)initWithDelegate:(id)Adelegate;
-(void)translate:(NSString*)text from:(NSString*)firstL to:(NSString*)secondLan;
-(void)clear;
@end
