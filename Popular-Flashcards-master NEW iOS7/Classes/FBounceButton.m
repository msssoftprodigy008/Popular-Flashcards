//
//  FBounceButton.m
//  flashCards
//
//  Created by Ruslan on 7/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FBounceButton.h"

@interface FBounceButton(Private)

-(void)startBouncing;
-(void)bounce;

@end


@implementation FBounceButton
@synthesize bounceNum;
@synthesize oneBounceTime;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
    }
    return self;
}

-(void)startBounceAnimation
{
    self.userInteractionEnabled = NO;
    
	if (!self.imageView) {
		if (delegate && [delegate respondsToSelector:@selector(animationFinished:)]) {
			[delegate animationFinished:self];
		}
		return;
	}
	if (bounceTimer && [bounceTimer isValid]) {
		[bounceTimer invalidate];
		bounceTimer = nil;
	}
	
	[self startBouncing];
}

-(void)stopAnimation
{
    self.userInteractionEnabled = YES;
    
	if (bounceTimer && [bounceTimer isValid]) {
		[bounceTimer invalidate];
		bounceTimer = nil;
	}
	
	if (delegate && [delegate respondsToSelector:@selector(animationFinished:)]) {
		[delegate animationFinished:self];
	}
	
}

#pragma mark -
#pragma mark private

-(void)bounce
{
	count++;
	
	if (count<=bounceNum) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		if (count%2!=0) {
			self.transform = CGAffineTransformIdentity;
		}
		else {
			self.transform = CGAffineTransformMakeScale(1.2,1.2);
		}
		[UIView commitAnimations];
	}
	else {
        
        self.userInteractionEnabled = YES;    
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		self.transform = CGAffineTransformIdentity;
		[UIView commitAnimations];
		[bounceTimer invalidate];
		bounceTimer = nil;
		
		if (delegate && [delegate respondsToSelector:@selector(animationFinished:)]) {
			[delegate animationFinished:self];
		}
        
	}

	
}

-(void)startBouncing
{
	if (!self.imageView) {
		if (delegate && [delegate respondsToSelector:@selector(animationFinished:)]) {
			[delegate animationFinished:self];
		}
		return;
	}
	
	count = 0;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.1f];	
	self.transform = CGAffineTransformMakeScale(1.3,1.3);
	[UIView commitAnimations];
	
	bounceTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(bounce) userInfo:nil repeats:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
