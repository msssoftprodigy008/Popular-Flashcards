//
//  FIToolBar.m
//  flashCards
//
//  Created by Ruslan on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIToolBar.h"


@implementation FIToolBar
@synthesize bgImage;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        // Initialization code.
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
		[bgImage drawInRect:rect];
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
