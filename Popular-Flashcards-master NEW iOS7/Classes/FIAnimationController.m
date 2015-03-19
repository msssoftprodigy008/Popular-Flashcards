//
//  FIAnimationController.m
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAnimationController.h"
#import <QuartzCore/QuartzCore.h>
#import "FICardsConstants.h"

@interface FIAnimationController(Private)

-(void)notificateDelegate;
-(void)notificateDelegateWithoutBlocking;
-(void)bouncing:(NSTimer*)timer;
-(void)bounce:(UIView*)withView;

//bounceAnimations

-(void)startBounceView:(UIView*)withView;
-(void)bouncingView:(NSTimer*)timer;

//trembel animation
-(void)needTrembel:(NSTimer*)timer;



@end


static FIAnimationController *sharedAnimator = nil;
static id animationDelegate = nil;

@implementation FIAnimationController

+(id)sharedAnimation:(id)Adelegate
{
	if (!sharedAnimator) {
		sharedAnimator = [[FIAnimationController alloc] init];
	}
	
	animationDelegate = Adelegate;
	
	return sharedAnimator;
}

-(void)fallAndBounce:(UIView*)withView
{
	//[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: kCATransitionFromBottom];
	[animation setSpeed:1.5];
	[[withView layer] addAnimation:animation forKey:@"push"];
	[self bounce:withView];
}

-(void)fallAndTrembell:(UIView *)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: kCATransitionFromRight];
	[animation setSpeed:1.5];
	[[withView	layer] addAnimation:animation forKey:@"push"];
	
	times = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(needTrembel:) userInfo:withView repeats:NO];
}

-(void)fallAndTrembell:(UIView *)withView dir:(NSString*)direction
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: direction];
	[animation setSpeed:1.5];
	[[withView	layer] addAnimation:animation forKey:@"push"];
	
	times = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(needTrembel:) userInfo:withView repeats:NO];
}

-(void)rotate:(UIView*)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
	rotation.duration = 0.25f;
	rotation.speed = 1.0f;
	rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	rotation.byValue = [NSNumber numberWithFloat:2*M_PI];
	rotation.toValue = [NSNumber numberWithFloat:2*M_PI];
	[[withView layer] addAnimation:rotation forKey:@"animateRotate"];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
	
}

-(void)flip:(UIView*)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: @"oglFlip"];
	[animation setSubtype: kCATransitionFromBottom];
	[animation setSpeed:1.5];
	[[withView layer] addAnimation:animation forKey:@"swipe"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.5f];
}

-(void)pushView:(UIView*)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: kCATransitionFromRight];
	[animation setSpeed:1.5];
	[[withView layer] addAnimation:animation forKey:@"swipe"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.5f];
}

-(void)fade:(UIView*)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionFade];
	[animation setSubtype: kCATransitionFromTop];
	[animation setSpeed:1.5];
	[[withView layer] addAnimation:animation forKey:@"swipe"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.5f];
}

-(void)pushView:(UIView*)withView dir:(NSString*)direction
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: direction];
	[animation setSpeed:1.5];
	[[withView layer] addAnimation:animation forKey:@"swipe"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.5f];
}

-(void)makeAnimation:(UIView*)withView type:(NSString*)type dir:(NSString*)direction
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.3f];
	[animation setType:type];
	[animation setSubtype:direction];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
	[[withView layer] addAnimation:animation forKey:@"animation"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.5f];
}

-(void)makeAnimation:(UIView*)withView
				type:(NSString*)type
			 subType:(NSString*)subType
			duration:(CGFloat)duration
			   speed:(CGFloat)speed
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:duration];
	[animation setType:type];
	[animation setSubtype:subType];
	[animation setSpeed:speed];
	[[withView layer] addAnimation:animation forKey:@"animation"];
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:duration];
}

-(void)grow:(UIView*)withView fromCenter:(CGPoint)growCenter fromSize:(CGSize)growSize
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CGSize originalSize = withView.frame.size;
	
	withView.center = growCenter;
	
	withView.transform = CGAffineTransformMakeScale(growSize.width/originalSize.width,growSize.height/originalSize.height);
	withView.hidden = NO;	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	withView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
}

-(void)resize:(UIView*)withView toSize:(CGSize)resizeSize
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CGSize originalSize = withView.frame.size;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	withView.transform = CGAffineTransformMakeScale(resizeSize.width/originalSize.width,resizeSize.height/originalSize.height);
	
	[UIView commitAnimations];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
}

