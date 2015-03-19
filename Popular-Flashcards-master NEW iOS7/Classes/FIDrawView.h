//
//  FIDrawView.h
//  flashCards
//
//  Created by Ruslan on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FIDrawView : UIView {
	BOOL isBrush;
	UIColor *usingColor;
	BOOL shouldDraw;
	BOOL isColorChanged;
	UIImage* currentImage;
	UIImage* backgroundImage;
	UIBezierPath *bPath;
	CGFloat lineWidth;
	int flushContIter;
}

@property(retain) UIColor *usingColor;
@property(retain) UIImage *backgroundImage;
@property(nonatomic,readwrite) BOOL isBrush;

-(void)clear;
-(UIImage*)getImage;
-(void)changeLineWidth:(CGFloat)lWidth;

@end
