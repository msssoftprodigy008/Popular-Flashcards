    //
//  FBoxSceneController.m
//  flashCards
//
//  Created by Ruslan on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FBoxSceneController.h"
#import "FDBController.h"
#import "FIAnimationController.h"
#import "NSMutableArrayExtensions.h"
#import "Util.h"
#import "DBTime.h"

@interface FBoxSceneController(Private)

#pragma mark init
-(void)createMainView;
-(void)createSmallView;
-(void)initLabels;
-(void)initLeftBox;
-(void)initRightBox;
-(void)initBottomBox;

-(void)initPreferences;
-(void)initCurrentFont;

-(void)initSlideView;
-(void)showSlideView:(NSInteger)days;
-(void)hideSlideView;

-(void)initPauseButton;

#pragma mark targets
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender;
-(void)handleTap:(UITapGestureRecognizer*)sender;
-(void)pauseButtonPressed;
-(void)dropToLeftBox;
-(void)dropToRightBox;
-(void)dropToBottomBox;
-(void)growEnded;
-(void)awakeInfo:(BOOL)isQuestion;

#pragma mark animation block
-(void)seeBox;
-(void)hideBox;
-(void)moveBox:(FCard)box direction:(BOOL)d;
-(CGPoint)animateDraggingCard:(FCard)box;
-(void)clearSession;
-(void)updateBoxImage;
-(void)restoreState;
-(void)growCard;
-(void)animateDropBlock;

#pragma mark private
-(NSDictionary*)createContent:(NSInteger)index;
-(NSInteger)getCurrentId;
-(void)updateCards;
-(void)updateNextCard;
-(CGFloat)getPathLen:(CGPoint)p1 secPoint:(CGPoint)p2;
-(void)showPauseButton:(BOOL)isShow;
-(void)changeCardByJumping;
-(BOOL)compareCurrentIdWithFirst:(FILearningProccesType)prType;
-(void)updateCardFromArray:(FICardView*)card forArr:(NSArray*)cardArr;
-(void)changeFromMainToNext;
-(void)makeSoundCardFalls;
-(void)makeSoundCardTurn;
-(void)makeSoundBoxIn;
-(void)makeSoundBoxOut;
-(void)hideBoxWhileNotStart;
-(void)animateStarting;
-(void)prepareToExit;
-(void)exit;
-(BOOL)shuffleTest;

@end

#pragma mark -

