//
//  FICustomProgressView.h
//  flashCards
//
//  Created by Ruslan on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FICustomProgressView : UIView {
	UIColor *r_borderColor; 
	UIFont *r_font;
	NSArray *r_attributeArr;
	NSInteger r_borderWidth;
	NSInteger r_value;
}

-(id)initWithAttribDic:(CGRect)frame
			 forAttrib:(NSArray*)attrib
		   borderColor:(UIColor*)borderColor
		   borderWidth:(NSInteger)borderWidth
				  font:(UIFont*)font;
		

-(void)changeValue:(NSInteger)newValue;

@end
