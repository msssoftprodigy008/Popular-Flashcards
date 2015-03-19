    //
//  FICardsDeckController.m
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FICardsDeckController.h"
#import "FDBController.h"
#import "NSMutableArrayExtensions.h"
#import "Util.h"
#import "Constant.h"
@interface FICardsDeckController()

-(void)createMainView;
-(void)createSmallView;
-(void)initPreferences;


-(NSDictionary*)createContent:(NSInteger)index;

-(void)initSettings;
-(void)initTopBar;
-(void)initBottomBar;

-(void)handleTap:(UITapGestureRecognizer*)sender;
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender;

-(void)updateMainCard;
-(void)updateNextCard;
-(void)controlButtons;
-(void)initCurrentFont;

-(void)initCenterLabel;

-(void)changeCardByJumping;
-(void)changeFromMainToNext;
-(void)growCard;
-(void)growEnded;
-(void)awakeInfo:(BOOL)isQuestion;

-(void)animateFalling;

-(BOOL)compareCurrentIdWithFirst:(FILearningProccesType)prType;
-(void)updateCardFromArray:(FICardView*)card forArr:(NSArray*)cardArr;

-(void)showInfoAfterDelay;
-(BOOL)shuffleTest;

@end


@implementation FICardsDeckController

@synthesize delegate;
@synthesize currentId;
@synthesize isUsingPref;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

-(id)initWithCardsArray:(NSArray*)cards forCategory:(NSString*)Acategory
{
	if (cards) {
        if ([self shuffleTest]) {
            NSLog(@"shuffle");
            NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:cards];
            cardsArray = [[NSMutableArray alloc] initWithObjects:[cards objectAtIndex:0],nil];
            [tmpArr removeObjectAtIndex:0];
            [tmpArr shuffle];
            [cardsArray addObjectsFromArray:tmpArr];     
        }else{
            NSLog(@"not shuffle");
            cardsArray = [[NSMutableArray alloc] initWithArray:cards];
        }
        allCardsNumber = [cards count];
	}else {
		allCardsNumber = 0;
	}

	
	if (Acategory) {
		category = [[NSString alloc] initWithString:Acategory];
	}
	
	
	currentId = 0;
	
	[self init];
	
	[self initPreferences];
	
    isShouldChangeCard = isBothSide;
    
	if (!isUsingPref) {
		isBothSide = NO;
	}

	
	return self;
	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
    CGRect frame;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                frame = CGRectMake(0,0,568,320);
            }
            else{
                frame = CGRectMake(0,0,568,300);
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                frame = CGRectMake(0,0,480,320);
            }
            else{
                frame = CGRectMake(0,0,480,300);
            }
        }
	}else {
		frame = CGRectMake(0,0,1024,1024);
	}
    
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	self.view = contentView;
	[contentView release];
	
	self.view.backgroundColor = [UIColor clearColor];
	self.view.multipleTouchEnabled = NO;
    self.view.exclusiveTouch = YES;
    
	isResized = NO;
	isAwakedInfo = NO;

	[self initCurrentFont];
	[self createSmallView];
	[self initCenterLabel];
	[self createMainView];
		
	
	
	self.view.userInteractionEnabled = NO;
	
    if (!isShouldChangeCard) {
        [NSTimer scheduledTimerWithTimeInterval:1.1f
                                         target:self
                                       selector:@selector(updateNextCard)
                                       userInfo:nil
                                        repeats:NO];
        [self performSelector:@selector(growCard) withObject:nil afterDelay:1.0f];
    }else{
        [self performSelector:@selector(changeCardByJumping) withObject:nil afterDelay:1.0f];
    }
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void)viewDidAppear:(BOOL)animated
{
	
	
}

