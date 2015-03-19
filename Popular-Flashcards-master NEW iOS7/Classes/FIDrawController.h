//
//  FIDrawController.h
//  flashCards
//
//  Created by Ruslan on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRootConstants.h"
#import "FAdMobController.h"
#import "FIToolBar.h"

@class FIGLView;

@protocol FIDrawControllerDelegate

-(void)drawnedImage:(UIImage*)img;

@end


@interface FIDrawController : UIViewController {
	FIGLView *molbert;
	id delegate;
	FIToolBar *instrumentView;
	NSMutableArray *buttonArray;
	UIImage *bgImage;
	
	NSInteger colorIndex;
	NSInteger lineIndex;
	
	FIOrientation orientation;
	
	BOOL isBrush;
}

@property(nonatomic,assign)id delegate;
@property(retain) UIImage *bgImage;
@property(nonatomic,readwrite)FIOrientation orientation;

@end
