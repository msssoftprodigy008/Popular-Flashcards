//
//  FAlertView.m
//  flashCards
//
//  Created by Руслан Руслан on 4/1/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import "FAlertView.h"
#import "FDBController.h"
#import "Util.h"

@interface FAlertView(Private)

-(UIWindow*)getCurrentWindow;
-(void)initImageViews;
-(void)initLabels;
-(void)initButtons;
-(void)dissmiss;
-(void)quitButtonPressed;
-(void)addSuccesNum;
-(void)addDoubtNum;
-(void)addFailedNum;
-(void)rotateToPortrait:(BOOL)isPort;
-(void)playSound;
@end


@implementation FAlertView

-(id)initWithFrame:(CGRect)frame forCategory:(NSString*)Acategory forMode:(FAlert)mode forDelegate:(id)Adelegate
{
	category = [NSString stringWithString:Acategory];
	alertMode = mode;
	delegate = Adelegate;
	return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
			alertView = [[UIImageView alloc] initWithFrame:CGRectMake(183,253,402,497)];
		}else {
			alertView = [[UIImageView alloc] initWithFrame:CGRectMake(320,153,402,497)];	
		}

		alertView.userInteractionEnabled = YES;
		alertView.image = [UIImage imageNamed:@"fc_alert_bg.png"];
		
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		
		UIView *blackView = [[UIView alloc] initWithFrame:frame];
		blackView.userInteractionEnabled = NO;
		blackView.backgroundColor = [UIColor blackColor];
		blackView.alpha = 0.5;	
		
		[self addSubview:blackView];
		[self addSubview:alertView];
		[alertView release];
		[blackView release];
        
         AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Calc" ofType:@"wav"]], &playerCalc);
		
		[self initImageViews];
		[self initLabels];
		[self initButtons];
    }
    return self;
}

-(void)show:(UIView*)inView
{
	[UIImageView beginAnimations:nil context:nil];
	[UIImageView setAnimationDuration:0.5f];
	[UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	
	
	[inView addSubview:self];
	
	[UIImageView commitAnimations];
	
}

-(void)dissmissWithoutResponse
{
	[self removeFromSuperview];
	
}

-(void)setValues:(NSArray*)values forTime:(NSString*)Atime
{
	plannedCards = [[values objectAtIndex:0] intValue];
	plannedLabel.text = [NSString stringWithFormat:@"%d",plannedCards];
	viewLabel.text = [values objectAtIndex:1];
	succesVal = [[values objectAtIndex:2] intValue];

	NSInteger viewedCards = [[values objectAtIndex:1] intValue];
	
	if(viewedCards<=0)
		succesVal = 0;
	else
		succesVal = (int)(((double)succesVal/(double)viewedCards)*100);
	
	
	if(!alertMode)
	{
		doubtVal = [[values objectAtIndex:3] intValue];
		failedVal = [[values objectAtIndex:4] intValue];
		
		if(viewedCards<=0)
			doubtVal = 0;
		else
			doubtVal = (int)(((double)doubtVal/(double)viewedCards)*100);

		
		doubtTimer = [NSTimer scheduledTimerWithTimeInterval:0.015f target:self selector:@selector(addDoubtNum) userInfo:nil repeats:YES];
	}
	else
		failedVal = [[values objectAtIndex:3] intValue];
	
	if(viewedCards<=0)
		failedVal = 0;
	else
		failedVal = (int)(((double)failedVal/(double)viewedCards)*100); 
	
	timeLabel.text = Atime;
	succesTimer = [NSTimer scheduledTimerWithTimeInterval:0.015f target:self selector:@selector(addSuccesNum) userInfo:nil repeats:YES];
	failedTimer = [NSTimer scheduledTimerWithTimeInterval:0.015f target:self selector:@selector(addFailedNum) userInfo:nil repeats:YES];
}

-(void)rotateToPortrait:(BOOL)isPort{
	if (isPort){
		alertView.frame = CGRectMake(183,253,402,497);
	}else {
		alertView.frame = CGRectMake(320,153,402,497);	
	}
}

- (void)drawRect:(CGRect)rect {
	[super	drawRect:rect];
    // Drawing code
}

#pragma mark Private Methods

-(void)addSuccesNum
{
  
	if(succesVal<=0)
	{
		[succesTimer invalidate];
		return;
	}
	
	succesVal--;
	
	CGRect frame = succesView.frame;
	CGFloat step = 0.82;
	frame.origin.y-=step;
	frame.size.height+=step;
	succesView.frame = frame;
	
	frame = shadowForSuccess.frame;
	frame.origin.y-=step;
	shadowForSuccess.frame = frame;
	shadowForSuccess.alpha = 0.5+0.5*(1-succesVal/100);
	
	NSInteger labLVal = [succesLabel.text intValue];
	labLVal++;
	succesLabel.text = [NSString stringWithFormat:@"%d%%",labLVal];
    [self playSound];
}

-(void)addDoubtNum
{
	if(doubtVal<=0)
	{
		[doubtTimer invalidate];
		return;
	}
	
	doubtVal--;	
	
	UIImageView *doubtView = (UIImageView*)[alertView viewWithTag:111];
	UILabel *doubtLabel = (UILabel*)[alertView viewWithTag:333];
	
	CGRect frame = doubtView.frame;
	CGFloat step = 0.82;
	frame.origin.y-=step;
	frame.size.height+=step;
	doubtView.frame = frame;
	
	UIImageView *shadowForDoubt = (UIImageView*)[alertView viewWithTag:444];
	frame = shadowForDoubt.frame;
	frame.origin.y-=step;
	shadowForDoubt.frame = frame;
	shadowForDoubt.alpha = 0.5+0.5*(1-doubtVal/100);
	
	NSInteger labLVal = [doubtLabel.text intValue];
	labLVal++;
	doubtLabel.text = [NSString stringWithFormat:@"%d%%",labLVal];
    [self playSound];
}

-(void)addFailedNum
{
	if(failedVal<=0)
	{
		[failedTimer invalidate];
		return;
	}
	
	failedVal--;
	
	CGRect frame = failedView.frame;
	CGFloat step = 0.82;
	frame.origin.y-=step;
	frame.size.height+=step;
	failedView.frame = frame;
	
	frame = shadowForFailed.frame;
	frame.origin.y-=step;
	shadowForFailed.frame = frame;
	shadowForFailed.alpha = 0.5+0.5*(1-failedVal/100);
	
	NSInteger labLVal = [failedLabel.text intValue];
	labLVal++;
	failedLabel.text = [NSString stringWithFormat:@"%d%%",labLVal];
    [self playSound];
}

-(void)playSound{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(playerCalc);
    }
}

