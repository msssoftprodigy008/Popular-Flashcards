//
//  FIRoundedButton.m
//  flashCards
//
//  Created by Ruslan on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIRoundedButton.h"
#import "Util.h"

#define k_r_defaultDis 4

@implementation FIRoundedButton
@synthesize r_titleLabel;
@synthesize r_innerRadius;
@synthesize r_outerRadius;
@synthesize r_distance;
@synthesize r_outerColor;
@synthesize r_innnerColor;
@synthesize r_hinnnerColor;
@synthesize r_houterColor;
@synthesize r_isTouched;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		r_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(k_r_defaultDis-1,
															k_r_defaultDis-1,
															frame.size.width-2*(k_r_defaultDis-1),
															frame.size.height-2*(k_r_defaultDis-1))];
		self.layer.borderWidth = k_r_defaultDis;
		self.backgroundColor = [UIColor grayColor];
		
		if (![Util isPhone]) 
			self.layer.shouldRasterize = YES;
		
		r_titleLabel.backgroundColor = [UIColor whiteColor];
		r_titleLabel.textColor = [UIColor blackColor];
		r_isTouched = NO;
		[self addSubview:r_titleLabel];
		
	}
    return self;
}

-(void)setR_innerRadius:(NSInteger)r
{
	r_innerRadius = r;
	r_titleLabel.layer.cornerRadius = r;
}

-(void)setR_outerRadius:(NSInteger)r
{
	r_outerRadius = r;
	self.layer.cornerRadius = r;
}

-(void)setR_distance:(NSInteger)d
{
	r_distance = d;
	self.layer.borderWidth = d;
	r_titleLabel.frame = CGRectMake(d-1,
									d-1,
									self.frame.size.width-2*(d-1),
									self.frame.size.height-2*(d-1));
}

-(void)setR_innnerColor:(UIColor *)c
{
	if (!c) {
		return;
	}
	
	if (r_innerColor) {
		[r_innerColor release];
	}
	
	r_innerColor = [[UIColor alloc] initWithCGColor:c.CGColor];
	r_titleLabel.backgroundColor = r_innerColor;
}

-(void)setR_outerColor:(UIColor *)c
{
	if (!c) {
		return;
	}
	
	if (r_outerColor) {
		[r_outerColor release];
	}
	
	r_outerColor = [[UIColor alloc] initWithCGColor:c.CGColor];
	self.layer.borderColor = r_outerColor.CGColor;
}

-(void)setR_hinnnerColor:(UIColor *)c
{
	if (!c) {
		return;
	}
	
	if (r_hinnerColor) {
		[r_hinnerColor release];
	}
	
	r_hinnerColor = [[UIColor alloc] initWithCGColor:c.CGColor];
}

-(void)setR_houterColor:(UIColor *)c
{
	if (!c) {
		return;
	}
	
	if (r_houterColor) {
		[r_houterColor release];
	}
	
	r_houterColor = [[UIColor alloc] initWithCGColor:c.CGColor];
}

-(void)addTarget:(id)target forAction:(SEL)selector
{
	r_target = target;
	r_selector = selector;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	r_isTouched = YES;
	
	if (r_hinnerColor) {
		r_titleLabel.backgroundColor = r_hinnerColor;
	}
	
	if (r_houterColor) {
		self.layer.borderColor = r_houterColor.CGColor;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	r_isTouched = NO;
	
	if (r_innerColor) {
		r_titleLabel.backgroundColor = r_innerColor;
	}
	
	if (r_outerColor) {
		self.layer.borderColor = r_outerColor.CGColor;
	}
	
	if (r_target && r_selector) {
		objc_msgSend(r_target,r_selector);
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
	
	if (r_titleLabel) {
		[r_titleLabel release];
	}
	
	if (r_innerColor) {
		[r_innerColor release];
	}
	
	if (r_outerColor) {
		[r_outerColor release];
	}
	
	if (r_hinnerColor) {
		[r_hinnerColor release];
	}
	
	if (r_houterColor) {
		[r_houterColor release];
	}
	
    [super dealloc];
}


@end
