//
//  FIMicrosoftTranslate.m
//  flashCards
//
//  Created by Ruslan on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIMicrosoftTranslate.h"
#import "JSON.h"
#import "FHTMLConverter.h"
#import "Util.h"

@interface FIMicrosoftTranslate(Private)

-(void)failTranslate:(NSString*)description;
-(void)clearConnections;
-(void)clearData;

@end


#define kMicrosoftKey @"660A7DFF6A661ED25AA9005C835FC2A2FA53ACC1"

FIMicrosoftTranslate *translator = nil;
id<FIMicrosoftTranslateDelegate> translatorDelegate = nil;
NSURLConnection *microsoftConnection = nil;
NSMutableData *microsoftTranslatedData = nil;
NSXMLParser *translatorParser;

@implementation FIMicrosoftTranslate

+(id)initWithDelegate:(id<FIMicrosoftTranslateDelegate>)delegate
{
	if (!translator) {
		translator = [[FIMicrosoftTranslate alloc] init];
	}
	
	translatorDelegate = delegate;
	
	return translator;
}

-(void)getLanguageNames
{
    if (![Util connectedToNetwork]) {
        [self failTranslate:@"Check internet connection and try again"];
        return;
    }
    
	NSString *urlStr = [NSString stringWithFormat:
						@"http://api.microsofttranslator.com/v2/Http.svc/GetLanguagesForTranslate?appId=%@",kMicrosoftKey];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	if (!url) {
		[self failTranslate:@"Getting languages failed."];
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
	if (!request) {
		[self failTranslate:@"Tranlation failed. Please check your text."];
		return;
	}
	
	[request setTimeoutInterval:15];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	
	[self clearConnections];
	[self clearData];
	
    trType = FIMicrosoftTranslateTypeLanguage;
	microsoftTranslatedData = [[NSMutableData alloc] init];
	microsoftConnection	= [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

-(void)translate:(NSString*)text from:(NSString*)lang1 to:(NSString*)lang2
{
    if (![Util connectedToNetwork]) {
        [self failTranslate:@"Check internet connection and try again"];
        return;
    }
    
	if (!text || !lang1 || !lang2) {
		[self failTranslate:@"Empty parameter"];
		return;
	}
	
	NSString *t = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *urlString = [NSString stringWithFormat:
						   @"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&from=%@&to=%@",
						   kMicrosoftKey,
						   t,
						   lang1,
						   lang2];
	NSURL *url = [NSURL URLWithString:urlString];
	
	if (!url) {
		[self failTranslate:@"Tranlation failed. Please check your text."];
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		
	if (!request) {
		[self failTranslate:@"Tranlation failed. Please check your text."];
		return;
	}
	
	[request setTimeoutInterval:15];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	
	[self clearConnections];
	[self clearData];
	
	trType = FIMicrosoftTranslateTypeTranslate;
	microsoftTranslatedData = [[NSMutableData alloc] init];
	microsoftConnection	= [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}

-(void)clear
{
	if(languages){
		[languages release];
		languages = nil;
	}
	
	if (translatorParser) {
		[translatorParser release];
		translatorParser = nil;
	}
		
	[self clearConnections];
	[self clearData];
	translatorDelegate = nil;
}

-(void)removeCurTranslator
{
	if (translator) {
		[translator release];
		translator = nil;
	}
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (data) {
		[microsoftTranslatedData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (error) {
		[self failTranslate:[error localizedDescription]];
	}else {
		[self failTranslate:@"Translating failed.Try later.Perhaps the server is busy."];
	}

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

	if(microsoftTranslatedData)
	{
		if (translatorParser) {
			[translatorParser release];
		}
		translatorParser = [[NSXMLParser alloc] initWithData:microsoftTranslatedData];
		translatorParser.delegate = self;
		[translatorParser parse];
	}else {
		[self failTranslate:@"Can't translate. Please check your text."];
	}

}

#pragma mark NSURLConnection Delegate ends

#pragma mark -
#pragma mark private

-(void)failTranslate:(NSString*)description
{
	if (description && translatorDelegate && [translatorDelegate respondsToSelector:@selector(translatingFailed:)]) {
		[translatorDelegate translatingFailed:description];
	}
	
	if (description) {
		NSLog(@"Microsoft translator:%@",description);
	}
}

-(void)clearConnections
{
	if (microsoftConnection) {
		[microsoftConnection cancel];
		[microsoftConnection release];
		microsoftConnection = nil;
	}
}

-(void)clearData
{
	if (microsoftTranslatedData) {
		[microsoftTranslatedData release];
		microsoftTranslatedData = nil;
	}
}

#pragma mark private ends

#pragma mark -
#pragma mark XML parser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	if (trType == FIMicrosoftTranslateTypeLanguage) {
		if (languages) {
			[languages release];
		}
		
		languages = [[NSMutableArray alloc] init];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	if (trType == FIMicrosoftTranslateTypeLanguage) {
		if (translatorDelegate && [translatorDelegate respondsToSelector:@selector(supportedLanguages:)]) {
			[translatorDelegate supportedLanguages:languages];
		}
	}else {
		if (translatorDelegate && [translatorDelegate respondsToSelector:@selector(translatedText:)]) {
			[translatorDelegate translatedText:xmlCurrentString];
		}
	}


}

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict
{
	if (elementName) {
		xmlCurrentElement = [NSString stringWithString:elementName];
	}
	
	xmlCurrentString = [NSMutableString stringWithString:@""];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if (string) {
		[xmlCurrentString appendString:string];
	}
}


- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
	if (trType == FIMicrosoftTranslateTypeLanguage) {
		if (elementName && [elementName isEqualToString:@"string"]) {
			[languages addObject:xmlCurrentString];
		}
	}	
	xmlCurrentElement = nil;
	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	if (parseError) {
		NSLog(@"Parser error:%@",[parseError localizedDescription]);
	}else {
		NSLog(@"Error ocurred");
	}
}

#pragma mark XML parser ends

@end
