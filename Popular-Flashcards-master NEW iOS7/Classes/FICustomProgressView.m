//
//  FICustomProgressView.m
//  flashCards
//
//  Created by Ruslan on 6/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FICustomProgressView.h"


@implementation FICustomProgressView

-(id)initWithAttribDic:(CGRect)frame
			 forAttrib:(NSArray*)attrib
		   borderColor:(UIColor*)borderColor
		   borderWidth:(NSInteger)borderWidth
				  font:(UIFont*)font;
{
	if (borderColor) {
		r_borderColor = [[UIColor alloc] initWithCGColor:borderColor.CGColor];
	}else {
		r_borderColor = [[UIColor alloc] initWithCGColor:[UIColor blackColor].CGColor];
	}
	
	if (font) {
		r_font = font;
	}
	
	if (attrib) {
		r_attributeArr = [[NSArray alloc] initWithArray:attrib];
	}
	
	r_borderWidth = borderWidth;
	
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		r_value = 0;
		self.backgroundColor = [UIColor clearColor];
        // Initialization code.
    }
    return self;
}

-(void)changeValue:(NSInteger)newValue
{
	r_value = newValue;
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGRect progressBarRect = CGRectMake(0,0,self.frame.size.width*0.6*r_value/100.0,self.frame.size.height);
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:progressBarRect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	for (NSDictionary *att in r_attributeArr) {
		NSRange drawVal = [[att objectForKey:@"value"] rangeValue];
		if (drawVal.location<=r_value && r_value<drawVal.location+drawVal.length) {
			UIColor *drColor = [att objectForKey:@"color"];
			CGContextSetFillColorWithColor(context,drColor.CGColor);
			break;
		}
	}
	
	[path fill];
	
	if(r_borderWidth>0){
		path = [UIBezierPath bezierPathWithRect:CGRectMake(0,0,self.frame.size.width*0.6,self.frame.size.height)];
		path.lineJoinStyle = kCGLineJoinRound;
		path.lineCapStyle = kCGLineCapRound;
		CGContextSetStrokeColorWithColor(context,r_borderColor.CGColor);
		path.lineWidth = r_borderWidth;
		[path stroke];
	}

	
	NSString *drString = [NSString stringWithFormat:@"%d%%",r_value];
	[drString drawAtPoint:CGPointMake(self.frame.size.width*0.6+2.0,0) withFont:r_font];
	
}



- (void)dealloc {
	
	if (r_borderColor) {
		[r_borderColor release];
	}
	
	if (r_attributeArr) {
		[r_attributeArr release];
	}
	
    [super dealloc];
}


@end