@implementation FBoxSceneController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)initWithCards:(NSArray*)cards forCategory:(NSString*)prCategory forMode:(FILearningProccesType)mode forDelegate:(id)prDelegate{
	if (cards) {
        if ([self shuffleTest]) {
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:cards];
            cardsArray = [[NSMutableArray alloc] initWithObjects:[cards objectAtIndex:0],nil];
            [tmpArr removeObjectAtIndex:0];
            [tmpArr shuffle];
            [cardsArray addObjectsFromArray:tmpArr];    
        }else{
            cardsArray = [[NSMutableArray alloc] initWithArray:cards];
        }

	}
	
	currentId = 0;
	
	if (prCategory) {
		category = [[NSString alloc] initWithString:prCategory];
	}
    
    delegate = prDelegate;
	
	learningType = mode;
	
	isLeftBoxExist = YES;
	isRightBoxExist = YES;
	
	if (learningType == FILearningProccesTypeStudy) {
		isBottomBoxExist = NO;
	}else {
		isBottomBoxExist = YES;
	}
    
  	[self initPreferences];
    isShouldChangeCard = isBothSide;
    isBothSide = NO;

	learningController = [[FILearningController alloc] initWithCategory:category forType:learningType];
		
	[self init];
	
	return self;
	
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,768.0,1024.0)];
	self.view = contentView;
	self.view.backgroundColor = [UIColor blackColor];
	[contentView release];
	
	r_bgLandView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Landscape.png"]];
    
    r_bgLandView.frame =CGRectMake(0, 10, 1024, 1024);
    [self.view addSubview:r_bgLandView];
    [r_bgLandView release];
    
    r_bgPortView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Portrait.png"]];
    [self.view addSubview:r_bgPortView];
    [r_bgPortView release];
    
    if ([Util isPortrait:self]) {
        r_bgLandView.alpha = 0.0;
    }else{
        r_bgPortView.alpha = 0.0;
    }
	
	/*touchView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,1024.0,1024.0)];
	touchView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:touchView];
	[touchView release];
	
	longPressRecog = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																   action:@selector(handleLongPress:)];
    longPressRecog.delegate = self;
	[touchView addGestureRecognizer:longPressRecog];
	[longPressRecog release];
	longPressRecog.allowableMovement = 500;
	longPressRecog.minimumPressDuration = 0.2f;
	
	tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapRecog.delegate = self;
	[touchView addGestureRecognizer:tapRecog];
	[tapRecog release];*/
	
	
	isResized = NO;
	isInfoChecked = NO;
	isDeckEnded = NO;
	isPaused = NO;
	currentBox = FCardNone;
	coordinate = [Util getCoordinate];
	[self initSlideView];
    self.view.multipleTouchEnabled = NO;
    self.view.exclusiveTouch = YES;
	
	numInLeft = 0;
	numInRight = 0;
	numInBottom = 0;
	
	if (cardsArray) {
		numInCenter = [cardsArray count];
	}
	
	[self initCurrentFont];
	//[self initSoundSettings];
	isSoundOn = YES;
	
	if(isLeftBoxExist)
		[self initLeftBox];
	
	if (isRightBoxExist) {
		[self initRightBox];
	}
	
	if (isBottomBoxExist) {
		[self initBottomBox];
	}
	
	[self createSmallView];
	[self initLabels];
	[self createMainView];
    [self initPauseButton];
	
		
	//[self hideBox];
	[self hideBoxWhileNotStart];
	
	isFallBlock = NO;
	isTurnBlock = NO;
	isBoxInBlock = NO;
	isBoxOutBlock = NO;
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BoxIn" ofType:@"caf"]], &playerInBox);
    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BoxOut" ofType:@"caf"]], &playerOutBox);
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CardFlip" ofType:@"wav"]], &playerCardTurn);
	
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CardFall" ofType:@"wav"]], &playerCardFalls);
    
	[[AVAudioSession sharedInstance] setActive:isSoundOn error:nil];
	
	if (isShouldChangeCard) {
        [self performSelector:@selector(changeCardByJumping)
                   withObject:nil
                   afterDelay:0.25f];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
	//[self performSelector:@selector(growCard) withObject:nil afterDelay:0.25f];
	[self performSelector:@selector(animateStarting)
			   withObject:nil
			   afterDelay:0.5f];
	
    
    
	
	//[self awakeInfo:YES];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    
   // return YES; changed by sanjeev reddy for quiz completion iphone alert
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (delegate && [delegate respondsToSelector:@selector(rotated:)]) {
		[delegate rotated:interfaceOrientation];
	}
	
	if (interfaceOrientation == UIInterfaceOrientationPortrait ||
		interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		mainCard.center = CGPointMake(384,381);
		nextCard.center = CGPointMake(384,381);
		
		if (isLeftBoxExist) {
			leftBox.frame = CGRectMake(kCardLeftBoxPortX,kCardLeftBoxPortY,kCardLeftBoxPortWidth,kCardLeftBoxPortHeight);
		}
		
		if (isRightBoxExist) {
			rightBox.frame = CGRectMake(kCardRightBoxPortX,kCardRightBoxPortY,kCardRightBoxPortWidth,kCardRightBoxPortHeight);
		}
		
		if (isBottomBoxExist) {
			bottomBox.frame = CGRectMake(kCardBottomBoxPortX,kCardBottomBoxPortY,kCardBottomBoxPortWidth,kCardBottomBoxPortHeight);
		}
		
		totalLabel.frame = CGRectMake(330,250,100,60);
			
		if (alert) {
			[alert rotateToPortrait:YES];
		}
		
		r_slideView.center = CGPointMake(384,-40);
		
        r_bgPortView.alpha = 1.0;
        r_bgLandView.alpha = 0.0;
		
	}else {
		mainCard.center = CGPointMake(512,337);
		nextCard.center = CGPointMake(512,337);
		
		if (isLeftBoxExist) {
			leftBox.frame = CGRectMake(kCardLeftBoxX,kCardLeftBoxY,kCardLeftBoxWidth,kCardLeftBoxHeight);
		}
		
		if (isRightBoxExist) {
			rightBox.frame = CGRectMake(kCardRightBoxX,kCardRightBoxY,kCardRightBoxWidth,kCardRightBoxHeight);
		}
		
		if (isBottomBoxExist) {
			bottomBox.frame = CGRectMake(kCardBottomBoxX,kCardBottomBoxY,kCardBottomBoxWidth,kCardBottomBoxHeight);
		}
		
		totalLabel.frame = CGRectMake(460,210,100,60);
			
		if (alert) {
			[alert rotateToPortrait:NO];
		}
		
		r_slideView.center = CGPointMake(512,-40);
		
        r_bgPortView.alpha = 0.0;
        r_bgLandView.alpha = 1.0;
		
	}
    
    UIImage *pauseImage = [Util imageFromBundle:@"test_arrow1.png"];
    if (isPauseVisible) {
        if ([Util isPortraitWithOrientation:interfaceOrientation]) {
            pauseButton.frame = CGRectMake(768-pauseImage.size.width,
                                           1004-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }else{
            pauseButton.frame = CGRectMake(1024-pauseImage.size.width,
                                           748-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }
    }else{
        if ([Util isPortraitWithOrientation:interfaceOrientation]) {
            pauseButton.frame = CGRectMake(768+pauseImage.size.width,
                                           1004-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }else{
            pauseButton.frame = CGRectMake(1024+pauseImage.size.width,
                                           748-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }
    }
	
    [self hideBox];

}

-(void)pauseTest
{
	if (!isPaused) {
		[self pauseButtonPressed];
	}
}

#pragma mark -
#pragma mark init

-(void)createMainView
{
	if (cardsArray) {
        mainCard = [[FICardView alloc] initWithContent:[self createContent:currentId] forSide:NO forRev:isReversed forCheckBox:NO];
		mainCard.delegate = self;
        longPressRecog = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                       action:@selector(handleLongPress:)];
        longPressRecog.delegate = self;
        [mainCard addGestureRecognizer:longPressRecog];
        [longPressRecog release];
        longPressRecog.allowableMovement = 500;
        longPressRecog.minimumPressDuration = 0.2f;
        
        tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapRecog.delegate = self;
        [mainCard addGestureRecognizer:tapRecog];
        [tapRecog release];
		mainCard.currentFont = [UIFont fontWithName:currentFont size:currentSize];
        mainCard.exclusiveTouch = YES;
		[self.view addSubview:mainCard];
		
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			mainCard.center = CGPointMake(384,381);	
		}else {
			mainCard.center = CGPointMake(512,337);
		}
		
        if (isShouldChangeCard) {
            mainCard.transform = CGAffineTransformMakeScale(158.0/654.0,118.0/491.0);
            [self.view bringSubviewToFront:nextCard];
        }

	}
}

-(void)createSmallView
{
	if ((cardsArray && [cardsArray count]>1) || isShouldChangeCard) {
        if (isShouldChangeCard) {
            nextCard = [[FICardView alloc] initWithContent:[self createContent:currentId] forSide:YES forRev:isReversed forCheckBox:NO];
        }else{
            nextCard = [[FICardView alloc] initWithContent:[self createContent:currentId+1] forSide:NO forRev:isReversed forCheckBox:NO];
        }
		nextCard.currentFont = [UIFont fontWithName:currentFont size:currentSize];
		nextCard.userInteractionEnabled = NO;
        nextCard.exclusiveTouch = YES;
        if (!isShouldChangeCard) {
            [nextCard hideShadow];
        }
		
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			nextCard.center = CGPointMake(384,381);	
		}else {
			nextCard.center = CGPointMake(512,337);
		}

		[self.view addSubview:nextCard];
        if (!isShouldChangeCard) {
            nextCard.transform = CGAffineTransformMakeScale(158.0/654.0,118.0/491.0);
        }
	}
}

-(void)initLabels
{
	totalLabel = [[UILabel alloc] init];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		totalLabel.frame = CGRectMake(330,250,100,60);
	}else {
		totalLabel.frame = CGRectMake(460,210,100,60);
	}
	
	totalLabel.textColor = [UIColor blackColor];
	totalLabel.textAlignment = UITextAlignmentCenter;
	totalLabel.backgroundColor = [UIColor clearColor];
	totalLabel.font = [UIFont boldSystemFontOfSize:24];
	totalLabel.text = [NSString stringWithFormat:@"%d",numInCenter];
	[self.view addSubview:totalLabel];
	[totalLabel release];
}

-(void)initLeftBox
{
	leftBox = [[UIImageView alloc] init];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		leftBox.frame = CGRectMake(kCardLeftBoxPortX,kCardLeftBoxPortY,kCardLeftBoxPortWidth,kCardLeftBoxPortHeight);
	}else {
		leftBox.frame = CGRectMake(kCardLeftBoxX,kCardLeftBoxY,kCardLeftBoxWidth,kCardLeftBoxHeight);
	}

	
	leftBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
	leftBox.userInteractionEnabled = YES;
	leftBox.tag = FCardLeftBox;
	
	UIImageView *leftAnIm = [[UIImageView alloc] initWithFrame:CGRectMake(35,35,145,170)];
	leftAnIm.tag = 100;
	[leftBox addSubview:leftAnIm];
	[leftAnIm release];
	
	UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(80,100,51,44)];
	leftImage.image = [UIImage imageNamed:@"countcover.png"];
	[leftBox addSubview:leftImage];
	
	dontLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,51,44)];
	dontLabel.backgroundColor = [UIColor clearColor];
	dontLabel.textColor = [UIColor whiteColor];
	dontLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
	dontLabel.textAlignment = UITextAlignmentCenter;
	dontLabel.adjustsFontSizeToFitWidth = YES;
	dontLabel.text = @"0";
	[leftImage addSubview:dontLabel];
	
	unButton = [UIButton buttonWithType:UIButtonTypeCustom];
	unButton.frame = CGRectMake(kCardLeftBoxWidth-68,40,60,160);
	unButton.backgroundColor = [UIColor clearColor];
	[unButton setImage:[UIImage imageNamed:@"dknow_1.png"] forState:UIControlStateNormal];
	[unButton setImage:[UIImage imageNamed:@"dknow_2.png"] forState:UIControlStateHighlighted];
    unButton.exclusiveTouch = YES;
	[unButton addTarget:self action:@selector(dropToLeftBox) forControlEvents:UIControlEventTouchUpInside]; 
	[leftBox addSubview:unButton];
	
	[self.view addSubview:leftBox];
	
	[dontLabel release];
	[leftImage release];
	[leftBox release];
}

