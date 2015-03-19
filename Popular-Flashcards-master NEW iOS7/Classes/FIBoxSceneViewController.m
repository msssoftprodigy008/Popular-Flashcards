    //
//  FIBoxSceneViewController.m
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIBoxSceneViewController.h"
#import "FDBController.h"
#import "DBTime.h"
#import "Util.h"

#import "Constant.h"
@interface FIBoxSceneViewController(Private)

-(void)initAxilluryStaticViews;
-(void)createLeftBox;
-(void)createRightBox;
-(void)createBottomBox;

-(void)moveLeftBox:(FIBoxMovingDirection)direction;
-(void)moveRightBox:(FIBoxMovingDirection)direction;
-(void)moveBottomBox:(FIBoxMovingDirection)direction;

-(void)seeLeftBox;
-(void)seeRightBox;
-(void)seeBotomBox;

-(void)hideLeftBox;
-(void)hideRightBox;
-(void)hideBottomBox;

-(void)pausePressed;

-(void)chooseActiveBoxToPoint:(CGPoint)point;
-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP;

-(void)hidePanels:(NSTimer*)timer;
-(void)seePanels;

-(void)clearSession;

-(void)leftPressed;
-(void)rightPressed;
-(void)bottomPressed;
-(void)soundButtonPressed;

-(void)quitPressed;
-(void)setVersion;
-(void)upgraded;

-(void)makeSoundCardFalls;
-(void)makeSoundCardTurn;
-(void)makeSoundBoxIn;
-(void)makeSoundBoxOut;

-(void)restoreController;
-(void)prepareToExit;

-(void)initSlideView;
-(void)showSlideView:(NSInteger)days;
-(void)hideSlideView;

-(void)initSoundSettings;
-(void)saveSoundSettings;

-(void)initLearningResultView;
-(void)closeLearningView;
-(void)regularShadow;

@end


@implementation FIBoxSceneViewController
@synthesize delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id)createLearningProcces:(FILearningProccesType)type forCategory:(NSString*)Acategory
{
	proccesType = type;
	
	if (Acategory) {
		category = [[NSString alloc] initWithString:Acategory];
	}
	
	learnController = [[FILearningController alloc] initWithCategory:Acategory forType:type];
	
	return [self init];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc] init];
    UIImageView *bg = [[UIImageView alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                contentView.frame = CGRectMake(0,0,568,320);
                bg.frame = CGRectMake(0,0,568,320);
            }
            else{
                contentView.frame = CGRectMake(0,0,568,300);
                bg.frame = CGRectMake(0,0,568,320);
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                contentView.frame = CGRectMake(0,0,480,320);
                bg.frame = CGRectMake(0,0,480,320);
            }
            else{
                contentView.frame = CGRectMake(0,0,480,300);
                bg.frame = CGRectMake(0,0,480,320);
            }
        }
	}
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[contentView release];
	
	
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
       bg.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90]; 
    }else{
       bg.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:-90];  
    }
	
	[self.view addSubview:bg];
	[bg	release];
	
	
	NSArray *card = [learnController learningArray];
	isDeckEnded = NO;
    isButtonLocked = NO;
	
	if (card && [card count]>0) {
		deck = [[FICardsDeckController alloc] initWithCardsArray:card forCategory:category];
        NSLog(@"deck frame:%@",[deck.view description]);
		deck.delegate = self;
		deck.isUsingPref = NO;
		[self.view addSubview:deck.view];
		[card release];
	
		activeBox = FIActiveBoxNone;
		prevBox = FIActiveBoxNone;
    }
	
	[self setVersion];
	
	
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(upgraded)
												 name:@"upgraded"
											   object:nil];
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BoxIn" ofType:@"caf"]], &playerInBox);

    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BoxOut" ofType:@"caf"]], &playerOutBox);
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CardFlip" ofType:@"wav"]], &playerCardTurn);
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CardFall" ofType:@"wav"]], &playerCardFalls);
	
	isFallBlock = NO;
	isTurnBlock = NO;
	isBoxInBlock = NO;
	isBoxOutBlock = NO;
	isPaused = NO;
	
	//[self initSoundSettings];
        isSoundOn = YES;
	[[AVAudioSession sharedInstance] setActive:isSoundOn error:nil];
    

	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[UIApplication sharedApplication].statusBarHidden = YES;
    [super viewDidLoad];
	
	_learningBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,1024,1024)];
	_learningBgView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
	
	[self createLeftBox];
	[self createRightBox];
	
	
	if (proccesType == FILearningProccesTypeTest) {
		[self createBottomBox];
		[self.view bringSubviewToFront:bottomButton];
	}
	NSLog(@"%@",[self.view description]);
	[self initAxilluryStaticViews];
	[self.view bringSubviewToFront:deck.view];
	[self.view bringSubviewToFront:backButton];	
	
	[self initSlideView];
}

