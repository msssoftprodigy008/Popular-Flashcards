//
//  FHTMLConverter.m
//  flashCards
//
//  Created by Ruslan on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FHTMLConverter.h"


@implementation FHTMLConverter

@synthesize resultString;
- (id)init
{
	if([super init]) {
		resultString = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
	[self.resultString appendString:s];
}

- (NSString*)convertEntiesInString:(NSString*)s {
	if(s == nil) {
		NSLog(@"ERROR : Parameter string is nil");
	}
	NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
	NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	
	if (xmlParse) {
		[xmlParse release];
	}
	
	xmlParse = [[NSXMLParser alloc] initWithData:data];
	[xmlParse setDelegate:self];
	[xmlParse parse];
	NSString* returnStr = [[NSString alloc] initWithFormat:@"%@",resultString];
	return returnStr;
}

- (void)dealloc {
	[resultString release];
	[xmlParse release];
	[super dealloc];
}

@end
