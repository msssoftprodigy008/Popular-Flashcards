//
//  FQuizletImport.m
//  flashCards
//
//  Created by Ruslan on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FQuizletImport.h"
#import "DBTime.h"
#import "JSON.h"

@interface FQuizletImport(Private)

-(void)parseFindedValue:(NSString*)strToParse;

@end


@implementation FQuizletImport
@synthesize delegate;

-(id)initWithDelegate:(id)Adelegate
{
	if (self = [super init]) {
		delegate = Adelegate;
	}
	
	return self;
}

-(void)setDelegate:(id)Adelegate
{
	delegate = Adelegate;
}

-(void)findByTerm:(NSString*)term sortBy:(NSInteger)sort pages:(NSInteger)pageNum
{
	if (!term) {
		NSLog(@"Term not found");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Term not found"];
		}
		
		return;
	}
	
	if (sort>2) {
		NSLog(@"Uncompatible mode");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible mode"];
		}
		
		return;
	}
	
	if (pageNum<=0) {
		NSLog(@"Uncompatible page number");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible page number"];
		}
		
		return;
	}
	
	NSString *mode;
	
	switch (sort) {
		case 0:
			mode = @"most_studied";
			break;
		case 1:
			mode = @"alphabetical";
			break;
		case 2:
			mode = @"most_recent";
			break;
			
		default:
			break;
	}
	
    term = [term stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
	NSString *urlStr = [NSString stringWithFormat:@"http://quizlet.com/api/1.0/sets?dev_key=a3ogw91qx544wc08&q=term:%@&sort=%@&per_page=50&page=%d",term,mode,pageNum];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	if (!url) {
		NSLog(@"Undefined url");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Undefined url"];
		}
		
		return;
	}
	
	if (connection) {
		[connection cancel];
		[connection release];
	}
	
	if (downloadingData) {
		[downloadingData release];
	}
	
	downloadingData = [[NSMutableData alloc] init];
	
	connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	[connection start];
	
}

-(void)findByCreator:(NSString*)creator sortBy:(NSInteger)sort pages:(NSInteger)pageNum
{
	if (!creator) {
		NSLog(@"Term not found");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Term not found"];
		}
		
		return;
	}
	
	if (sort>2) {
		NSLog(@"Uncompatible mode");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible mode"];
		}
		
		return;
	}
	
	if (pageNum<=0) {
		NSLog(@"Uncompatible page number");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible page number"];
		}
		
		return;
	}
	
	NSString *mode;
	
	switch (sort) {
		case 0:
			mode = @"most_studied";
			break;
		case 1:
			mode = @"alphabetical";
			break;
		case 2:
			mode = @"most_recent";
			break;
			
		default:
			break;
	}
	creator = [creator stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	NSString *urlStr = [NSString stringWithFormat:@"http://quizlet.com/api/1.0/sets?dev_key=a3ogw91qx544wc08&q=creator:%@&sort=%@&per_page=50&page=%d",creator,mode,pageNum];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	if (!url) {
		NSLog(@"Undefined url");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Undefined url"];
		}
		
		return;
	}
	
	if (connection) {
		[connection cancel];
		[connection release];
	}
	
	if (downloadingData) {
		[downloadingData release];
	}
	
	downloadingData = [[NSMutableData alloc] init];
	
	connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	[connection start];
	
}

-(void)findBySubject:(NSString*)subject sortBy:(NSInteger)sort pages:(NSInteger)pageNum
{
	if (!subject) {
		NSLog(@"Term not found");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Term not found"];
		}
		
		return;
	}
	
	if (sort>2) {
		NSLog(@"Uncompatible mode");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible mode"];
		}
		
		return;
	}
	
	if (pageNum<=0) {
		NSLog(@"Uncompatible page number");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Uncompatible page number"];
		}
		
		return;
	}
	
	NSString *mode;
	
	switch (sort) {
		case 0:
			mode = @"most_studied";
			break;
		case 1:
			mode = @"alphabetical";
			break;
		case 2:
			mode = @"most_recent";
			break;
			
		default:
			break;
	}
    
    subject = [subject stringByReplacingOccurrencesOfString:@" " withString:@"-"];
	
	NSString *urlStr = [NSString stringWithFormat:@"http://quizlet.com/api/1.0/sets?dev_key=a3ogw91qx544wc08&q=%@&sort=%@&per_page=50&page=%d",subject,mode,pageNum];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	if (!url) {
		NSLog(@"Undefined url");
		
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Undefined url"];
		}
		
		return;
	}
	
	if (connection) {
		[connection cancel];
		[connection release];
	}
	
	if (downloadingData) {
		[downloadingData release];
	}
	
	downloadingData = [[NSMutableData alloc] init];
	
	connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	[connection start];
}

-(void)cancel
{
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (downloadingData) {
		[downloadingData release];
		downloadingData = nil;
	}
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[downloadingData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
		[delegate listFormed:NO forData:nil forError:@"Connection failed"];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (downloadingData) {
		NSString *strToParse = [[NSString alloc] initWithData:downloadingData encoding:NSUTF8StringEncoding];
		[self parseFindedValue:strToParse];
		[strToParse release];
	}
	
}

#pragma mark -
#pragma mark private methods

-(void)parseFindedValue:(NSString*)strToParse
{
	
	
	NSMutableDictionary* fileNames = [[NSMutableDictionary alloc] init];
	
	NSDictionary *dicResult = [strToParse JSONValue];
	
	if(dicResult)
	{
		NSString *result = [dicResult objectForKey:@"response_type"];
		if([result isEqualToString:@"ok"])
		{
			NSArray *arrSet = [dicResult objectForKey:@"sets"];
			[fileNames setObject:arrSet forKey:@"sets"];
			[fileNames setObject:[dicResult objectForKey:@"total_results"] forKey:@"total"];
			[fileNames setObject:[dicResult objectForKey:@"total_pages"] forKey:@"total_pages"];
			
			if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
				[delegate listFormed:YES forData:fileNames forError:nil];
			}
			
		}
		else
		{
			[fileNames release];
			if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
				[delegate listFormed:NO forData:nil forError:@"Sets not found"];
			}
		}
	}
	else {
		[fileNames release];
		if ([delegate respondsToSelector:@selector(listFormed:forData:forError:)]) {
			[delegate listFormed:NO forData:nil forError:@"Service busy.\nPlease try later."];
		}
		
		NSLog(@"%@",strToParse);
	}

	
	
}

-(void)dealloc
{
	if(downloadingData)
		[downloadingData release];
	
	if (connection) {
		[connection cancel];
		[connection release];
	}
	
	[super dealloc];
}


@end