-(void)viewDidAppear:(BOOL)animated
{
	[self restoreController];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([Util isPhone]) {
        
    
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)pauseTest
{
	if (!isPaused) {
		[self pausePressed];
	}
}

#pragma mark -
#pragma mark deck delegate

-(void)draggingBeganAtPoint:(CGPoint)beganPoint
{
    isButtonLocked = YES;
	[self seeLeftBox];
	[self seeRightBox];
	
	if (proccesType == FILearningProccesTypeTest) {
		[self seeBotomBox];
	}
	
	[self chooseActiveBoxToPoint:beganPoint];
	
	
	
}

-(void)cardMovedToPoint:(CGPoint)movedPointTo
{
	[self chooseActiveBoxToPoint:movedPointTo];
	
}

-(void)draggingEndedAtPoint:(CGPoint)endedPoint
{
	NSDictionary *stat = [learnController statisticForSession];
	NSInteger updateAfter = -1;
   	switch (activeBox) {
		case FIActiveBoxNone:
			[deck normalizeState];
			[self hideLeftBox];
			[self hideRightBox];
			
			if (proccesType == FILearningProccesTypeTest) {
				[self hideBottomBox];
			}
			isButtonLocked = NO;
			break;
		case FIActiveBoxLeft:
            
			updateAfter = [learnController updateAnswer:[deck getCurrentId] forAnswer:0];
			leftCountLabel.text = [NSString stringWithFormat:@"%d",[[stat objectForKey:@"wrong"] intValue]+1];
            CGPoint pointToFall = [leftCoverView convertPoint:CGPointMake(30+rand()%15,30+rand()%15)
                                                       toView:self.view];
			[deck animateFallingAtCenter:pointToFall];
            [self makeSoundCardFalls];
			break;
		case FIActiveBoxRight:
            
            updateAfter = [learnController updateAnswer:[deck getCurrentId] forAnswer:2];
			rightCountLabel.text = [NSString stringWithFormat:@"%d",[[stat objectForKey:@"right"] intValue]+1];
            CGPoint pointToFall2 = [rightCoverView convertPoint:CGPointMake(30+rand()%15,30+rand()%15)
                                                         toView:self.view];
			[deck animateFallingAtCenter:pointToFall2];
            
            [self makeSoundCardFalls];
			break;
		case FIActiveBoxBottom:
            updateAfter = [learnController updateAnswer:[deck getCurrentId] forAnswer:1];
			bottomCountLabel.text = [NSString stringWithFormat:@"%d",[[stat objectForKey:@"notSure"] intValue]+1];
			CGPoint pointToFall3 = [bottomCoverView convertPoint:CGPointMake(30+rand()%15,30+rand()%15)
                                                          toView:self.view];
			[deck animateFallingAtCenter:pointToFall3];
			break;
		default:
			break;
	}
	
	[self performSelector:@selector(hideSlideView)
			   withObject:nil
			   afterDelay:1.0f];
}

-(void)cardFallingWillBegin
{

}

-(void)cardFallingDidEnd
{
    [self makeSoundCardFalls];
    [self performSelector:@selector(regularShadow) withObject:nil afterDelay:0.35];
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(clearSession) userInfo:nil repeats:NO];
}

-(void)cardTurned:(BOOL)isQuestion
{
	[self makeSoundCardTurn];
}

-(FILearningProccesType)learningType{
	return	proccesType;
}

-(void)deckEnded
{
     deck.view.userInteractionEnabled = YES;
    NSString *message;
    isDeckEnded = YES;
    
    if (proccesType == FILearningProccesTypeTest) {
        message =@"You have tested all the cards scheduled for today.";
    }else {
        message = @"You have studied all the cards scheduled for this session.";
    }
    
    
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Good Job!"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    alertView.tag = 100;
    [alertView show];
    [alertView release];
    
//    self.view.userInteractionEnabled = YES;
//    deck.view.userInteractionEnabled = YES;
//	isDeckEnded = YES;
//
//	if (proccesType == FILearningProccesTypeTest) {
//        
//        
//        
//        RIAlertView *alertView = [[RIAlertView alloc] initWithTitle:@"Test"
//                                                        message:@"You have tested all the cards scheduled for today."
//                                                   buttonTitles:[NSArray arrayWithObject:@"OK"]];
//        alertView.delegate = self;
//        [alertView showInView:self.view];
//        [alertView release];
//        
//        
//        
//    }else{
//        RIAlertView *alertView = [[RIAlertView alloc] initWithTitle:@"Study"
//                                                            message:@"You have studied all the cards scheduled for today."
//                                                       buttonTitles:[NSArray arrayWithObject:@"OK"]];
//        alertView.delegate = self;
//        [alertView showInView:self.view];
//        [alertView release];
//    }
}

-(void)cardIdChangedTo:(NSInteger)cardId
{

}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark myAdView delegate

-(void)iAdFailed{
    [adView tryGAD:GAD_SIZE_468x60];
    adView.frame = CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 60);
}

-(void)adMobFailed{
    
}

-(void)gAdFailed{
    
}

#pragma mark -

#pragma mark -
#pragma mark RIAlertViewDelegate

-(void)clickedButtonAtIndex:(RIAlertView*)alertView buttonIndex:(NSInteger)index{
    [self quitPressed];
}

#pragma mark -

#pragma mark -
#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self quitPressed];
}

#pragma mark -
#pragma mark gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	
    return YES;
}

#pragma mark -
#pragma mark UIView delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	
	if (animationID && [animationID isEqualToString:@"exit"]) {
		[self.navigationController popViewControllerAnimated:NO];
	}
	
	
	if (animationID && [animationID isEqualToString:@"learningViewOpen"]) {
		[learnView startShowingResult];
	}
	
	if (animationID && [animationID isEqualToString:@"learningViewClose"]) {
		[_learningBgView removeFromSuperview];
		[learnView removeFromSuperview];
		[learnView release];
		learnView = nil;
	}
}

#pragma mark -

#pragma mark -
#pragma mark after pause