-(void)changeFrame:(UIView*)withView toFrame:(CGRect)frame
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	withView.frame = frame; 
	
	[UIView commitAnimations];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
}

-(void)moveCenter:(UIView*)withView toPoint:(CGPoint)newCenter
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25f];
	
	withView.center = newCenter; 
	
	[UIView commitAnimations];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
}

-(void)normalizeView:(UIView*)withView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	withView.transform = CGAffineTransformIdentity; 
	
	[UIView commitAnimations];
	
	[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
}

-(void)fallingToSomething:(UIView*)withView forPoint:(CGPoint)moveToPoint forScale:(CGSize)scale forRot:(CGFloat)angle
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.toValue = [NSValue valueWithCGPoint:moveToPoint];
	
	CABasicAnimation * rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
	rotationAnimation.toValue = [NSNumber numberWithFloat:angle];
		
	CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.toValue = [NSValue valueWithCGSize:scale];
														   
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	theGroup.duration = 1.0f;
	theGroup.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
	theGroup.removedOnCompletion = NO;
	theGroup.speed = 3.0;
	theGroup.animations = [NSArray arrayWithObjects:animation,rotationAnimation,scaleAnimation,nil]; // you can add more
	[[withView layer] addAnimation:theGroup forKey:@"group"];
		
	[self notificateDelegate];
}

-(void)small:(UIView*)withView fromCenter:(CGPoint)smallCenter fromSize:(CGSize)smallSize
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.toValue = [NSValue valueWithCGPoint:smallCenter];
	
	CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.toValue = [NSValue valueWithCGSize:smallSize];
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	theGroup.duration = 0.5f;
	theGroup.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.removedOnCompletion = NO;
	theGroup.speed = 2.0;
	theGroup.animations = [NSArray arrayWithObjects:animation,scaleAnimation,nil]; // you can add more
	[[withView layer] addAnimation:theGroup forKey:@"group"];
	[self performSelector:@selector(notificateDelegate)
			   withObject:nil
			   afterDelay:0.45f];
}

-(void)small:(UIView*)withView toFrame:(CGRect)frame
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.toValue = [NSValue valueWithCGPoint:frame.origin];
	
	CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	scaleAnimation.toValue = [NSValue valueWithCGSize:frame.size];
	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	theGroup.duration = 0.5f;
	theGroup.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	theGroup.removedOnCompletion = NO;
	theGroup.speed = 2.0;
	theGroup.animations = [NSArray arrayWithObjects:animation,scaleAnimation,nil]; // you can add more
	theGroup.delegate = self;
	theGroup.removedOnCompletion = NO;
	[[withView layer] addAnimation:theGroup forKey:@"group"];

	
}

-(void)leakToPoint:(CGPoint)p withView:(UIView*)withView
{
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!withView) {
		[self notificateDelegate];
		return;
	}
	
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.toValue = [NSValue valueWithCGPoint:p];
	
    CABasicAnimation *anchorPointAnimation = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
    anchorPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)];
    
	CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	scaleAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.0,0.0)];

	
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    theGroup.duration = 1.1f;
    theGroup.speed = 1.0f;
    CAMediaTimingFunction *timeFunc = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    theGroup.timingFunction = timeFunc;
	theGroup.repeatCount = 0;
	theGroup.animations = [NSArray arrayWithObjects:animation,anchorPointAnimation,scaleAnimation,nil];
    // you can add more
	// Add the animation group to the layer
	[[withView layer] addAnimation:theGroup forKey:nil];
	[self performSelector:@selector(notificateDelegateWithoutBlocking)
			   withObject:nil
			   afterDelay:1.0f];
}