-(void)animateFallingAtCenter:(CGPoint)fallPoint
{
	if (delegate && [delegate respondsToSelector:@selector(cardFallingWillBegin)]) {
		[delegate cardFallingWillBegin];
	}
	
	
	NSLog(@"falling");
	
	CGFloat angle = rand()%5;
	angle = M_PI/4.0 + M_PI/(2.0*(angle+1)); 
	[mainCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0]];
	currLoc = fallPoint;
	currScale.width = 20.0f/mainCard.frame.size.width;
	currScale.height = 13.0f/mainCard.frame.size.height;
	currRotation = angle;
	
	currAnimation = 2;

	
	[UIView beginAnimations:@"animatePosition" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	mainCard.layer.position = currLoc;
	//[mainCard hideShadow];
	
	[UIView commitAnimations];
	
	[self performSelector:@selector(animateFalling)
			   withObject:nil
			   afterDelay:0.05f];
}

-(void)goAway:(FIDirection)direction
{
	currAnimation = 1;
	mainCard.alpha = 0.0;
    [mainCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:1.0f]];
	switch (direction) {
		case FIDirectionLeft:
			[[FIAnimationController sharedAnimation:self] moveCenter:mainCard toPoint:CGPointMake(-kFCardWidth,mainCard.center.y)];
			break;
		case FIDirectionRight:
			[[FIAnimationController sharedAnimation:self] moveCenter:mainCard toPoint:CGPointMake(480+kFCardWidth,mainCard.center.y)];
			break;
		case FIDirectionDown:
			[[FIAnimationController sharedAnimation:self] moveCenter:mainCard toPoint:CGPointMake(mainCard.center.x,320+kFCardHieght)];
			break;
		default:
			break;
	}
	
		
}

-(void)normalizeState
{
    self.view.userInteractionEnabled = YES;
	currAnimation = -223;
	[self controlButtons];
//	[mainCard hideShadow];
	[[FIAnimationController sharedAnimation:nil] moveCenter:mainCard toPoint:CGPointMake((IS_IPHONE_5)?284:240,160)];
	[[FIAnimationController sharedAnimation:nil] normalizeView:mainCard];
	isResized = NO;
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

-(NSInteger)allCards
{
	if (cardsArray) {
		return [cardsArray count];
	}else {
		return -1;
	}
	
}

-(NSInteger)viewedCards
{
	return currentId;
}

-(void)handleNonDraggingFalling
{
	[self.view bringSubviewToFront:mainCard];
	[mainCard stopAudio];
	if (delegate && [delegate respondsToSelector:@selector(draggingEndedAtPoint:)]) {
		
		[UIView beginAnimations:@"animationScale" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		mainCard.transform = CGAffineTransformScale(mainCard.transform,kFCardResizeWidth/kFCardWidth,kFCardResizeHeight/kFCardHieght);
		[UIView commitAnimations];
		
		[delegate performSelector:@selector(draggingEndedAtPoint:)
					   withObject:nil
					   afterDelay:0.05f];
	}
	
	
	
}

-(void)stopSounds
{
	if (mainCard) {
		[mainCard stopAudio];
	}
}

-(void)restoreCenterCard:(FILearningProccesType)proccesType
{
    if (![self compareCurrentIdWithFirst:proccesType]) {
        nextCard.hidden = NO;
       [nextCard seeShadow];
        [self changeFromMainToNext];
           
    }else{
        
        if (mainCard) {
            mainCard.transform = CGAffineTransformMakeScale(0.65,0.65);
        }
         
        if (centerLabel) {
            centerLabel.hidden = YES;
        }
         
        if (!mainCard.isQuestion) {
            [[FIAnimationController sharedAnimation:nil] flip:mainCard];
            [mainCard setSide:YES];
        }
        
    }

    
	
}

#pragma mark -
#pragma mark FICardView delegate

-(void)checkButtonChangedState:(FICheckboxState)checkedState{
	
}

-(void)imageNeedFullScreen:(CGPoint)imageCenter forSize:(CGSize)imageSize forSide:(BOOL)isFront{
	if (mainCard) {
		[mainCard changeSide];
		
		if (!isAwakedInfo) {
			isAwakedInfo = YES;
		//	[self awakeInfo:NO];
			
		}
		
		[[FIAnimationController sharedAnimation:nil] flip:mainCard];
	}
	
	if (delegate && [delegate respondsToSelector:@selector(cardTurned:)]) {
		[delegate cardTurned:mainCard.isQuestion];
	}
}

#pragma mark -

#pragma mark -
#pragma mark FIAnimationController delegate

-(void)didEndAnimation
{
	if (currAnimation == 1) {
		currAnimation = -100;
		mainCard.hidden = YES;
		mainCard.alpha = 1.0;
		mainCard.center = CGPointMake((IS_IPHONE_5)?284:240,150);
		
		currentId++;
		
		if (delegate && [delegate respondsToSelector:@selector(cardIdChangedTo:)]) {
			[delegate cardIdChangedTo:[self getCurrentId]];
		}
		
		
		isResized = NO;
		
		if (currentId != [cardsArray count]) {
			[NSTimer scheduledTimerWithTimeInterval:0.2f
										 target:self
									   selector:@selector(updateMainCard)
									   userInfo:nil
										repeats:NO];
		
			[NSTimer scheduledTimerWithTimeInterval:0.6f
										 target:self
									   selector:@selector(updateNextCard)
									   userInfo:nil
										repeats:NO];
		}
		else {
			if (delegate && [delegate respondsToSelector:@selector(deckEnded)]) {
				[delegate deckEnded];
			}
		}
	
	}
	else if(currAnimation == 2) {
			currAnimation = -100;
			mainCard.center = currLoc;
            mainCard.layer.transform = CATransform3DScale(mainCard.layer.transform,currScale.width,currScale.height,1);
			mainCard.layer.transform = CATransform3DRotate(mainCard.layer.transform,currRotation,0,0,1);
			
			if (delegate && [delegate respondsToSelector:@selector(cardFallingDidEnd)]) {
				[delegate cardFallingDidEnd];
			}
		}else if(currAnimation == 3){
			if (!isAwakedInfo) {
				isAwakedInfo = YES;
				[self performSelector:@selector(showInfoAfterDelay)
                           withObject:nil afterDelay:0.25f];
			}
		}else if(currAnimation == 4){
            currAnimation = -100;
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
            nextCard.isBothSide = isBothSide;
            [nextCard hideShadow];
            [self updateNextCard];
            [self controlButtons];
            [self performSelector:@selector(growCard) withObject:nil afterDelay:0.25f];
        }else if(currAnimation == 500){
            currAnimation = -100;
            self.view.userInteractionEnabled = YES;
        }

}

#pragma mark -

#pragma mark -
#pragma mark UIView animation delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:@"animationScale"]) {
		[delegate draggingEndedAtPoint:mainCard.center];
	}
}

