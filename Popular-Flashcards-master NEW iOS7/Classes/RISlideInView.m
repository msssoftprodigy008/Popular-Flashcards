//
//  RISlideInView.m
//  flashCards
//
//  Created by Ruslan on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RISlideInView.h"


@implementation RISlideInView
@synthesize r_imageSize;
@synthesize r_adjustX;
@synthesize r_adjustY;

#pragma mark -
#pragma mark main methods

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
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

+(id)viewWithImage:(UIImage*)SlideInImage
{
	RISlideInView *SlideIn = [[[RISlideInView alloc] init] autorelease];
	
	if (SlideInImage) {
		SlideIn.r_imageSize = SlideInImage.size;
		SlideIn.layer.bounds = CGRectMake(0,0,SlideIn.r_imageSize.width,SlideIn.r_imageSize.height);
		SlideIn.layer.anchorPoint = CGPointMake(0,0);
		SlideIn.layer.position = CGPointMake(-SlideIn.r_imageSize.width,0);
		SlideIn.layer.contents = (id)SlideInImage.CGImage;
	}
	

	
	return SlideIn;
	
}

-(void)showWithTimer:(CGFloat)time inView:(UIView*)view from:(SlideInView)side bounce:(BOOL)bounce
{
	CGPoint fromPos;
	CGPoint toPos;
	CGPoint bouncePos;
	switch (side) {
		case SlideInViewTop:
			self.r_adjustY = self.r_imageSize.height;
			fromPos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,-self.r_imageSize.height);
			toPos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,0);
			bouncePos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,5);
			break;
		case SlideInViewBottom:
			self.r_adjustY = -self.r_imageSize.height;
			fromPos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,view.bounds.size.height);
			toPos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,view.frame.size.height-self.r_imageSize.height);
			bouncePos = CGPointMake(view.frame.size.width/2-self.r_imageSize.width/2,view.frame.size.height-self.r_imageSize.height-5.0); 
			break;
		case SlideInViewLeft:
			self.r_adjustX = self.r_imageSize.width;
			fromPos = CGPointMake(-self.r_imageSize.width,view.frame.size.height/2-self.r_imageSize.height/2);
			toPos = CGPointMake(0,view.frame.size.height/2-self.r_imageSize.height/2);
			bouncePos = CGPointMake(5,view.frame.size.height/2-self.r_imageSize.height/2);
			break;
		case SlideInViewRight:
			self.r_adjustX = -self.r_imageSize.width;
			fromPos = CGPointMake(view.bounds.size.width,
								  view.frame.size.height/2-self.r_imageSize.height/2);
			toPos = CGPointMake(view.bounds.size.width-self.r_imageSize.width,
								view.frame.size.height/2-self.r_imageSize.height/2);
			bouncePos = CGPointMake(view.bounds.size.width-self.r_imageSize.width-5,
									view.frame.size.height/2-self.r_imageSize.height/2); 
			break;
	
		default:
			break;
	}
	
	[view addSubview:self];
	
	
	
	if (bounce) {
		CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"position"];
		keyFrame.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:fromPos],
						   [NSValue valueWithCGPoint:bouncePos],
						   [NSValue valueWithCGPoint:toPos],
						   [NSValue valueWithCGPoint:bouncePos],
						   [NSValue valueWithCGPoint:toPos],
						   nil];
		keyFrame.keyTimes = [NSArray arrayWithObjects:
							 [NSNumber numberWithFloat:0],
							[NSNumber numberWithFloat:.18],
							[NSNumber numberWithFloat:.5],
							[NSNumber numberWithFloat:.75],
							 [NSNumber numberWithFloat:1],
							 nil];
		
		self.layer.position = toPos;
		[self.layer addAnimation:keyFrame forKey:@"keyFrame"];
	}else {
		CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"position"];
		basic.fromValue = [NSValue valueWithCGPoint:fromPos];
		basic.toValue = [NSValue valueWithCGPoint:toPos];
		self.layer.position = toPos;
		[self.layer addAnimation:basic forKey:@"basic"];
	}
	
	if (r_popInTimer && [r_popInTimer isValid]) {
		[r_popInTimer invalidate];
	}
	
	r_popInTimer = [NSTimer scheduledTimerWithTimeInterval:time
													target:self
												  selector:@selector(popIn)
												  userInfo:nil
												   repeats:NO];
	

	
}

-(void)popIn
{
	if (r_popInTimer && [r_popInTimer isValid]) {
		[r_popInTimer invalidate];
		r_popInTimer = nil;
	}
	
	[UIView beginAnimations:nil context:nil];
	self.frame = CGRectOffset(self.frame,-self.r_adjustX,-self.r_adjustY);
	[UIView commitAnimations];
	
	[self performSelector:@selector(removeFromSuperview)
			   withObject:nil
			   afterDelay:0.5];
	
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark main methods ends

@end
