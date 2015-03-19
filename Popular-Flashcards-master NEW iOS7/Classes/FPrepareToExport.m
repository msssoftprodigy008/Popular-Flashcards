//
//  FPrepareToExport.m
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPrepareToExport.h"
#import "FCSVgen.h"
#import "FDBController.h"
#import "ZipArchive/ZipArchive.h"

@interface FPrepareToExport(Private)

+(NSString*)pathForTmpFile;
+(NSString*)pathImages:(NSString*)category;
+(NSString*)pathForSounds:(NSString*)category;

@end


@implementation FPrepareToExport

+(BOOL)makeZipFromCategoryAtPath:(NSString*)path forResultsPath:(NSString*)resPath fromCategory:(NSString*)category
{
	if (!path || !category) {
		return FALSE;
	}

	NSString *pathToCSV = [self pathForTmpFile];
	
	if(![FCSVgen createCSVFileAtPathFromCategory:pathToCSV forCategory:category]){
		return FALSE;
	}
	
	ZipArchive *zipArch = [[ZipArchive alloc] init];
	
	if (![zipArch CreateZipFile2:path])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCSV])
			[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
		[zipArch release];
		return FALSE;
	}
	
	if(![zipArch addFileToZip:pathToCSV newname:[NSString stringWithFormat:@"%@.txt",[[FDBController sharedDatabase] nameForCategory:category]]])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCSV])
			[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
		[zipArch release];
		return FALSE;
	}
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCSV])
		[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
	
	NSString *pathForIm = [self pathImages:category];
	
	if (!pathForIm) {
		[zipArch release];
		return FALSE;
	}
	
	NSDirectoryEnumerator *enumerate = [[NSFileManager defaultManager] enumeratorAtPath:pathForIm];
	NSString *fileName;
	while (fileName=[enumerate nextObject]) {
		NSString *pIm = [pathForIm stringByAppendingPathComponent:fileName];
		if (![zipArch addFileToZip:pIm newname:fileName]) {
			[zipArch release];
			return FALSE;
		}
	}
	
	NSString *pathForSounds = [self pathForSounds:category];
	
	if (!pathForSounds) {
		[zipArch release];
		return FALSE;
	}
	
	enumerate = [[NSFileManager defaultManager] enumeratorAtPath:pathForSounds];
	while (fileName=[enumerate nextObject]) {
		NSString *sound = [pathForSounds stringByAppendingPathComponent:fileName];
		if (![zipArch addFileToZip:sound newname:fileName]) {
			[zipArch release];
			return FALSE;
		}
	}
	
	if (resPath) {
		if (![zipArch addFileToZip:resPath newname:@"results.txt"]) {
			[zipArch release];
			return FALSE;
		}
		
		[[NSFileManager defaultManager] removeItemAtPath:resPath error:nil];
	}
	
	if(![zipArch CloseZipFile2])
	{
		[zipArch release];
		return FALSE;
	}
	
	[zipArch release];
	return TRUE;
	
}

+(BOOL)makeZipFromCategoryAtPathAsAnki:(NSString*)path fromCategory:(NSString*)category
{
	if (!path || !category) {
		return FALSE;
	}
	
	NSString *pathToCSV = [self pathForTmpFile];
	
	if(![FCSVgen createCSVFileAtPathFromCategoryAsAnki:pathToCSV forCategory:category]){
		return FALSE;
	}
	
	ZipArchive *zipArch = [[ZipArchive alloc] init];
	
	if (![zipArch CreateZipFile2:path])
	{
		[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
		[zipArch release];
		return FALSE;
	}
	
	if(![zipArch addFileToZip:pathToCSV newname:[NSString stringWithFormat:@"%@.txt",[[FDBController sharedDatabase] nameForCategory:category]]])
	{
		[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
		[zipArch release];
		return FALSE;
	}
	
	[[NSFileManager defaultManager] removeItemAtPath:pathToCSV error:nil];
	
	NSString *pathForIm = [self pathImages:category];
	
	if (!pathForIm) {
		[zipArch release];
		return FALSE;
	}
	
	NSDirectoryEnumerator *enumerate = [[NSFileManager defaultManager] enumeratorAtPath:pathForIm];
	NSString *fileName;
	while (fileName=[enumerate nextObject]) {
		NSString *pIm = [pathForIm stringByAppendingPathComponent:fileName];
				
		if (![zipArch addFileToZip:pIm newname:[NSString stringWithFormat:@"%@.media/%@",[[FDBController sharedDatabase] nameForCategory:category],fileName]]) {
			[zipArch release];
			return FALSE;
		}
	}
	
	NSString *pathForSounds = [self pathForSounds:category];
	
	if (!pathForSounds) {
		[zipArch release];
		return FALSE;
	}
	
	enumerate = [[NSFileManager defaultManager] enumeratorAtPath:pathForSounds];
	while (fileName=[enumerate nextObject]) {
		NSString *sound = [pathForSounds stringByAppendingPathComponent:fileName];
		if (![zipArch addFileToZip:sound newname:[NSString stringWithFormat:@"%@.media/%@",[[FDBController sharedDatabase] nameForCategory:category],fileName]]) {
			[zipArch release];
			return FALSE;
		}
	}
	
	if(![zipArch CloseZipFile2])
	{
		[zipArch release];
		return FALSE;
	}
	
	[zipArch release];
	return TRUE;
}

+(BOOL)makeZipFromFileAtPath:(NSString*)resource forPath:(NSString*)path forNewPath:(NSString*)newFile
{
	if (!path || !newFile || !resource) {
		return FALSE;
	}
	
	ZipArchive *zipArch = [[ZipArchive alloc] init];
	
	if (![zipArch CreateZipFile2:path])
	{
		[zipArch release];
		return FALSE;
	}
	
	if(![zipArch addFileToZip:resource newname:newFile])
	{
		[zipArch release];
		return FALSE;
	}
	
	[zipArch release];
	return YES;
}

+(NSString*)pathForTmpFile
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	NSString *pathToCSV = [documents stringByAppendingPathComponent:@"_csvTemp"];
	return pathToCSV;
}

+(NSString*)pathImages:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	newDir = [newDir stringByAppendingPathComponent:category];
	return newDir;
}

+(NSString*)pathForSounds:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	newDir = [newDir stringByAppendingPathComponent:category];
	return newDir;
}

@end
