//
//  FISplashController.h
//  flashCards
//
//  Created by Ruslan on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class FISplashController;

@protocol FISplashControllerDelegate <NSObject>

@optional
-(void)splashScreenDidAppear:(FISplashController*)splashController;
-(void)splashScreenWillDisappear:(FISplashController*)splashController;
-(void)splashScreenDidDisappear:(FISplashController*)splashController;

@end


@interface FISplashController : UIViewController {
	
}

@property(nonatomic,retain) UIImage *splashImage;
@property(nonatomic,assign) id<FISplashControllerDelegate> delegate;

- (void)showInWindow:(UIWindow *)window;
- (void)performTransition;

@end