-(void)initRightBox
{
	rightBox = [[UIImageView alloc] init];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		rightBox.frame = CGRectMake(kCardRightBoxPortX,kCardRightBoxPortY,kCardRightBoxPortWidth,kCardRightBoxPortHeight);
	}else {
		rightBox.frame = CGRectMake(kCardRightBoxX,kCardRightBoxY,kCardRightBoxWidth,kCardRightBoxHeight);
	}
	
	rightBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
	rightBox.userInteractionEnabled = YES;
	rightBox.tag = FCardRightBox;
	
	UIImageView *rightAnIm = [[UIImageView alloc] initWithFrame:CGRectMake(33,35,145,170)];
	rightAnIm.tag = 100;
	[rightBox addSubview:rightAnIm];
	[rightAnIm release];
	
	UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(80,100,51,44)];
	rightImage.image = [UIImage imageNamed:@"countcover.png"];
	[rightBox addSubview:rightImage];
	
	knowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,51,44)];
	knowLabel.backgroundColor = [UIColor clearColor];
	knowLabel.textColor = [UIColor whiteColor];
	knowLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
	knowLabel.textAlignment = UITextAlignmentCenter;
	knowLabel.adjustsFontSizeToFitWidth = YES;
	knowLabel.text = @"0";
	[rightImage addSubview:knowLabel];
	
	knButton = [UIButton buttonWithType:UIButtonTypeCustom];
	knButton.frame = CGRectMake(-25,40,60,160);
	knButton.backgroundColor = [UIColor clearColor];
	[knButton setImage:[UIImage imageNamed:@"know_1.png"] forState:UIControlStateNormal];
	[knButton setImage:[UIImage imageNamed:@"know_2.png"] forState:UIControlStateHighlighted];
    knButton.exclusiveTouch = YES;
	[knButton addTarget:self action:@selector(dropToRightBox) forControlEvents:UIControlEventTouchUpInside]; 
	[rightBox addSubview:knButton];
	
	[self.view addSubview:rightBox];
	
	[knowLabel release];
	[rightImage release];
	[rightBox release];
}

-(void)initBottomBox
{
	bottomBox = [[UIImageView alloc] init];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		bottomBox.frame = CGRectMake(kCardBottomBoxPortX,kCardBottomBoxPortY,kCardBottomBoxPortWidth,kCardBottomBoxPortHeight);
	}else {
		bottomBox.frame = CGRectMake(kCardBottomBoxX,kCardBottomBoxY,kCardBottomBoxWidth,kCardBottomBoxHeight);
	}
	
	imageForBot = [[UIImage alloc] initWithCGImage:[Util	mirrorMappingToRight:[Util rotateImage:[UIImage imageNamed:@"fc_table_box_1.png"] forAngle:90]].CGImage];
	imageForBot2 = [[UIImage alloc] initWithCGImage:[Util mirrorMappingToRight:[Util rotateImage:[UIImage imageNamed:@"fc_table_box_2.png"] forAngle:90]].CGImage];
	
	bottomBox.image = imageForBot;
	bottomBox.userInteractionEnabled = YES;
	bottomBox.tag = FCardBottomBox;
	
	UIImageView *bottomAnIm = [[UIImageView alloc] initWithFrame:CGRectMake(35,35,170,145)];
	bottomAnIm.tag = 100;
	[bottomBox addSubview:bottomAnIm];
	[bottomAnIm release];
	
	UIImageView *botImage = [[UIImageView alloc] initWithFrame:CGRectMake(100,85,51,44)];
	botImage.image = [UIImage imageNamed:@"countcover.png"];
	[bottomBox addSubview:botImage];
	
	notSureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,51,44)];
	notSureLabel.backgroundColor = [UIColor clearColor];
	notSureLabel.textColor = [UIColor whiteColor];
	notSureLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
	notSureLabel.textAlignment = UITextAlignmentCenter;
	notSureLabel.adjustsFontSizeToFitWidth = YES;
	notSureLabel.text = @"0";
	[botImage addSubview:notSureLabel];
	
	botButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (![Util isPhone]) {
        botButton.frame = CGRectMake(40,-25,160,60);
    }else
    {
    botButton.frame = CGRectMake(40,-30,160,60);
    }
	
	
    
    botButton.backgroundColor = [UIColor clearColor];
	[botButton setImage:[UIImage imageNamed:@"notsure_1.png"] forState:UIControlStateNormal];
	[botButton setImage:[UIImage imageNamed:@"notsure_2.png"] forState:UIControlStateHighlighted];
    botButton.exclusiveTouch = YES;
	[botButton addTarget:self action:@selector(dropToBottomBox) forControlEvents:UIControlEventTouchUpInside]; 
	[bottomBox addSubview:botButton];
	
	[self.view addSubview:bottomBox];
	
	[notSureLabel release];
	[botImage release];
	[bottomBox release];
}

-(void)initPreferences
{
	if (category) {
		NSArray *cardSettings = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_Setings",category]];
		
		if (cardSettings) {
            isBothSide = [[cardSettings objectAtIndex:0] boolValue];
			isReversed = [[cardSettings objectAtIndex:1] boolValue];
		}
		else {
            isBothSide = NO;
			isReversed = NO;
		}
	}
	else {
        isBothSide = NO;
		isReversed = NO;
	}
}

-(void)initCurrentFont
{
	if (currentFont) {
		[currentFont release];
		currentFont = nil;
	}
	
	if (category) {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",category]];
		
		if (currentSettings) {
			currentFont = [[NSString alloc] initWithString:[currentSettings objectAtIndex:0]];
			currentSize = [[currentSettings objectAtIndex:1] intValue];
			return;
		}
	}
	
	currentFont = [[NSString alloc] initWithString:@"Helvetica"];
	currentSize = 30;
}

-(void)initSlideView
{
    r_slideView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"test_repeated.png"]];
    
	if ([Util isPortrait:self]) {
		r_slideView.center = CGPointMake(384, -r_slideView.frame.size.height/2.0);
	}else {
		r_slideView.center = CGPointMake(512, -r_slideView.frame.size.height/2.0);
	}
    
    r_slideLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, -3, r_slideView.frame.size.width-20, r_slideView.frame.size.height-6)];
	r_slideLabel.backgroundColor = [UIColor clearColor];
    r_slideLabel.shadowColor = [UIColor darkGrayColor];
    r_slideLabel.shadowOffset = CGSizeMake(1, 1);
	r_slideLabel.textColor = [UIColor whiteColor];
	r_slideLabel.textAlignment = UITextAlignmentCenter;
	r_slideLabel.adjustsFontSizeToFitWidth = YES;
	r_slideLabel.font = [UIFont boldSystemFontOfSize:40];
    [r_slideView addSubview:r_slideLabel];
	[self.view addSubview:r_slideView];
    [r_slideLabel release];
	[r_slideView release];
	
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
	
	if ([Util isPortrait:self]) {
		r_slideView.center = CGPointMake(384,r_slideView.frame.size.height/2.0);
	}else {
		r_slideView.center = CGPointMake(512,r_slideView.frame.size.height/2.0);
	}

	[UIView commitAnimations];
	
}

