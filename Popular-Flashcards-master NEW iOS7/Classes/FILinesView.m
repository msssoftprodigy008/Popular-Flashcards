//
//  FILinesView.m
//  flashCards
//
//  Created by Ruslan on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FILinesView.h"
#import <QuartzCore/QuartzCore.h>

@interface FILinesView(Private)

void Interpolate (void* info, float const* inData, float* outData);

@end


@implementation FILinesView

-(id)initWithAttributes:(CGRect)frame forDic:(NSArray*)attr
{
		if (attr) {
			attributes = [[NSArray alloc] initWithArray:attr];
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

-(void)changeAttributes:(NSArray*)newattr
{
	if (newattr) {
		if (attributes) {
			[attributes release];
		}
		
		attributes = [[NSArray alloc] initWithArray:newattr];
		[self setNeedsDisplay];
	}
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	if (attributes) {
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		

		
		for(NSDictionary *line in attributes)
		{
			NSInteger lineWidth = [[line objectForKey:@"width"] intValue];
			NSInteger lineHeight = [[line objectForKey:@"height"] intValue];
			NSInteger offsetX = [[line objectForKey:@"offsetX"] intValue];
			NSInteger offsetY = [[line objectForKey:@"offsetY"] intValue];
			BOOL isRounded = [[line objectForKey:@"rounded"] boolValue];
			UIColor *drawColor = [line objectForKey:@"color"];
			
			if (isRounded) {
				CGContextSetLineCap(context,kCGLineCapRound);
			}else {
				CGContextSetLineCap(context,kCGLineCapButt);
			}
			
			if (drawColor) {
				CGContextSetStrokeColorWithColor(context,drawColor.CGColor);
			}else {
				CGContextSetStrokeColorWithColor(context,[UIColor darkGrayColor].CGColor);
			}
			
			CGContextSetLineWidth(context,lineHeight);
			CGContextMoveToPoint(context,offsetX,offsetY);
			CGContextAddLineToPoint(context,offsetX+lineWidth,offsetY);
			CGContextStrokePath(context);
		}
		
		
	}		
}

void Interpolate (void* info, float const* inData, float* outData)
{
	outData[0] = inData[0];
	outData[1] = sin(M_PI * inData[0]);
	outData[2] = 1.0;
	outData[3] = 1.0;
}



- (void)dealloc {
	
	if (attributes) {
		[attributes release];
	}
	
    [super dealloc];
}


@end
