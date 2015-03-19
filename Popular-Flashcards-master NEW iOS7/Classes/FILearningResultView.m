//
//  FILearningResultView.m
//  flashCards
//
//  Created by Ruslan on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FILearningResultView.h"

@interface FILearningResultView(Private)
	
#pragma mark init
-(void)initImageViews;
-(void)initLabels;
-(void)initButtons;

#pragma mark targets
-(void)quitButtonPressed:(id)sender;
-(void)continueButtonPressed:(id)sender;

#pragma mark private
-(void)addStepToKnow;
-(void)addStepToDontKnow;
-(void)addStepToNotSure;
-(void)playSound;

#pragma mark -
#pragma mark private

@end

#define step 0.96

@implementation FILearningResultView
@synthesize delegate;

#pragma mark -
#pragma mark main

-(id)initWithResult:(NSDictionary*)result forType:(FILearningProccesType) type{
	if (result) {
		_result = [[NSDictionary alloc] initWithDictionary:result];
	}
	
	_learningType = type;
	
	UIImage *bgImage = [UIImage imageNamed:@"i_results_bg.png"];
		
	return [self initWithFrame:CGRectMake(0, 0, bgImage.size.width, bgImage.size.height)];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Calc" ofType:@"wav"]], &playerCalc);
		[self initImageViews];
		[self initLabels];
		[self initButtons];
		
    }
    return self;
}

-(void)startShowingResult{
	CGFloat viewed = (CGFloat)[[_result objectForKey:@"viewed"] intValue];
	if (viewed>0) {
		_knowVal = 	([[_result objectForKey:@"kn"] intValue]/viewed)*100;
		_dontKnowVal = ([[_result objectForKey:@"dk"] intValue]/viewed)*100;
	}else {
		_knowVal = 0;
		_dontKnowVal = 0;
	}

	if (_learningType == FILearningProccesTypeTest) {
		if (viewed>0) {
			_notSureVal = ([[_result objectForKey:@"ns"] intValue]/viewed)*100;
		}else {
			_notSureVal = 0;
		}

		_notSureTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f
														 target:self
													   selector:@selector(addStepToNotSure)
													   userInfo:nil
														repeats:YES];
	}
	
	_knowTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f
													 target:self
												   selector:@selector(addStepToKnow)
												   userInfo:nil
													repeats:YES];
	_dontKnowTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f
													 target:self
												   selector:@selector(addStepToDontKnow)
												   userInfo:nil
													repeats:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    
    AudioServicesDisposeSystemSoundID(playerCalc);
	
	if (_knowTimer && [_knowTimer isValid]) {
		[_knowTimer invalidate];
		_knowTimer = nil;
	}
	if (_dontKnowTimer && [_dontKnowTimer isValid]) {
		[_dontKnowTimer invalidate];
		_dontKnowTimer = nil;
	}
	if (_notSureTimer) {
		[_notSureTimer invalidate];
		_notSureTimer = nil;
	}
    
    if (_result) {
        [_result release];
    }
	
    [super dealloc];
}

#pragma mark -

#pragma mark -
#pragma mark init

-(void)initImageViews{
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_results_bg.png"]];
	[self addSubview:bgView];
	[bgView release];
	
	_dontKnowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_results_red.png"]];
	_dontKnowImageView.frame = CGRectMake(21, self.frame.size.height-69,
										  _dontKnowImageView.frame.size.width,
										  1.0);
	_dontKnowImageView.alpha = 0.0f;
	[self addSubview:_dontKnowImageView];
	[_dontKnowImageView release];
	
	UIView *dontKnowView = [[UIView alloc] initWithFrame:CGRectMake(0,0,_dontKnowImageView.frame.size.width,1)];
	dontKnowView.backgroundColor = [UIColor colorWithRed:208.0/255.0
												   green:78.0/255.0
													blue:52.0/255.0
												   alpha:1.0];
	[_dontKnowImageView addSubview:dontKnowView];
	[dontKnowView release];
	
	if (_learningType == FILearningProccesTypeTest) {
		_notSureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_results_gray.png"]];
		_notSureImageView.frame = CGRectMake(_dontKnowImageView.frame.origin.x+_dontKnowImageView.frame.size.width+20,
											 self.frame.size.height-69,
											 _notSureImageView.frame.size.width,
											 1.0f);
		_notSureImageView.alpha = 0.0f;
		[self addSubview:_notSureImageView];
		[_notSureImageView release];
	
		UIView *notSureView = [[UIView alloc] initWithFrame:CGRectMake(0,0,_notSureImageView.frame.size.width,1)];
		notSureView.backgroundColor = [UIColor colorWithRed:138.0/255.0
													  green:138.0/255.0
													   blue:138.0/255.0
													  alpha:1.0];
		[_notSureImageView addSubview:notSureView];
		[notSureView release];
	}
	
	_knowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_results_green.png"]];
	_knowImageView.frame = CGRectMake(_dontKnowImageView.frame.origin.x+2*_dontKnowImageView.frame.size.width+40,
									  self.frame.size.height-69,
									  _knowImageView.frame.size.width,
									  1.0);
	_knowImageView.alpha = 0.0;
	[self addSubview:_knowImageView];
	[_knowImageView release];
	
	UIView *knowView = [[UIView alloc] initWithFrame:CGRectMake(0,0,_knowImageView.frame.size.width,1)];
	knowView.backgroundColor = [UIColor colorWithRed:124.0/255.0
												  green:156.0/255.0
												   blue:17.0/255.0
												  alpha:1.0];
	[_knowImageView addSubview:knowView];
	[knowView release];
	
}