-(void)hideSlideView
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	if ([Util isPortrait:self]) {
		r_slideView.center = CGPointMake(384,-40);
	}else {
		r_slideView.center = CGPointMake(512,-40);
	}
	[UIView commitAnimations];
}

-(void)initPauseButton{
    UIImage *pauseImage = [Util imageFromBundle:@"test_arrow1.png"];
    pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    pauseButton.exclusiveTouch = YES;
    isPauseVisible = NO;
    if ([Util isPortrait:self]) {
        pauseButton.frame = CGRectMake(768+pauseImage.size.width,
                                       1004-pauseImage.size.height,
                                       pauseImage.size.width,
                                       pauseImage.size.height);
    }else{
        pauseButton.frame = CGRectMake(1024+pauseImage.size.width,
                                       748-pauseImage.size.height,
                                       pauseImage.size.width,
                                       pauseImage.size.height);
    }
    [pauseButton setImage:pauseImage forState:UIControlStateNormal];
    [pauseButton setImage:[Util imageFromBundle:@"test_arrow2.png"] forState:UIControlStateHighlighted];
    [pauseButton addTarget:self
                    action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseButton];
}

-(void)showPauseButton:(BOOL)isShow{
    UIImage *pauseImage = [Util imageFromBundle:@"test_arrow1.png"];
    isPauseVisible = isShow;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    
    if (isShow) {
        if ([Util isPortrait:self]) {
            pauseButton.frame = CGRectMake(768-pauseImage.size.width,
                                           1004-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }else{
            pauseButton.frame = CGRectMake(1024-pauseImage.size.width,
                                           748-pauseImage.size.height+20, //+20 added by sanjeev reddy for arrow position in ipad ios7
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }
    }else{
        if ([Util isPortrait:self]) {
            pauseButton.frame = CGRectMake(768+pauseImage.size.width,
                                           1004-pauseImage.size.height,
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }else{
            pauseButton.frame = CGRectMake(1024+pauseImage.size.width,
                                           748-pauseImage.size.height+20,//+20 added by sanjeev reddy for arrow position in ipad ios7
                                           pauseImage.size.width,
                                           pauseImage.size.height);
        }
    }
    
    [UIView commitAnimations];
}

#pragma mark -

#pragma mark -
#pragma mark alertView delegate

-(void)quitButtonPressed{
	
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
	
	if (delegate && [delegate respondsToSelector:@selector(learningWillEnd:animated:)]) {
		[delegate learningWillEnd:category animated:isDeckEnded];
	}
    
    if (!isDeckEnded && ![self compareCurrentIdWithFirst:FILearningProccesTypeTest]) {
        nextCard.hidden = NO;
        [nextCard seeShadow];
        [self performSelector:@selector(changeFromMainToNext)
                   withObject:nil
                   afterDelay:0.25];
        
        [self prepareToExit];
        [self performSelector:@selector(exit)
                   withObject:nil
                   afterDelay:0.50];
      
    }else{
    
        [self prepareToExit];
        if (!isDeckEnded) {
            if (!mainCard.isQuestion) {
                [[FIAnimationController sharedAnimation:nil] flip:mainCard];
                [mainCard changeSide];
            }
        }
        
        [self performSelector:@selector(exit)
                   withObject:nil
                   afterDelay:0.25];
    }
}

-(void)continueButtonPressed{
	alert = nil;
	isPaused = NO;
}

#pragma mark -

#pragma mark -
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	[self quitButtonPressed];
}

#pragma mark -

#pragma mark -
#pragma mark FICardView delegate

-(void)checkButtonChangedState:(FICheckboxState)checkedState{
	
}

-(void)imageNeedFullScreen:(CGPoint)imageCenter forSize:(CGSize)imageSize forSide:(BOOL)isFront{
	if (mainCard) {
		[mainCard changeSide];
		[[FIAnimationController sharedAnimation:self] flip:mainCard];
        [self makeSoundCardTurn];
	}
	
}

#pragma mark -
#pragma mark FIAnimationController delegate

-(void)didEndAnimation{
	   
	if (currentAnimation == 2) {
     	[self makeSoundCardFalls];
		currentAnimation = -2;
		[self performSelector:@selector(updateBoxImage)
				   withObject:nil
				   afterDelay:0.3f];
		[self performSelector:@selector(clearSession)
				   withObject:nil
				   afterDelay:0.5f];
	}else if(currentAnimation  == 4){
        currentAnimation = -100;
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
        nextCard.isBothSide = NO;
        nextCard.transform = CGAffineTransformMakeScale(158.0/654.0,118.0/491.0);
        [nextCard hideShadow];
        [self updateNextCard];
    }else {
		if (!isInfoChecked) {
			isInfoChecked = YES;
	//		[self awakeInfo:NO];
		}
	}
}

#pragma mark -

#pragma mark -
#pragma mark targets

-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{
	if (mainCard) 
	{
		CGPoint translate = [sender locationInView:self.view];
		[mainCard stopAudio];
		
		FCard curB = FCardNone;
		
		if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
			CGFloat dis = [self getPathLen:translate secPoint:CGPointMake(384,381)];
			
			if(isLeftBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(0,381)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(0,381)];
				curB = FCardLeftBox;
			}
			
			if(isRightBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(768,381)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(768,381)];
				curB = FCardRightBox;
			}
			
			if(isBottomBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(384,907)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(384,907)];
				curB = FCardBottomBox;
			}
		}else {
			CGFloat dis = [self getPathLen:translate secPoint:CGPointMake(512,359)];
			if(isLeftBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(0,359)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(0,359)];
				curB = FCardLeftBox;
			}
			
			if(isRightBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(1024,359)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(1024,359)];
				curB = FCardRightBox;
			}
			if(isBottomBoxExist && dis>[self getPathLen:translate secPoint:CGPointMake(512,701)])
			{
				dis = [self getPathLen:translate secPoint:CGPointMake(512,701)];
				curB = FCardBottomBox;
			}
			
		}
		
				
		if (!isResized) 
		{
			[self.view bringSubviewToFront:mainCard];
			
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.25f];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			
			mainCard.center = translate;
			mainCard.transform = CGAffineTransformMakeScale(0.6,0.6);

			[self seeBox];
			
			for(int i=1;i<4;i++)
				if(i==curB)
					[self moveBox:curB direction:YES];
				else
					[self moveBox:i direction:NO];
			

			
			[UIView commitAnimations];
			
			isResized = YES;
			
			
		}
		else {
			
			mainCard.center = translate;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.25f];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			
			for(int i=1;i<4;i++)
				if(i==curB)
					[self moveBox:curB direction:YES];
				else
					[self moveBox:i direction:NO];
			
			[UIView commitAnimations];
			
			
		}
		
		switch (curB) {
			case FCardLeftBox:
				if (currentBox!=curB) {
					[self showSlideView:[learningController getIntervalForAnswer:0]];
				}
				
				break;
			case FCardRightBox:
				if (currentBox!=curB) {
					[self showSlideView:[learningController getIntervalForAnswer:2]];
				}
				break;
			case FCardBottomBox:
				if (currentBox!=curB) {
					[self showSlideView:[learningController getIntervalForAnswer:1]];
				}
				break;
			default:
				if (currentBox != FCardNone) {
					[self hideSlideView];
				}
				break;
		}
		
		currentBox = curB;
		
		if (sender.state == UIGestureRecognizerStateEnded ) {
			if(currentBox != FCardNone)
			{

				[self performSelector:@selector(hideSlideView)
						   withObject:nil
						   afterDelay:0.5];
				
				UIImageView *boxA = (UIImageView*)[self.view viewWithTag:currentBox];
				CGPoint orig = [boxA convertPoint:CGPointMake(45,40) toView:self.view];
				
				if (currentBox == FCardBottomBox) {
					orig = [boxA convertPoint:CGPointMake(31,20) toView:self.view];
				}
				
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				[UIView setAnimationDuration:0.25f];
				[UIView setAnimationDelegate:self];
				
				mainCard.layer.position = orig;
				
				[UIView commitAnimations];
				
                self.view.userInteractionEnabled = NO;
				[self animateDropBlock];
				
				
			}else {
				[UIView beginAnimations:nil context:nil];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				[UIView setAnimationDuration:0.5f];
				mainCard.transform = CGAffineTransformIdentity;
				
				if(self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
					mainCard.center = CGPointMake(384,381);
				}else {
					mainCard.center = CGPointMake(512,337);
				}

				[self hideBox];
				[UIView commitAnimations];
				
			}
			
			isResized = NO;
		}
		
	}
}

