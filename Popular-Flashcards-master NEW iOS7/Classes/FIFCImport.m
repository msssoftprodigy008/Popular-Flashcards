//
//  FIFCImport.m
//  flashCards
//
//  Created by Ruslan on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIFCImport.h"
#import "Constants.h"
#import "FRootConstants.h"
#import "FCSVParser.h"
#import "Util.h"
#import "ZipArchive.h"
#import "FDBController.h"

@interface FIFCImport(Private)

#pragma mark private
//import set represented by array to database
+(NSString*)addArrayToBase:(NSMutableArray*)set fromDir:(NSString*)path forFilename:(NSString*)filename;
//unziping file to dir with path
+(BOOL)unzipFile:(NSString*)filePath;
//import backup file
+(NSString*)importBackupWithName:(NSString*)filePath;

@end


@implementation FIFCImport

#pragma mark -
#pragma mark main methods

+(NSSet*)supportedExtensions{
	return [NSSet setWithObjects:@"csv",
						@"",
						@"anki",
						@"txt",
						@"doc",
						@"docx",
						@"rtf",
						@"odt",
						@"flashCardPlus",
                        @"zip",    
						@"flashBackup",nil];
    
//    return [NSSet setWithObjects:@"csv",
//            @"",
//            @"anki",
//            @"txt",
//            @"doc",
//            @"docx",
//            @"rtf",
//            @"odt",
//            @"flashCardPlus",
//            @"zip",
//            @"flashBackup",
//            @"apkg",nil];

}

+(NSSet*)supportedCSVExt{
    return [NSSet setWithObjects:@"csv",
            @"anki",
            @"txt",
            @"doc",
            @"docx",
            @"rtf",
            @"odt",
            nil];
}

+(NSString*)importFCFile:(NSString*)filename{
	if (!filename) {
		NSLog(@"%@",@"Empty FC filename while importing");
		return nil;
	}
	
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	return [self importFCFileWithPath:[documents stringByAppendingPathComponent:filename]];
}

