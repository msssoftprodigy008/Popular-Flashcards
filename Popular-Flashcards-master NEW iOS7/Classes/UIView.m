//
//  UIView.m
//  Pasl
//
//  Created by ravil ibragimov on 9/30/09.
//  Copyright 2009 RusLang Solutions. All rights reserved.
//

#import "UIView.h"


@implementation UIView (Utilities)

- (void) setOrigin:(CGPoint)origin {
	[self setFrame:CGRectMake(origin.x, 
							  origin.y, 
							  self.frame.size.width, 
							  self.frame.size.height)];
}

- (void) setOrigin:(CGPoint)origin animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self setOrigin:origin];
	[UIView commitAnimations];
}

- (void) setSize:(CGSize)size {
	[self setFrame:CGRectMake(self.frame.origin.x, 
							  self.frame.origin.y, 
							  size.width, 
							  size.height)];
}

- (void) setSize:(CGSize)size animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self setSize:size];
	[UIView commitAnimations];
}



- (void) addToX:(float) value {
	[self setFrame:CGRectMake(self.frame.origin.x + value, 
							  self.frame.origin.y, 
							  self.frame.size.width, 
							  self.frame.size.height)];
}

- (void) addToX:(float)value animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToX:value];
	[UIView commitAnimations];
}

- (void) addToY:(float) value {
	[self setFrame:CGRectMake(self.frame.origin.x, 
							  self.frame.origin.y + value, 
							  self.frame.size.width, 
							  self.frame.size.height)];
}

- (void) addToY:(float)value animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToY:value];
	[UIView commitAnimations];
}

- (void) addToX:(float)xValue andToY:(float)yValue {
	[self setFrame:CGRectMake(self.frame.origin.x + xValue, 
							  self.frame.origin.y + yValue, 
							  self.frame.size.width, 
							  self.frame.size.height)];
}

- (void) addToX:(float)xValue andToY:(float)yValue animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToX:xValue andToY:yValue];
	[UIView commitAnimations];
}



- (void) addToWidth:(float) value {
	[self setFrame:CGRectMake(self.frame.origin.x, 
							  self.frame.origin.y, 
							  self.frame.size.width + value, 
							  self.frame.size.height)];
}

- (void) addToHeight:(float) value {
	[self setFrame:CGRectMake(self.frame.origin.x, 
							  self.frame.origin.y, 
							  self.frame.size.width, 
							  self.frame.size.height + value)]; 
}

- (void) addToWidth:(float)width andToHeight:(float)height {
	[self setFrame:CGRectMake(self.frame.origin.x,
							  self.frame.origin.y,
							  self.frame.size.width + width,
							  self.frame.size.height + height)];
}

- (void) addToWidth:(float)value animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToWidth:value];
	[UIView commitAnimations];
}

- (void) addToHeight:(float)value animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToHeight:value];
	[UIView commitAnimations];
}

- (void) addToWidth:(float)width andToHeight:(float)height animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self addToWidth:width andToHeight:height];
	[UIView commitAnimations];
}



- (float) yFromCentre {
	return (self.frame.origin.y + self.frame.size.height/2);
}

- (float) yFromBottom {
	return (self.frame.origin.y + self.frame.size.height);
}

- (float) xFromCentre {
	return (self.frame.origin.x + self.frame.size.width/2);
}

- (float) xFromRight {
	return (self.frame.origin.x + self.frame.size.width);
}


- (void) setX:(float)x {
	[self setFrame:CGRectMake(x,
							  self.frame.origin.y,
							  self.frame.size.width,
							  self.frame.size.height)];
}

- (void) setX:(float)x animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self setX:x];
	[UIView commitAnimations];
}

- (void) setY:(float)y {
	[self setFrame:CGRectMake(self.frame.origin.x,
							  y,
							  self.frame.size.width,
							  self.frame.size.height)];
}

- (void) setY:(float)x animated:(BOOL)animated {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[self setY:x];
	[UIView commitAnimations];
}


- (void) showOriginAndSizeWithTitle:(NSString*)title {
	NSLog(@"%@ x = %f y = %f w = %f h = %f",title,self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
}

- (CGRect) resizeOriginAndFrameForScale:(float)scale {
	return CGRectMake(self.frame.origin.x*scale,
					  self.frame.origin.y*scale,
					  self.frame.size.width*scale,
					  self.frame.size.height*scale);
}
@end
