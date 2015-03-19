//
//  FHTMLConverter.h
//  flashCards
//
//  Created by Ruslan on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FHTMLConverter : NSObject<NSXMLParserDelegate> {
	NSMutableString* resultString;
	NSXMLParser* xmlParse;
}

@property (nonatomic, retain) NSMutableString* resultString;
- (NSString*)convertEntiesInString:(NSString*)s;

@end