#pragma mark UIView animation delegate ends

#pragma mark -
#pragma mark private

-(void)controlButtons
{
	UIButton *leftButton = (UIButton*)[self.view viewWithTag:-111];
	UIButton *rightButton = (UIButton*)[self.view viewWithTag:-112];
	UIButton *bottomButton = (UIButton*)[self.view viewWithTag:-113];
	
	if (leftButton) {
		[self.view bringSubviewToFront:leftButton];
	}
	
	if (rightButton) {
		[self.view bringSubviewToFront:rightButton];
	}
	
	if (bottomButton) {
		[self.view bringSubviewToFront:bottomButton];
	}
}

-(void)createMainView
{
	if (cardsArray) {
        
        mainCard = [[FICardView alloc] initWithContent:[self createContent:currentId] forSide:isBothSide forRev:isReversed forCheckBox:NO];
		mainCard.delegate = self;
		mainCard.currentFont = [UIFont fontWithName:currentFont size:currentSize];
		[self.view addSubview:mainCard];
		
		longPressRecog = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																			 action:@selector(handleLongPress:)];
		[mainCard addGestureRecognizer:longPressRecog];
		[longPressRecog release];
		longPressRecog.allowableMovement = 500;
		longPressRecog.minimumPressDuration = 0.2f;
		
		tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[mainCard addGestureRecognizer:tapRecog];
		[tapRecog release];
		
		currAnimation = -223;
		[self controlButtons];
        
		mainCard.center = CGPointMake((IS_IPHONE_5)?284:240,160);
        
        if (!isShouldChangeCard) {
            mainCard.transform = CGAffineTransformMakeScale(0.65,0.65);
        }else{
            mainCard.transform = CGAffineTransformMakeScale(kFCardSmallWidth/kFCardWidth,kFCardSmallHeight/kFCardHieght);
            [self.view bringSubviewToFront:nextCard];
        }
	}
	
}

