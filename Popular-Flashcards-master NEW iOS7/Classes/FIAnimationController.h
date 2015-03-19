//
//  FIAnimationController.h
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FIAnimationControllerDelegate
@optional
-(void)willBeginAnimation;
-(void)didEndAnimation;

@end


@interface FIAnimationController : NSObject {
	NSInteger times;
}

+(id)sharedAnimation:(id)Adelegate;

-(void)fallAndBounce:(UIView*)withView;
-(void)fallAndTrembell:(UIView *)withView;
-(void)fallAndTrembell:(UIView *)withView dir:(NSString*)direction;
-(void)rotate:(UIView*)withView;
-(void)flip:(UIView*)withView;
-(void)grow:(UIView*)withView fromCenter:(CGPoint)growCenter fromSize:(CGSize)growSize;
-(void)small:(UIView*)withView fromCenter:(CGPoint)smallCenter fromSize:(CGSize)smallSize;
-(void)small:(UIView*)withView toFrame:(CGRect)frame;
-(void)resize:(UIView*)withView toSize:(CGSize)resizeSize;
-(void)changeFrame:(UIView*)withView toFrame:(CGRect)frame;
-(void)moveCenter:(UIView*)withView toPoint:(CGPoint)newCenter;
-(void)fallingToSomething:(UIView*)withView forPoint:(CGPoint)moveToPoint forScale:(CGSize)scale forRot:(CGFloat)angle;
-(void)normalizeView:(UIView*)withView;
-(void)bounceView:(UIView*)bounceView;
-(void)pushView:(UIView*)withView;
-(void)pushView:(UIView*)withView dir:(NSString*)direction;
-(void)fade:(UIView*)withView;
-(void)makeAnimation:(UIView*)withView type:(NSString*)type dir:(NSString*)direction;

-(void)makeAnimation:(UIView*)withView
				type:(NSString*)type
			 subType:(NSString*)subType
			duration:(CGFloat)duration
			   speed:(CGFloat)speed;

-(void)leakToPoint:(CGPoint)p withView:(UIView*)withView;
-(void)deckChangeAnimation:(UIView*)destView forScr:(UIView*)srcView;
-(void)deckChangeAnimationIPad:(UIView*)destView forScr:(UIView*)srcView;
+(void)clearAnimations;

@end