-(void)handleTap:(UITapGestureRecognizer*)sender{
	if (mainCard) {
		[mainCard changeSide];
		[[FIAnimationController sharedAnimation:self] flip:mainCard];
        [self makeSoundCardTurn];
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /*NSLog(@"%@",[touch.view class]);
	if ([touch.view isDescendantOfView:mainCard]){
		return NO;
	}*/
	
	return YES;
}

-(void)pauseButtonPressed{
	isPaused = YES;
	
    NSInteger numOfPlannedC = [cardsArray count];
	
	NSMutableArray *arr = [NSMutableArray arrayWithObjects:[NSString stringWithFormat:@"%d",numOfPlannedC],
						   [NSString stringWithFormat:@"%d",numOfPlannedC - numInCenter],nil];
	
	if (isRightBoxExist) {
		[arr addObject:[NSString stringWithString:knowLabel.text]];
	}
	
	if (isBottomBoxExist) {
		[arr addObject:[NSString stringWithString:notSureLabel.text]];
	}
	
	if (isLeftBoxExist) {
		[arr addObject:[NSString stringWithString:dontLabel.text]];
	}
					
					
					
	
	NSString *currTime=@"";
	
	if (learningType == FILearningProccesTypeTest) {
		alert = [[FAlertView alloc] initWithFrame:CGRectMake(0,0,1024,1024) forCategory:category forMode:FAlertTest forDelegate:self];	
	}else {
		alert = [[FAlertView alloc] initWithFrame:CGRectMake(0,0,1024,1024) forCategory:category forMode:FAlertStudy forDelegate:self];	
	}
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		[alert rotateToPortrait:YES];
	}else {
		[alert rotateToPortrait:NO];
	}


	
	[alert setValues:arr forTime:currTime];
	[alert show:self.view];
	[alert release];
}


-(void)seeBox{
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		
		if (isRightBoxExist) 
			rightBox.alpha = 1.0f;
		
		if (isLeftBoxExist) 
			leftBox.alpha = 1.0f;
		
		if (isBottomBoxExist) 
			bottomBox.alpha = 1.0f;
		
		if (isLeftBoxExist) 
			leftBox.frame = CGRectMake(kCardLeftBoxPortX,kCardLeftBoxPortY,kCardLeftBoxPortWidth,kCardLeftBoxPortHeight);
		
		if (isRightBoxExist) 
			rightBox.frame = CGRectMake(kCardRightBoxPortX,kCardRightBoxPortY,kCardRightBoxPortWidth,kCardRightBoxPortHeight);
		
		if (isBottomBoxExist) 
			bottomBox.frame = CGRectMake(kCardBottomBoxPortX,kCardBottomBoxPortY,kCardBottomBoxPortWidth,kCardRightBoxPortHeight);
		
	}else {
		
		if (isRightBoxExist) 
			rightBox.alpha = 1.0f;
		
		if (isLeftBoxExist) 
			leftBox.alpha = 1.0f;
		
		if (isBottomBoxExist) 
			bottomBox.alpha = 1.0f;
		
		
		if (isLeftBoxExist) 
			leftBox.frame = CGRectMake(kCardLeftBoxX,kCardLeftBoxY,kCardLeftBoxWidth,kCardLeftBoxHeight);
		
		if (isRightBoxExist) 
			rightBox.frame = CGRectMake(kCardRightBoxX,kCardRightBoxY,kCardRightBoxWidth,kCardRightBoxHeight);
		
		if (isBottomBoxExist) 
			bottomBox.frame = CGRectMake(kCardBottomBoxX,kCardBottomBoxY,kCardBottomBoxWidth,kCardRightBoxHeight);
				
		
	}
	
    [self makeSoundBoxIn];
}

-(void)hideBox{
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		
				
		if (isLeftBoxExist) {
			CGRect leftBoxF = leftBox.frame;
			leftBoxF.origin.x = -leftBoxF.size.width+61;
			leftBox.frame = leftBoxF;
			leftBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
		}
		
		if (isRightBoxExist) {
			CGRect rightBoxF = rightBox.frame;
			rightBoxF.origin.x = 740;
			rightBox.frame = rightBoxF;
			rightBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
		
		}
		
		if (isBottomBoxExist) {
			CGRect bottomBoxF = bottomBox.frame;
			bottomBoxF.origin.y = 1004-5;//-26
			bottomBox.frame = bottomBoxF;
			bottomBox.image = imageForBot;
		}
		
				
	}else {
		
				
		if (isLeftBoxExist) {
			CGRect leftBoxF = leftBox.frame;
			leftBoxF.origin.x = -leftBoxF.size.width+61;
			leftBox.frame = leftBoxF;
			leftBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
		}
		
		if (isRightBoxExist) {
			CGRect rightBoxF = rightBox.frame;
			rightBoxF.origin.x = 996;
			rightBox.frame = rightBoxF;
			rightBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];	
		}

		if (isBottomBoxExist) {
			CGRect bottomBoxF = bottomBox.frame;
			bottomBoxF.origin.y = 748-5;//748-26
			bottomBox.frame = bottomBoxF;
			bottomBox.image = imageForBot;		
		}	
       
	}
	
	if (isLeftBoxExist || isRightBoxExist || isBottomBoxExist) {
        [self makeSoundBoxOut];
	}


}