-(UIWindow*)getCurrentWindow
{
	UIApplication *currentAp = [UIApplication sharedApplication];
	NSArray *visiWondows = [currentAp windows];
	UIWindow *usingWindow;
	for(UIWindow* aWindow in visiWondows)
	{
		if(aWindow.keyWindow)
		{
			usingWindow = aWindow;
			break;
		}
	}
	return usingWindow;
}

-(void)initImageViews
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	succesView = [[[UIImageView alloc] initWithFrame:CGRectMake(25,313,109,0)] autorelease];
	succesView.image = [UIImage imageNamed:@"fc_alert_stlob_g.png"];
	succesView.contentMode = UIViewContentModeScaleToFill;
	[alertView addSubview:succesView];
	
	shadowForSuccess = [[[UIImageView alloc] initWithFrame:CGRectMake(25,296,109,17)] autorelease];
	shadowForSuccess.image = [UIImage imageNamed:@"fc_alert_stlob_shadow.png"];
	shadowForSuccess.alpha = 0.0f;
	[alertView addSubview:shadowForSuccess];
	
	failedView = [[[UIImageView alloc] initWithFrame:CGRectMake(269,313,109,0)] autorelease];
	failedView.image = [UIImage imageNamed:@"fc_alert_stlob_b.png"];
	failedView.contentMode = UIViewContentModeScaleToFill;
	[alertView addSubview:failedView];
	
	shadowForFailed = [[[UIImageView alloc] initWithFrame:CGRectMake(269,296,109,17)] autorelease];
	shadowForFailed.image = [UIImage imageNamed:@"fc_alert_stlob_shadow.png"];
	shadowForFailed.alpha = 0.0f;
	[alertView addSubview:shadowForFailed];
	
	if(!alertMode)
	{
		UIImageView *doubtView = [[[UIImageView alloc] initWithFrame:CGRectMake(146,313,109,0)] autorelease];
		doubtView.image = [UIImage imageNamed:@"fc_alert_stlob_o.png"];
		doubtView.contentMode = UIViewContentModeScaleToFill;
		doubtView.tag = 111;
		[alertView addSubview:doubtView];
		
		UIImageView *shadowForDoubt = [[[UIImageView alloc] initWithFrame:CGRectMake(146,296,109,17)] autorelease];
		shadowForDoubt.image = [UIImage imageNamed:@"fc_alert_stlob_shadow.png"];
		shadowForDoubt.alpha = 0.0f;
		shadowForDoubt.tag = 444;
		[alertView addSubview:shadowForDoubt];
	}
	
	[pool release];
}

