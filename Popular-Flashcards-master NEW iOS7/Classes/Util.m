#import "Util.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import <QuartzCore/QuartzCore.h>
#import "FIFCImport.h"
#import "FRootConstants.h"
#import "FDBController.h"
#include <netinet/in.h> 
#import "Constants.h"
#import "stdlib.h"




@interface Util(Private)

+(UIImage*)searchIconWithName:(NSString*)name;
+(void)copyIcons;

@end

static NSMutableDictionary *lan = nil;

@implementation Util
    
// Convert an iPhone date to a string (like dd.mm.yy as defined by the locale short date)
+ (NSString*) shortStringFromDate:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

// Convert an iPhone date to a time string (like hh::mm::ss dd.mm.yy)
+ (NSString*) shortTimeStringFromDate:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    return [dateFormatter stringFromDate:date];
}

+ (NSString*) fullTimeStringFromDate:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate:date];
}

/** Make a string for day differences.
 * \param dayDifference the time difference in days
 * \param textFlag if YES represent -1, 0 and +1 as text
 * \return string representation
 */
+ (NSString*) makeDayDifferenceString: (NSInteger) dayDifference asText: (BOOL) textFlag {
    NSString *retVal;
    if (dayDifference==0 && textFlag) {
        retVal = [NSString stringWithFormat:@"%@",NSLocalizedString(@"today",@"day difference")];
    } else if (dayDifference==-1 && textFlag) {
        retVal = [NSString stringWithFormat:@"%@",NSLocalizedString(@"yesterday",@"day difference")];
    } else if (dayDifference==1 && textFlag) {
        retVal = [NSString stringWithFormat:@"%@",NSLocalizedString(@"tomorrow",@"day difference")];
    } else if (dayDifference==1 || dayDifference==-1) {
        retVal = [NSString stringWithFormat:@"%d %@",dayDifference,NSLocalizedString(@"day",@"day difference")];
    } else {
        retVal = [NSString stringWithFormat:@"%d %@",dayDifference,NSLocalizedString(@"days",@"day difference")];
    }
    return retVal;
}

