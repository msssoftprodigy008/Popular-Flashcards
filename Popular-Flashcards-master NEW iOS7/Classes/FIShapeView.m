//
//  FIShapeView.m
//  flashCards
//
//  Created by Ruslan on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIShapeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FIShapeView

-(id)initWithTriangle:(CGRect)frame
			  b_color:(UIColor*)b_color
			  f_color:(UIColor*)fillColor
			  s_color:(UIColor*)shadowColor
shadow_offset:(CGSize)shadowOffset	
boundWidth:(NSInteger)b_width;
{
	if (b_color) {
		r_boundsColor = [[UIColor alloc] initWithCGColor:b_color.CGColor];
	}else {
		r_boundsColor = [[UIColor alloc] initWithCGColor:[UIColor blackColor].CGColor];
	}
	
	if (fillColor) {
		r_fillColor = [[UIColor alloc] initWithCGColor:fillColor.CGColor];
	}else {
		r_fillColor = [[UIColor alloc] initWithCGColor:[UIColor redColor].CGColor];
	}
	
	if (shadowColor) {
		r_shadowColor = [[UIColor alloc] initWithCGColor:shadowColor.CGColor];
	}else {
		r_shadowColor = [[UIColor alloc] initWithCGColor:[UIColor blackColor].CGColor];
	}

	
	r_shadowOffset = shadowOffset;
	r_boundWidth = b_width;
	r_shapeType = FIShapeTypeTriangle;
	
	return [self initWithFrame:frame];
	

}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        // Initialization code.
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (r_shapeType == FIShapeTypeTriangle) {
		UIBezierPath *path = [UIBezierPath bezierPath];
		[path moveToPoint:CGPointMake(self.frame.size.width/2.0,self.frame.size.height)];
		[path addLineToPoint:CGPointMake(0,0)];
		[path addLineToPoint:CGPointMake(self.frame.size.width,0)];
		[path addLineToPoint:CGPointMake(self.frame.size.width/2.0,self.frame.size.height)];

		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context,r_fillColor.CGColor);
		
		if (r_shadowOffset.width>=0) {
			CGContextSetShadowWithColor(context,r_shadowOffset,1.0,r_shadowColor.CGColor);
		}
		path.lineCapStyle = kCGLineCapRound;
		path.lineJoinStyle = kCGLineJoinRound;
		[path fill];
		if (r_boundWidth>0) {
			path.lineWidth = r_boundWidth;
			CGContextSetStrokeColorWithColor(context,r_boundsColor.CGColor);
			[path stroke];
		}
		

	}
	
	
}


- (void)dealloc {
	
	if(r_boundsColor){
		[r_boundsColor release];
	}
	if (r_shadowColor) {
		[r_shadowColor release];
	}
	if (r_fillColor) {
		[r_fillColor release];
	}
	
	
    [super dealloc];
}


@end