-(void)deckChangeAnimation:(UIView*)destView forScr:(UIView*)srcView{
    
    if (!destView || !srcView) {
        [self notificateDelegate];
        return;
    }
    
        
    CABasicAnimation *scaleAnimationScr = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimationScr.toValue = [NSValue valueWithCGSize:CGSizeMake(kFCardSmallWidth/kFCardWidth,kFCardSmallHeight/kFCardHieght)];
            
    CABasicAnimation *scaleAnimationDest = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimationDest.toValue = [NSValue valueWithCGSize:CGSizeMake(0.65,
                                                                    0.65)];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    UIBezierPath *keyFramePath = [UIBezierPath bezierPath];
    [keyFramePath moveToPoint:destView.layer.position];
    [keyFramePath addLineToPoint:CGPointMake(240, 0)];
    [keyFramePath moveToPoint:CGPointMake(240, 0)];
    [keyFramePath addLineToPoint:srcView.layer.position];
    [positionAnimation setPath:[keyFramePath CGPath]];
    NSArray *timesArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.0],
                      [NSNumber numberWithDouble:0.24],
                      [NSNumber numberWithDouble:0.48],
                      [NSNumber numberWithDouble:0.6],nil];
    [positionAnimation setKeyTimes:timesArray];
    
    CAKeyframeAnimation *positionAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *keyFramePath2 = [UIBezierPath bezierPath];
    [keyFramePath2 moveToPoint:srcView.layer.position];
    [keyFramePath2 addLineToPoint:CGPointMake(240, 300)];
    [keyFramePath2 moveToPoint:CGPointMake(240, 300)];
    [keyFramePath2 addLineToPoint:destView.layer.position];
    [positionAnimation2 setPath:[keyFramePath2 CGPath]];
    [positionAnimation2 setKeyTimes:timesArray];
    
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.duration = 0.5f;
    theGroup.speed = 1.0f;
	theGroup.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	theGroup.animations = [NSArray arrayWithObjects:scaleAnimationDest,positionAnimation,nil];
    
    CAAnimationGroup *theGroup2 = [CAAnimationGroup animation];
	theGroup2.duration = 0.5f;
    theGroup2.speed = 1.0f;
	theGroup2.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	theGroup2.animations = [NSArray arrayWithObjects:scaleAnimationScr,positionAnimation2,nil];
    
    UIView *supView = destView.superview;
    destView.transform = CGAffineTransformMakeScale(0.65, 0.65);
    [supView performSelector:@selector(bringSubviewToFront:) withObject:destView afterDelay:0.1];
    [[destView layer] addAnimation:theGroup forKey:@"pgn1"];
    [[srcView layer] addAnimation:theGroup2 forKey:@"pgn2"];
    srcView.transform = CGAffineTransformMakeScale(kFCardSmallWidth/kFCardWidth,kFCardSmallHeight/kFCardHieght);
    
    [self performSelector:@selector(notificateDelegateWithoutBlocking)
               withObject:nil afterDelay:0.5f];
}

-(void)deckChangeAnimationIPad:(UIView*)destView forScr:(UIView*)srcView{
    if (!destView || !srcView) {
        [self notificateDelegate];
        return;
    }
    
    
    CABasicAnimation *scaleAnimationScr = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimationScr.toValue = [NSValue valueWithCGSize:CGSizeMake(158.0/654.0,118.0/491.0)];
    
    CABasicAnimation *scaleAnimationDest = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimationDest.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0,1.0)];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    UIBezierPath *keyFramePath = [UIBezierPath bezierPath];
    [keyFramePath moveToPoint:destView.layer.position];
    [keyFramePath addLineToPoint:CGPointMake(destView.center.x, destView.center.y-300)];
    [keyFramePath moveToPoint:CGPointMake(destView.center.x, destView.center.y-300)];
    [keyFramePath addLineToPoint:srcView.layer.position];
    [positionAnimation setPath:[keyFramePath CGPath]];
    NSArray *timesArray = [NSArray arrayWithObjects:[NSNumber numberWithDouble:0.0],
                           [NSNumber numberWithDouble:0.24],
                           [NSNumber numberWithDouble:0.48],
                           [NSNumber numberWithDouble:0.6],nil];
    [positionAnimation setKeyTimes:timesArray];
    
    CAKeyframeAnimation *positionAnimation2 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    UIBezierPath *keyFramePath2 = [UIBezierPath bezierPath];
    [keyFramePath2 moveToPoint:srcView.layer.position];
    [keyFramePath2 addLineToPoint:CGPointMake(destView.center.x, destView.center.y+300)];
    [keyFramePath2 moveToPoint:CGPointMake(destView.center.x, destView.center.y+300)];
    [keyFramePath2 addLineToPoint:destView.layer.position];
    [positionAnimation2 setPath:[keyFramePath2 CGPath]];
    [positionAnimation2 setKeyTimes:timesArray];
    
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	theGroup.duration = 0.5f;
    theGroup.speed = 1.0f;
	theGroup.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	theGroup.animations = [NSArray arrayWithObjects:scaleAnimationDest,positionAnimation,nil];
    
    CAAnimationGroup *theGroup2 = [CAAnimationGroup animation];
	theGroup2.duration = 0.5f;
    theGroup2.speed = 1.0f;
	theGroup2.repeatCount = 0;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	theGroup2.animations = [NSArray arrayWithObjects:scaleAnimationScr,positionAnimation2,nil];
    
    UIView *supView = destView.superview;
    [supView performSelector:@selector(bringSubviewToFront:) withObject:destView afterDelay:0.1];
    [[destView layer] addAnimation:theGroup forKey:@"pgn1"];
    [[srcView layer] addAnimation:theGroup2 forKey:@"pgn2"];
    destView.transform = CGAffineTransformIdentity;
   
    
    [self performSelector:@selector(notificateDelegateWithoutBlocking)
               withObject:nil afterDelay:0.5f];
}

