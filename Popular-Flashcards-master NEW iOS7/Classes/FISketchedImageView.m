//
//  FISketchedImageView.m
//  flashCards
//
//  Created by Ruslan on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISketchedImageView.h"
#import "Util.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

@interface FISketchedImageView(Private)

-(CGSize)fitToSize:(CGSize)size1 secSize:(CGSize)size2;
-(void)setRects:(CGRect)frame;

@end


@implementation FISketchedImageView

#pragma mark -
#pragma mark main 

-(id)initWithAtrributes:(CGRect)frame attr:(NSDictionary*)attr
{
	if (attr) {
		r_atrributes = [[NSMutableDictionary alloc] initWithDictionary:attr];
	}
	[self setRects:frame];
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		// Initialization code.
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}

-(CGRect)changeAtributes:(NSDictionary*)attributes
{
	if (attributes) {
		
		if (r_atrributes) {
			[r_atrributes release];
		}
		r_atrributes = [[NSMutableDictionary alloc] initWithDictionary:attributes];
		
		[self setRects:self.frame];
		[self setNeedsDisplay];
		
		return r_borderRect;
	}
	
	return CGRectNull;
}

-(CGSize)drawnedImageSize
{
	return r_borderRect.size;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (r_atrributes) {
		UIImage *image = [r_atrributes objectForKey:@"image"];
		UIColor *borderColor = [r_atrributes objectForKey:@"borderColor"];
		UIColor *strokeColor = [r_atrributes objectForKey:@"strokeColor"];
		NSInteger borderWidth = [[r_atrributes objectForKey:@"borderWidth"]intValue];
		NSInteger strokeLineWidth = [[r_atrributes objectForKey:@"strokeWidth"] intValue];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		UIBezierPath *topPath = [UIBezierPath bezierPathWithRoundedRect:r_topRect cornerRadius:r_topRect.size.width/60];
		CGContextSetStrokeColorWithColor(context,strokeColor.CGColor);
		topPath.lineWidth = strokeLineWidth;
		[topPath stroke];
		
		UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:r_borderRect cornerRadius:r_borderRect.size.width/60];
		CGContextSetFillColorWithColor(context,borderColor.CGColor);
		path.lineWidth = borderWidth;
		[path fill];

		UIBezierPath *botPath1 = [UIBezierPath bezierPathWithRoundedRect:r_botRect cornerRadius:r_botRect.size.width/60];
		CGContextSetStrokeColorWithColor(context,borderColor.CGColor);
		botPath1.lineWidth = strokeLineWidth;
		[botPath1 addClip];
		[botPath1 stroke];
        
		[image drawInRect:r_drrect];
		
		UIBezierPath *botPath2 = [UIBezierPath bezierPathWithRoundedRect:r_botRect cornerRadius:r_botRect.size.width/60];
		CGContextSetStrokeColorWithColor(context,borderColor.CGColor);
		botPath2.lineWidth = strokeLineWidth;
		[botPath2 addClip];
		[botPath2 stroke];
		
		
	}
	
}


- (void)dealloc {
	
	if (r_atrributes) {
		[r_atrributes release];
	}
	
    [super dealloc];
}



#pragma mark main ends

#pragma mark -
#pragma private

-(CGSize)fitToSize:(CGSize)size1 secSize:(CGSize)size2
{
	if (size1.width>size2.width && size1.height>size2.height) {
		return size2;
	}else {
		CGFloat max = size2.width-size1.width>size2.height-size1.height ? size1.width/size2.width:size1.height/size2.height;
		return CGSizeMake(size2.width*max,size2.height*max);
	}

}

-(void)setRects:(CGRect)frame
{
	if (r_atrributes) {
		UIImage *image = [r_atrributes objectForKey:@"image"];
		NSInteger borderWidth = [[r_atrributes objectForKey:@"borderWidth"] intValue];
		NSInteger strokeWidth = [[r_atrributes objectForKey:@"strokeWidth"] intValue];
		CGSize drSize;
		CGRect viewRect = CGRectMake(borderWidth+2*strokeWidth,
									 borderWidth+2*strokeWidth,
									 frame.size.width-2*borderWidth-4*strokeWidth,
									 frame.size.height-2*borderWidth-4*strokeWidth);
		//for width
		drSize = [self fitToSize:viewRect.size	secSize:image.size];
		//for height
		drSize = [self fitToSize:viewRect.size secSize:drSize];

		r_drrect = CGRectMake(viewRect.origin.x+viewRect.size.width/2.0-drSize.width/2.0,
							  viewRect.origin.y+viewRect.size.height/2.0-drSize.height/2.0,
							  drSize.width,
							  drSize.height);
        
        r_borderRect = CGRectMake(r_drrect.origin.x-3.0*borderWidth/4.0-strokeWidth,
								  r_drrect.origin.y-3.0*borderWidth/4.0-strokeWidth,
								  r_drrect.size.width+3.0*borderWidth/2.0+2.0*strokeWidth,
								  r_drrect.size.height+3.0*borderWidth/2.0+2.0*strokeWidth);
		r_botRect = CGRectMake(r_drrect.origin.x-strokeWidth/2.0,
							   r_drrect.origin.y-strokeWidth/2.0,
							   r_drrect.size.width+strokeWidth,r_drrect.size.height+strokeWidth);
		r_topRect = CGRectMake(r_drrect.origin.x-borderWidth-strokeWidth,
							   r_drrect.origin.y-borderWidth-strokeWidth,
							   r_drrect.size.width+2.0*borderWidth+2.0*strokeWidth,
							   r_drrect.size.height+2.0*borderWidth+2.0*strokeWidth);
	
	}else {
		r_drrect = CGRectNull;
		r_borderRect = CGRectNull;
	}

}

#pragma mark private ends


@end
