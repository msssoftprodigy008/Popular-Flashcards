//
//  RIBlinkButton.m
//  flashCards
//
//  Created by Ruslan on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIBlinkButton.h"

#define kAlpha 0.5f;
#define kTime 1.0f

@interface RIBlinkButton(Private)


-(void)blink:(NSTimer*)timer;
- (void)getRGBComponents:(CGFloat [4])components forColor:(UIColor *)col ;

@end


@implementation RIBlinkButton
@synthesize r_blinkAlpha;
@synthesize r_blinkTime;
@synthesize r_isBlinking;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		r_blinkAlpha = kAlpha;
		r_blinkTime = kTime;
		r_isBlinking = NO;
    }
    return self;
}

-(void)setImages:(NSArray*)images{
    if (r_images) {
        [r_images release];
    }
    
    if (images) {
        r_images = [[NSArray alloc] initWithArray:images];
        [self setImage:[r_images objectAtIndex:0] forState:UIControlStateNormal];
        [self setImage:[r_images objectAtIndex:0] forState:UIControlStateHighlighted];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
	
	if (r_blinkTimer && [r_blinkTimer isValid]) {
		[r_blinkTimer invalidate];
	}
	
    if (r_images) {
        [r_images release];
    }
    
    [super dealloc];
}

#pragma mark -
#pragma mark public methods

-(void)startBlinking
{
    if (!r_images || [r_images count]<3) {
        return;
    }
    
	if (r_isBlinking) {
		return;
	}
	
	r_isBlinking = YES;
	r_count = 0;
	r_blinkTimer = [NSTimer scheduledTimerWithTimeInterval:r_blinkTime
													target:self
												  selector:@selector(blink:)
												  userInfo:nil
												   repeats:YES];
}

-(void)stopBlinking
{
	if (!r_isBlinking) {
		return;
	}
	
	r_isBlinking = NO;
	
	if (r_blinkTimer && [r_blinkTimer isValid]) {
		[r_blinkTimer invalidate];
		r_blinkTimer = nil;
	}
	
    [self setImage:[r_images objectAtIndex:0] forState:UIControlStateNormal];
    [self setImage:[r_images objectAtIndex:0] forState:UIControlStateHighlighted];    
}

#pragma mark public ends

#pragma mark -
#pragma mark private methods

-(void)blink:(NSTimer*)timer
{
	if (r_count == 0) {
		[self setImage:[r_images objectAtIndex:1] forState:UIControlStateNormal];
        [self setImage:[r_images objectAtIndex:1] forState:UIControlStateHighlighted];
	}else {
        [self setImage:[r_images objectAtIndex:2] forState:UIControlStateNormal];
        [self setImage:[r_images objectAtIndex:2] forState:UIControlStateHighlighted];
	}
	
	r_count = (r_count+1)%2;
}

- (void)getRGBComponents:(CGFloat [4])components forColor:(UIColor *)col {
	CGColorRef colorref = [col CGColor];
	int numComponents = CGColorGetNumberOfComponents(colorref);
	if (numComponents == 4) {
		const CGFloat *comp = CGColorGetComponents(colorref);
		for (int i = 0; i < 4; i++) {
			components[i] = comp[i] / 255.0f;
		}
		
		
	}
	
}

#pragma mark -

@end
