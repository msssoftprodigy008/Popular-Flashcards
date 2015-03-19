//
//  RISlideInView.h
//  flashCards
//
//  Created by Ruslan on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum SlideInView{
	SlideInViewTop,
	SlideInViewBottom,
	SlideInViewLeft,
	SlideInViewRight
}SlideInView;

@interface RISlideInView : UIView {
	CGSize r_imageSize;
	CGFloat r_adjustX;
	CGFloat r_adjustY;
	NSTimer *r_popInTimer;
}

@property(nonatomic,readwrite)CGSize r_imageSize;
@property(nonatomic,readwrite)CGFloat r_adjustX;
@property(nonatomic,readwrite)CGFloat r_adjustY;

+(id)viewWithImage:(UIImage*)SlideInImage;
-(void)showWithTimer:(CGFloat)time inView:(UIView*)view from:(SlideInView)side bounce:(BOOL)bounce;
-(void)popIn;

@end
