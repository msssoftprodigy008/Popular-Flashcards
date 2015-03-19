//
//  FIRoundedProgress.m
//  flashCards
//
//  Created by Ruslan on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIRoundedProgress.h"


@implementation FIRoundedProgress

-(id)initWithColors:(CGRect)frame attributes:(NSDictionary*)attr
{
	if (attr) {
		r_attributes = [[NSDictionary alloc] initWithDictionary:attr];
	}	
	
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
        // Initialization code.
    }
    return self;
}

-(void)changeValue:(NSDictionary*)newVal
{
	if (newVal) {
		if (r_attributes) {
			[r_attributes release];
		}
		
		r_attributes = [[NSDictionary alloc] initWithDictionary:newVal];
		[self setNeedsDisplay];
	}
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (r_attributes) {
		NSInteger rad = [[r_attributes objectForKey:@"radius"] intValue];
		NSInteger tx = [[r_attributes objectForKey:@"tx"] intValue];
		CGContextRef context = UIGraphicsGetCurrentContext();
		NSArray* colors = [r_attributes objectForKey:@"colors"];
		NSInteger curX = tx;
		for (UIColor* curColor in colors) {
			UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(curX,2,rad,rad)];
			CGContextSetFillColorWithColor(context,curColor.CGColor);
			[path fill];
			curX+=rad+tx;
		}
	}
}


- (void)dealloc {
	
	if (r_attributes) {
		[r_attributes release];
	}
	
    [super dealloc];
}


@end