+(NSString*)importZipToApp:(NSString*)zipPath
{
	if (!zipPath || ![[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
		NSLog(@"%@",@"Can't found zip to import!");
		return nil;
	}
	
	NSMutableArray *parsed = nil;
	NSString *item;
		
	if ([self unzipFile:zipPath])
	{	
		NSString *csvPath = [FIFCImport findCSVFileinDir:[zipPath stringByDeletingPathExtension]];
		parsed = [FCSVParser parseCSVFile:csvPath];
		
		if (parsed) {
			
			item = [NSString stringWithString:[self addArrayToBase:parsed fromDir:[csvPath stringByDeletingLastPathComponent] forFilename:[csvPath lastPathComponent]]];
		}
		[Util removeFile:zipPath];
		[Util removeFile:[zipPath stringByDeletingPathExtension]];
	}
	
	return item;
}


+(NSString*)importFCFileWithPath:(NSString*)path{
	
	if (!path) {
		NSLog(@"%@",@"Empty FC path while importing");
		return nil;
	}
	
	NSString *item = nil;
	NSMutableArray *parsed;
	
//    if ([[path pathExtension] isEqualToString:@"flashCardPlus"] || [[path pathExtension] isEqualToString:@"zip"] || [[path pathExtension] isEqualToString:@"apkg"])
    if ([[path pathExtension] isEqualToString:@"flashCardPlus"] || [[path pathExtension] isEqualToString:@"zip"])
	{
		if ([self unzipFile:path])
		{		
			NSString *csvPath = [FIFCImport findCSVFileinDir:[path stringByDeletingPathExtension]];
            NSLog(@"%@",csvPath);
			parsed = [FCSVParser parseCSVFile:csvPath];
			
			if (parsed) {
				
				item = [NSString stringWithString:[self addArrayToBase:parsed fromDir:[csvPath stringByDeletingLastPathComponent] forFilename:[csvPath lastPathComponent]]];
			}
			
			[Util removeFile:[path stringByDeletingPathExtension]];
		}
	}else if ([[path pathExtension] isEqualToString:@"flashBackup"]) {
		item = [NSString stringWithString:[self importBackupWithName:path]];
	}else{
		parsed = [FCSVParser parseCSVFile:path];
		
		if (parsed) {
			item = [NSString stringWithString:[self addArrayToBase:parsed fromDir:[path stringByDeletingLastPathComponent] forFilename:[path lastPathComponent]]];
		}
	}
	
	[Util removeFile:path];
	
	return item;
}

#pragma mark main methods ends

#pragma mark -
#pragma mark private

+(BOOL)unzipFile:(NSString*)filePath
{
	if (!filePath) {
		NSLog(@"Empty filename while unziping!");
		return FALSE;
	}
	
	if (![Util checkFileExist:filePath]) {
		NSLog(@"%@",@"File not exist while unziping!");
		return FALSE;
	}
	
	ZipArchive *unrchiver = [[ZipArchive alloc] init];
	
	NSString *dir_to_unzip = [filePath stringByDeletingPathExtension];
	
	if (![unrchiver UnzipOpenFile:filePath]) {
		NSLog(@"Error while opening file %@ to unzip!",filePath);
		[unrchiver release];
		return FALSE;
	}
	
	if (![unrchiver UnzipFileTo:dir_to_unzip overWrite:YES]) {
		NSLog(@"Error while unziping file %@ to %@!",filePath,dir_to_unzip);
		[unrchiver release];
		return FALSE;
	}
	
	[unrchiver release];
	return YES;
}

+(NSString*)addArrayToBase:(NSMutableArray*)set fromDir:(NSString*)path forFilename:(NSString*)filename{
	
	if (!path || !set || !filename) {
		NSLog(@"%@",@"Empty parameter in addArrayToBase function");
		return nil;
	}
	
	if (![Util checkFileExist:path]) {
		NSLog(@"%@",@"File not exist while importing array to base!");
		return nil;
	}
	
	NSString *category = [filename stringByDeletingPathExtension];
	NSString *item = [[FDBController sharedDatabase] addCategory:category];
	
	[[FDBController sharedDatabase] insertTemplate:item withTemplate:kCustomTemplate];
	
	NSSet *audioSet = [NSSet setWithObjects:@"mp3",@"caf",@"wav",nil];
	NSSet *imageSet = [NSSet setWithObjects:@"",@"png",@"jpg",@"jpeg",@"gif",nil];
	
	if (item) {
		for (NSMutableArray *qArr in set) {
			
			NSString *q = nil;
			NSString *a = nil;
			NSString *qI = nil;
			NSString *aI = nil;
			NSString *qS = nil;
			NSString *aS = nil;
			
			if ([qArr count]>0) 
				q = [qArr objectAtIndex:0];
			else
				q = @"";
			
			if ([qArr count]>1) 
				a = [qArr objectAtIndex:1];
			else
				a = @"";
			
			NSInteger qArrCount = [qArr count];
			
			if (qArrCount>6) {
				qArrCount = 6;
			}
			
			
			for (int i=2;i<qArrCount;i++){
				
				NSString *strToDef = [qArr objectAtIndex:i];
				if (strToDef && [imageSet containsObject:[strToDef pathExtension]]) {
					if (i==2) {
						qI = [qArr objectAtIndex:i];
					}else if (i==3) {
						aI = [qArr objectAtIndex:i];						
					}
				}
				
				if (strToDef && [audioSet containsObject:[strToDef pathExtension]]){
					if (i==4) {
						qS = [qArr objectAtIndex:i];
					}else if (i==5) {
						aS = [qArr objectAtIndex:i];
					} 
				}
				
			}
			
			
			
			NSInteger Id = [[FDBController sharedDatabase] addQuestionToCategory:item question:q answer:a];
			
			UIImage* imForQ = nil;
			UIImage* imForA = nil;
			NSData* soundDataQ = nil;
			NSData* soundDataA = nil;
			
			if (qI){ 
                imForQ = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:qI]]; 
             }
			
			if(aI){
                imForA = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:aI]]; 
            }
			
			if (qS) {
				soundDataQ = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:qS]];
				if (soundDataQ) {
					[Util saveSoundForCard:soundDataQ
							   forCategory:item
									 forId:Id
								   forWhat:YES];
					[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:qS] error:nil];
				}
			}
			
			if (aS) {
				soundDataA = [NSData dataWithContentsOfFile:[path stringByAppendingPathComponent:aS]];
				if (soundDataA) {
					[Util saveSoundForCard:soundDataA
							   forCategory:item
									 forId:Id
								   forWhat:NO];
					[[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:aS] error:nil];
				}
			}
			
			if(imForQ)
			{
				[Util saveImageWithName:imForQ withName:item forId:Id forWhat:YES];
				NSString *remPath = [path stringByAppendingPathComponent:qI];
				[[NSFileManager defaultManager] removeItemAtPath:remPath error:nil];
			}
			
			if(imForA)
			{
				[Util	saveImageWithName:imForA withName:item forId:Id forWhat:NO];
				NSString *remPath = [path stringByAppendingPathComponent:aI];
				[[NSFileManager defaultManager] removeItemAtPath:remPath error:nil];
			}
			
		}
	}
	
	return item;
}

