//
//  FDrawController.h
//  flashCards
//
//  Created by Ruslan on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"

@protocol FDrawControllerDelegate

-(void)imageSaved:(UIImage*)img;

@end

@class FIGLView;

@interface FDrawController : UIViewController {
	//views
	FIGLView *molbert;
	UIImageView *instrumentView;
	UIImage *bgImage;
	
	//buttons
	NSMutableArray *buttonArray;
	NSInteger selectedLineIndex;
	NSInteger selectedColorIndex;
	BOOL isBrush;
	
	id delegate;
	
	
}

@property(nonatomic,assign) id delegate;
@property(retain) UIImage *bgImage;
-(void)showInstruments;

@end