-(void)initCenterLabel{
	centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,60.0,60.0)];
	centerLabel.backgroundColor = [UIColor clearColor];
    centerLabel.textColor = kBoxCountLabelTextColor;
    centerLabel.shadowColor = kBoxCountLabelShadowColor;
    centerLabel.shadowOffset = kBoxCountLabelShadowOffset;
	centerLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	centerLabel.center = CGPointMake(((IS_IPHONE_5)?284.0:240.0),105.0);
	centerLabel.textAlignment = UITextAlignmentCenter;
	centerLabel.text = [NSString stringWithFormat:@"%d",allCardsNumber-1];
	[self.view addSubview:centerLabel];
	[centerLabel release];
}

-(void)createSmallView
{
	if ((cardsArray && [cardsArray count]>1) || isShouldChangeCard) {
        
        if (!isShouldChangeCard) {
            nextCard = [[FICardView alloc] initWithContent:[self createContent:currentId+1] forSide:isBothSide forRev:isReversed forCheckBox:NO];
       		[nextCard hideShadow];
        }else{
            nextCard = [[FICardView alloc] initWithContent:[self createContent:currentId] forSide:YES forRev:isReversed forCheckBox:NO];
        }
        
		nextCard.currentFont = [UIFont fontWithName:currentFont size:currentSize];
		nextCard.center = CGPointMake((IS_IPHONE_5)?284:240,160);
		[self.view addSubview:nextCard];
        if (!isShouldChangeCard) {
            nextCard.transform = CGAffineTransformMakeScale(kFCardSmallWidth/kFCardWidth,kFCardSmallHeight/kFCardHieght);
        }else{
            nextCard.transform = CGAffineTransformMakeScale(0.65,0.65);
        }
	}
}

-(void)initSettings
{
	
}

-(void)initTopBar
{
	
}

-(void)initBottomBar
{
	
}

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

-(void)changeCardByJumping{
    currAnimation = 4;
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
    [[FIAnimationController sharedAnimation:self] deckChangeAnimation:mainCard forScr:nextCard];
}

-(void)changeFromMainToNext{
    [[FIAnimationController sharedAnimation:nil] deckChangeAnimation:nextCard forScr:mainCard];
}

-(void)growCard{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growEnded)];
	mainCard.transform = CGAffineTransformIdentity;
	
	[UIView commitAnimations];
	
}

-(void)growEnded{
    self.view.userInteractionEnabled = YES;
	//[self awakeInfo:YES];
}

-(void)animateFalling
{
	[[FIAnimationController sharedAnimation:self] fallingToSomething:mainCard
															forPoint:currLoc
															forScale:currScale
															  forRot:currRotation];
}