// Convert a content UTF-8 string to a html compatible string. \n is translated to <br>
+ (NSString*) contentToHTML:(NSString*) content {
    
    NSInteger nlPos = 0;
    NSInteger contentLength = [content length];
    NSString *outStr = [[[NSString alloc] init] autorelease];
    NSString *trStr = nil;
    
    do {
        NSRange pos = [content rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] 
                                               options: NSLiteralSearch range: NSMakeRange(nlPos,contentLength-nlPos)];
        if(pos.location==NSNotFound) {
            
            trStr = [content substringWithRange:NSMakeRange(nlPos,contentLength-nlPos)];
            trStr = [trStr stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
            trStr = [trStr stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
            trStr = [trStr stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
            outStr = [outStr stringByAppendingString: trStr];
            break;
        }
        trStr = [content substringWithRange:NSMakeRange(nlPos,pos.location-nlPos)];
        trStr = [trStr stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        trStr = [trStr stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        trStr = [trStr stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        outStr = [outStr stringByAppendingString: trStr];
        outStr = [outStr stringByAppendingString: @"<br>"];
        nlPos = pos.location+1;
    } while(YES);
    return outStr;
}

/** Guess the number of lines to display a string, according to the following algorithm:
 *  - take at least one line
 *  - break line after count characters, or at a new-line character.
 *  parameters:
 *  string = the string to be displayed
 *  count = number of characters per line
 */
+ (NSInteger) guessLineCountOfString: (NSString*) string maxCharsPerLine: (NSInteger) count {
    NSInteger xCount = 0;
    NSInteger yCount = 0;
    for(NSInteger n=0;n<[string length];n++) {
        UniChar c = [string characterAtIndex:n];
        if(c==0x000A || c==0x2028 || c==0x2029) {  // new line
            yCount++;
            xCount =0;
            continue;
        }
        xCount++;
        if(xCount>count) {  // long line
            yCount++;
            xCount =1;
            continue;
        }
    }
    if(xCount>0 || yCount==0) yCount++;    // last non-empty line is another line
    return yCount;
}

/** random number in the range of 0 .. n-1 
 * @param n defines the range for the random number
 * @return the requested random number.
 */
+ (NSInteger) getRandomNumber: (NSInteger) n {
    long r = random();
#ifdef DEV_VERSION
//    NSLog(@"Random number %lx, %x", r,  (NSInteger) (r % n));
#endif
    return (NSInteger) (r % n);
}

/** random value 0 <= r < 1
 * @return the random value
 */
+ (double) getRandomValue {
    return (double) rand() / (double) RAND_MAX;
}

/** round a double value to an NSInteger.
 * It is rounded up or down, with a probabiltity dependant on
 * how close it was to the next lower / resp. higher integer value.
 * 
 */
+ (NSInteger) roundValue: (double) value {
    double r = [self getRandomValue];
    NSInteger floor = (NSInteger) value;    // round down
    if (r >= value - (double) floor) {
        // round down if its close to the next-lower integer
#ifdef DEV_VERSION
        NSLog(@"roundValue: %lf rounded down to %d", value, floor);
#endif
        return floor;
    } else {
        // round up
#ifdef DEV_VERSION
        NSLog(@"roundValue: %lf rounded up to %d", value, floor +1);
#endif
        return floor +1;
    }
}

/** Make a backup copy of a file.
 * All backup copies may have the same filename. If a backup file already
 * exists it gets deleted.
 * @param fullFilename file name with path
 * @return file name (with path) of the backup copy, or nil if fails
 */
+ (NSString *) makeBackupCopyOf: (NSString *) fullFilename {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *newFilename = [fullFilename stringByAppendingString:@"~"];
    if([fileMgr fileExistsAtPath:newFilename])
        [fileMgr removeItemAtPath:newFilename error:nil];
    if(![fileMgr copyItemAtPath:fullFilename toPath:newFilename error:nil]) {
        NSLog(@"copying from %@ to %@ failed",fullFilename,newFilename);
        return nil;
    }
    return newFilename;
}

/** Move a backup file to the original one.
 * @param backupFilename name of the backup file
 * @param targetFilename name of the original file
 */
+ (void) moveBackupCopy: (NSString *) backupFilename backTo: (NSString *) targetFilename {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    [fileMgr removeItemAtPath:targetFilename error:nil];
    if(![fileMgr moveItemAtPath:backupFilename toPath:targetFilename error:nil])
        NSLog(@"copying from %@ to %@ failed",backupFilename,targetFilename);
}

/** construct a hex-dump representation for an array of bytes.
 * @param bytes the array of bytes
 * @param len the length of the array
 * @return the hex-dump string
 */
+ (NSString *) hexFromBytes: (const unsigned char *) bytes withLen: (int) len {
    NSString * string = [NSString string];
    for (int i = 0; i < len; i++) {
        string = [string stringByAppendingFormat: @"%02X ", bytes[i]];
    }
    return string;
}

// Hex-dump a string to the console
+ (void) hexDump: (const char *) string {
    int len = strlen(string);
    int offset = 0;
    while (len > 0) {
        if (len > 16) {
            NSLog(@"%@", [Util hexFromBytes: (const unsigned char *) (string + offset) withLen: 16]);
            len -= 16;
            offset += 16;
        } else {
            NSLog(@"%@", [Util hexFromBytes: (const unsigned char *) (string + offset) withLen: len]);
            len -= len;
            offset += len;
        }
    }
}

+(UIImage*)generateImage:(UIImage*)image forSize:(CGSize)size
{
	if (!image) {
		return nil;
	}
	
	CGSize imageSize = image.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	BOOL isSizeChange = NO;
	
	while (width>size.width || height>size.height) {
		width -= imageSize.width*0.1; 
		height -= imageSize.height*0.1;
		isSizeChange = YES;
	}
	
	UIImage *resultImage;
	
	if (!isSizeChange) {
		resultImage = [[UIImage alloc] initWithCGImage:image.CGImage];
	}
	else {
		resultImage = [[UIImage alloc] initWithCGImage:[Util generateThumbImageFromImage:image toSize:CGSizeMake(width,height)].CGImage];
	}

	return resultImage;
	
}

+(UIImage*)generateThumbImageFromImage:(UIImage*)fullImage toSize:(CGSize)size
{
		CGImageRef defaultImage1 = [fullImage CGImage];
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef mainViewContentContext = CGBitmapContextCreate (nil, size.width,size.height, 8, 0, colorSpace, (kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
		CGColorSpaceRelease(colorSpace);
		CGFloat width = CGImageGetWidth(defaultImage1);
		CGFloat height = CGImageGetHeight(defaultImage1);
		CGRect imageRect;
		if (width>height) {
				imageRect = CGRectMake(-(float)(((float)(width*size.width)/(float)(height))-size.height)/2.0f, 0.0f, (float)(width*size.width)/(float)(height),size.height);
		} else {
				imageRect = CGRectMake(0.0f, -(float)(((float)(height*size.height)/(float)(width))-size.width)/2.0f, size.width, (float)(height*size.height)/(float)(width));
		}
		CGContextDrawImage(mainViewContentContext, imageRect, defaultImage1);
		CGContextBeginPath(mainViewContentContext);
		CGContextAddRect(mainViewContentContext, imageRect);
		CGContextClosePath(mainViewContentContext);
		CGContextSetStrokeColorWithColor(mainViewContentContext, [[UIColor whiteColor] CGColor]);
		CGContextSetLineWidth(mainViewContentContext, 2.0f);
		CGContextDrawPath(mainViewContentContext, kCGPathStroke);
		CGImageRef resultImage = CGBitmapContextCreateImage(mainViewContentContext);
		CGContextRelease(mainViewContentContext);
		UIImage *tmpImage = [UIImage imageWithCGImage:resultImage];
		CGImageRelease(resultImage);
		return tmpImage;
}

+(UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return scaledImage;
}

+(UIColor*)getColorForIndex:(NSInteger)ind
{
	NSArray *colors = [NSArray arrayWithObjects:[UIColor blackColor],[UIColor darkGrayColor],[UIColor lightGrayColor],[UIColor whiteColor],
					   [UIColor grayColor],[UIColor greenColor],[UIColor redColor],[UIColor blueColor],
					   [UIColor cyanColor],[UIColor yellowColor],[UIColor magentaColor],[UIColor orangeColor],
					   [UIColor purpleColor],[UIColor greenColor],[UIColor clearColor],nil];
	if(ind<0 || ind>=15)
		return nil;
	return [colors objectAtIndex:ind];
}

+(NSMutableArray*)getDesign:(NSString*)category
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	NSString *designName = [NSString stringWithFormat:@"%@.des",category];
	NSString *designPath = [documents stringByAppendingPathComponent:@".Design"];
	designPath = [designPath stringByAppendingPathComponent:designName];
	NSData *dataDes = [NSData dataWithContentsOfFile:designPath];
	NSMutableArray *arr;
	if(dataDes)
		arr = [NSKeyedUnarchiver unarchiveObjectWithData:dataDes];
	else
	{
		NSString *docDes = [documents stringByAppendingPathComponent:@".Design"];
		NSString *pathToDefDes = [docDes stringByAppendingPathComponent:@"_tmpFlashDes.des"];
		arr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathToDefDes];
	}
	return arr;
}

+(void)saveDesign:(NSMutableArray*)design forCat:(NSString*)category
{
	if(!design || !category)
		return;
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [path objectAtIndex:0];
	NSString *designName = [NSString stringWithFormat:@"%@.des",category];
	NSString *designPath = [documents stringByAppendingPathComponent:@".Design"];
	designPath = [designPath stringByAppendingPathComponent:designName];
	BOOL succes = [[NSFileManager defaultManager] fileExistsAtPath:designPath];
	if(succes)
		[[NSFileManager defaultManager] removeItemAtPath:designPath error:nil];
	[NSKeyedArchiver archiveRootObject:design toFile:designPath];
	return;
}

+(UIImage*)imageWithId:(NSString*)category forId:(NSInteger)catId forWhat:(BOOL)forQ
{
	NSString *imageName;
	if(forQ)
		imageName = [NSString stringWithFormat:@"%d_%@.png",catId,category];
	else
		imageName = [NSString stringWithFormat:@"a%d_%@.png",catId,category];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	newDir = [newDir stringByAppendingPathComponent:category];
	newDir = [newDir stringByAppendingPathComponent:imageName];
	UIImage *image = [UIImage imageWithContentsOfFile:newDir];
	return image;
}

+(NSString*)pathForImage:(NSString*)category forID:(NSInteger)cid front:(BOOL)isFront{
    NSString *imageName;
	if(isFront)
		imageName = [NSString stringWithFormat:@"%d_%@.png",cid,category];
	else
		imageName = [NSString stringWithFormat:@"a%d_%@.png",cid,category];
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	newDir = [newDir stringByAppendingPathComponent:category];
	newDir = [newDir stringByAppendingPathComponent:imageName];
    return newDir;
}

+(UIImage*)getIcon:(NSString*)category forId:(NSInteger)catId forWhat:(BOOL)forQ
{
	NSString *imageName;
	if(forQ)
		imageName = [NSString stringWithFormat:@"%d_%@.png",catId,category];
	else
		imageName = [NSString stringWithFormat:@"a%d_%@.png",catId,category];
	UIImage *curIcon = [self searchIconWithName:imageName];
	if(curIcon)
		return curIcon;
	UIImage *tmpImage = [self imageWithId:category forId:catId forWhat:forQ];
	if(!tmpImage)
		return nil;
	curIcon = [self generateThumbImageFromImage:tmpImage toSize:CGSizeMake(80.0f,94.0f)];
	[self	saveIconWithName:curIcon withName:imageName];
	return curIcon;
}

+(BOOL)saveImageWithName:(UIImage*)imageToSave withName:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	newDir = [newDir stringByAppendingPathComponent:category];
	[self createDir:newDir];
	NSString *cardName;
	
	if(forQ)
		cardName = [NSString stringWithFormat:@"%d_%@.png",cardId,category];
	else
		cardName = [NSString stringWithFormat:@"a%d_%@.png",cardId,category];

	NSString *imagePath = [newDir stringByAppendingPathComponent:cardName];
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:imagePath];
	if(success)
	{
		[[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
	}
	success = [[NSFileManager defaultManager] createFileAtPath:imagePath contents:nil attributes:nil];
	if(!success)
	{
		printf("Some problems with creating file\n");
		return FALSE;
	}
	NSData *dataForImage = UIImagePNGRepresentation(imageToSave);
	return [dataForImage writeToFile:imagePath atomically:YES];
}

+(BOOL)saveIconWithName:(UIImage*)imageToSave withName:(NSString*)imageName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForIcons = [documentsDirectory stringByAppendingPathComponent:@".Icons"];
	dirForIcons = [dirForIcons stringByAppendingPathComponent:imageName];
	NSData *dataForImage = UIImagePNGRepresentation(imageToSave);
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:dirForIcons];
	if(success)
	{
		[[NSFileManager defaultManager] removeItemAtPath:dirForIcons error:nil];
	}
	
	success = [[NSFileManager defaultManager] createFileAtPath:dirForIcons contents:nil attributes:nil];
	if(!success)
	{
		printf("Some problems with creating file\n");
		return FALSE;
	}
	return [dataForImage writeToFile:dirForIcons atomically:YES];
}

+(void)removeImageWithName:(NSString*)category withId:(NSInteger)cardID forWhat:(BOOL)forQ
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	newDir = [newDir stringByAppendingPathComponent:category];
	BOOL isDir = NO;
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:newDir isDirectory:&isDir];
	if(success && isDir)
	{
		NSString *imageName;
		if(forQ)
			imageName = [NSString stringWithFormat:@"%d_%@.png",cardID,category];
		else
			imageName = [NSString stringWithFormat:@"a%d_%@.png",cardID,category];
		[self removeIconWithName:imageName];
		imageName = [newDir stringByAppendingPathComponent:imageName];
		success = [[NSFileManager defaultManager] fileExistsAtPath:imageName];
		if(success)
			[[NSFileManager defaultManager] removeItemAtPath:imageName error:nil];
	}
	return;
}

+(void)removeIconWithName:(NSString*)iconName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForIcons = [documentsDirectory stringByAppendingPathComponent:@".Icons"];
	NSString *pathForIcon = [dirForIcons stringByAppendingPathComponent:iconName];
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:pathForIcon];
	if(success)
		[[NSFileManager defaultManager] removeItemAtPath:pathForIcon error:nil];
	return;
}

