//
//  FIImageUtilits.m
//  flashCards
//
//  Created by Ruslan on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIImageUtilits.h"
#import <QuartzCore/QuartzCore.h>

@implementation FIImageUtilits

+(UIImage*)createImageFromScreen:(CGRect)rect forLayer:(CALayer*)layer
{
	CGRect usingRect = rect;
	
	if ([[UIDevice currentDevice].systemVersion intValue]<4.0) {
		UIGraphicsBeginImageContext([layer bounds].size);	
	}else {
		UIGraphicsBeginImageContextWithOptions([layer bounds].size,NO,0.0);
	}
	
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
		([UIScreen mainScreen].scale == 2.0)) {
		// Retina display
		usingRect = CGRectMake(2.0*rect.origin.x,2*rect.origin.y,2*rect.size.width,2*rect.size.height);
	} 
	
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	CGImageRef imageRef = image.CGImage;
	image = nil;
	CGImageRef rectImage = CGImageCreateWithImageInRect(imageRef,usingRect);
	image = [UIImage imageWithCGImage:rectImage];
	CGImageRelease(rectImage);
	
	return image;
} 

+(UIImage*)roundedImage:(UIImage*)image forRadius:(CGFloat)radius
{
	if ([[UIDevice currentDevice].systemVersion intValue]<4) {
		UIGraphicsBeginImageContext(image.size);	
	}else {
		UIGraphicsBeginImageContextWithOptions(image.size,NO,0.0);
	}
	
	CGRect imageRect = CGRectMake(0,0,image.size.width,image.size.height);
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageRect
													cornerRadius:radius];
	[path addClip];
	[path stroke];
	[image drawInRect:imageRect];
	UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return returnImage;
}

@end
