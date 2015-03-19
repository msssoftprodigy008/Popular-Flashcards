//
//  FITestImport.m
//  flashCards
//
//  Created by Ruslan on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FITestImport.h"
#import "Util.h"
#import "FIFCImport.h"
#import "FDBController.h"

@implementation FITestImport

+(BOOL)testCSVorAnki:(FIImportTest)testType{
	
	if (testType == FIImportTestCSV) {
		NSLog(@"%@",@"Testing import CSV [BEGAN]");
	}else {
		NSLog(@"%@",@"Testing import Anki [BEGAN]");
	}

	NSString *tPath;
	if (testType == FIImportTestCSV) {
		tPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TestImport/CSV"];
	}else {
		tPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TestImport/Anki"];
	}

	
	if (!tPath || ![Util checkFileExist:tPath]) {
		
		if (testType == FIImportTestCSV){ 
			NSLog(@"%@",@"Can't find CSV folder!");
			if (tPath) {
				NSLog(@"CSV Path: %@",tPath);
			}
		}else {
			NSLog(@"%@",@"Can't find Anki folder!");
			if (tPath) {
				NSLog(@"Anki Path: %@",tPath);
			}
		}

		
		NSLog(@"%@",@"[FAILED]");
		return NO;
	}
	
	NSDirectoryEnumerator *tDirEnum = [[NSFileManager defaultManager] enumeratorAtPath:tPath];
	NSString *file;
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	
	while (file = [tDirEnum nextObject]) {
		NSLog(@"Copying %@",file);
		NSString *source = [tPath stringByAppendingPathComponent:file];
		NSString *target = [documents stringByAppendingPathComponent:file];
		NSError *error = nil;
		if (![[NSFileManager defaultManager] copyItemAtPath:source
													 toPath:target
													  error:&error])
		{
			if (error) {
				NSLog(@"%@",[error localizedDescription]);
			}
			NSLog(@"Copy %@ failed",file);
			continue;
		}	
	}
	
	NSString *groupId;
	if (testType == FIImportTestCSV){ 
		groupId	= [[FDBController sharedDatabase] addGroup:@"TestCSV"];
	}else {
		groupId	= [[FDBController sharedDatabase] addGroup:@"TestAnki"];
	}

	if (!groupId) {
		if (testType == FIImportTestCSV){
			NSLog(@"%@",@"Can't create TestCSV Group while testing csv!");
		}else {
			NSLog(@"%@",@"Can't create TestAnki Group while testing anki!");
		}

		NSLog(@"%@",@"[FAILED]");
		return NO;
	}
	
	while (file = [tDirEnum nextObject]) {
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:[tPath stringByAppendingPathComponent:file]
											 isDirectory:&isDirectory];
		if (isDirectory) {
			NSLog(@"File %@ is directory and missed",file);
			continue;
		}
		
		if (testType == FIImportTestCSV){
			if (![[FIFCImport supportedExtensions] containsObject:[file pathExtension]])
				continue;
		}else {
			if (![[file pathExtension] isEqualToString:@"anki"]) {
				continue;
			}
		}

		
		if ([[file stringByDeletingLastPathComponent] isEqualToString:@""]) {
			NSLog(@"Trying to import %@",file);
			NSString *target = [documents stringByAppendingPathComponent:file];
			NSString *item = [NSString stringWithString:[FIFCImport importFCFileWithPath:target]];
			
			if (item) {
				[[FDBController sharedDatabase] insertCategory:item
													   toGroup:groupId];
				[[FDBController sharedDatabase] insertTemplate:item
												  withTemplate:kCustomTemplate];
			}else {
				NSLog(@"Import of %@ failed. Item is nil",file);
				NSLog(@"%@",@"[FAILED]");
				continue;
			}
			NSLog(@"File %@ successfully imported.",file);
			NSLog(@"%@",@"[COMPLETE]");
		}else {
			NSLog(@"File %@ missed.",file);
		}
		
	}
	if (testType == FIImportTestCSV){
		NSLog(@"%@",@"Testing import CSV [COMPLETE]");
	}else {
		NSLog(@"%@",@"Testing import Anki [COMPLETE]");
	}

	
	return YES;
}

+(BOOL)testAll{
	
	[self testCSVorAnki:FIImportTestCSV];
	[self testCSVorAnki:FIImportTestAnki];

	NSLog(@"%@",@"Testing import... [BEGAN]");
	
	NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TestImport"];
	
	if (!bundlePath || ![Util checkFileExist:bundlePath]) {
		NSLog(@"%@",@"Can't find TestImport folder!");
		
		if (bundlePath) {
			NSLog(@"Bundle Path: %@",bundlePath);
		}
		
		NSLog(@"%@",@"[FAILED]");
		return NO;
	}
	
	NSDirectoryEnumerator *testDirEnum = [[NSFileManager defaultManager] enumeratorAtPath:bundlePath];
	
	NSString *file;
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	
	NSString *groupId = [[FDBController sharedDatabase] addGroup:@"TestImport"];
	if (!groupId) {
		NSLog(@"%@",@"Can't create TestImport Group while testing import!");
		NSLog(@"%@",@"[FAILED]");
		return NO;
	}
	
	while (file = [testDirEnum nextObject]) {
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:[bundlePath stringByAppendingPathComponent:file]
											 isDirectory:&isDirectory];
		if (isDirectory) {
			NSLog(@"File %@ is directory and missed",file);
			continue;
		}
		
		if ([[file stringByDeletingLastPathComponent] isEqualToString:@""]) {
			NSLog(@"Trying to import %@",file);
			NSString *source = [bundlePath stringByAppendingPathComponent:file];
			NSString *target = [documents stringByAppendingPathComponent:file];
			NSError *error = nil;
			if (![[NSFileManager defaultManager] copyItemAtPath:source
													toPath:target
													 error:&error])
			{
				if (error) {
					NSLog(@"%@",[error localizedDescription]);
				}
				NSLog(@"Import of %@ failed",file);
				continue;
			}
			NSString *item = [NSString stringWithString:[FIFCImport importFCFileWithPath:target]];
			
			if (item) {
				[[FDBController sharedDatabase] insertCategory:item
													   toGroup:groupId];
				[[FDBController sharedDatabase] insertTemplate:item
												  withTemplate:kCustomTemplate];
			}else {
				NSLog(@"Import of %@ failed. Item is nil",file);
				NSLog(@"%@",@"[FAILED]");
				continue;
			}
			NSLog(@"File %@ successfully imported.",file);
			NSLog(@"%@",@"[COMPLETE]");
		}else {
			NSLog(@"File %@ missed.",file);
		}

	}
	
	NSLog(@"%@",@"Testing import... [COMPLETE]");
	
	return YES;
	
}

@end
