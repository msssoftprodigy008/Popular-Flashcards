//
//  UIView.h
//  Pasl
//
//  Created by ravil ibragimov on 9/30/09.
//  Copyright 2009 RusLang Solutions. All rights reserved.
//

//#import <Cocoa/Cocoa.h>


@interface UIView (Utilities) 
- (void) setOrigin:(CGPoint)origin;
- (void) setSize:(CGSize)size;
- (void) setOrigin:(CGPoint)origin animated:(BOOL)animated;
- (void) setSize:(CGSize)size animated:(BOOL)animated;

- (void) addToX:(float)value;
- (void) addToY:(float)value;
- (void) addToX:(float)xValue andToY:(float)yValue; 
- (void) addToX:(float)value animated:(BOOL)animated;
- (void) addToY:(float)value animated:(BOOL)animated;
- (void) addToX:(float)xValue andToY:(float)yValue animated:(BOOL)animated;

- (void) addToWidth:(float)value;
- (void) addToHeight:(float)value;
- (void) addToWidth:(float)width andToHeight:(float)height;
- (void) addToWidth:(float)value animated:(BOOL)animated;
- (void) addToHeight:(float)value animated:(BOOL)animated;
- (void) addToWidth:(float)width andToHeight:(float)height animated:(BOOL)animated;

- (float) yFromCentre;
- (float) yFromBottom;
- (float) xFromCentre;
- (float) xFromRight;

- (void) setX:(float)x;
- (void) setX:(float)x animated:(BOOL)animated;
- (void) setY:(float)y;
- (void) setY:(float)y animated:(BOOL)animated;

- (void) showOriginAndSizeWithTitle:(NSString*)title;
- (CGRect) resizeOriginAndFrameForScale:(float)scale;

@end
