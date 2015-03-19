//
//  FLabelIndicatorView.m
//  flashCards
//
//  Created by Ruslan on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FLabelIndicatorView.h"


@implementation FLabelIndicatorView
@synthesize indicatorView;
@synthesize messageLabel;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		indicatorView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0.0,0.0,frame.size.width,3.0*frame.size.height/4.0)];
		[indicatorView setBgColor:[UIColor clearColor]];
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,3.0*frame.size.height/4.0,frame.size.width,frame.size.height/4.0)];
		messageLabel.backgroundColor = [UIColor clearColor];
		self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
		
		[self addSubview:indicatorView];
		[self addSubview:messageLabel];
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
	
	if (indicatorView) 
		[indicatorView release];
	
	if (messageLabel) {
		[messageLabel release];
	}
	
    [super dealloc];
}


@end