-(void)quitPressed
{
    if (![Util isFullVersion] && adView && adView._delegate) {
        adView._delegate = nil;
    }
    
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	[[AVAudioSession sharedInstance] setActive:NO error:nil];
	//[self saveSoundSettings];
	
	NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithDictionary:                            [learnController statisticForSession]];
    
	[resultDic setObject:[NSNumber numberWithInt:deck.currentId] forKey:@"viewed"];
	[resultDic setObject:[DBTime shortStringFromDBDay:[DBTime Today]] forKey:@"date"];
	
	if (proccesType == FILearningProccesTypeTest) {
		[[NSUserDefaults standardUserDefaults] setObject:resultDic forKey:[NSString stringWithFormat:@"lastTest%@",category]];
	}else {
		[[NSUserDefaults standardUserDefaults] setObject:resultDic forKey:[NSString stringWithFormat:@"lastStudy%@",category]];
	}

	
	if (delegate && [delegate respondsToSelector:@selector(learningResult:forResult:)]) {
		[delegate learningResult:proccesType forResult:resultDic];
	}
	
	
	
	if (delegate && [delegate respondsToSelector:@selector(learningWillEnd:animated:)]) {
		[delegate learningWillEnd:category animated:isDeckEnded];
	}
	
	[self performSelector:@selector(prepareToExit)
			   withObject:nil afterDelay:0.2f];
}

-(void)continuePressed
{
    if (adView._delegate) {
        adView._delegate = nil;
    }
    
    isButtonLocked = NO;
	isPaused = NO;	
    [adView hide:NO];
    adView = nil;
}



#pragma mark -
#pragma mark private methods

-(void)upgraded
{
	
}

-(void)setVersion
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
		isFullVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"version"] boolValue];
	}else {
		isFullVersion = NO;
	}
	
	
	
}

-(void)initSoundSettings
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"TSound"]) {
		isSoundOn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TSound"] boolValue];
	}else {
		isSoundOn = YES;
	}

}

-(void)saveSoundSettings
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isSoundOn] forKey:@"TSound"];
}

-(void)initAxilluryStaticViews{
	backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *backButtonImage = [UIImage imageNamed:@"i_test_arrow1.png"];
	backButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)+backButtonImage.size.width,
								  320-backButtonImage.size.height,
								  backButtonImage.size.width,
								  backButtonImage.size.height);
	[backButton setImage:backButtonImage forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_test_arrow2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(pausePressed) forControlEvents:UIControlEventTouchUpInside];
    backButton.exclusiveTouch = YES;
	[self.view addSubview:backButton];
	
}

-(void)createLeftBox
{
	leftBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box.png"]];
    leftBox.center = CGPointMake(-leftBox.frame.size.width/2.0,160);
	leftBox.backgroundColor = [UIColor clearColor];
	
    leftCoverView = [[UIImageView alloc] initWithFrame:kBoxImageFrame];
    [leftBox addSubview:leftCoverView];
    [leftCoverView release];
    
	leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButtonImage = [UIImage imageNamed:@"i_test_dont1.png"];
    leftButton.frame = CGRectMake(-leftButtonImage.size.width,
                                  160-leftButtonImage.size.height/2.0,
                                  leftButtonImage.size.width,
                                  leftButtonImage.size.height);
	[leftButton setImage:leftButtonImage forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"i_test_dont2.png"] forState:UIControlStateHighlighted];
	[leftButton addTarget:self action:@selector(leftPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.exclusiveTouch = YES;
	leftButton.tag = -111;
	
	[deck.view addSubview:leftButton];
	[deck.view addSubview:leftBox];
	
	leftCountLabel = [[UILabel alloc] initWithFrame:kBoxLabelFrame];
	leftCountLabel.backgroundColor = [UIColor clearColor];
    leftCountLabel.adjustsFontSizeToFitWidth = YES;
	leftCountLabel.font = kBoxCountLabelFont;
	leftCountLabel.textColor = kBoxCountLabelTextColor;
    leftCountLabel.shadowColor = kBoxCountLabelShadowColor;
    leftCountLabel.shadowOffset = kBoxCountLabelShadowOffset;
	leftCountLabel.textAlignment = UITextAlignmentCenter;
	leftCountLabel.text = @"0";
	[leftBox addSubview:leftCountLabel];
	leftCountLabel.tag = 2307;
	[leftCountLabel release];
	
	[leftBox release];
    
    leftBoxShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box_shadow.png"]];
    leftBoxShadow.center = CGPointMake(leftBox.frame.size.width/2.0,leftBox.frame.size.height/2.0);
    [leftBox addSubview:leftBoxShadow];
    
    UILabel *boxNameLabel = [[UILabel alloc] initWithFrame:kBoxNameFrame];
    boxNameLabel.backgroundColor = [UIColor clearColor];
    boxNameLabel.adjustsFontSizeToFitWidth = YES;
    boxNameLabel.font = kBoxNameFont;
    boxNameLabel.textColor = kBoxCountLabelTextColor;
    boxNameLabel.shadowColor = kBoxCountLabelShadowColor;
    boxNameLabel.shadowOffset = kBoxCountLabelShadowOffset;
    boxNameLabel.textAlignment = UITextAlignmentCenter;
    boxNameLabel.text = @"Don't know";
    [leftBox addSubview:boxNameLabel];
    [boxNameLabel release];
    
}

-(void)createRightBox
{
	rightBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box.png"]];
    rightBox.center = CGPointMake(((IS_IPHONE_5)?568:480)+rightBox.frame.size.width/2.0,160);
	rightBox.backgroundColor = [UIColor clearColor];
	
    NSLog(@"%f",rightBox.center.x);
    rightCoverView = [[UIImageView alloc] initWithFrame:kBoxImageFrame];
    [rightBox addSubview:rightCoverView];
    [rightCoverView release];
    
	rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButtonImage = [UIImage imageNamed:@"i_test_know1.png"];
    rightButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
                                   160-rightButtonImage.size.height/2.0,
                                   rightButtonImage.size.width,
                                   rightButtonImage.size.height);
	[rightButton setImage:rightButtonImage forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"i_test_know2.png"] forState:UIControlStateHighlighted];
	[rightButton addTarget:self action:@selector(rightPressed) forControlEvents:UIControlEventTouchUpInside];
	rightButton.tag = -112;
    rightButton.exclusiveTouch = YES;
	
	NSLog(@"%@",[deck.view description]);
	[deck.view addSubview:rightBox];
	[deck.view addSubview:rightButton];
	[rightBox release];
	
    rightCountLabel = [[UILabel alloc] initWithFrame:kBoxLabelFrame];
	rightCountLabel.backgroundColor = [UIColor clearColor];
    rightCountLabel.adjustsFontSizeToFitWidth = YES;
	rightCountLabel.font = kBoxCountLabelFont;
	rightCountLabel.textColor = kBoxCountLabelTextColor;
    rightCountLabel.shadowColor = kBoxCountLabelShadowColor;
    rightCountLabel.shadowOffset = kBoxCountLabelShadowOffset;
	rightCountLabel.textAlignment = UITextAlignmentCenter;
	rightCountLabel.text = @"0";
	[rightBox addSubview:rightCountLabel];
	rightCountLabel.tag = 2307;
	[rightCountLabel release];
	
    rightBoxShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box_shadow.png"]];
    rightBoxShadow.center = CGPointMake(rightBox.frame.size.width/2.0,rightBox.frame.size.height/2.0);
    [rightBox addSubview:rightBoxShadow];
    
    UILabel *boxNameLabel = [[UILabel alloc] initWithFrame:kBoxNameFrame];
    boxNameLabel.backgroundColor = [UIColor clearColor];
    boxNameLabel.font = kBoxNameFont;
    boxNameLabel.adjustsFontSizeToFitWidth = YES;
    boxNameLabel.textColor = kBoxCountLabelTextColor;
    boxNameLabel.shadowColor = kBoxCountLabelShadowColor;
    boxNameLabel.shadowOffset = kBoxCountLabelShadowOffset;
    boxNameLabel.textAlignment = UITextAlignmentCenter;
    boxNameLabel.text = @"Know";
    [rightBox addSubview:boxNameLabel];
    [boxNameLabel release];
}

