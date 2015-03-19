//
//  FILoadingView.m
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FILoadingView.h"


@implementation FILoadingView
@synthesize indicator;
@synthesize messageLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		
		indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		indicator.center = CGPointMake(frame.size.width/2,frame.size.height/2);
		[self addSubview:indicator];
		[indicator release];
		
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,frame.size.width,frame.size.height)];
		messageLabel.textColor = [UIColor grayColor];
		messageLabel.backgroundColor = [UIColor clearColor];
		messageLabel.adjustsFontSizeToFitWidth = YES;
		messageLabel.textAlignment = UITextAlignmentCenter;
		messageLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
		messageLabel.center = CGPointMake(frame.size.width/2,frame.size.height/2+25);
		messageLabel.text = @"Loading...";
		[self addSubview:messageLabel];
		[messageLabel release];
		self.backgroundColor = [UIColor whiteColor];
		self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)showInView:(UIView*)view
{
	if (view) {
		[indicator startAnimating];
		[view addSubview:self];
	}
}

-(void)dismiss
{
	[indicator stopAnimating];
	[self removeFromSuperview];
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