+(BOOL)saveSoundForCard:(NSData*)soundToSave forCategory:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	NSString *newSoundDir = [dirForSounds stringByAppendingPathComponent:category];
	[self createDir:newSoundDir];
	NSString *soundName;
	
	if(forQ)
		soundName = [NSString stringWithFormat:@"%d_%@.caf",cardId,category];
	else
		soundName = [NSString stringWithFormat:@"a%d_%@.caf",cardId,category];
	NSString *pathForSound = [newSoundDir stringByAppendingPathComponent:soundName];
	
	if(soundToSave)
	{
	
		BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:pathForSound];
	
		if(success)
			[[NSFileManager defaultManager] removeItemAtPath:pathForSound error:nil];
		success = [soundToSave writeToFile:pathForSound atomically:YES];
		return success;
	}else {
		return NO;
	}

	
	
}

+(NSData*)getSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	dirForSounds = [dirForSounds stringByAppendingPathComponent:category];
	NSString *soundName;
	
	if(forQ)
		soundName = [NSString stringWithFormat:@"%d_%@.caf",cardId,category];
	else
		soundName = [NSString stringWithFormat:@"a%d_%@.caf",cardId,category];
	NSString *pathForSound = [dirForSounds stringByAppendingPathComponent:soundName];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:pathForSound];
	
	if(success)
	{
		NSData *sound = [NSData dataWithContentsOfFile:pathForSound];
		return sound;
	}else {
		return nil;
	}

	
	
}

