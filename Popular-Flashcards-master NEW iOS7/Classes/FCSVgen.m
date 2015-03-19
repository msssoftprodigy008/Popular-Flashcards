//
//  FCSVgen.m
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FCSVgen.h"
#import "FDBController.h"
#import "Util.h"

@interface FCSVgen(Private)

+(NSString*)genFileName:(NSString*)category forId:(NSInteger)index forQ:(BOOL)isQ;

@end


@implementation FCSVgen

+(BOOL)createCSVFileAtPathFromCategory:(NSString*)path forCategory:(NSString*)category
{
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (!path || !category) {
		return NO;
	}
	
	NSMutableArray *infoForCategory = [[FDBController sharedDatabase] infoForCategory:category];
	NSMutableString *csvStr = [NSMutableString string];
	
	for (NSArray *currentQ in infoForCategory) {
		NSString *question = [currentQ objectAtIndex:1];
		NSString *answer = [currentQ objectAtIndex:2];
		NSInteger index = [[currentQ objectAtIndex:0] intValue];
		
		//[csvStr appendString:category];

		//[csvStr appendString:@";"];
		if (question) {
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",question]];
		}else {
			[csvStr appendString:@"\"\""];
		}

		[csvStr appendString:@"\t"];
		
		if (answer) {
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",answer]];
		}else {
			[csvStr appendString:@"\"\""];
		}

		[csvStr appendString:@"\t"];	
		if ([Util imageWithId:category forId:index forWhat:YES]) {
			NSString *imageName = [NSString stringWithFormat:@"%d_%@.png",index,category]; 
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",imageName]];
		}else {
			[csvStr appendString:@"\"\""];
		}
		[csvStr appendString:@"\t"];

		if ([Util imageWithId:category forId:index forWhat:NO]) {
			NSString *imageName = [NSString stringWithFormat:@"a%d_%@.png",index,category]; 
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",imageName]];
		}else {
			[csvStr appendString:@"\"\""];
		}
		[csvStr appendString:@"\t"];
		
		if ([Util checkSoundForCard:category forId:index forWhat:YES]) {
			NSString *soundName = [NSString stringWithFormat:@"%d_%@.caf",index,category];
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",soundName]];
		}else {
			[csvStr appendString:@"\"\""];
		}
		[csvStr appendString:@"\t"];
	
		if ([Util checkSoundForCard:category forId:index forWhat:NO]) {
			NSString *soundName = [NSString stringWithFormat:@"a%d_%@.caf",index,category];
			[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",soundName]];
		}else {
			[csvStr appendString:@"\"\""];
		}

		
		[csvStr appendString:@"\n"];
	}

	[infoForCategory release];
	[csvStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
	//[pool release];
	return YES;
}

+(BOOL)createCSVFileAtPathFromCategoryAsAnki:(NSString*)path forCategory:(NSString*)category
{
		//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
		if (!path || !category) {
			return NO;
		}
		
		NSMutableArray *infoForCategory = [[FDBController sharedDatabase] infoForCategory:category];
		NSMutableString *csvStr = [NSMutableString string];
		
		for (NSArray *currentQ in infoForCategory) {
			NSString *question = [currentQ objectAtIndex:1];
			NSString *answer = [currentQ objectAtIndex:2];
			NSInteger index = [[currentQ objectAtIndex:0] intValue];
			
			if (question) {
				[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",question]];
			}
			
			if ([Util imageWithId:category forId:index forWhat:YES]) {
				NSString *imageName = [NSString stringWithFormat:@"%d_%@.png",index,category]; 
				[csvStr appendString:[NSString stringWithFormat:@" <img src=\"%@\">",imageName]];
			}

			if ([Util checkSoundForCard:category forId:index forWhat:YES]) {
				NSString *soundName = [NSString stringWithFormat:@"[sound:%d_%@.caf]",index,category];
				[csvStr appendString:[NSString stringWithFormat:@"%@",soundName]];
			}
			[csvStr appendString:@"\t"];	

			
			if (answer) {
				[csvStr appendString:[NSString stringWithFormat:@"\"%@\"",answer]];
			}
			
			
			if([Util imageWithId:category forId:index forWhat:NO]) {
				NSString *imageName = [NSString stringWithFormat:@"a%d_%@.png",index,category]; 
				[csvStr appendString:[NSString stringWithFormat:@" <img src=\"%@\">",imageName]];
			} 
			
	
			if ([Util checkSoundForCard:category forId:index forWhat:NO]) {
				NSString *soundName = [NSString stringWithFormat:@"[sound:a%d_%@.caf]",index,category];
				[csvStr appendString:[NSString stringWithFormat:@"%@",soundName]];
			}
			
			
			[csvStr appendString:@"\n"];
		}
		
		[infoForCategory release];
		[csvStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
		//[pool release];
		return YES;
	
}


@end
