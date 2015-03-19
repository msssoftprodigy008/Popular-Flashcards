//
//  FImportSet.m
//  flashCards
//
//  Created by Руслан Руслан on 2/22/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import "FImportSet.h"
#import "FDBController.h"
#import "Util.h"
#import "JSON.h"
#import "FHTMLConverter.h"
#import "FCSVParser.h"
#import "FDownLoader.h"

@interface FImportSet(Private)
-(void)downloadFileWithID;
-(void)addToCategory:(NSArray*)set;
-(NSMutableString*)scanStr:(NSString*)str;
-(void)saveFile:(NSData*)data;
-(void)completeImportFromDic;
@end


@implementation FImportSet

-(id)initWithDelegate:(id)Adelegate
{
	if(self = [super init])
		delegate = Adelegate;
	isReversed = NO;
	return self;
}

-(void)importWithFileName:(NSString*)Aname forId:(NSString*)idStr withAdd:(BOOL)add
{
	if (currentSet) {
		[currentSet release];
	}
	
	currentSet = [[NSString alloc] initWithString:Aname];
	
	NSString *newStr = [self scanStr:currentSet];
	
	isAddSet = add;
	
	BOOL checked = [[FDBController sharedDatabase] checkCategoryExisting:newStr];
	
	if (checked && isAddSet) {
		
		if (delegate && [delegate respondsToSelector:@selector(justForget)]) {
			[delegate justForget];
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import"
														message:@"This set is already imported"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else{
		NSString *urlStr = [NSString stringWithFormat:@"http://quizlet.com/api/1.0/sets?dev_key=a3ogw91qx544wc08&q=ids:%@&extended=on",idStr];
		urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:urlStr];
	
		if (connection) {
			[connection cancel];
			[connection release];
			connection = nil;
		}
	
		connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
	
		if (curData) 
			[curData release];
	
		curData = [[NSMutableData alloc] init];
	
		[connection start];
	}
	[newStr release];
}

-(void)addArrToCategory:(NSString*)category forArr:(NSArray*)set forRev:(BOOL)isRev
{
	if (!category || !set) {
		if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) {
			[delegate importFinished:NO forCat:nil];
		}
	}
	else {
		
		isReversed = isRev;
		
		if (currentSet) {
			[currentSet release];
		}
		
		currentSet = [[NSString alloc] initWithString:category];
		[self addToCategory:set];
	}

}

-(void)cancelDownload
{
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (curData) {
		[curData release];
		curData = nil;
	}
	
	if (setToImport) {
		[setToImport release];
		setToImport = nil;
	}
	
	if (indexes) {
		[indexes release];
		indexes = nil;
	}
	
	if (currentSet) {
		[currentSet release];
		currentSet = nil;
	}
	
	[[FDownLoader sharedDownloader:self] cancelDownloading];
}



#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	
	[curData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) {
		[delegate importFinished:NO forCat:currentSet];
	}
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (curData) {
		NSString *strToParse = [[NSString alloc] initWithData:curData encoding:NSUTF8StringEncoding];
		NSDictionary *dic = [strToParse JSONValue];
		if(dic)
		{
			NSArray *set = [dic objectForKey:@"sets"];
			dic = [set objectAtIndex:0];
			set = nil;
			set = [dic objectForKey:@"terms"];
			
			if(!set)
			{
				if (delegate && [delegate respondsToSelector:@selector(importFinished:)]) 
					[delegate importFinished:NO forCat:nil];
			}
			else
			{
				if (isAddSet) 
					[self addToCategory:set];
				else {
					if (delegate && [delegate respondsToSelector:@selector(recivedCards:)]) {
						[delegate recivedCards:set];
					}
				}

			}
		}
		else
			if (delegate && [delegate respondsToSelector:@selector(importFinished:)]) 
				[delegate importFinished:NO forCat:nil];
		[strToParse release];
	}
	else {
		if (delegate && [delegate respondsToSelector:@selector(importFinished:)]) 
			[delegate importFinished:NO forCat:nil];
	}

}

#pragma mark -
#pragma mark FDownLoader delegate
-(void)downloadedDataRecived:(NSData*)downloadedData{
	if (downloadedData && [indexes count]>0) {
		NSInteger index = [[indexes objectAtIndex:0] intValue];
		[indexes removeObjectAtIndex:0];
		UIImage *image = [UIImage imageWithData:downloadedData];
        if (image) {
            NSMutableArray *cards = [setToImport objectForKey:@"cards"];
            NSMutableArray *card = [cards objectAtIndex:index];
            [card addObject:image];
            [cards replaceObjectAtIndex:index withObject:card];
            [setToImport setObject:cards forKey:@"cards"];
        }
        if (delegate && [delegate respondsToSelector:@selector(dataRecived:)]) {
            [delegate dataRecived:1];
        } 
		
		if(downloadedData)
			[downloadedData release];
	}
}

-(void)downloadingDidFailed:(NSString*)url
{
	if ([indexes count]>0) {
		[indexes removeObjectAtIndex:0];
	}
}

-(void)downloadingFinished:(BOOL)result
{
	if (result) {
		[self completeImportFromDic];
	}else {
		
		if (setToImport) {
			[setToImport release];
			setToImport = nil;
		}
		
		if (indexes) {
			[indexes release];
			indexes = nil;
		}
		
		if (currentSet) {
			[currentSet release];
			currentSet = nil;
		}
		
		if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) {
			[delegate importFinished:result forCat:currentSet];
		}
	}
}

