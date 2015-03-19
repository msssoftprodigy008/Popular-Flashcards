//
//  FINavigationBar.m
//  flashCards
//
//  Created by Ruslan on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FINavigationBar.h"
#import <QuartzCore/QuartzCore.h>


@implementation FINavigationBar
@synthesize bgImage;
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        // Initialization code.
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, frame.size.width-240,
                                                               frame.size.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(1, 0);
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        titleLabel.shadowColor = [UIColor blackColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [self addSubview:titleLabel];
        
        [titleLabel release];
        
	}
    return self;
}

-(void)setBgImage:(UIImage *)image
{
	if (bgImage) {
		[bgImage release];
		bgImage = nil;
	}
	
	if (image) {
		bgImage = [[UIImage alloc] initWithCGImage:image.CGImage];
	}
	
	[self setNeedsDisplay];
	
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (bgImage) {
		[bgImage drawInRect:self.frame];
	}else {
		[super drawRect:rect];
	}

}


- (void)dealloc {
	
	if (bgImage) {
		[bgImage release];
	}
	
    [super dealloc];
}


@end
