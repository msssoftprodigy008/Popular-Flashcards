/////////////////////////
// This file is part of the karatasi project.
//
// Copyright 2009 Christa Runge, Mathias Kussinger
//
// karatasi is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// karatasi is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with karatasi.  If not, see <http://www.gnu.org/licenses/>.
/////////////////////////

// Utility methods. There is no instance of Util. The methods are static and may be used by all classes.

#import <UIKit/UIKit.h>
#import "RIAlertView.h"

@interface Util : NSObject {

}

// Convert an iPhone date to a string (like dd.mm.yy as defined by the locale short date)
+ (NSString*) shortStringFromDate:(NSDate*) date;

// Convert an iPhone date to a time string (like hh::mm::ss dd.mm.yy)
+ (NSString*) shortTimeStringFromDate:(NSDate*) date;

+ (NSString*) fullTimeStringFromDate:(NSDate*) date;

// Make a string for day differences.
+ (NSString*) makeDayDifferenceString: (NSInteger) dayDifference asText: (BOOL) textFlag;

// Convert a content UTF-8 string to a html compatible string. \n is translated to <br>
+ (NSString*) contentToHTML:(NSString*) content;

// make a (good) guess how many lines a string will use
+ (NSInteger) guessLineCountOfString: (NSString*) string maxCharsPerLine: (NSInteger) count;

// random number in the range of 0 .. n-1
+ (NSInteger) getRandomNumber: (NSInteger) n;

// return random value 0 <= r < 1
+ (double) getRandomValue;

// round a double value to an NSInteger.
+ (NSInteger) roundValue: (double) value;

// Make a backup copy of a file.
+ (NSString *) makeBackupCopyOf: (NSString *) fullFilename;

// Move a backup file to the original one.
+ (void) moveBackupCopy: (NSString *) backupFilename backTo: (NSString *) targetFilename;

// Hex-dump a string to the console
+ (void) hexDump: (const char *) string;

+(BOOL)firstInitFor:(NSInteger)who;
+(void)setInitFor:(NSInteger)who;

+(NSMutableDictionary*)getCoordinate;

//generalize icons
+(UIImage*)generateThumbImageFromImage:(UIImage*)fullImage toSize:(CGSize)size;

+(UIImage*)generateImage:(UIImage*)image forSize:(CGSize)size;

+(NSMutableArray*)getDesign:(NSString*)category;

+(void)saveDesign:(NSMutableArray*)design forCat:(NSString*)category;

//get image with id
+(UIImage*)imageWithId:(NSString*)category forId:(NSInteger)catId forWhat:(BOOL)forQ;

//copy image
+(void)copyImage;

+(void)copyDesign;

//get icon
+(UIImage*)getIcon:(NSString*)category forId:(NSInteger)catId forWhat:(BOOL)forQ; 

+(void)createNeededDir;
+(BOOL)createDir:(NSString*)path;
+(UIColor*)getColorForIndex:(NSInteger)ind;

+(UIImage*)rotateImage:(UIImage*)image forAngle:(int)angle;
+(UIImage*)mirrorMappingToRight:(UIImage*)image; 

+(CGRect)getFrameFromString:(NSString*)Atext forSize:(NSInteger)size;
+(CGRect)resizeToViewSize:(NSString*)Atext forSize:(NSInteger*)size;

+(CGRect)frameFromString:(NSString*)Atext forSize:(NSInteger)size contsrToSize:(CGSize)cSize;
+(CGRect)makeResizeToViewSize:(NSString*)Atext forSize:(NSInteger*)size contsrToSize:(CGSize)cSize;

//save icon for question
+(BOOL)saveIconWithName:(UIImage*)imageToSave withName:(NSString*)imageName ;

+(UIImage *)scale:(UIImage *)image toSize:(CGSize)size;

+(CGSize)imageFitToView:(UIImage*)image toView:(UIView*)view;

//save image for questions
+(BOOL)saveImageWithName:(UIImage*)imageToSave withName:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ;
+(void)removeImageWithName:(NSString*)category withId:(NSInteger)cardID forWhat:(BOOL)forQ;
+(void)removeIconWithName:(NSString*)iconName;
+(void)removeAllIcons:(NSString*)category;
+(void)removeAllImages:(NSString*)category;
+(NSString*)pathForImage:(NSString*)category forID:(NSInteger)cid front:(BOOL)isFront;

//sound for card
+(BOOL)saveSoundForCard:(NSData*)soundToSave forCategory:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ;
+(NSData*)getSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ;
+(BOOL)removeSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ;
+(BOOL)checkSoundForCard:(NSString*)category forId:(NSInteger)cardId forWhat:(BOOL)forQ;
+(BOOL)removeAllSounds:(NSString*)category;

//settings
+(void)saveSetF:(NSString*)category forSide:(BOOL)bothSide forShuffle:(BOOL)shuffle andForNotUse:(NSSet*)notUseCards;
+(NSArray*)getSetF:(NSString*)category;
+(void)copySettings;
+(void)saveLastTestInformation:(NSMutableDictionary*)info forCategory:(NSString*)category;
+(void)saveLastStudyInformation:(NSMutableDictionary*)info forCategory:(NSString*)category;
+(NSMutableDictionary*)getLastTestInformation:(NSString*)category;
+(NSMutableDictionary*)getLastStudyInformation:(NSString*)category;
+(BOOL)isFullVersion;
+(void)buyVersion;
+(void)deleteTestForCategory:(NSString*)category;
+(void)deleteStudyForCategory:(NSString*)category;
+(void)deleteIgnoreCardsForCategory:(NSString*)category;
+(void)removeSettings:(NSString*)category;
+(NSMutableDictionary*)lanCode;
+(BOOL) connectedToNetwork;
+ (UIImage*) createImageWithSize:(CGSize)newSize withImage:(UIImage*)image;

+(UIImage*)imageFromBundle:(NSString*)imageName;

//language
+(void)saveLang:(NSArray*)lang forCategory:(NSString*)category;
+(NSArray*)readLang:(NSString*)category;
+(void)removeLang:(NSString*)category;

+(BOOL)isPhone;
+(void)showMessage:(NSString*)title forMessage:(NSString*)message forButtonTitle:(NSString*)buttonTitle;
+(void)showMessageInCustomAlert:(UIView*)view forTitle:(NSString*)title forMessage:(NSString*)message forButtonTitle:(NSString*)buttonTitle;
+(BOOL)isPortrait:(UIViewController*)controller;
+(BOOL)isPortraitWithOrientation:(UIInterfaceOrientation)orientation;

//working with files
+(BOOL)checkFileExist:(NSString*)path;
+(BOOL)removeFile:(NSString*)path;

//importing default sets
+(void)importDefaultSets:(NSString*)dirName;
+(NSString *) getParamStringFromUrl: (NSString*) url needle:(NSString *) needle;



@end
