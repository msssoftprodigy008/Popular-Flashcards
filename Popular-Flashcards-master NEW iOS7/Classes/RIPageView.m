//
//  RIPageView.m
//  flashCards
//
//  Created by Ruslan on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIPageView.h"

@interface RIPageView(Private)

#pragma mark targets
-(void)buttonPressed:(id)sender;
#pragma mark targets ends

@end


@implementation RIPageView
@synthesize r_pageview;
@synthesize r_titleLabel;
@synthesize r_delegate;

#pragma mark -
#pragma mark main methods

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		UIColor *cardSteelBlue = [UIColor colorWithRed:70.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1.0];
		r_pageview = [[FIRoundedButton alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,frame.size.height-frame.size.width/3.0)];
		r_pageview.r_distance = 2.0;
		r_pageview.r_innerRadius = frame.size.width/4.0;
		r_pageview.r_outerRadius = frame.size.width/5.0;
		r_pageview.r_innnerColor = [UIColor whiteColor];
		r_pageview.r_outerColor = cardSteelBlue;
		r_pageview.layer.shouldRasterize = YES;
		[r_pageview addTarget:self
					forAction:@selector(buttonPressed:)];
		[self addSubview:r_pageview];
		[r_pageview release];
		
	
		r_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,
																 frame.size.height-frame.size.width/3.0,
																 frame.size.width,
																 frame.size.width/3.0)];
		r_titleLabel.backgroundColor = [UIColor clearColor];
		r_titleLabel.textColor = [UIColor whiteColor];
		r_titleLabel.shadowColor = [UIColor blackColor];
		r_titleLabel.shadowOffset = CGSizeMake(0.0,-1.0);
		r_titleLabel.adjustsFontSizeToFitWidth = YES;
		r_titleLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:r_titleLabel];
		[r_titleLabel release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    [super dealloc];
}

#pragma mark main methods ends

#pragma mark -
#pragma mark targets

-(void)buttonPressed:(id)sender
{
	if (r_delegate && [r_delegate respondsToSelector:@selector(viewDidSelected:)]) {
		[r_delegate viewDidSelected:self];
	}
}

#pragma mark targets ends

@end