-(void)bounceView:(UIView*)bounceView
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(willBeginAnimation)]) {
		[animationDelegate willBeginAnimation];
	}
	
	if (!bounceView) {
		[self notificateDelegate];
		return;
	}
	
	[self startBounceView:bounceView];
}

+(void)clearAnimations
{
	if (sharedAnimator) {
		[sharedAnimator release];
	}
}

#pragma mark -
#pragma mark CAAnimationGroup delegate

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	[self notificateDelegate];
}


#pragma mark -
#pragma mark private methods

-(void)notificateDelegate
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(didEndAnimation)]) {
		[animationDelegate didEndAnimation];
	}
	
	[pool release];
}

-(void)notificateDelegateWithoutBlocking{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (animationDelegate && [animationDelegate respondsToSelector:@selector(didEndAnimation)]) {
		[animationDelegate didEndAnimation];
	}
	
	[pool release];
}

-(void)needTrembel:(NSTimer*)timer
{
	if (times>2) {
		[timer invalidate];
		[self notificateDelegate];
		return;
	}
	
	UIView *withView = (UIView*)[timer userInfo];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f-times*0.015f];
	if (times%2!=0){ 
		withView.transform = CGAffineTransformMakeTranslation(-(2-times)*30,0);
	}
	else {
		withView.transform = CGAffineTransformIdentity;
	}
	[UIView commitAnimations];
	times++;
	[NSTimer scheduledTimerWithTimeInterval:0.25f-times*0.015f target:self selector:@selector(needTrembel:) userInfo:withView repeats:NO];
}

-(void)bouncing:(NSTimer*)timer
{
	if (times>2) {
		[timer invalidate];
		[self notificateDelegate];
		return;
	}
	
	UIView *withView = (UIView*)[timer userInfo];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f-times*0.015f];
	if (times%2!=0){ 
		withView.transform = CGAffineTransformMakeScale(0.9f+times*0.05f,0.9f+times*0.05f);
	}
	else {
		withView.transform = CGAffineTransformIdentity;
	}
	[UIView commitAnimations];
	times++;
	[NSTimer scheduledTimerWithTimeInterval:0.25f-times*0.015f target:self selector:@selector(bouncing:) userInfo:withView repeats:NO];
}

-(void)bounce:(UIView*)withView
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	withView.transform = CGAffineTransformMakeScale(0.8f,0.8f);
	[UIView commitAnimations];
	
	times = 0;
	[NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(bouncing:) userInfo:withView repeats:NO];
	
}

-(void)startBounceView:(UIView*)withView
{
	times = 0;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.1f];	
	withView.transform = CGAffineTransformMakeScale(1.3,1.3);
	[UIView commitAnimations];
	
	[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(bouncingView:) userInfo:withView repeats:NO];
}

-(void)bouncingView:(NSTimer*)timer
{
	UIView *withView = (UIView*)[timer userInfo];
	
	times++;
	
	if (times<=3) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		if (times%2!=0) {
			withView.transform = CGAffineTransformIdentity;
		}
		else {
			withView.transform = CGAffineTransformMakeScale(1.2,1.2);
		}
		[UIView commitAnimations];
		[NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(bouncingView:) userInfo:withView repeats:NO];
	}
	else {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		withView.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
				
		[sharedAnimator performSelector:@selector(notificateDelegate) withObject:nil afterDelay:0.25f];
		
	}
}

@end