-(void)initLabels{
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, self.frame.size.width-40.0, 50)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textColor = [UIColor colorWithRed:147.0/255.0 green:95.0/255.0 blue:48.0/255.0 alpha:1.0f];
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake(0.5f,0.5f);
	titleLabel.adjustsFontSizeToFitWidth = YES;
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:21];
	titleLabel.textAlignment = UITextAlignmentCenter;
	if (_result) {
		titleLabel.text = [_result objectForKey:@"title"];
	}
	[self addSubview:titleLabel];
	[titleLabel release];
	
	
	UILabel *dontKnowTitle = [[UILabel alloc] initWithFrame:CGRectMake(21,
																	   self.frame.size.height-165,
																	   _dontKnowImageView.frame.size.width,
																	   50)];
	dontKnowTitle.backgroundColor = [UIColor clearColor];
	dontKnowTitle.textColor = [UIColor whiteColor];
	dontKnowTitle.numberOfLines = 2;
	dontKnowTitle.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
	dontKnowTitle.shadowOffset = CGSizeMake(-0.5f,0.5f);
	dontKnowTitle.font = [UIFont fontWithName:@"Helvetica" size:18];
	dontKnowTitle.textAlignment = UITextAlignmentCenter;
	dontKnowTitle.text = @"Don't know";
	[self addSubview:dontKnowTitle];
	[dontKnowTitle release];
	
	if (_learningType == FILearningProccesTypeTest) {
		UILabel *notSureTitle = [[UILabel alloc] initWithFrame:CGRectMake(dontKnowTitle.frame.origin.x+dontKnowTitle.frame.size.width+20,
																		  self.frame.size.height-165,
																		  _notSureImageView.frame.size.width,
																		  50)];
		notSureTitle.backgroundColor = [UIColor clearColor];
		notSureTitle.textColor = [UIColor whiteColor];
		notSureTitle.numberOfLines = 2;
		notSureTitle.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
		notSureTitle.shadowOffset = CGSizeMake(-0.5f,0.5f);
		notSureTitle.font = [UIFont fontWithName:@"Helvetica" size:18];
		notSureTitle.textAlignment = UITextAlignmentCenter;
		notSureTitle.text = @"Not\nsure";
		[self addSubview:notSureTitle];
		[notSureTitle release];
	}
	
	UILabel *knowTitle = [[UILabel alloc] initWithFrame:CGRectMake(dontKnowTitle.frame.origin.x+2*dontKnowTitle.frame.size.width+40,
																	   self.frame.size.height-175,
																	   _knowImageView.frame.size.width,
																	   50)];
	knowTitle.backgroundColor = [UIColor clearColor];
	knowTitle.textColor = [UIColor whiteColor];
	knowTitle.numberOfLines = 2;
	knowTitle.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
	knowTitle.shadowOffset = CGSizeMake(-0.5f,0.5f);
	knowTitle.font = [UIFont fontWithName:@"Helvetica" size:18];
	knowTitle.textAlignment = UITextAlignmentCenter;
	knowTitle.text = @"Know";
	[self addSubview:knowTitle];
	[knowTitle release];
	
	_dontKnowLabel = [[UILabel alloc] initWithFrame:CGRectMake(21,
																	   self.frame.size.height-135,
																	   _dontKnowImageView.frame.size.width,
																	   100)];
	_dontKnowLabel.backgroundColor = [UIColor clearColor];
	_dontKnowLabel.textColor = [UIColor whiteColor];
	_dontKnowLabel.numberOfLines = 2;
	_dontKnowLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
	_dontKnowLabel.shadowOffset = CGSizeMake(-0.5f,0.5f);
	_dontKnowLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
	_dontKnowLabel.textAlignment = UITextAlignmentCenter;
	_dontKnowLabel.text = @"0%";
	[self addSubview:_dontKnowLabel];
	[_dontKnowLabel release];
	
	if (_learningType == FILearningProccesTypeTest) {
		_notSureLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dontKnowLabel.frame.origin.x+_dontKnowLabel.frame.size.width+20,
																			self.frame.size.height-135,
																			_notSureImageView.frame.size.width,
																			100)];
		_notSureLabel.backgroundColor = [UIColor clearColor];
		_notSureLabel.textColor = [UIColor whiteColor];
		_notSureLabel.numberOfLines = 2;
		_notSureLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
		_notSureLabel.shadowOffset = CGSizeMake(-0.5f,0.5f);
		_notSureLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
		_notSureLabel.textAlignment = UITextAlignmentCenter;
		_notSureLabel.text = @"0%";
		[self addSubview:_notSureLabel];
		[_notSureLabel release];
	}
	
	_knowLabel = [[UILabel alloc] initWithFrame:CGRectMake(_dontKnowLabel.frame.origin.x+2*_dontKnowLabel.frame.size.width+40,
																	   self.frame.size.height-135,
																	   _knowImageView.frame.size.width,
																	   100)];
	_knowLabel.backgroundColor = [UIColor clearColor];
	_knowLabel.textColor = [UIColor whiteColor];
	_knowLabel.numberOfLines = 2;
	_knowLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4f];
	_knowLabel.shadowOffset = CGSizeMake(-0.5f,0.5f);
	_knowLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
	_knowLabel.textAlignment = UITextAlignmentCenter;
	_knowLabel.text = @"0%";
	[self addSubview:_knowLabel];
	[_knowLabel release];
	
	UILabel *plannedLabel = [[UILabel alloc] initWithFrame:CGRectMake(_knowLabel.frame.origin.x+_knowLabel.frame.size.width+20,
																	self.frame.size.height-160,
																	120,
																	50)];
	plannedLabel.backgroundColor = [UIColor clearColor];
	plannedLabel.textColor = [UIColor colorWithRed:214.0/255.0 green:154.0/255.0 blue:87.0/255.0 alpha:0.7f];
	plannedLabel.adjustsFontSizeToFitWidth = YES;
	plannedLabel.shadowColor = [UIColor whiteColor];
	plannedLabel.shadowOffset = CGSizeMake(0.5f,0.5f);
	plannedLabel.font = [UIFont fontWithName:@"Helvetica" size:30];
	plannedLabel.textAlignment = UITextAlignmentCenter;
	if (_result) {
		plannedLabel.text = [NSString stringWithFormat:@"%d",[[_result objectForKey:@"planned"] intValue]];
	}
	[self addSubview:plannedLabel];
	[plannedLabel release];
	
	UILabel *viewdLabel = [[UILabel alloc] initWithFrame:CGRectMake(_knowLabel.frame.origin.x+_knowLabel.frame.size.width+20,
																	  self.frame.size.height-105,
																	  120,
																	  50)];
	viewdLabel.backgroundColor = [UIColor clearColor];
	viewdLabel.textColor = [UIColor colorWithRed:214.0/255.0 green:154.0/255.0 blue:87.0/255.0 alpha:0.7f];
	viewdLabel.adjustsFontSizeToFitWidth = YES;
	viewdLabel.shadowColor = [UIColor whiteColor];
	viewdLabel.shadowOffset = CGSizeMake(0.5f,0.5f);
	viewdLabel.font = [UIFont fontWithName:@"Helvetica" size:30];
	viewdLabel.textAlignment = UITextAlignmentCenter;
	if (_result) {
		viewdLabel.text = [NSString stringWithFormat:@"%d",[[_result objectForKey:@"viewed"] intValue]];
	}
	[self addSubview:viewdLabel];
	[viewdLabel release];
	
}