+(NSString*)importBackupWithName:(NSString*)filePath{
	if (!filePath) {
		NSLog(@"Empty filePath while importin backup!");
		return nil;
	}
	
	if (![Util checkFileExist:filePath]) {
		NSLog(@"%@",@"File not exist while importing backup!");
		return nil;
	}
	
	NSMutableDictionary *setDic = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
	
	if (!setDic) {
		NSLog(@"File doesn't encrypted using NSKeyedArchiver!");
		return nil;
	}
	
	NSString *name = [setDic objectForKey:@"name"];
	NSInteger template = kCustomTemplate;
	
	if ([setDic objectForKey:@"template"]) {
		template = [[setDic objectForKey:@"template"] intValue];
	}
	
	
	if (!name) {
		NSLog(@"Can't find set name while importing backup!");
		return nil;
	}
	
	NSMutableDictionary *lastTest = [setDic objectForKey:@"test"];
	NSMutableDictionary *lastStudy = [setDic objectForKey:@"study"];
	NSArray *ignoredCards = [setDic objectForKey:@"ignored"];
	NSArray *rb = [setDic objectForKey:@"rb"];
	NSArray *font = [setDic objectForKey:@"font"];
	NSMutableArray *contentArr = [setDic objectForKey:@"content"];

	NSString *item = [[FDBController sharedDatabase] addCategory:name];
	
	if (!item || !contentArr) {
		return nil;
	}
	
	[[FDBController sharedDatabase] insertTemplate:item withTemplate:template];
	
	NSMutableArray *newIgnored = [NSMutableArray array];
	
	for (NSDictionary *card in contentArr) {
		
		NSInteger prevId = [[card objectForKey:@"id"] intValue];
		NSString *q = [card objectForKey:@"q"];
		NSString *a = [card objectForKey:@"a"];
		NSMutableArray *s = [card objectForKey:@"s"];
		NSData *qIm = [card objectForKey:@"qIm"];
		NSData *aIm = [card objectForKey:@"aIm"];
		NSData *qS = [card objectForKey:@"qS"];
		NSData *aS = [card objectForKey:@"aS"];
		
		NSInteger curId = [[FDBController sharedDatabase] addQuestionToCategory:item question:q answer:a];
		[[FDBController sharedDatabase] updateStatistic:s forCategory:item forIndex:curId];
		
		if (qIm) {
			[Util saveImageWithName:[UIImage imageWithData:qIm] withName:item forId:curId forWhat:YES];
		}
		
		if (aIm) {
			[Util saveImageWithName:[UIImage imageWithData:aIm] withName:item forId:curId forWhat:NO];
		}
		
		if (qS) {
			[Util saveSoundForCard:qS
					   forCategory:item
							 forId:curId
						   forWhat:YES];
		}
		
		if (aS) {
			[Util saveSoundForCard:aS
					   forCategory:item
							 forId:curId
						   forWhat:NO];
		}
		
		if ([ignoredCards containsObject:[NSNumber numberWithInt:prevId]]) {
			[newIgnored addObject:[NSNumber numberWithInt:curId]];
		}
	}
	
	if (newIgnored) 
		[[NSUserDefaults standardUserDefaults] setObject:newIgnored forKey:[NSString stringWithFormat:@"%@_ignored",item]];
	
	if (lastTest) 
		[Util saveLastTestInformation:lastTest forCategory:item];
	
	if (lastStudy) 
		[Util saveLastTestInformation:lastStudy forCategory:item];
	
	if (rb) 
		[[NSUserDefaults standardUserDefaults] setObject:rb forKey:[NSString stringWithFormat:@"%@_Setings",item]];
	
	if (font) {
		[[NSUserDefaults standardUserDefaults] setObject:font forKey:[NSString stringWithFormat:@"%@Font",item]];
	}
	
	return item;
}

+(NSString*)findCSVFileinDir:(NSString*)dir{
	if (!dir) {
		return nil;
	}
	
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dir];
	NSString *file;
	NSSet *suppExt = [FIFCImport supportedCSVExt];
	while (file = [dirEnum nextObject]) {
        NSString *last = [file lastPathComponent];
        
        if (last && [last characterAtIndex:0]=='.') {
            continue;
        }
        
		if ([suppExt containsObject:[file pathExtension]]) {
			return [dir stringByAppendingPathComponent:file];
		}
	}
	
	return nil;
}

#pragma mark private ends

@end