-(void)createBottomBox
{
	bottomBox = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box.png"]];
    CGRect nameFrame = kBoxNameFrame;
	bottomBox.center = CGPointMake(((IS_IPHONE_5)?284:240), 320+(bottomBox.frame.size.height+nameFrame.size.height)/2.0);
	
    bottomCoverView = [[UIImageView alloc] initWithFrame:kBoxImageFrame];
    [bottomBox addSubview:bottomCoverView];
    [bottomCoverView release];
    
	bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *bottomButtonImage = [UIImage imageNamed:@"i_test_notsure1.png"];
    bottomButton.frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomButtonImage.size.width/2.0, 320, bottomButtonImage.size.width, bottomButtonImage.size.height);
	[bottomButton setImage:bottomButtonImage forState:UIControlStateNormal];
    [bottomButton setImage:[UIImage imageNamed:@"i_test_notsure2.png"] forState:UIControlStateHighlighted];
	bottomButton.titleLabel.textColor = kBoxCountLabelTextColor;
	[bottomButton addTarget:self action:@selector(bottomPressed) forControlEvents:UIControlEventTouchUpInside];
	bottomButton.tag = -113;
    bottomButton.exclusiveTouch = YES;
		
	[deck.view addSubview:bottomBox];
	[deck.view addSubview:bottomButton];
	[bottomBox release];
	
	
	bottomCountLabel = [[UILabel alloc] initWithFrame:kBoxLabelFrame];
	bottomCountLabel.backgroundColor = [UIColor clearColor];
    bottomCountLabel.adjustsFontSizeToFitWidth = YES;
	bottomCountLabel.font = kBoxCountLabelFont;
	bottomCountLabel.textColor = kBoxCountLabelTextColor;
    bottomCountLabel.shadowColor = kBoxCountLabelShadowColor;
    bottomCountLabel.shadowOffset = kBoxCountLabelShadowOffset;
	bottomCountLabel.textAlignment = UITextAlignmentCenter;
	bottomCountLabel.text = @"0";
	[bottomBox addSubview:bottomCountLabel];
	bottomCountLabel.tag = 2307;
	[bottomCountLabel release];
	
    bottomBoxShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_box_shadow.png"]];
    bottomBoxShadow.center = CGPointMake(bottomBox.frame.size.width/2.0,bottomBox.frame.size.height/2.0);
    [bottomBox addSubview:bottomBoxShadow];
    
    UILabel *boxNameLabel = [[UILabel alloc] initWithFrame:kBoxNameFrame];
    boxNameLabel.backgroundColor = [UIColor clearColor];
    boxNameLabel.font = kBoxNameFont;
    boxNameLabel.adjustsFontSizeToFitWidth = YES;
    boxNameLabel.textColor = kBoxCountLabelTextColor;
    boxNameLabel.shadowColor = kBoxCountLabelShadowColor;
    boxNameLabel.shadowOffset = kBoxCountLabelShadowOffset;
    boxNameLabel.textAlignment = UITextAlignmentCenter;
    boxNameLabel.text = @"Not Sure";
    [bottomBox addSubview:boxNameLabel];
    [boxNameLabel release];
    

}

-(void)moveLeftBox:(FIBoxMovingDirection)direction
{
	CGRect frame;
	
	if (direction == FIBoxMovingDirectionForward) {
		frame = CGRectMake(kBoxBorderDistance,
						   160-leftBox.frame.size.height/2.0,
						   leftBox.frame.size.width,
						   leftBox.frame.size.height);
	}
	else {
		frame = CGRectMake(-kBoxVisiblePart*leftBox.frame.size.width,
						   160-leftBox.frame.size.height/2.0,
						   leftBox.frame.size.width,
						   leftBox.frame.size.height);
	}
   
    [[FIAnimationController sharedAnimation:nil] changeFrame:leftBox toFrame:frame];
   	[self makeSoundBoxIn];
}