-(void)awakeInfo:(BOOL)isQuestion{
	
	if (!delegate || ![delegate respondsToSelector:@selector(learningType)]) {
		return;
	}
	
	if ([delegate learningType] == FILearningProccesTypeTest) {
		
		if (isQuestion) {
            BOOL isTF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isTF"];
			if(!isTF)
			{
				NSString* Amessage=@"When you test,we build studying schedule for you. To begin, try to guess the back of this card.";

                [Util showMessageInCustomAlert:self.view
                                      forTitle:@"Test"
                                    forMessage:Amessage
                                forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isTF"];
			}	
		}else {
            BOOL isDF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDF"];
			if(!isDF)
			{
				NSString* Amessage=@"Choose whether you knew the answer or remembered it with some effort. Move card to the according bin or tap on a button.";

				[Util showMessageInCustomAlert:self.view
                                      forTitle:@"Test"
                                    forMessage:Amessage
                                forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDF"];
			}
		}
	}else {
        BOOL isSTF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSTF"];
		if (isQuestion) {
			if(!isSTF)
			{
				NSString* Amessage=@"You can repeat forgotten cards without those which we schedule for you. To begin,try to guess the back of this card.";

				[Util showMessageInCustomAlert:self.view
                                      forTitle:@"Study"
                                    forMessage:Amessage
                                forButtonTitle:@"OK"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSTF"];
			}
		}else {
            BOOL isSDF = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSDF"];
			if(!isSDF)
			{
				NSString* Amessage=@"Choose whether you knew the answer. Move card to the according bin or tap on a button.";

				[Util showMessageInCustomAlert:self.view
                                      forTitle:@"Study"
                                    forMessage:Amessage
                                forButtonTitle:@"OK"];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSDF"];
			}
		}
		
	}
	
}


-(void)handleTap:(UITapGestureRecognizer*)sender;
{
	if (!isBothSide) {
		if (mainCard) {
			[mainCard changeSide];
		
			currAnimation = 3;	
			[[FIAnimationController sharedAnimation:self] flip:mainCard];
		}
		
		if (delegate && [delegate respondsToSelector:@selector(cardTurned:)]) {
			[delegate cardTurned:mainCard.isQuestion];
		}
	}
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)sender
{
	if (mainCard) 
	{
		CGPoint translate = [sender locationInView:self.view];
		[mainCard stopAudio];
		if (!isResized) 
		{
            [mainCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5f]];
			[mainCard seeShadow];
			[self.view bringSubviewToFront:mainCard];
			[[FIAnimationController sharedAnimation:nil] resize:mainCard toSize:CGSizeMake(kFCardResizeWidth,kFCardResizeHeight)];
			[[FIAnimationController sharedAnimation:nil] moveCenter:mainCard toPoint:translate];
			isResized = YES;
			
			//[NSThread detachNewThreadSelector:@selector(makeSoundBoxIn) toTarget:self withObject:nil];
			if (delegate && [delegate respondsToSelector:@selector(draggingBeganAtPoint:)]) {
				[delegate draggingBeganAtPoint:translate];
			}
			
			
			
		}
		else {
			mainCard.center = translate;
			
			if (delegate && [delegate respondsToSelector:@selector(cardMovedToPoint:)]) {
				[delegate cardMovedToPoint:translate];
			}
						
		}
		
		if (sender.state == UIGestureRecognizerStateEnded ) {
			NSLog(@"press ended");
            self.view.userInteractionEnabled = NO;
			if (delegate && [delegate respondsToSelector:@selector(draggingEndedAtPoint:)]) {
				[delegate draggingEndedAtPoint:translate];
			}
		}
		
	}
}

-(void)updateMainCard
{
	mainCard.transform = CGAffineTransformIdentity;
	[mainCard seeShadow];
	[mainCard changeContent:[self createContent:currentId]];
	currAnimation = -223;
	[self controlButtons];
	allCardsNumber--;
	centerLabel.text = [NSString stringWithFormat:@"%d",allCardsNumber-1];
    currAnimation = 500;
	[[FIAnimationController sharedAnimation:self] grow:mainCard
                                            fromCenter:CGPointMake(((IS_IPHONE_5)?284:240),160)
											 fromSize:CGSizeMake(kFCardSmallWidth,kFCardSmallHeight)];
    
}

-(void)updateNextCard
{
	if (currentId+1 != [cardsArray count]) {
		[nextCard changeContent:[self createContent:currentId+1]];
	}
	else {
		nextCard.hidden = YES;
	}

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

-(void)initPreferences
{
	if (category) {
		NSArray *cardSettings = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_Setings",category]];
		
		if (cardSettings) {
			isBothSide = [[cardSettings objectAtIndex:0] boolValue];
			isReversed = [[cardSettings objectAtIndex:1] boolValue];
		}
		else {
			isReversed = NO;
			isBothSide = NO;
		}
	}
	else {
		isReversed = NO;
		isBothSide = NO;
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
	currentSize = 21;
}

-(BOOL)shuffleTest{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"]){
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"] boolValue];
    }
    return NO;
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

-(void)showInfoAfterDelay{
    //[self awakeInfo:NO];
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
	
		
	if (mainCard) 
		[mainCard release];
	
	if (nextCard) 
		[nextCard release];
	
	if (cardsArray) {
		[cardsArray release];
	}
	
	if (currentFont) {
		[currentFont release];
	}
	
	[super dealloc];
}


@end