+(BOOL)checkSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	dirForSounds = [dirForSounds stringByAppendingPathComponent:category];
	NSString *soundName;
	
	if(forQ)
		soundName = [NSString stringWithFormat:@"%d_%@.caf",cardId,category];
	else
		soundName = [NSString stringWithFormat:@"a%d_%@.caf",cardId,category];
	NSString *pathForSound = [dirForSounds stringByAppendingPathComponent:soundName];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:pathForSound];
	
	if(success)
	{
		return YES;
	}else {
		return NO;
	}

}


+(BOOL)removeSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	dirForSounds = [dirForSounds stringByAppendingPathComponent:category];
	NSString *soundName;
	
	if(forQ)
		soundName = [NSString stringWithFormat:@"%d_%@.caf",cardId,category];
	else
		soundName = [NSString stringWithFormat:@"a%d_%@.caf",cardId,category];
	NSString *pathForSound = [dirForSounds stringByAppendingPathComponent:soundName];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:pathForSound];
	
	if(success)
	{
		success = [[NSFileManager defaultManager] removeItemAtPath:pathForSound error:nil];
		return success;
	}else {
		return NO;
	}

}

+(BOOL)removeAllSounds:(NSString*)category
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	dirForSounds = [dirForSounds stringByAppendingPathComponent:category];
	BOOL isDir = NO;
	BOOL isSuc = [[NSFileManager defaultManager] fileExistsAtPath:dirForSounds isDirectory:&isDir];
	if(isSuc && isDir)
	{
	   isSuc = [[NSFileManager defaultManager] removeItemAtPath:dirForSounds error:nil];
		return isSuc;
	}else {
		return NO;
	}

	
}

+(void)removeSettings:(NSString*)category
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Setings",category]];
}

