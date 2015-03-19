//
//  FISearchBar.m
//  flashCards
//
//  Created by Ruslan on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISearchBar.h"

@implementation FISearchBar
@synthesize bgImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroundColor = [UIColor clearColor];
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
	}
    
    for ( UIView * subview in self.subviews ) 
    {
        
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) 
            subview.alpha = 0.0;  
        
        if ([subview isKindOfClass:NSClassFromString(@"UISegmentedControl") ] )
            subview.alpha = 0.0; 
        if ([subview isKindOfClass:[UITextField class]]) {
            CGRect frame = subview.frame;
            frame.origin.y = 6;
            subview.frame = frame;
        }
    } 
}

- (void)dealloc {
	
	if (bgImage) {
		[bgImage release];
	}
	
    [super dealloc];
}

@end