-(void)moveRightBox:(FIBoxMovingDirection)direction
{
	CGRect frame;
	
	if (direction == FIBoxMovingDirectionForward) {
		frame = CGRectMake(((IS_IPHONE_5)?568:480)-rightBox.frame.size.width-kBoxBorderDistance,
						   160-rightBox.frame.size.height/2.0,
						   rightBox.frame.size.width,
						   rightBox.frame.size.height);
	}
	else {
		frame = CGRectMake(((IS_IPHONE_5)?568:480)-(1.0-kBoxVisiblePart)*rightBox.frame.size.width,
						   160-rightBox.frame.size.height/2.0,
						   rightBox.frame.size.width,
						   rightBox.frame.size.height);
	}
   
    [[FIAnimationController sharedAnimation:nil] changeFrame:rightBox toFrame:frame];
   	[self makeSoundBoxIn];
}

-(void)moveBottomBox:(FIBoxMovingDirection)direction
{
	CGRect frame;
	
	if (direction == FIBoxMovingDirectionForward) {
		frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomBox.frame.size.width/2.0,
						   320-bottomBox.frame.size.height-bottomCountLabel.frame.size.height-kBoxBorderDistance+15,
						   bottomBox.frame.size.width,
						   bottomBox.frame.size.height);
	}
	else {
		frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomBox.frame.size.width/2.0,
						   320-(1.0-kBoxVisiblePart)*bottomBox.frame.size.height,
						   bottomBox.frame.size.width,
						   bottomBox.frame.size.height);
	}
  
   	[[FIAnimationController sharedAnimation:nil] changeFrame:bottomBox toFrame:frame];
  	[self makeSoundBoxIn];
}

-(void)seeLeftBox
{
	//[deck.view bringSubviewToFront:leftBox];
	
	CGRect frame = CGRectMake(-kBoxVisiblePart*leftBox.frame.size.width,
					   160-leftBox.frame.size.height/2.0,
					   leftBox.frame.size.width,
					   leftBox.frame.size.height);
	CGRect frame1 = CGRectMake(-leftButton.frame.size.width,
                               160-leftButton.frame.size.height/2.0,
                               leftButton.frame.size.width,
                               leftButton.frame.size.height);
    
    [[FIAnimationController sharedAnimation:nil] changeFrame:leftBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:leftButton toFrame:frame1];
    [self makeSoundBoxIn];
}

-(void)seeRightBox
{
	//[deck.view bringSubviewToFront:rightBox];
	
	CGRect frame = CGRectMake(((IS_IPHONE_5)?568:480)-(1.0-kBoxVisiblePart)*rightBox.frame.size.width,
                              160-rightBox.frame.size.height/2.0,
                              rightBox.frame.size.width,
                              rightBox.frame.size.height);
	CGRect frame1 = CGRectMake(((IS_IPHONE_5)?568:480),
                               160-rightButton.frame.size.height/2.0,
                               rightButton.frame.size.width,
                               rightButton.frame.size.height);
	[[FIAnimationController sharedAnimation:nil] changeFrame:rightBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:rightButton toFrame:frame1];
    [self makeSoundBoxIn];
}

-(void)seeBotomBox
{
    CGRect frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomBox.frame.size.width/2.0,
                              320-(1.0-kBoxVisiblePart)*bottomBox.frame.size.height,
                              bottomBox.frame.size.width,
                              bottomBox.frame.size.height);
	CGRect frame1 = CGRectMake(((IS_IPHONE_5)?284:240)-bottomButton.frame.size.width/2.0,
                               320,
                               bottomButton.frame.size.width,
                               bottomButton.frame.size.height);
	[[FIAnimationController sharedAnimation:nil] changeFrame:bottomBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:bottomButton toFrame:frame1];
    [self makeSoundBoxIn];
}

-(void)hideLeftBox
{
	CGRect frame = CGRectMake(-leftBox.frame.size.width,
                              160-leftBox.frame.size.height/2.0,
                              leftBox.frame.size.width,
                              leftBox.frame.size.height);
	CGRect frame1 = CGRectMake(0,
                               160-leftButton.frame.size.height/2.0,
                               leftButton.frame.size.width,
                               leftButton.frame.size.height);
    [[FIAnimationController sharedAnimation:nil] changeFrame:leftBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:leftButton toFrame:frame1];
    [self makeSoundBoxOut];
}

-(void)hideRightBox
{
	CGRect frame = CGRectMake((IS_IPHONE_5)?568:480,
                              160-rightBox.frame.size.height/2.0,
                              rightBox.frame.size.width,
                              rightBox.frame.size.height);
	CGRect frame1 = CGRectMake(((IS_IPHONE_5)?568:480)-rightButton.frame.size.width,
                               160-rightButton.frame.size.height/2.0,
                               rightButton.frame.size.width,
                               rightButton.frame.size.height);
	[[FIAnimationController sharedAnimation:nil] changeFrame:rightBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:rightButton toFrame:frame1];
    [self makeSoundBoxOut];
}