+(UIImage*)rotateImage:(UIImage*)image forAngle:(int)angle
{
	// calculate the size of the rotated view's containing box for our drawing space
	UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,image.size.width,image.size.height)];
	CGAffineTransform t = CGAffineTransformMakeRotation(angle*M_PI/180.0);
	rotatedViewBox.transform = t;
	CGSize rotatedSize = rotatedViewBox.frame.size;
	[rotatedViewBox release];
	
	// Create the bitmap context
	if([[UIDevice currentDevice].systemVersion floatValue]>=4.0){
		UIGraphicsBeginImageContextWithOptions(rotatedSize,NO,image.scale);
	}else {
		UIGraphicsBeginImageContext(rotatedSize);
	}

	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	
	// Move the origin to the middle of the image so we will rotate and scale around the center.
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	
	//   // Rotate the image context
	CGContextRotateCTM(bitmap,angle*M_PI/180.0);
	
	// Now, draw the rotated/scaled image into the context
	CGContextScaleCTM(bitmap, 1.0, -1.0);
	CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
	
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}


+(UIImage*)mirrorMappingToRight:(UIImage*)image
{
	CGImageRef cgimage = image.CGImage;
	CGFloat width = CGImageGetWidth(cgimage);
	CGFloat height = CGImageGetHeight(cgimage);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate (NULL, width, height, 8, 0, colorSpace, (kCGImageAlphaPremultipliedFirst || kCGImageAlphaPremultipliedLast));
	CGColorSpaceRelease(colorSpace);
	CGContextScaleCTM(context, -1, 1);
	CGContextTranslateCTM(context, -width, 0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), cgimage);
	CGImageRef Image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	UIImage *theImage = [UIImage imageWithCGImage:Image];
	CGImageRelease(Image);
	return theImage;
}

+(void)removeAllIcons:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForIcons = [documentsDirectory stringByAppendingPathComponent:@".Icons"];
	BOOL isDir = NO;
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:dirForIcons isDirectory:&isDir];
	if(success && isDir)
		{
			NSDirectoryEnumerator *enumerate = [[NSFileManager defaultManager] enumeratorAtPath:dirForIcons];
			NSString *fileName;
			while (fileName=[enumerate nextObject]) {
				NSArray *strComp = [fileName componentsSeparatedByString:@"_"];
				int size = [strComp count];
				if(size>1)
				{
					NSString *cat = [strComp objectAtIndex:1];
					if([cat isEqualToString:[NSString stringWithFormat:@"%@.png",category]])
						[[NSFileManager defaultManager] removeItemAtPath:[dirForIcons stringByAppendingPathComponent:fileName]
																   error:nil];
				}
			}
		}
}

+(void)removeAllImages:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForImages = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	dirForImages = [dirForImages stringByAppendingPathComponent:category];
	BOOL isDir = NO;
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:dirForImages isDirectory:&isDir];
	if(success && isDir)
		[[NSFileManager defaultManager] removeItemAtPath:dirForImages error:nil];
	
}

+(void)createNeededDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForImages = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	NSString *dirForDatabase = [documentsDirectory stringByAppendingPathComponent:@".Database"];
	NSString *dirForSounds = [documentsDirectory stringByAppendingPathComponent:@".Sounds"];
	[self createDir:dirForDatabase];
	[self createDir:dirForImages];
	[self createDir:dirForSounds];
}

+(void)copySettings
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@".Settings"];
	settingsPath = [settingsPath stringByAppendingPathComponent:@"Settings.plist"];
	BOOL isDirectory;
	BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:settingsPath isDirectory:&isDirectory];
	if(!isExist || isDirectory)
	{
		NSString *atPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
		[[NSFileManager defaultManager] copyItemAtPath:atPath toPath:settingsPath error:nil];
	}
}

+(void)saveLastTestInformation:(NSMutableDictionary*)info forCategory:(NSString*)category
{
	if(!info)
		return;
	
	[[NSUserDefaults standardUserDefaults] setObject:info forKey:[NSString stringWithFormat:@"lastTest%@",category]];
}

+(void)saveLastStudyInformation:(NSMutableDictionary*)info forCategory:(NSString*)category
{
	if(!info)
		return;
	
	[[NSUserDefaults standardUserDefaults] setObject:info forKey:[NSString stringWithFormat:@"lastStudy%@",category]];
}

+(NSMutableDictionary*)getLastTestInformation:(NSString*)category
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lastTest%@",category]];
}

+(NSMutableDictionary*)getLastStudyInformation:(NSString*)category
{
	return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"lastStudy%@",category]];
}

+(void)deleteTestForCategory:(NSString*)category
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastTest%@",category]];
}

+(void)deleteStudyForCategory:(NSString*)category
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastStudy%@",category]];
}

+(void)deleteIgnoreCardsForCategory:(NSString*)category
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_ignored",category]];
}

+(BOOL)firstInitFor:(NSInteger)who
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@".Settings"];
	settingsPath = [settingsPath stringByAppendingPathComponent:@"Settings.plist"];
	NSMutableDictionary *curSettings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	NSInteger curInit = [[curSettings objectForKey:@"TDParametrs"] intValue];
	return	(curInit & who);
}
// NILESH PATEL MAIN FOR FULL VERSION..
+(BOOL)isFullVersion
{
	if([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]){
		return [[[NSUserDefaults standardUserDefaults] objectForKey:@"version"] boolValue];
	}else {
		return NO;
	}

}

+(void)buyVersion
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
											  forKey:@"version"];
}

