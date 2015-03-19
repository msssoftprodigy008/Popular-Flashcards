//
//  FIndicatorView.m
//  flashCards
//
//  Created by Ruslan on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIndicatorView.h"
#import <QuartzCore/QuartzCore.h>

#import "UIProgressView+customView.h"

#import "Util.h"

@interface FIndicatorView(Private)

-(void)cancelButtonPressed;

@end


@implementation FIndicatorView

@synthesize delegate;
@synthesize progressView;
@synthesize progressViewLabel;
@synthesize cancelButton;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        float X1;
        if ([Util isPhone]) {  // for backgroundview adjustment
            X1=0;
        }else
        {
            X1=15;
            
        }
        
       downloadView = [[UIView alloc] initWithFrame:CGRectMake(0,X1,frame.size.width,frame.size.height)];
		downloadView.opaque = 0;
		[downloadView setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f]];// 
		
		CGFloat x = frame.size.width/2-140;
		CGFloat y = frame.size.height/2-5;
		
        float X;
        if ([Util isPhone]) { //prgress bar length
            X=350;
        }else
        {
            X=400;
        
        }
        
		progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(x,y,X,20)];
//        progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//        progressView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        progressView.trackImage = [[UIImage imageNamed:@"search-progress-track"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f)];
        progressView.progressImage = [[UIImage imageNamed:@"search-progress"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0f, 3.0f, 3.0f, 3.0f)];
        progressView.frame = self.bounds;
        [progressView setProgress:0.5];
//        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 5.0f);
//        progressView.transform = transform;
        
        [progressView setTrackImage:[UIImage imageNamed:@"track.png"]];
       
        
        [progressView setTintColor:[UIColor colorWithRed:68.0/255.0 green:160.0/255.0 blue:68.0/255.0 alpha:1.0]];
        
        
//        progressView.trackTintColor = [UIColor blueColor];

        //[UIColor colorWithRed:0.2 green:0.45 blue:0.8 alpha:1.0];
        
		progressView.progress = 1.0f;
		progressViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+285,y-5,60,20)];
		progressViewLabel.adjustsFontSizeToFitWidth = YES;
		progressViewLabel.backgroundColor = [UIColor clearColor]; //percentage label color
		progressViewLabel.textColor = [UIColor whiteColor];
		progressViewLabel.text = @"0%";
		
		cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(frame.size.width-40,y-10,30,30);
		[cancelButton setImage:[UIImage imageNamed:@"i_stop_download.png"] forState:UIControlStateNormal];
		[cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
     
		[downloadView addSubview:progressView];
		[downloadView addSubview:progressViewLabel];
		[downloadView addSubview:cancelButton];
		[self addSubview:downloadView];
    }
    return self;
}

-(void)setDelegate:(id)Adelegate
{
	delegate = Adelegate;
}

-(void)setBgColor:(UIColor*)bgColor // background color
{
	if (bgColor)
		downloadView.backgroundColor = bgColor;
}

-(void)setImportLen:(NSInteger)Alen
{
	importLen = Alen;	
}

-(void)setCurVal:(NSInteger)currVal
{
	if (currVal>importLen) {
		currentLen = importLen;
	}
	else {
		if (currVal<0) {
			currentLen = 0;
		}
		else {
			currentLen = currVal;
		}
	}
	NSInteger calToSet = (int)(((float)currentLen/(float)importLen)*100.0f);
	NSString *str = [NSString stringWithFormat:@"%d",calToSet];
	str	 = [str stringByAppendingString:@"%"]; 
	progressViewLabel.text = str;
	progressView.progress = (float)currentLen/(float)importLen;
}

-(void)showInView:(UIView*)inView
{
	self.hidden = YES;
	[inView addSubview:self];
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionFade];
	[animation setSubtype: kCATransitionFromBottom];
	[animation setSpeed:1.5];
	self.hidden = NO;
	[[self layer] addAnimation:animation forKey:@"fade"];
}

-(void)dissmis
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	[self removeFromSuperview];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Private methods

-(void)cancelButtonPressed
{
	if (delegate && [delegate respondsToSelector:@selector(cancelButtonPressed)]) {
		[delegate cancelButtonPressed];
	}
}

#pragma mark -

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	
	[downloadView release];
	[progressView release];
	[progressViewLabel release];
		
	[super dealloc];
}


@end