-(void)hideBottomBox
{
    CGRect nameFrame = kBoxNameFrame;
	CGRect frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomBox.frame.size.width/2.0,
                              320+nameFrame.size.height,
                              bottomBox.frame.size.width,
                              bottomBox.frame.size.height);
	CGRect frame1 = CGRectMake(((IS_IPHONE_5)?284:240)-bottomButton.frame.size.width/2.0,
                               320-bottomButton.frame.size.height,
                               bottomButton.frame.size.width,
                               bottomButton.frame.size.height);
	
    [[FIAnimationController sharedAnimation:nil] changeFrame:bottomBox toFrame:frame];
	[[FIAnimationController sharedAnimation:nil] changeFrame:bottomButton toFrame:frame1];
    
	[self makeSoundBoxOut];
}

-(void)pausePressed
{
    if (isButtonLocked) {
        return;
    }
    
	isPaused = YES;
    isButtonLocked = YES;
	[deck stopSounds];
	[self initLearningResultView];
	
    if (![Util isFullVersion]) {
        if (!adView) {
            if ([Util isPhone]) {
                
            
                  if (IS_IPHONE_5) {
                      adView = [[myAdView alloc] initWithFrame:CGRectMake( 0, 0, 568, 50)
                                                delegate:self];
                    }else
                    {
                   adView = [[myAdView alloc] initWithFrame:CGRectMake( 0, 0, 480, 50)
                                                   delegate:self];
                    }
            }
            else
            {
            
                adView = [[myAdView alloc] initWithFrame:CGRectMake(0, 0,1024,70)
                                                delegate:self];      //changed sanjeev reddy
            }
            
            adView.backgroundColor = [UIColor clearColor];
            adView.ViewController = [[self.navigationController viewControllers] objectAtIndex:0];
        }
        [adView showInView:_learningBgView animated:YES];
        [adView tryiAd:ADBannerContentSizeIdentifierLandscape];
        [adView release];
    
    }
    
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	[UIView beginAnimations:@"learningViewOpen" context:nil];
	[UIView setAnimationDelay:0.25f];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	
	learnView.center = self.view.center;
	_learningBgView.alpha = 1.0;
	
	[UIView commitAnimations];
	
}

-(void)chooseActiveBoxToPoint:(CGPoint)point
{
	FIActiveBox curActiveBox;
	
	CGFloat v1 = [self calculateDis:point forSec:CGPointMake(((IS_IPHONE_5)?284:240),160)];
	CGFloat v2 = [self calculateDis:point forSec:CGPointMake(0,160)];
	CGFloat v3 = [self calculateDis:point forSec:CGPointMake(((IS_IPHONE_5)?568:480),160)];
	
	CGFloat min = v1;
	curActiveBox = FIActiveBoxNone;
	
	if (min>v2) {
		min = v2;
		curActiveBox = FIActiveBoxLeft;
	}
	
	if (min>v3) {
		min = v3;
		curActiveBox = FIActiveBoxRight;
	}
	
	if (proccesType == FILearningProccesTypeTest) {
		CGFloat v4 = [self calculateDis:point forSec:CGPointMake(((IS_IPHONE_5)?284:240),320)];
		
		if (min>v4) {
			min = v4;
			curActiveBox = FIActiveBoxBottom;
		}
		
	}
	
	if (activeBox != curActiveBox) {
		
		switch (activeBox) {
			case FIActiveBoxLeft:
				[self moveLeftBox:FIBoxMovingDirectionBack];
				break;
			case FIActiveBoxRight:
				[self moveRightBox:FIBoxMovingDirectionBack];
				break;
			case FIActiveBoxBottom:
				[self moveBottomBox:FIBoxMovingDirectionBack];
				break;
			default:
				break;
		}
		
		switch (curActiveBox) {
			case FIActiveBoxLeft:
				[self moveLeftBox:FIBoxMovingDirectionForward];
				if (activeBox!=curActiveBox) {
					[self showSlideView:[learnController getIntervalForAnswer:0]];
				}
				
				break;
			case FIActiveBoxRight:
				[self moveRightBox:FIBoxMovingDirectionForward];
				if (activeBox!=curActiveBox) {
					[self showSlideView:[learnController getIntervalForAnswer:2]];
				}
				break;
			case FIActiveBoxBottom:
				[self moveBottomBox:FIBoxMovingDirectionForward];
				if (activeBox!=curActiveBox) {
					[self showSlideView:[learnController getIntervalForAnswer:1]];
				}
				break;
			default:
				if (activeBox != FIActiveBoxNone) {
					[self hideSlideView];
				}
				break;
		}
		
		
		
				
		activeBox = curActiveBox;
	}
	
	
	
}

-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP
{
	return sqrt((fP.x-sP.x)*(fP.x-sP.x)+(fP.y-sP.y)*(fP.y-sP.y));
}