+(UIImage*)imageFromBundle:(NSString*)imageName{
    if (imageName) {
        NSString *imageExt = [imageName pathExtension];
        NSString *imgName = [imageName stringByDeletingPathExtension];
        return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgName
                                                                                ofType:imageExt]];
        
    }
    
    return nil;
}

+ (UIImage*) createImageWithSize:(CGSize)newSize withImage:(UIImage*)image {
    float w = newSize.width;
    float h = newSize.height;
    CGRect contextRect = CGRectMake(0, 0, w, h);
    
    UIGraphicsBeginImageContext(newSize);
    
	[image drawInRect:contextRect];
	UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return returnImage;
}

+(void)setInitFor:(NSInteger)who
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *settingsPath = [documentsDirectory stringByAppendingPathComponent:@".Settings"];
	settingsPath = [settingsPath stringByAppendingPathComponent:@"Settings.plist"];
	NSMutableDictionary *curSettings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsPath];
	NSInteger curInit = [[curSettings objectForKey:@"TDParametrs"] intValue];
	curInit = curInit | who;
	[curSettings setObject:[NSNumber numberWithInt:curInit] forKey:@"TDParametrs"];
	[curSettings writeToFile:settingsPath atomically:YES];
	return;
}

+(BOOL)createDir:(NSString*)path
{
	NSString *databasePath =[NSString stringWithString:path];
	BOOL isDirectory = NO;
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:databasePath isDirectory:&isDirectory];
	if (!success || !isDirectory)
	{
		NSError *error;
		success = [[NSFileManager defaultManager] createDirectoryAtPath:databasePath
											withIntermediateDirectories:NO
															 attributes:nil error:&error];
		if (!success)
		{
			if(error)
			{
				NSLog(@"%@",[error localizedDescription]);
			}else {
				NSLog(@"%s","Failed to create Directory");
			}
			return FALSE;
		}
		
		return TRUE;
	}
	return FALSE;
}

+(NSMutableDictionary*)lanCode
{
	if (lan) {
		return lan;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"LanCode" ofType:@"txt"];
	FILE* inFile = fopen([path UTF8String], "r");
	lan = [[NSMutableDictionary alloc] init];
	for (int i=0;i<50;i++) 
	{
		char lang[30];
		char code[4];
		fscanf(inFile,"%s",lang);
		fscanf(inFile,"%s",code);
		[lan setObject:[NSString stringWithCString:code encoding:NSUTF8StringEncoding]
				forKey:[NSString stringWithCString:lang encoding:NSUTF8StringEncoding]];
	}
	
	return lan;
}

//language
+(void)saveLang:(NSArray*)lang forCategory:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForLang = [documentsDirectory stringByAppendingPathComponent:@".Language"];
	NSString *filePath = [dirForLang stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lan",category]];
	
	BOOL isFileEx = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if (isFileEx) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}
	[NSKeyedArchiver archiveRootObject:lang toFile:filePath];
	return;
}

+(NSArray*)readLang:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForLang = [documentsDirectory stringByAppendingPathComponent:@".Language"];
	NSString *filePath = [dirForLang stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lan",category]];
	
	BOOL isFileEx = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if (isFileEx) {
		NSArray *returnArray = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
		return returnArray;
	}
	return nil;
}

+(void)removeLang:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForLang = [documentsDirectory stringByAppendingPathComponent:@".Language"];
	NSString *filePath = [dirForLang stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lan",category]];
	
	BOOL isFileEx = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
	
	if (isFileEx) {
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
	}
	return;
}

+(CGSize)imageFitToView:(UIImage*)image toView:(UIView*)view
{
	CGSize imageSize = image.size;
	CGSize viewSz = view.frame.size;
	CGSize retSz;
	
		
	if(viewSz.width>viewSz.height)
	{
		retSz.width = (imageSize.width/imageSize.height)*viewSz.height;
		retSz.height = viewSz.height;
	}
	else {
		retSz.width = viewSz.width;
		retSz.height = (imageSize.height/imageSize.width)*viewSz.width;
		
	}
	
	if(retSz.width>viewSz.width)
		retSz.width = viewSz.width;
	
	if(retSz.height>viewSz.height)
		retSz.height = viewSz.height;
	
	
	return retSz;
	
}

+(BOOL)isPhone
{
	return (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone);
}

