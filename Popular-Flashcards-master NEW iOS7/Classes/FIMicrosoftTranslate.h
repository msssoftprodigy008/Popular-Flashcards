//
//  FIMicrosoftTranslate.h
//  flashCards
//
//  Created by Ruslan on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FIMicrosoftTranslateDelegate<NSObject>
@optional
-(void)supportedLanguages:(NSArray*)languages;
-(void)translatingFailed:(NSString*)desription;
-(void)translatedText:(NSString*)text;

@end

typedef enum{
	FIMicrosoftTranslateTypeLanguage,
	FIMicrosoftTranslateTypeTranslate
}FIMicrosoftTranslateType;

@interface FIMicrosoftTranslate : NSObject<NSXMLParserDelegate> {
	NSMutableArray *languages;
	NSMutableString *xmlCurrentString;
	NSString *xmlCurrentElement;
	FIMicrosoftTranslateType trType;
}

+(id)initWithDelegate:(id<FIMicrosoftTranslateDelegate>)delegate;
-(void)getLanguageNames;
-(void)translate:(NSString*)text from:(NSString*)lang1 to:(NSString*)lang2;
-(void)clear;
-(void)removeCurTranslator;
@end