-(void)clearSession
{
	FIDirection goDirection;

	CALayer *layer = self.view.layer;
	
	switch (activeBox) {
		case FIActiveBoxLeft:
		{
			goDirection = FIDirectionLeft;
            CGRect leftImageFrame = [self.view convertRect:leftCoverView.frame fromView:leftBox];
			UIImage *image = [FIImageUtilits createImageFromScreen:leftImageFrame
														  forLayer:layer ];
			leftCoverView.image = image;
                 
            [leftBoxShadow removeFromSuperview];
            leftBoxShadow.image = [UIImage imageNamed:@"i_test_box_shadow.png"];
            leftBoxShadow.center = CGPointMake(leftBox.frame.size.width/2.0,
                                               leftBox.frame.size.height/2.0);
            [leftBox addSubview:leftBoxShadow];
                    
			break;
		}
		case FIActiveBoxRight:
		{
			goDirection = FIDirectionRight;
            CGRect rightImageFrame = [self.view convertRect:rightCoverView.frame fromView:rightBox];
			UIImage *image = [FIImageUtilits createImageFromScreen:rightImageFrame
														  forLayer:layer ];
			rightCoverView.image = image;
            [rightBoxShadow removeFromSuperview];
            rightBoxShadow.image = [UIImage imageNamed:@"i_test_box_shadow.png"];
            rightBoxShadow.center = CGPointMake(rightBox.frame.size.width/2.0,
                                                rightBox.frame.size.height/2.0);
            [rightBox addSubview:rightBoxShadow];
			break;
		}
		case FIActiveBoxBottom:
		{
			goDirection = FIDirectionDown;
            CGRect bottomImageFrame = [self.view convertRect:bottomCoverView.frame fromView:bottomBox];
			UIImage *image = [FIImageUtilits createImageFromScreen:bottomImageFrame
														  forLayer:layer];
			bottomCoverView.image = image;
            [bottomBoxShadow removeFromSuperview];
            bottomBoxShadow.image = [UIImage imageNamed:@"i_test_box_shadow.png"];
            bottomBoxShadow.center = CGPointMake(bottomBox.frame.size.width/2.0,
                                                 bottomBox.frame.size.height/2.0);
            [bottomBox addSubview:bottomBoxShadow];
                break;
		}
		default:
			break;
	}
    
    [self hideLeftBox];
	[self hideRightBox];
	
	if (proccesType == FILearningProccesTypeTest) {
		[self hideBottomBox];
	}
	
	[deck goAway:goDirection];
    isButtonLocked = NO;
	activeBox = FIActiveBoxNone;
	prevBox = FIActiveBoxNone;
}

-(void)leftPressed
{
    if (isButtonLocked) {
        return;
    }
    isButtonLocked = YES;
    deck.view.userInteractionEnabled = NO;
	activeBox = FIActiveBoxLeft;
    [self showSlideView:[learnController getIntervalForAnswer:0]];
    [self seeLeftBox];
	[self moveLeftBox:FIBoxMovingDirectionForward];
	[deck handleNonDraggingFalling];
    
}

-(void)rightPressed
{
    if (isButtonLocked) {
        return;
    }
    isButtonLocked = YES;
    deck.view.userInteractionEnabled = NO;
	activeBox = FIActiveBoxRight;
    [self showSlideView:[learnController getIntervalForAnswer:2]];
    [self seeRightBox];
	[self moveRightBox:FIBoxMovingDirectionForward];
	[deck handleNonDraggingFalling];
    
}

-(void)bottomPressed{
    if (isButtonLocked) {
        return;
    }
    isButtonLocked = YES;
    deck.view.userInteractionEnabled = NO;
	activeBox = FIActiveBoxBottom;
    [self showSlideView:[learnController getIntervalForAnswer:1]];
    [self seeBotomBox];
	[self moveBottomBox:FIBoxMovingDirectionForward];
	[deck handleNonDraggingFalling];
    
}

-(void)soundButtonPressed{
	
	isSoundOn = !isSoundOn;
	
	if(isSoundOn)
	{
		[soundButton setImage:[UIImage imageNamed:@"fc_bottombar_sound_1.png"] forState:UIControlStateNormal];
	}
	else
	{
		[soundButton setImage:[UIImage imageNamed:@"fc_bottombar_sound_2.png"] forState:UIControlStateNormal];
	}
	
	[[AVAudioSession sharedInstance] setActive:isSoundOn error:nil];
	
}

-(void)makeSoundCardFalls
{
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
       AudioServicesPlaySystemSound(playerCardFalls); 
	}
}


-(void)makeSoundCardTurn
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
		AudioServicesPlaySystemSound(playerCardTurn);
	}
		
}

-(void)makeSoundBoxIn
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(playerInBox);
	}
}

-(void)makeSoundBoxOut
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(playerOutBox);
	}
	
}

-(void)restoreController
{
	[self hideLeftBox];
	[self hideRightBox];
		
	if (proccesType == FILearningProccesTypeTest) 
		[self hideBottomBox];
	
	UIImage *backButtonImage = [UIImage imageNamed:@"i_test_arrow1.png"];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	backButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-backButtonImage.size.width,320-backButtonImage.size.height,backButtonImage.size.width,backButtonImage.size.height);
	
	[UIView commitAnimations];
}

-(void)prepareToExit
{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    
	UIImage *backButtonImage = [UIImage imageNamed:@"i_test_arrow1.png"];
	
	[UIView beginAnimations:@"exit" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	
	[deck restoreCenterCard:proccesType];
	
	
	leftButton.frame = CGRectMake(-leftButton.frame.size.width,
                                  160-leftButton.frame.size.height/2,
                                  leftButton.frame.size.width,
                                  leftButton.frame.size.height);
	rightButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
								   160-rightButton.frame.size.height/2,
								   rightButton.frame.size.width,
								   rightButton.frame.size.height);
	
	if (proccesType == FILearningProccesTypeTest) {
		bottomButton.frame = CGRectMake(((IS_IPHONE_5)?284:240)-bottomButton.frame.size.width/2,
										320,
										bottomButton.frame.size.width,
										bottomButton.frame.size.height);
	}
	

	backButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)+backButtonImage.size.width,320-backButtonImage.size.height,backButtonImage.size.width,backButtonImage.size.height);
	
	[UIView commitAnimations];
    
    
}