#pragma mark -
#pragma mark Private Methods

-(void)addToCategory:(NSArray*)set
{
	if(!currentSet)
	{
		if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) 
			[delegate importFinished:NO forCat:nil];
		return;
	}
	
	if (setToImport) {
		[setToImport release];
	}
	
	setToImport = [[NSMutableDictionary alloc] init];
	
	FHTMLConverter *converter = [[FHTMLConverter alloc] init];
	NSString *newSet = [converter convertEntiesInString:currentSet];
	[currentSet release];
	[converter release];
	NSString *checkBrackStr = [newSet stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	
	if (checkBrackStr) {
		currentSet = [[NSString alloc] initWithString:checkBrackStr];
	}else {
		return;
	}

	[newSet release];
	[setToImport setObject:currentSet forKey:@"setName"];
		
	if (indexes) {
		[indexes release];
	}
	
	indexes = [[NSMutableArray alloc] init];
	
	NSMutableArray *urls = [NSMutableArray array];
	NSMutableArray *cardsForSet = [NSMutableArray array];
	int index = 0;
    
    
    
	for (NSArray *qArr in set) {
		NSMutableArray *card = [NSMutableArray array];
		FHTMLConverter *converterQ = [[FHTMLConverter alloc] init];
		FHTMLConverter *converterA = [[FHTMLConverter alloc] init];
		NSString *q; 
		NSString *a; 
		
		if (isReversed) {
			a = [qArr objectAtIndex:0];
			q = [qArr objectAtIndex:1];
		}
		else {
			a = [qArr objectAtIndex:1];
			q = [qArr objectAtIndex:0];
		}

		
		a = [converterA convertEntiesInString:a];
		q = [converterQ convertEntiesInString:q];
		
		[converterA release];
		[converterQ release];
		
		NSString* aa = [a stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
		NSString* qq = [q stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
		
		[a release];
		[q release];
	
		[card addObject:qq];
		[card addObject:aa];
		
		NSString *imUr = [qArr objectAtIndex:2];
				
		//получаем картинки
		if (!([imUr isEqualToString:@"\"\""]) && !([imUr isEqualToString:@""])) {
			NSString* urlStr = [imUr stringByReplacingOccurrencesOfString:@"_m" withString:@""];
			urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
			[urls addObject:urlStr];		
			[indexes addObject:[NSNumber numberWithInt:index]];
		}
		index++;
		[cardsForSet addObject:card];
        
    }
	
	[setToImport setObject:cardsForSet forKey:@"cards"];
	
	if ([urls count]>0) {
		if (delegate && [delegate respondsToSelector:@selector(dataContentLen:)]) {
			[delegate dataContentLen:[urls count]];
		}
		[[FDownLoader sharedDownloader:self] download:urls];
	}
	else {
		[self completeImportFromDic];
	}
		
	
}

-(NSMutableString*)scanStr:(NSString*)str
{
	NSMutableString *helthStr = [[NSMutableString alloc] init];
	int len = [str length];
	
	NSCharacterSet *alfa = [NSCharacterSet alphanumericCharacterSet];
	
	for (int i = 0;i<len;i++) {
		unichar c = [str characterAtIndex:i];
		if([alfa characterIsMember:c])
		{
			if (i==0 && (c>='0' && c<='9')) {
				[helthStr appendString:[NSString stringWithFormat:@"_%c",c]];
			}
			else {
				[helthStr appendString:[NSString stringWithFormat:@"%c",c]];
			}
		}
		else {
			[helthStr appendString:[NSString stringWithString:@"_"]];
		}

	}
	return helthStr;
}

-(void)completeImportFromDic{
	if (setToImport) {
		NSString *setName = [setToImport objectForKey:@"setName"];
		NSMutableArray *cards = [setToImport objectForKey:@"cards"];
		NSString *item = [[FDBController sharedDatabase] addCategory:setName];
		
		if (item) {
            
                        
			for (NSArray *card in cards) {
				NSString *q = [card objectAtIndex:0];
				NSString *a = [card objectAtIndex:1];
				NSInteger index = [[FDBController sharedDatabase] addQuestionToCategory:item
																			   question:q
																				 answer:a];
				if ([card count]>2) {
					UIImage *image = [card objectAtIndex:2];
					[Util saveImageWithName:image
								   withName:item
									  forId:index
									forWhat:NO];
				}
                
            }
			
			[setToImport release];
			setToImport = nil;
			
			if (indexes) {
				[indexes release];
				indexes = nil;
			}
			
			if (currentSet) {
				[currentSet release];
				currentSet = nil;
			}
			
			if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) {
				[delegate importFinished:YES forCat:item];
			}
		}else {
			[setToImport release];
			setToImport = nil;
			
			if (indexes) {
				[indexes release];
				indexes = nil;
			}
			
			if (currentSet) {
				[currentSet release];
				currentSet = nil;
			}
			
			if (delegate && [delegate respondsToSelector:@selector(importFinished:forCat:)]) {
				[delegate importFinished:NO forCat:nil];
			}
		}

	}	
}


-(void)saveFile:(NSData*)data
{
	
}

- (void)downloadFileWithID
{
}



-(void)dealloc
{
	if (currentSet) {
		[currentSet release];
	}
	
	if (indexes) {
		[indexes release];
	}
	
	if (curData) {
		[curData release];
	}
	
	if(connection)
	{
		[connection cancel];
		[connection release];
	}
	
	[super dealloc];
}
@end
