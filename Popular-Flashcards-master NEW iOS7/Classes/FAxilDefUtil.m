//
//  FAxilDefUtil.m
//  flashCards
//
//  Created by Ruslan on 7/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FAxilDefUtil.h"
#import "JSON.h"
#import "ModalAlert.h"

FAxilDefUtil *sharedWordSpel = nil;
id SpelDelegate = nil;

//#define k_key_id @"8ef8aad0150489e8f22080b1bb80c9d9b9e92568c95983d62"

#define k_key_id @"a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5" //working sanjeev reddy

@interface FAxilDefUtil(Private)

-(void)parseJSON:(NSString*)JSONstr;

@end


@implementation FAxilDefUtil

+(id)sharedWordSpel:(id)Adelegate
{
	if (!sharedWordSpel) {
		sharedWordSpel = [[FAxilDefUtil alloc] init];
	}
	
	SpelDelegate = Adelegate;
	return sharedWordSpel;
}

-(void)trueWordSpel:(NSString*)word
{
	if (!word) {
		return;
	}
	
	NSString *parStr = [word lowercaseString];
	parStr = [parStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    NSString *urlStr = [NSString stringWithFormat:@"http://api.wordnik.com/v4/word.json/%@?useSuggest=true&literal=false",parStr];
                        
                        
                        
                        
    //@"http://api.wordnik.com:80/v4/word.json/%@?limit=1&includeRelated=true&useCanonical=false&includeTags=false",parStr]; //working
    
  //http://api.wordnik.com:80/v4/word.json/home/definitions?limit=200&includeRelated=true&useCanonical=false&includeTags=false&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5   working
    
    //@"http://api.wordnik.com/v4/word.json/%@/definitions?api_key=8ef8aad0150489e8f22080b1bb80c9d9b9e92568c95983d62",parStr];

    //http://api.wordnik.com/v4/word.json/{word}/definitions
                        
    //@"https://wordnik.com/words/%@",parStr];
    //@"http://api.wordnik.com/v4/word.json/%@?useSuggest=true&literal=false",parStr]; //origi
  
    
	
	NSURL	*url = [NSURL URLWithString:urlStr];
	
	if (!url) {
		if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
			[SpelDelegate spellingFailed];
		}
		return;
	}
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	if (!request) {
		if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
			[SpelDelegate spellingFailed];
		}
		return;
	}
	
	NSDictionary *header = [NSDictionary dictionaryWithObject:k_key_id forKey:@"api_key"];
	
	if (!header) {
		if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
			[SpelDelegate spellingFailed];
		}
		return;
	}
	
	[request setAllHTTPHeaderFields:header];
    NSLog(@"url appending -->%@",request.URL);
	
    if (connection) {
        [connection cancel];
        [connection release];
    }
	
	if (currentData) {
		[currentData release];
		currentData = nil;
	}
	lastStatusCode = -1;
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:sharedWordSpel];
	currentData = [[NSMutableData alloc] init];
  
  
}

-(void)cancelAllOperations
{
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (currentData) {
		[currentData release];
		currentData = nil;
	}
	
	SpelDelegate = nil;
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *Aresponse = (NSHTTPURLResponse *)response;
        lastStatusCode = [Aresponse statusCode];
		NSLog(@"Status code: %d",lastStatusCode);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (currentData)
		[currentData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (error) 
		NSLog(@"%@",[error description]);
	
	if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
		[SpelDelegate spellingFailed];
		[ModalAlert say:@"Connection failed"];
	}
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	
	NSString *JSONstr;
	
    JSONstr = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
	
	if (JSONstr && lastStatusCode!=404) {
		NSLog(@"%@",JSONstr);
    	[self parseJSON:JSONstr];
				
	}
	else {
		if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
			[SpelDelegate spellingFailed];
		}
	}
	
	if (JSONstr) {
		[JSONstr release];
		JSONstr = nil;
	}
	
}

#pragma mark -
#pragma mark private

-(void)parseJSON:(NSString*)JSONstr
{
	NSString *returnStr = nil;
	NSDictionary *sugDic = [JSONstr JSONValue];
	
    NSLog(@"sugDIc Value in Parse JSON %@",sugDic);
	if (!sugDic) {
		if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingFailed)]) {
			[SpelDelegate spellingFailed];
		}
		return;
	}
	
	returnStr = [sugDic objectForKey:@"canonicalForm"];
	
	if (!returnStr) {
		returnStr = [sugDic objectForKey:@"word"];
	}
	
	if (SpelDelegate && [SpelDelegate respondsToSelector:@selector(spellingWord:)]) {
		[SpelDelegate spellingWord:returnStr];
	}
}

@end