-(void)initLabels
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	succesLabel = [[[UILabel alloc] initWithFrame:CGRectMake(42,245,75,50)] autorelease];
	succesLabel.backgroundColor = [UIColor clearColor];
	succesLabel.textColor = [UIColor blackColor];
	succesLabel.font = [UIFont boldSystemFontOfSize:22];
	succesLabel.textAlignment = UITextAlignmentCenter;
	succesLabel.text = @"";
	succesVal = 0;
	[alertView addSubview:succesLabel];
	
	failedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(289,245,75,50)] autorelease];
	failedLabel.backgroundColor = [UIColor clearColor];
	failedLabel.textColor = [UIColor blackColor];
	failedLabel.font = [UIFont boldSystemFontOfSize:22];
	failedLabel.textAlignment = UITextAlignmentCenter;
	failedLabel.text = @"";
	failedVal = 0;
	[alertView addSubview:failedLabel];
	
	if(!alertMode)
	{
		UILabel *doubtLabel = [[[UILabel alloc] initWithFrame:CGRectMake(170,245,75,50)] autorelease];
		doubtLabel.backgroundColor = [UIColor clearColor];
		doubtLabel.textColor = [UIColor blackColor];
		doubtLabel.font = [UIFont boldSystemFontOfSize:22];
		doubtLabel.textAlignment = UITextAlignmentCenter;
		doubtLabel.text = @"";
		doubtLabel.tag = 333;
		doubtVal = 0;
		[alertView addSubview:doubtLabel];
	}
	
	NSInteger currentSize;
	[Util	makeResizeToViewSize:category forSize:&currentSize contsrToSize:CGSizeMake(236,40)];
	
	titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(86,25,236,40)] autorelease];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
	titleLabel.text = [[FDBController sharedDatabase] nameForCategory:category];
	[alertView addSubview:titleLabel];
	
	plannedLabel = [[[UILabel alloc] initWithFrame:CGRectMake(56,135,119,40)] autorelease];
	plannedLabel.backgroundColor = [UIColor clearColor];
	plannedLabel.textColor = [UIColor whiteColor];
	plannedLabel.textAlignment = UITextAlignmentCenter;
	plannedLabel.font = [UIFont fontWithName:@"Helvetica" size:44];
	plannedLabel.text = @"0";
	[alertView addSubview:plannedLabel];
	
	viewLabel = [[[UILabel alloc] initWithFrame:CGRectMake(235,135,119,40)] autorelease];
	viewLabel.backgroundColor = [UIColor clearColor];
	viewLabel.textColor = [UIColor whiteColor];
	viewLabel.textAlignment = UITextAlignmentCenter;
	viewLabel.font = [UIFont fontWithName:@"Helvetica" size:44];
	viewLabel.text = @"0";
	[alertView addSubview:viewLabel];
	
	timeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(95,355,210,47)] autorelease];
	timeLabel.backgroundColor = [UIColor clearColor];
	timeLabel.textColor = [UIColor whiteColor];
	timeLabel.textAlignment = UITextAlignmentCenter;
	timeLabel.font = [UIFont fontWithName:@"Helvetica" size:44];
	timeLabel.text= @"00:00:00";
	[alertView addSubview:timeLabel];
	
	[pool release];
	
}

-(void)initButtons
{
	UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	quitButton.frame = CGRectMake(26,415,173,63);
	[quitButton setImage:[UIImage imageNamed:@"fc_alert_quit_1.png"] forState:UIControlStateNormal];
	[quitButton setImage:[UIImage imageNamed:@"fc_alert_quit_2.png"] forState:UIControlStateHighlighted];
	[quitButton addTarget:self action:@selector(quitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[alertView addSubview:quitButton];
	
	UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
	continueButton.frame = CGRectMake(209,415,173,63);
	[continueButton setImage:[UIImage imageNamed:@"fc_alert_continue_1.png"] forState:UIControlStateNormal];
	[continueButton setImage:[UIImage imageNamed:@"fc_alert_continue_2.png"] forState:UIControlStateHighlighted];
	[continueButton addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
	[alertView addSubview:continueButton];
}

-(void)dissmiss
{
	[UIImageView beginAnimations:nil context:nil];
	[UIImageView setAnimationDuration:0.5f];
	[UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[self removeFromSuperview];
		
	[UIImageView commitAnimations];
	
	[delegate continueButtonPressed];
}

-(void)quitButtonPressed
{
	[self removeFromSuperview];
	[delegate quitButtonPressed];
}

- (void)dealloc {
     AudioServicesDisposeSystemSoundID(playerCalc);
    [super dealloc];
}


@end