+(BOOL)isPortrait:(UIViewController*)controller
{
	return (controller.interfaceOrientation == UIInterfaceOrientationPortrait || controller.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

+(void)showMessage:(NSString*)title forMessage:(NSString*)message forButtonTitle:(NSString*)buttonTitle
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil
										  cancelButtonTitle:buttonTitle
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+(void)showMessageInCustomAlert:(UIView*)view forTitle:(NSString*)title forMessage:(NSString*)message forButtonTitle:(NSString*)buttonTitle{
    RIAlertView *alert = [[RIAlertView alloc] initWithTitle:title
                                                    message:message
                                               buttonTitles:[NSArray arrayWithObject:buttonTitle]];
    [alert showInView:view];
    [alert release];
}

+(BOOL)isPortraitWithOrientation:(UIInterfaceOrientation)orientation
{
	return (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown);
}



#pragma mark -
#pragma mark importing default sets
+(void)importDefaultSets:(NSString*)dirName
{
	BOOL defaultSetsImp = [[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultSetsImp"];
	if(defaultSetsImp){
		return;
	}
	
	NSString *pathToDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dirName];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:pathToDir];
	NSString *file;
	
	NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
	
	while (file = [dirEnum nextObject]) {
		NSString *source = [pathToDir stringByAppendingPathComponent:file];
		BOOL isDir;
		NSLog(@"Analizing %@",file);
		if([[NSFileManager defaultManager] fileExistsAtPath:source isDirectory:&isDir] && isDir)
		{
			NSLog(@"Missed %@",file);
			continue;
		}
		
		NSString *target = [documents stringByAppendingPathComponent:[file lastPathComponent]];
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
		
		NSArray *pathComp = [file pathComponents];
		NSString *grName = [NSString stringWithString:dirName];
		
		NSLog(@"%@",file);
		
		if([pathComp count]>1){
			grName = [pathComp objectAtIndex:[pathComp count]-2];
		}
		
		NSString *grId = [[FDBController sharedDatabase] idForGroupName:grName];
		
		if(!grId){
			grId = [[FDBController sharedDatabase] addGroup:grName];
			if(!grId){
				continue;
			}
		}
		
		NSString *setId = [FIFCImport importFCFileWithPath:target];
		if(setId){
			[[FDBController sharedDatabase] insertCategory:setId toGroup:grId];
			[[FDBController sharedDatabase] insertTemplate:setId withTemplate:kCustomTemplate];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DefaultSetsImp"];
	
}
#pragma mark -

#pragma mark -
#pragma mark working with files

+(BOOL)checkFileExist:(NSString*)path{
	if(!path){
		NSLog(@"%@",@"Empty path while checking file existing!");
		return NO;
	}
	
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(BOOL)removeFile:(NSString*)path{
	if(![self checkFileExist:path]){
		return YES;
	}
	
	NSError *error;
	
	BOOL remove = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
	
	if(!remove && error)
	{
		NSLog(@"%@",[error localizedDescription]);
	}
	
	return remove;
		
}

#pragma mark working with files ends

#pragma mark Private Methods

+(UIImage*)searchIconWithName:(NSString*)name
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForIcons = [documentsDirectory stringByAppendingPathComponent:@".Icons"];
	dirForIcons = [dirForIcons stringByAppendingPathComponent:name];
	UIImage *retImage = [UIImage imageWithContentsOfFile:dirForIcons];
	return retImage;
}

+(void)copyImage
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *newDir = [documentsDirectory stringByAppendingPathComponent:@".flashCardImages"];
	NSString *imagePath = [[NSBundle mainBundle] bundlePath];
	NSString *regionsPath = [imagePath stringByAppendingPathComponent:@"maps"];
	NSString *flagsPath = [imagePath stringByAppendingPathComponent:@"flags"];
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSError *error;
	if(![fileMan copyItemAtPath:regionsPath toPath:[newDir stringByAppendingPathComponent:@"maps"] error:&error])
	{
		NSLog(@"maps not copied.");
	}
	if(![fileMan copyItemAtPath:flagsPath toPath:[newDir stringByAppendingPathComponent:@"flags"] error:nil])
	{
		NSLog(@"flags not copied.");
	}
	[self copyIcons];
	return;
}

+(void)copyIcons
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *dirForIcons = [documentsDirectory stringByAppendingPathComponent:@".Icons"];
	if ([self createDir:dirForIcons]) {
		NSString *imagePath = [[NSBundle mainBundle] bundlePath];
		NSString *regionsPath = [imagePath stringByAppendingPathComponent:@"maps.png"];
		NSString *flagsPath = [imagePath stringByAppendingPathComponent:@"flags.png"];
		NSString *capPath = [imagePath stringByAppendingPathComponent:@"capitals.png"];
		NSString *trivialPath = [imagePath stringByAppendingPathComponent:@"trivial.png"];
		NSFileManager *fileMan = [NSFileManager defaultManager];
		if(![fileMan copyItemAtPath:regionsPath toPath:[dirForIcons stringByAppendingPathComponent:@"maps.png"] error:nil])
		{
			NSLog(@"maps not copied.");
		}
		if(![fileMan copyItemAtPath:flagsPath toPath:[dirForIcons stringByAppendingPathComponent:@"flags.png"] error:nil])
		{
			NSLog(@"flags not copied.");
		}
		if(![fileMan copyItemAtPath:capPath toPath:[dirForIcons stringByAppendingPathComponent:@"capitals.png"] error:nil])
		{
			NSLog(@"maps not copied.");
		}
		if(![fileMan copyItemAtPath:trivialPath toPath:[dirForIcons stringByAppendingPathComponent:@"trivial.png"] error:nil])
		{
			NSLog(@"flags not copied.");
		}
	}
}

+(void)copyDesign
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *desPath = [[NSBundle mainBundle] bundlePath];
	desPath = [desPath stringByAppendingPathComponent:@".Design"];
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSError *error;
	if(![fileMan copyItemAtPath:desPath toPath:[documentsDirectory stringByAppendingPathComponent:@"Design"] error:&error])
	{
		NSLog(@"design not copied.");
		
	}
	return;
	
}

+(NSMutableDictionary*)getCoordinate
{
	NSString *path = [[NSBundle mainBundle] pathForResource:@"C" ofType:@"txt"];
	FILE* inFile = fopen([path UTF8String], "r");
	NSMutableDictionary *dicForRet = [[NSMutableDictionary alloc] init];
	for(int i=1;i<28;i++)
	{
		double size;
		double angle;
		double x;
		double y;
		fscanf(inFile,"%lf",&size);
		fscanf(inFile,"%lf",&angle);
		fscanf(inFile,"%lf",&x);
		fscanf(inFile,"%lf",&y);
		NSArray *arr = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%lf",size],
												[NSString stringWithFormat:@"%lf",angle],
												[NSString stringWithFormat:@"%lf",x],
						[NSString stringWithFormat:@"%lf",y],nil];
		[dicForRet setObject:arr forKey:[NSString stringWithFormat:@"%d",i]];
	}
	return dicForRet;
}