-(void)moveBox:(FCard)box direction:(BOOL)d{
	
	if ((box == FCardLeftBox && !isLeftBoxExist) || (box == FCardRightBox && !isRightBoxExist) || (box == FCardBottomBox && !isBottomBoxExist)) {
		return;
	}
	
	if((box == currentBox && d) || (box!=currentBox && !d))
		return;
	
    [self makeSoundBoxIn];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
		
		switch (box) {
			case FCardLeftBox:
			{
				CGRect frame = leftBox.frame;
				if(d)
				{
					frame.origin.x=-30;
					leftBox.image = [UIImage imageNamed:@"fc_table_box_2.png"];
				}
				else
				{
					frame.origin.x = kCardLeftBoxPortX;
					leftBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
				}
				leftBox.frame = frame;
				break;
			}
			case FCardRightBox:
			{
				CGRect frame = rightBox.frame;
				if(d)
				{
					frame.origin.x = 587.0f;
					rightBox.image = [UIImage imageNamed:@"fc_table_box_2.png"];
				}
				else
				{
					frame.origin.x = kCardRightBoxPortX;
					rightBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
				}
				rightBox.frame = frame;
				break;
			}
			case FCardBottomBox:
			{
				CGRect frame = bottomBox.frame;
				if(d)
				{
					frame.origin.y =825.0f;
					bottomBox.image = imageForBot2;
				}
				else
				{
					frame.origin.y = kCardBottomBoxPortY;
					bottomBox.image = imageForBot;
				}
				bottomBox.frame = frame;
				break;
			}
			default:
				break;
		}
		
		
	}else {
		
		switch (box) {
			case FCardLeftBox:
			{
				CGRect frame = leftBox.frame;
				if(d)
				{
					frame.origin.x=-30;
					leftBox.image = [UIImage imageNamed:@"fc_table_box_2.png"];
				}
				else
				{
					frame.origin.x = kCardLeftBoxX;
					leftBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
				}
				leftBox.frame = frame;
				break;
			}
			case FCardRightBox:
			{
				CGRect frame = rightBox.frame;
				if(d)
				{
					frame.origin.x = 843.0f;
					rightBox.image = [UIImage imageNamed:@"fc_table_box_2.png"];
				}
				else
				{
					frame.origin.x = kCardRightBoxX;
					rightBox.image = [UIImage imageNamed:@"fc_table_box_1.png"];
				}
				rightBox.frame = frame;
				break;
			}
			case FCardBottomBox:
			{
				CGRect frame = bottomBox.frame;
				if(d)
				{
					frame.origin.y = 565.0f;
					bottomBox.image = imageForBot2;
				}
				else
				{
					frame.origin.y = kCardBottomBoxY;
					bottomBox.image = imageForBot;
				}
				bottomBox.frame = frame;
				break;
			}
			default:
				break;
		}
		
	}

}

-(void)dropToLeftBox
{
    self.view.userInteractionEnabled = NO;
    
	if (!isLeftBoxExist) {
		return;
	}
	
	[mainCard stopAudio];	
	UIImageView *boxA = (UIImageView*)[self.view viewWithTag:FCardLeftBox];
	CGPoint orig = [boxA convertPoint:CGPointMake(50,40) toView:self.view];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[self seeBox];
	[self moveBox:FCardLeftBox direction:YES];

	mainCard.layer.position = orig;
	mainCard.transform = CGAffineTransformMakeScale(0.6,0.6);
	
	[UIView commitAnimations];
    [self showSlideView:[learningController getIntervalForAnswer:0]];
    [self performSelector:@selector(hideSlideView)
               withObject:nil
               afterDelay:1.0f];
	currentBox = FCardLeftBox;
	[self animateDropBlock];

}

-(void)dropToRightBox
{
    self.view.userInteractionEnabled = NO;
    
	if (!isRightBoxExist) {
		return;
	}
	
	[mainCard stopAudio];
	UIImageView *boxA = (UIImageView*)[self.view viewWithTag:FCardRightBox];
	CGPoint orig= [boxA convertPoint:CGPointMake(45,40) toView:self.view];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[self seeBox];
	[self moveBox:FCardRightBox direction:YES];
	
	mainCard.layer.position = orig;
	mainCard.transform = CGAffineTransformMakeScale(0.6,0.6);
	
	[UIView commitAnimations];
	[self showSlideView:[learningController getIntervalForAnswer:2]];
    [self performSelector:@selector(hideSlideView)
               withObject:nil
               afterDelay:1.0f];
	currentBox = FCardRightBox;
	[self animateDropBlock];	
}

-(void)dropToBottomBox
{
    self.view.userInteractionEnabled = NO;
    
	if (!isBottomBoxExist) {
		return;
	}
	
	[mainCard stopAudio];
	UIImageView *boxA = (UIImageView*)[self.view viewWithTag:FCardBottomBox];
	CGPoint orig= [boxA convertPoint:CGPointMake(31,20) toView:self.view];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[self seeBox];
	[self moveBox:FCardBottomBox direction:YES];
	
	mainCard.layer.position = orig;
	mainCard.transform = CGAffineTransformMakeScale(0.6,0.6);
	
	[UIView commitAnimations];
	[self showSlideView:[learningController getIntervalForAnswer:1]];
	[self performSelector:@selector(hideSlideView)
               withObject:nil
               afterDelay:1.0f];
	currentBox = FCardBottomBox;
	[self animateDropBlock];
}

-(void)animateDropBlock
{
	outPoint = [self animateDraggingCard:currentBox];
}

#pragma mark -

