//
//  FLanguageTranslate.m
//  flashCards
//
//  Created by Ruslan on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FLanguageTranslate.h"
#import "JSON.h"
#import "FHTMLConverter.h"
#import "Util.h"

@interface FLanguageTranslate(Private)

-(void)parseCurrentData;

@end

FLanguageTranslate *langTrans = nil;
id Langdelegate = nil;
NSURLConnection *connection = nil;
NSMutableData *translatedData = nil;

@implementation FLanguageTranslate

+(id)initWithDelegate:(id)Adelegate
{
	if(!langTrans)
	{
		langTrans = [[FLanguageTranslate alloc] init];
	}
	Langdelegate = Adelegate;
	return langTrans;
}

-(void)translate:(NSString*)text from:(NSString*)firstL to:(NSString*)secondLan
{
	if (!text || !secondLan || !firstL) {
		if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
			[Langdelegate translatingFnished:NO translated:nil];
		return;
	}
	
	NSString *fr;
	NSString *to;
	
	NSMutableDictionary *curDic = [Util lanCode];
	
	if (firstL) {
		fr = [curDic objectForKey:firstL];
	}
	else {
		if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
			[Langdelegate translatingFnished:NO translated:nil];
		return;
	}
	
	if (secondLan) {
		to = [curDic objectForKey:secondLan];
	}
	else {
		if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
			[Langdelegate translatingFnished:NO translated:nil];
		return;
	}


	
	NSString *t = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSString *strForUrl = [NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=%@",t];
	
	if (!strForUrl) {
		if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
			[Langdelegate translatingFnished:NO translated:nil];
		return;
	}
	
	strForUrl = [strForUrl stringByAppendingString:[NSString stringWithFormat:@"&langpair=%@",fr]];
	strForUrl = [strForUrl stringByAppendingString:@"%7C"];
	strForUrl = [strForUrl stringByAppendingString:to];
	NSLog(@"%@",strForUrl);
	NSURL *url = [NSURL URLWithString:strForUrl];
	if(translatedData)
		[translatedData release];
	translatedData = [[NSMutableData alloc] init];
	
	if (connection) {
		[connection cancel];
		[connection release];
	}
	
	connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	[connection start];
}

-(void)clear
{
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (translatedData) {
		[translatedData release];
		translatedData = nil;
	}
	
	Langdelegate = nil;
}

#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (data) {
		[translatedData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"%@",[error localizedDescription]);
	
	if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)]) 
		[Langdelegate translatingFnished:NO translated:nil];
	

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (translatedData) {
		NSString *strToParse = [[NSString alloc] initWithCString:[translatedData bytes] encoding:NSUTF8StringEncoding];
		
		if (!strToParse) {
			if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
				[Langdelegate translatingFnished:NO translated:nil];
			return;
		}
		
		NSDictionary *dic = [strToParse JSONValue];
		
		[strToParse release];
		if (!dic) {
			if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
				[Langdelegate translatingFnished:NO translated:nil];
			return;
		}
		
		NSInteger code = [[dic objectForKey:@"responseStatus"] intValue];
		
		if (code != 200) {
			if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
				[Langdelegate translatingFnished:NO translated:nil];
			return;
		}
		
		
		dic = [dic objectForKey:@"responseData"];
		
				
		if (!dic) {
			if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
				[Langdelegate translatingFnished:NO translated:nil];
			return;
		}
		
		NSString *translated = [dic objectForKey:@"translatedText"];
		
		if (!translated) {
			if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
				[Langdelegate translatingFnished:NO translated:nil];
			return;
		}
		
		FHTMLConverter *converterQ = [[FHTMLConverter alloc] init];
		translated = [converterQ convertEntiesInString:translated];
		[converterQ release];
		if (Langdelegate && [Langdelegate respondsToSelector:@selector(translatingFnished:translated:)])
			[Langdelegate translatingFnished:YES translated:translated];
	}
		
}

#pragma mark private methods

-(void)parseCurrentData
{
	
}


@end