+(CGRect)getFrameFromString:(NSString*)Atext forSize:(NSInteger)size
{
	CGSize s; 
	s.width = kCardViewWidth;
	s.height = MAXFLOAT;
	CGSize Asize = [Atext sizeWithFont:[UIFont boldSystemFontOfSize:size] constrainedToSize:s lineBreakMode:NSLineBreakByWordWrapping];
	CGRect frame;
	
	CGFloat wT = kCardViewWidth-20-Asize.width;
	CGFloat hT = kCardViewHeight-20-Asize.height;
	
	if(wT>0)
		Asize.width+=20; 
	
	if(hT>0)
		Asize.height+=20;
	
	frame.origin.x = kCardViewWidth/2-Asize.width/2;
	frame.origin.y = kCardViewHeight/2 - Asize.height/2;
	frame.size = Asize;
	return frame;
	
}

+(CGRect)resizeToViewSize:(NSString*)Atext forSize:(NSInteger*)size
{
	CGRect frame;
	CGFloat currentSize = 26;
	do{
		frame	= [self getFrameFromString:Atext forSize:currentSize];
		currentSize-=2;
	}while (frame.size.height>kCardViewHeight);
	
	*size = currentSize;
	
	return frame;
}

+(CGRect)frameFromString:(NSString*)Atext forSize:(NSInteger)size contsrToSize:(CGSize)cSize
{
	CGSize Asize;
	/*UIFont *currFont = [UIFont fontWithName:@"Helvetica" size:size];
	NSInteger strNum = size*[Atext length]/cSize.width+1;
	Asize.height = strNum*(currFont.capHeight+1.5*currFont.xHeight);
	Asize.width = cSize.width;*/
	Asize =  [Atext sizeWithFont:[UIFont fontWithName:@"Helvetica" size:size]
			   constrainedToSize:cSize
				   lineBreakMode:NSLineBreakByTruncatingMiddle];
	CGRect frame;
	
	
	frame.origin.x = cSize.width/2-Asize.width/2;
	frame.origin.y = cSize.height/2 - Asize.height/2;
	frame.size = Asize;
	return frame;
}

+(CGRect)makeResizeToViewSize:(NSString*)Atext forSize:(NSInteger*)size contsrToSize:(CGSize)cSize
{
	CGRect frame;
	CGFloat currentSize = 32;
	do{
		if (currentSize<22) {
			break;
		}
		frame	= [self frameFromString:Atext forSize:currentSize contsrToSize:cSize];
		currentSize-=2;
	}while ((frame.size.height>cSize.height) || (frame.size.width>cSize.width));
	
	*size = currentSize-2;
	
	return frame;
}


+(void)saveSetF:(NSString*)category forSide:(BOOL)bothSide forShuffle:(BOOL)shuffle andForNotUse:(NSSet*)notUseCards
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [paths objectAtIndex:0];
	NSString *setPath = [documents stringByAppendingPathComponent:@".CardWork"];
	setPath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.s",category]];
	
	BOOL isSetExist = [[NSFileManager defaultManager] fileExistsAtPath:setPath];
	
	if (isSetExist) {
		[[NSFileManager defaultManager] removeItemAtPath:setPath error:nil];
	}
	
	NSArray *saveArr = [NSArray arrayWithObjects:[NSNumber numberWithBool:bothSide],
						[NSNumber numberWithBool:shuffle],
						notUseCards,nil];
	[NSKeyedArchiver archiveRootObject:saveArr toFile:setPath];
	
}

+(NSArray*)getSetF:(NSString*)category
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [paths objectAtIndex:0];
	NSString *setPath = [documents stringByAppendingPathComponent:@".CardWork"];
	setPath = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.s",category]];
	
	BOOL isSetExist = [[NSFileManager defaultManager] fileExistsAtPath:setPath];
	
	if (isSetExist) {
		NSArray *arrSet = [NSKeyedUnarchiver unarchiveObjectWithFile:setPath];
		return arrSet;
	}
	
	return nil;
}

+ (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

+(NSString *) getParamStringFromUrl: (NSString*) url needle:(NSString *) needle {
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}

@end