#pragma mark -
#pragma mark animation block
-(CGPoint)animateDraggingCard:(FCard)box
{
	UIImageView *boxA = (UIImageView*)[self.view viewWithTag:currentBox];
	mainCard.userInteractionEnabled = NO;
	NSArray *arr;
	int curNum;
	CGPoint moveToPoint;
	if(numInCenter>0)
		numInCenter--;
	totalLabel.text = [NSString stringWithFormat:@"%d",numInCenter];
	switch (box) {
		case FCardRightBox:
		{
			if(numInRight>=27)
				curNum = 25+numInRight%3;
			else
				curNum = numInRight+1;
			numInRight++;
			arr = [coordinate objectForKey:[NSString stringWithFormat:@"%d",curNum]];
			knowLabel.text = [NSString stringWithFormat:@"%d",numInRight];
			[learningController updateAnswer:[self getCurrentId] forAnswer:2];
			break;
		}
		case FCardLeftBox:
		{
			if(numInLeft>=27)
				curNum = 25+numInLeft%3;
			else
				curNum = numInLeft+1;
			numInLeft++;
			arr = [coordinate objectForKey:[NSString stringWithFormat:@"%d",curNum]];
			dontLabel.text = [NSString stringWithFormat:@"%d",numInLeft];
			[learningController updateAnswer:[self getCurrentId] forAnswer:0];
			break;
		}
		case FCardBottomBox:
		{
			if(numInBottom>=27)
				curNum = 25+numInBottom%3;
			else
				curNum = numInBottom+1;
			numInBottom++;
			arr = [coordinate objectForKey:[NSString stringWithFormat:@"%d",curNum]];
			notSureLabel.text = [NSString stringWithFormat:@"%d",numInBottom];
			[learningController updateAnswer:[self getCurrentId] forAnswer:1];
			break;
		}
			
		default:
			break;
	}
	
	CGFloat resize = [[arr objectAtIndex:0] floatValue];
	CGFloat angle = [[arr objectAtIndex:1] floatValue];
	CGFloat x = [[arr objectAtIndex:2] floatValue];
	CGFloat y = [[arr objectAtIndex:3] floatValue];
	CGPoint cent;
	CGPoint orig= [boxA convertPoint:CGPointMake(45,40) toView:self.view];
	
	
	
	if(box==FCardBottomBox)
	{
		angle = angle+90.0;
		CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI/2);
		
		orig= [boxA convertPoint:CGPointMake(31,20) toView:self.view];
		cent = CGPointApplyAffineTransform(CGPointMake(x+60,y-80),trans);	
				
		cent = [boxA convertPoint:cent toView:self.view];
		cent.x+=90;
		
	}
	else{
		
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			cent = [boxA convertPoint:CGPointMake(x+60,y+60) toView:self.view];	
		}else {
			cent = [boxA convertPoint:CGPointMake(x+60,y+75) toView:self.view];
		}

	}
	
	currentAnimation = 2;
	[[FIAnimationController sharedAnimation:self] fallingToSomething:mainCard
														   forPoint:cent
														   forScale:CGSizeMake(resize/98.0,resize/98.0)
																forRot:angle/57.7];
	mainCard.layer.position = cent;
	mainCard.layer.transform = CATransform3DScale(mainCard.layer.transform,resize/98.0,resize/98.0,1);
	mainCard.layer.transform = CATransform3DRotate(mainCard.layer.transform,angle/57.7,0,0,1);
	
	switch (box) {
		case FCardLeftBox:
		{
			moveToPoint.x = -200;
			moveToPoint.y = cent.y;
			break;
		}
		case FCardRightBox:
		{
			moveToPoint.x = 1200;
			moveToPoint.y = cent.y+30;
			break;
		}
		case FCardBottomBox:
		{
			moveToPoint.x = cent.x;
			moveToPoint.y = 1200;
			break;
		}
		default:
			break;
	}
	
	return moveToPoint;
}

-(void)updateBoxImage
{
	UIImageView *boxA = (UIImageView*)[self.view viewWithTag:currentBox];
	UIImageView *imageA = (UIImageView*)[boxA viewWithTag:100];
	CALayer *layer = self.view.layer;
	UIGraphicsBeginImageContext(layer.bounds.size);
	[layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGRect imageFrame;
	
	switch (currentBox) {
	case FCardLeftBox:
	{
		imageFrame.origin = [leftBox convertPoint:imageA.frame.origin toView:self.view];
		break;
	}
	case FCardRightBox:
	{
		imageFrame.origin = [rightBox convertPoint:imageA.frame.origin toView:self.view];
		break;
	}
	case FCardBottomBox:
	{
		imageFrame.origin = [bottomBox convertPoint:imageA.frame.origin toView:self.view];
		break;
	}
	default:
			break;
	}
	
	imageFrame.size = imageA.frame.size;
	CGImageRef imageRef = image.CGImage;
	image = nil;
	CGImageRef imageRef2 = CGImageCreateWithImageInRect(imageRef,imageFrame);
	image = [UIImage imageWithCGImage:imageRef2];
	CGImageRelease(imageRef2);
	imageA.image = image;
}

-(void)clearSession
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(restoreState)];
	mainCard.center = outPoint;
	mainCard.alpha = 0;
	[self hideBox];
	[UIView commitAnimations];
}


-(void)growCard{
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growEnded)];
	mainCard.transform = CGAffineTransformIdentity;
	
	[UIView commitAnimations];
	
	[mainCard seeShadow];
    
    self.view.userInteractionEnabled = YES;
}

-(void)restoreState{
	
	currentId++;
	currentBox = FCardNone;
	mainCard.userInteractionEnabled = YES;
	if (currentId != [cardsArray count]) {
		mainCard.alpha = 0.0;
		[self.view bringSubviewToFront:mainCard];
		mainCard.transform = CGAffineTransformIdentity;
	
		if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			mainCard.center = CGPointMake(384,381);
		}else {
			mainCard.center = CGPointMake(512,337);
		}
	
		mainCard.transform = CGAffineTransformMakeScale(158.0/654.0,118.0/491.0);
		mainCard.alpha = 1.0;
	
		[self updateCards];
		[mainCard seeShadow];
		[self growCard];
	}else {
        
        NSString *message;
		isDeckEnded = YES;
		
		if (learningType == FILearningProccesTypeTest) {
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
		
        self.view.userInteractionEnabled = YES;
	}

}

-(void)growEnded{
	//[self awakeInfo:YES];
}

