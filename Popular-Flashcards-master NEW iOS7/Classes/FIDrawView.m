//
//  FIDrawView.m
//  flashCards
//
//  Created by Ruslan on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDrawView.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface FIDrawView(Private)

-(void)panMoved:(UIPanGestureRecognizer*)sender;
-(void)flushContent;

@end


@implementation FIDrawView
@synthesize usingColor;
@synthesize isBrush;
@synthesize backgroundImage;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		UIPanGestureRecognizer *panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self
																				   action:@selector(panMoved:)];
		[self addGestureRecognizer:panRecog];
		[panRecog release];
		self.backgroundColor = [UIColor whiteColor];
		usingColor = [[UIColor blackColor] retain];
		shouldDraw = NO;
		isColorChanged = NO;
		lineWidth = 8.0;
		flushContIter = 0;
		
		CALayer *layer = self.layer;
		UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width,self.frame.size.height));
		[layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
		tmpImage = [Util rotateImage:tmpImage forAngle:180.0];
		tmpImage = [Util mirrorMappingToRight:tmpImage];
		UIGraphicsEndImageContext();
		backgroundImage = [[UIImage alloc] initWithCGImage:tmpImage.CGImage];
		
		[self flushContent];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
	if (shouldDraw) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGColorRef colorRef = [usingColor CGColor];
		CGContextSetStrokeColorWithColor(ctx,colorRef);
		CGContextDrawImage(ctx,CGRectMake(0.0,0.0,self.frame.size.width,self.frame.size.height),currentImage.CGImage);
		bPath.lineCapStyle = kCGLineCapRound;
		bPath.lineJoinStyle = kCGLineJoinRound;
		
		[bPath stroke];
	}
}

-(void)changeLineWidth:(CGFloat)lWidth
{
	lineWidth = lWidth;
	[self flushContent];
}


-(UIImage*)getImage
{
	CALayer *layer = self.layer;
	UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width,self.frame.size.height));
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}


-(void)clear
{
	[bPath release];
	bPath = [[UIBezierPath alloc] init];
	bPath.lineWidth = lineWidth;
	
	[currentImage release];
	currentImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
						   forView:self
							 cache:YES];
	
	[self setNeedsDisplay];
	
	[UIView commitAnimations];
	
}

-(void)flushContent
{
	if (currentImage) {
		[currentImage release];
	}
	
	if (shouldDraw) {
		CALayer *layer = self.layer;
		UIGraphicsBeginImageContext(CGSizeMake(self.frame.size.width,self.frame.size.height));
		[layer renderInContext:UIGraphicsGetCurrentContext()];
		UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
		tmpImage = [Util rotateImage:tmpImage forAngle:180.0];
		tmpImage = [Util mirrorMappingToRight:tmpImage];
		UIGraphicsEndImageContext();
		currentImage = [[UIImage alloc] initWithCGImage:tmpImage.CGImage];
	}else {
		currentImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage];	
	}

	if (bPath) 
		[bPath release];
	bPath = [[UIBezierPath alloc] init];
	bPath.lineWidth = lineWidth;
}

-(void)setUsingColor:(UIColor *)colorRef
{
	[usingColor release];
	usingColor = [colorRef retain];
	isColorChanged = YES;
	[self flushContent];
}

-(void)setBackgroundImage:(UIImage *)bImage
{
	if (bImage) {
		if (backgroundImage) {
			[backgroundImage release];
		}
		UIImage* tmpImage = [Util rotateImage:bImage forAngle:180.0];
		tmpImage = [Util mirrorMappingToRight:tmpImage];
		backgroundImage = [[UIImage alloc] initWithCGImage:tmpImage.CGImage];
		
		if (currentImage) {
			[currentImage release];
		}
		
		currentImage = [[UIImage alloc] initWithCGImage:backgroundImage.CGImage];
		
		shouldDraw = YES;
		[self setNeedsDisplay];
	}
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSSet *t = [event touchesForView:self];
	UITouch *imageTouch = [[t objectEnumerator] nextObject];
	CGPoint p = [imageTouch locationInView:self];
	[bPath moveToPoint:p];
	[bPath addLineToPoint:CGPointMake(p.x+1.0,p.y+1.0)];
	shouldDraw = YES;
	[self setNeedsDisplay];
	
}

-(void)panMoved:(UIPanGestureRecognizer*)sender
{
	
	if (sender.state != UIGestureRecognizerStateEnded) 
	{
		CGPoint p = [sender locationInView:self];
		CGPoint p1 = bPath.currentPoint;
		
		if (flushContIter == 10) {
			flushContIter = 0;
			[self flushContent];
			[bPath moveToPoint:p1];
		}
		
		flushContIter++;
		
		[bPath addQuadCurveToPoint:p controlPoint:CGPointMake((p1.x+p.x)/2.0,(p1.y+p.y)/2.0)];
		[self setNeedsDisplay];
	}
}


- (void)dealloc {
	[bPath release];
	[usingColor release];
	
	if (currentImage) {
		[currentImage release];
	}
	
	if (backgroundImage) {
		[backgroundImage release];
	}
	
    [super dealloc];
}


@end