-(void)initButtons{
	UIButton *quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *quitButtonImage = [UIImage imageNamed:@"i_results_quit1.png"];
	quitButton.frame = CGRectMake(20, self.frame.size.height-quitButtonImage.size.height-12, quitButtonImage.size.width, quitButtonImage.size.height);
	[quitButton setImage:quitButtonImage forState:UIControlStateNormal];
	[quitButton setImage:[UIImage imageNamed:@"i_results_quit2.png"] forState:UIControlStateHighlighted];
	[quitButton addTarget:self
				   action:@selector(quitButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:quitButton];
	
	UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *continueButtonImage = [UIImage imageNamed:@"i_results_continue1.png"];
	continueButton.frame = CGRectMake(280, self.frame.size.height-12-continueButtonImage.size.height, continueButtonImage.size.width, continueButtonImage.size.height);
	[continueButton setImage:continueButtonImage forState:UIControlStateNormal];
	[continueButton setImage:[UIImage imageNamed:@"i_results_continue2.png"] forState:UIControlStateHighlighted];
	[continueButton addTarget:self
				   action:@selector(continueButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:continueButton];
}

#pragma mark -

#pragma mark -
#pragma mark private

-(void)addStepToKnow{
    
	if (_knowVal<=0) {
		[_knowTimer invalidate];
		_knowTimer = nil;
		return;
	}
	
	if (_knowImageView.alpha<1e-14) {
		[UIView beginAnimations:nil context:nil];
		_knowImageView.alpha = 1.0;
		[UIView commitAnimations];
	}
	
	_knowVal--;
	
	CGRect knowFrame = _knowImageView.frame;
	knowFrame.origin.y -= step;
	knowFrame.size.height += step;
	_knowImageView.frame = knowFrame;
	CGFloat viewed = (CGFloat)[[_result objectForKey:@"viewed"] intValue];
	NSInteger knowV = ([[_result objectForKey:@"kn"] intValue]/viewed)*100;
	_knowLabel.text = [NSString stringWithFormat:@"%d%%",knowV-_knowVal];
    [self playSound];
}

-(void)addStepToDontKnow{
	if (_dontKnowVal<=0) {
		[_dontKnowTimer invalidate];
		_dontKnowTimer = nil;
		return;
	}
	
	if (_dontKnowImageView.alpha<1e-14) {
		[UIView beginAnimations:nil context:nil];
		_dontKnowImageView.alpha = 1.0;
		[UIView commitAnimations];
	}

	_dontKnowVal--;
	
	CGRect dontKnowFrame = _dontKnowImageView.frame;
	dontKnowFrame.origin.y -= step;
	dontKnowFrame.size.height += step;
	_dontKnowImageView.frame = dontKnowFrame;
	CGFloat viewed = (CGFloat)[[_result objectForKey:@"viewed"] intValue];
	NSInteger dontKnowV = ([[_result objectForKey:@"dk"] intValue]/viewed)*100;
	_dontKnowLabel.text = [NSString stringWithFormat:@"%d%%",dontKnowV-_dontKnowVal];
    [self playSound];
}

-(void)addStepToNotSure{
	if (_notSureVal<=0) {
		[_notSureTimer invalidate];
		_notSureTimer = nil;
		return;
	}
	
	if (_notSureImageView.alpha<1e-14) {
		[UIView beginAnimations:nil context:nil];
		_notSureImageView.alpha = 1.0;
		[UIView commitAnimations];
	}
	
	_notSureVal--;
	
	CGRect notSureFrame = _notSureImageView.frame;
	notSureFrame.origin.y -= step;
	notSureFrame.size.height += step;
	_notSureImageView.frame = notSureFrame;
	CGFloat viewed = (CGFloat)[[_result objectForKey:@"viewed"] intValue];
	NSInteger notSureV = ([[_result objectForKey:@"ns"] intValue]/viewed)*100;
	_notSureLabel.text = [NSString stringWithFormat:@"%d%%",notSureV-_notSureVal];
    [self playSound];
}

-(void)playSound{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(playerCalc);
    }
}

#pragma mark -

#pragma mark -
#pragma mark targets

-(void)quitButtonPressed:(id)sender{
	if (delegate && [delegate respondsToSelector:@selector(quitSelected)]) {
		[delegate quitSelected];
	}
}
-(void)continueButtonPressed:(id)sender{
	if (delegate && [delegate respondsToSelector:@selector(cancelSelected)]) {
		[delegate cancelSelected];
	}
}

#pragma mark -

@end