-(void)initSlideView
{
	r_slideView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_test_repeated.png"]];
	r_slideView.center = CGPointMake(((IS_IPHONE_5)?284:240), -r_slideView.frame.size.height/2.0-5.0);
	[self.view addSubview:r_slideView];
	[r_slideView release];
	
	r_slideLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,0,r_slideView.frame.size.width-10,r_slideView.frame.size.height)];
	r_slideLabel.backgroundColor = [UIColor clearColor];
	r_slideLabel.textColor = [UIColor whiteColor];
	r_slideLabel.shadowColor = [UIColor colorWithWhite:0.2 alpha:1.0];
	r_slideLabel.shadowOffset = CGSizeMake(0.5, 0.5);
	r_slideLabel.textAlignment = UITextAlignmentCenter;
	r_slideLabel.adjustsFontSizeToFitWidth = YES;
	r_slideLabel.font = [UIFont fontWithName:@"Helvetica Neua" size:22];
	[r_slideView addSubview:r_slideLabel];
	[r_slideLabel release];
	
}

-(void)showSlideView:(NSInteger)days
{
	if (days==0) {
		r_slideLabel.text = [NSString stringWithFormat:@"Don't have to repeat it again..."];
	}else if (days == 1) {
		r_slideLabel.text = [NSString stringWithFormat:@"Study again next session"];
	}else {
        if (days<3) {
            r_slideLabel.text = [NSString stringWithFormat:@"Study again in %d session",days-1];
        } else {
		  r_slideLabel.text = [NSString stringWithFormat:@"Study again in %d sessions",days-1];
        }
	}
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	r_slideView.center = CGPointMake(((IS_IPHONE_5)?284:240),15);
	[UIView commitAnimations];

}

-(void)hideSlideView
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	r_slideView.center = CGPointMake(((IS_IPHONE_5)?284:240),-20);
	[UIView commitAnimations];
}


-(void)initLearningResultView{
	
	NSDictionary *statistic = [learnController statisticForSession];
	NSNumber *wrong = [statistic objectForKey:@"wrong"];
	NSNumber *right = [statistic objectForKey:@"right"];
	NSNumber *viewed = [NSNumber numberWithInt:[deck viewedCards]];
	NSNumber *all = [NSNumber numberWithInt:[deck allCards]];
	
	
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	[result setValue:[[FDBController sharedDatabase] nameForCategory:category] forKey:@"title"];
	[result setValue:wrong forKey:@"dk"];
	[result setValue:right forKey:@"kn"];
	
	if (proccesType == FILearningProccesTypeTest) {
		NSNumber *notSure = [statistic objectForKey:@"notSure"];
		[result setValue:notSure forKey:@"ns"];
	}
	[result setValue:viewed forKey:@"viewed"];
	[result setValue:all forKey:@"planned"];
	
	learnView = [[FILearningResultView alloc] initWithResult:result forType:proccesType];
	learnView.delegate = self;
	learnView.center = CGPointMake(((IS_IPHONE_5)?284:240),320+learnView.frame.size.height/2.0);
	_learningBgView.alpha = 0.0;
	[self.view addSubview:_learningBgView];
	[self.view addSubview:learnView];
}

-(void)closeLearningView{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	
	[UIView beginAnimations:@"learningViewClose" context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	
	_learningBgView.alpha = 0.0;
	learnView.center = CGPointMake(((IS_IPHONE_5)?284:240), 320+learnView.frame.size.height/2.0);
	
	[UIView commitAnimations];
}

-(void)regularShadow{
    CGPoint shadowCenter;    
    UIImage *shadowMirr = [Util rotateImage:[UIImage imageNamed:@"i_test_box_shadow.png"] forAngle:180];
    shadowMirr = [Util mirrorMappingToRight:shadowMirr];
    
    switch (activeBox) {
		case FIActiveBoxNone:
			break;
		case FIActiveBoxLeft:
            
            shadowCenter = [leftBox convertPoint:leftBoxShadow.center 
                                          toView:[UIApplication sharedApplication].keyWindow];
            [leftBoxShadow removeFromSuperview];
            leftBoxShadow.image = shadowMirr;
            leftBoxShadow.center = shadowCenter;
            [[UIApplication sharedApplication].keyWindow addSubview:leftBoxShadow];
			break;
		case FIActiveBoxRight:
            
            shadowCenter = [rightBox convertPoint:rightBoxShadow.center 
                                           toView:[UIApplication sharedApplication].keyWindow];
            [rightBoxShadow removeFromSuperview];
            rightBoxShadow.image = shadowMirr;
            rightBoxShadow.center = shadowCenter;
            [[UIApplication sharedApplication].keyWindow addSubview:rightBoxShadow];
			break;
		case FIActiveBoxBottom:
            
            shadowCenter = [bottomBox convertPoint:bottomBoxShadow.center 
                                            toView:[UIApplication sharedApplication].keyWindow];
            [bottomBoxShadow removeFromSuperview];
            bottomBoxShadow.image = shadowMirr;
            bottomBoxShadow.center = shadowCenter;
            [[UIApplication sharedApplication].keyWindow addSubview:bottomBoxShadow];
			break;
		default:
			break;
	}
}

#pragma mark -



#pragma mark -
#pragma mark FILearningResultView delegate

-(void)cancelSelected{
	[self closeLearningView];
	[self performSelector:@selector(continuePressed)
			   withObject:nil
			   afterDelay:0.25f];
}
-(void)quitSelected{
	[self closeLearningView];
	[self performSelector:@selector(quitPressed)
			   withObject:nil
			   afterDelay:0.30f];
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	if (category) {
		[category release];
	}
	[learnController release];
	[learnView release];
	[_learningBgView release];
	[leftBoxShadow release];
    [rightBoxShadow release];
    if (bottomBoxShadow) {
        [bottomBoxShadow release];
    }
	
    AudioServicesDisposeSystemSoundID(playerInBox);
    AudioServicesDisposeSystemSoundID(playerOutBox);
    AudioServicesDisposeSystemSoundID(playerCardTurn);
    AudioServicesDisposeSystemSoundID(playerCardFalls);
    
	[deck release];
    [super dealloc];
}


@end
