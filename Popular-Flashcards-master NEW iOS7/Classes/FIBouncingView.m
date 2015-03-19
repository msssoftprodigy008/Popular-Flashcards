//
//  FIBouncingView.m
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIBouncingView.h"
#import "FIAnimationController.h"

@interface FIBouncingView(Private)

-(void)tapHandle:(UITapGestureRecognizer*)sender;

@end


@implementation FIBouncingView
@synthesize state;

-(id)initWithImages:(CGRect)frame  forActive:(UIImage*)active forNoneActive:(UIImage*)noneActive forDelegate:(id)Adelegate{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		delegate = Adelegate;
		
		if (active) 
			activeImage = [[UIImage alloc] initWithCGImage:active.CGImage];
		
		if (noneActive) {
			notActiveImage = [[UIImage alloc] initWithCGImage:noneActive.CGImage];
		}
		self.image = noneActive;
		state = NO;
		self.userInteractionEnabled = YES;
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
		[self addGestureRecognizer:tap];
		[tap release];
		
    }
	
    return self;
	
}

-(void)changeImages:(UIImage*)active forNoneActive:(UIImage*)noneActive
{
	if (activeImage) {
		[activeImage release];
		activeImage = nil;
	}
	
	if (notActiveImage) {
		[notActiveImage release];
		notActiveImage = nil;
	}
	
	if (active) 
		activeImage = [[UIImage alloc] initWithCGImage:active.CGImage];
	
	if (noneActive) {
		notActiveImage = [[UIImage alloc] initWithCGImage:noneActive.CGImage];
	}
	
	if (state) {
		self.image = active;
	}
	else {
		self.image = noneActive;
	}

}

-(void)changeState:(BOOL)newState
{
	state = newState;
	
	if (newState) {
		self.image = activeImage;
	}else {
		self.image = notActiveImage;
	}

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -
#pragma mark animation delegate
-(void)didEndAnimation
{
	if (delegate && [delegate respondsToSelector:@selector(stateChanged:)]) {
		[delegate stateChanged:state];
	}
}

#pragma mark -
#pragma mark private methods

-(void)tapHandle:(UITapGestureRecognizer*)sender
{
	state = !state;
	
	if (state) 
		self.image = activeImage;
	else 
		self.image = notActiveImage;
	
	[[FIAnimationController sharedAnimation:self] bounceView:self];
	
	
	
}

#pragma mark -

- (void)dealloc {
	
	if (activeImage) {
		[activeImage release];
	}
	
	if (notActiveImage) {
		[notActiveImage release];
	}
	
    [super dealloc];
}


@end
