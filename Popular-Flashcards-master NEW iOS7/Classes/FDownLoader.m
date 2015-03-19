//
//  FDownLoader.m
//  flashCards
//
//  Created by Ruslan on 6/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FDownLoader.h"

static FDownLoader* sharedDownloader = nil;
static NSMutableArray *downloadArray = nil;
static NSInteger currDownloaded = -1;
static id delegate = nil;

@interface FDownLoader(Private)

-(void)startDownload;

@end


@implementation FDownLoader

#pragma mark -
#pragma mark Important methods

+(FDownLoader*)sharedDownloader:(id)Adelegate
{
	if (!sharedDownloader) {
		sharedDownloader = [[FDownLoader alloc] init];
		downloadArray = [[NSMutableArray alloc] init];
		currDownloaded = -1;
	}
	
	delegate = Adelegate;
	
	return sharedDownloader;
}

-(void)addToDowload:(NSArray*)urls
{
	if (urls) {
		[downloadArray addObjectsFromArray:urls];
		if (currDownloaded<0) {
			[self startDownload];
		}
	}
	
}

-(void)download:(NSArray*)urls
{
	if ((!urls)&& delegate && [delegate respondsToSelector:@selector(downloadingFinished:)]) {
		[delegate downloadingFinished:NO];
	}
	else {
		[downloadArray addObjectsFromArray:urls];
		[self startDownload];
	}
}


-(void)stopDownloading
{
	if (currConnection) {
		[currConnection cancel];
		[currConnection release];
		currConnection = nil;
		currDownloaded = -1;
		
		if (currData) {
			[currData release];
			currData = nil;
		}
		
	}
}

-(void)cleanDownloader
{
	if (sharedDownloader) {
		[sharedDownloader release];
		[downloadArray release];
		if (currConnection) {
			[currConnection cancel];
			[currConnection release];
		}
		sharedDownloader = nil;
		downloadArray = nil;
		downloadArray = nil;
		currDownloaded = -1;
		
		if (currData) {
			[currData release];
			currData = nil;
		}
		
	}
}

-(BOOL)continueDownloading
{
	if (currConnection) {
		[currConnection start];
		return YES;
	}
	else {
		return NO;
	}

}

-(void)cancelDownloading
{
	if (currConnection) {
		[currConnection cancel];
		[currConnection release];
		currConnection = nil;
		[downloadArray removeAllObjects];
		currDownloaded = -1;
		
		if (currData) {
			[currData release];
			currData = nil;
		}
	}
}

-(BOOL)isDownloading
{
	if (currConnection) {
		return YES;
	}
	else {
		return NO;
	}

}

#pragma mark -
#pragma mark connection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (!currData) {
		currData = [[NSMutableData alloc] init];
	}
	
	[currData appendData:data];
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (delegate && [delegate respondsToSelector:@selector(downloadingDidFailed:)]) {
		NSString *urlStr;
		
		if (downloadArray && [downloadArray count]>currDownloaded) {
		  urlStr = [downloadArray objectAtIndex:currDownloaded];
		}
		
		[delegate downloadingDidFailed:urlStr];
	}
	
	[self startDownload];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (currData) {
		NSData *retData = [[NSData alloc] initWithData:currData];
		
		if (delegate && [delegate respondsToSelector:@selector(downloadedDataRecived:)]) {
			[delegate downloadedDataRecived:retData];
		}
		[self startDownload];
	}
}


#pragma mark -
#pragma mark private methods
-(void)startDownload
{
	if ([downloadArray count]>0) {
		currDownloaded++;
		
		if ((currDownloaded>=[downloadArray count])) {
			if (delegate && [delegate respondsToSelector:@selector(downloadingFinished:)])
											[delegate downloadingFinished:YES];
			[downloadArray removeAllObjects];
			
			if (currConnection) {
				[currConnection release];
				currConnection = nil;
			}
			
			if (currData) {
				[currData release];
				currData = nil;
			}
			
			currDownloaded = -1;
			
			
		}
		else {
			
			if (currConnection) {
				[currConnection release];
			}
			
			NSString *urlStr = [downloadArray objectAtIndex:currDownloaded];
			NSURL* url = [NSURL URLWithString:urlStr];
			
			if (!url) {
				if (delegate && [delegate respondsToSelector:@selector(downloadingFinished:)])
					[delegate downloadingFinished:NO];
				return;
			}
			
			if (currData) {
				[currData release];
				currData =	 nil;
			}
			
			currConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:sharedDownloader];
			[currConnection start];
		}
		
				
	}
}

@end
