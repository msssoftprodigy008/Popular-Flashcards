//
//  FIShapeView.h
//  flashCards
//
//  Created by Ruslan on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
	FIShapeTypeTriangle
}FIShapeType;

@interface FIShapeView : UIView {
	UIColor *r_boundsColor;
	UIColor *r_fillColor;
	UIColor *r_shadowColor;
	CGSize r_shadowOffset;
	NSInteger r_boundWidth;
	FIShapeType r_shapeType;
}

-(id)initWithTriangle:(CGRect)frame
			  b_color:(UIColor*)b_color
			  f_color:(UIColor*)fillColor
			  s_color:(UIColor*)shadowColor
		shadow_offset:(CGSize)shadowOffset	
			boundWidth:(NSInteger)b_width;

@end