-(void)awakeInfo:(BOOL)isQuestion{
		
	if (learningType == FILearningProccesTypeTest) {
		
		if (isQuestion) {
            BOOL isTF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isTF"];
			if(!isTF)
			{
				NSString* Amessage=@"When you test,we build studying schedule for you. To begin, try to guess the back of this card.";
	
                [Util showMessage:@"Test" forMessage:Amessage forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isTF"];
			}	
		}else {
            BOOL isDF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDF"];
			if(!isDF)
			{
				NSString* Amessage=@"Choose whether you knew the answer or remembered it with some effort. Move card to the according bin or tap on a button.";

				[Util showMessage:@"Test" forMessage:Amessage forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDF"];
			}
		}
	}else {
        BOOL isSTF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSTF"];
		if (isQuestion) {
			if(!isSTF)
			{
				NSString* Amessage=@"You can repeat forgotten cards without those which we schedule for you. To begin,try to guess the back of this card.";

				[Util showMessage:@"Study" forMessage:Amessage forButtonTitle:@"OK"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSTF"];
			}
		}else {
            BOOL isSDF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSDF"];
			if(!isSDF)
			{
				NSString* Amessage=@"Choose whether you knew the answer. Move card to the according bin or tap on a button.";

				[Util showMessage:@"Study" forMessage:Amessage forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSDF"];
			}
		}
		
	}

}


#pragma mark -

#pragma mark -
#pragma mark private

-(NSDictionary*)createContent:(NSInteger)index
{
	if (!cardsArray || [cardsArray count]<=index || index<0 || !category) {
		return nil;
	}
	
	NSArray *card = [cardsArray objectAtIndex:index];
	NSInteger cardId = [[card objectAtIndex:1] intValue];
	card = [[FDBController sharedDatabase] getCardArray:category forIndex:cardId];
	NSString *question = [card objectAtIndex:0];
	NSString *answer = [card objectAtIndex:1];
	UIImage *qImage = [Util imageWithId:category forId:cardId forWhat:YES];
	UIImage *aImage = [Util imageWithId:category forId:cardId forWhat:NO];
	NSData *qSound = [Util getSoundForCard:category forId:cardId forWhat:YES];
	NSData *aSound = [Util getSoundForCard:category forId:cardId forWhat:NO];
	NSNumber *cardNumber = [NSNumber numberWithInt:index+1];
	NSNumber *allCard = [NSNumber numberWithInt:[cardsArray count]];
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	if(question)
		[dic setObject:question forKey:@"question"];
	
	if (answer) 
		[dic setObject:answer forKey:@"answer"];
	
	if (qImage) {
		[dic setObject:qImage forKey:@"qImage"];
	}
	
	if (aImage) {
		[dic setObject:aImage forKey:@"aImage"];
	}
	
	if (qSound) {
		[dic setObject:qSound forKey:@"qSound"];
	}
	
	if (aSound) {
		[dic setObject:aSound forKey:@"aSound"];
	}
	
	[dic setObject:cardNumber forKey:@"number"];
	[dic setObject:allCard forKey:@"allNumber"];
	[card release];
	return dic;
}

-(void)updateCards{
	[mainCard changeContent:[self createContent:currentId]];
	
	if (currentId+1 != [cardsArray count]) {
		[nextCard changeContent:[self createContent:currentId+1]];
	}
	else {
		nextCard.hidden = YES;
	}
	
}

-(void)updateNextCard{
    if (currentId+1 != [cardsArray count]) {
		[nextCard changeContent:[self createContent:currentId+1]];
	}
	else {
		nextCard.hidden = YES;
	}
}

-(NSInteger)getCurrentId
{
	if (currentId>=0 && currentId<[cardsArray count]) {
		return [[[cardsArray objectAtIndex:currentId] objectAtIndex:1] intValue];
	}
	else {
		return -1;
	}
	
}

-(CGFloat)getPathLen:(CGPoint)p1 secPoint:(CGPoint)p2
{
	return sqrt((p1.x-p2.x)*(p1.x-p2.x) + (p1.y-p2.y)*(p1.y-p2.y));
}

-(void)changeCardByJumping{
    currentAnimation = 4;
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    [nextCard hideShadow];
    [[FIAnimationController sharedAnimation:self] deckChangeAnimationIPad:mainCard forScr:nextCard];
}

-(void)changeFromMainToNext{
    [[FIAnimationController sharedAnimation:nil] deckChangeAnimationIPad:nextCard forScr:mainCard];
}

-(void)hideBoxWhileNotStart
{
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			
		if (isLeftBoxExist) {
			leftBox.center = CGPointMake(-leftBox.frame.size.width/2-60,leftBox.center.y);
		}
		
		if (isRightBoxExist) {
			rightBox.center = CGPointMake(768+rightBox.frame.size.width/2+60,rightBox.center.y);			
		}
		
		if (isBottomBoxExist) {
			bottomBox.center = CGPointMake(bottomBox.center.x,1024+bottomBox.frame.size.height/2+60);
		}
		
		
	}else {
		if (isLeftBoxExist) {
			leftBox.center = CGPointMake(-leftBox.frame.size.width/2-60,leftBox.center.y);
		}
		
		if (isRightBoxExist) {
			rightBox.center = CGPointMake(1024+rightBox.frame.size.width/2+60,rightBox.center.y);			
		}
		
		if (isBottomBoxExist) {
			bottomBox.center = CGPointMake(bottomBox.center.x,768+bottomBox.frame.size.height/2+60);
		}
	}
}


-(void)animateStarting
{
    [self showPauseButton:YES];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	[self hideBox];

	[UIView commitAnimations];
}

-(void)prepareToExit
{
    [self showPauseButton:NO];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDelegate:self];
	
	[self hideBoxWhileNotStart];
	
	[UIView commitAnimations];
	
	
}

-(BOOL)compareCurrentIdWithFirst:(FILearningProccesType)prType{
    if(currentId<0 || currentId>=[cardsArray count]){
        return  YES;
    }
    
    NSArray *firstCard = nil;
    
    if (prType == FILearningProccesTypeTest) {
        firstCard = [[FDBController sharedDatabase] cardWithMinIdForTest:category];  
    }
    
    
    if (firstCard) {
        NSArray *currentCard = [cardsArray objectAtIndex:currentId];
        NSInteger currentCardId = [[currentCard objectAtIndex:1] intValue];
        NSInteger firstCardId = [[firstCard objectAtIndex:0] intValue];
        [self initPreferences];
        if ((currentCardId != firstCardId) || isBothSide) {
            [self updateCardFromArray:nextCard forArr:firstCard];
            return NO;
        }
    }
    
    return YES;
    
}

-(void)updateCardFromArray:(FICardView*)card forArr:(NSArray*)cardArr{
	NSInteger cardId = [[cardArr objectAtIndex:0] intValue];
	NSString *question = [cardArr objectAtIndex:1];
	NSString *answer = [cardArr objectAtIndex:2];
	UIImage *qImage = [Util imageWithId:category forId:cardId forWhat:YES];
	UIImage *aImage = [Util imageWithId:category forId:cardId forWhat:NO];
	NSData *qSound = [Util getSoundForCard:category forId:cardId forWhat:YES];
	NSData *aSound = [Util getSoundForCard:category forId:cardId forWhat:NO];
	NSNumber *cardNumber = [NSNumber numberWithInt:currentId+1];
	NSNumber *allCard = [NSNumber numberWithInt:[cardsArray count]];
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	if(question)
		[dic setObject:question forKey:@"question"];
	
	if (answer) 
		[dic setObject:answer forKey:@"answer"];
	
	if (qImage) {
		[dic setObject:qImage forKey:@"qImage"];
	}
	
	if (aImage) {
		[dic setObject:aImage forKey:@"aImage"];
	}
	
	if (qSound) {
		[dic setObject:qSound forKey:@"qSound"];
	}
	
	if (aSound) {
		[dic setObject:aSound forKey:@"aSound"];
	}
	
	[dic setObject:cardNumber forKey:@"number"];
	[dic setObject:allCard forKey:@"allNumber"];
    
    if(card.isBothSide != isBothSide){
        card.isBothSide = isBothSide;
    }
    
    [card changeContent:dic];
}

-(void)makeSoundCardFalls
{
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(playerCardFalls); 
	}
}


-(void)makeSoundCardTurn{
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

-(void)exit
{
	[self.navigationController popViewControllerAnimated:NO];
}

-(BOOL)shuffleTest{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"]){
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"] boolValue];
    }
    return NO;
}

#pragma mark -



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
		
	[mainCard release];
	[nextCard release];
	
    AudioServicesDisposeSystemSoundID(playerInBox);
    AudioServicesDisposeSystemSoundID(playerOutBox);
    AudioServicesDisposeSystemSoundID(playerCardTurn);
    AudioServicesDisposeSystemSoundID(playerCardFalls);
    
	if (imageForBot2) {
		[imageForBot2 release];
	}
	
	if (imageForBot) {
		[imageForBot release];
	}
	
	if (learningController) {
		[learningController release];
	}
	
	if (category) {
		[category release];
	}
	
	if (currentFont) {
		[currentFont release];
	}
	
	if (coordinate) {
		[coordinate release];	
	}

	if (cardsArray) {
		[cardsArray release];
	}
	
    [super dealloc];
}


@end
