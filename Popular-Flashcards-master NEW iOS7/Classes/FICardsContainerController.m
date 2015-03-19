    //
//  FICardsContainerController.m
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FICardsContainerController.h"
#import "FICardView.h"
#import "FIRoundedButton.h"
#import "FDBController.h"
#import "Util.h"
#import "Constant.h"
@interface FICardsContainerController(Private)

-(void)createCards;
-(void)handleTap:(UITapGestureRecognizer*) sender;
-(void)returnFromFullScreen:(UITapGestureRecognizer*)sender;
-(void)handlePan:(UIPanGestureRecognizer*)sender;
-(NSDictionary*)createContent:(NSInteger)index;
-(void)compleateDragging;
-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP;
-(void)updateCard:(NSInteger)tag;
-(void)updateCenterCard;
-(void)updateCardWithView:(FICardView*)cardView;
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)initPreferences;
-(void)savePreferences;

-(void)removeCardWithCurrentId;

-(void)initCurrentFont;
-(void)hideCenterCard;
-(void)seeCenterCard;

-(void)restoreCenterCard;
-(FICardView*)aboveCard:(NSDictionary*)dic;
-(NSDictionary*)traslateDictionary:(NSDictionary*)dic;

-(void)seeCenterCardShadow;

//animatios
-(void)performBothSideAnimation;

-(void)makeSoundCardTurn;

//Notifications
-(void)importCardNotification:(NSNotification*)sender;

@end


@implementation FICardsContainerController

@synthesize category;
@synthesize currentId;
@synthesize isBothSide;
@synthesize isReversed;
@synthesize delegate;
@synthesize withoutAnimations;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	CGRect frame;
	
	if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                frame = CGRectMake(0,0,568,320);
            }
            else{
                frame = CGRectMake(0,0,568,300);
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
	
	UIImageView *bg = [[UIImageView alloc] initWithFrame:frame];
	
	if ([Util isPhone]) {
		bg.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90];
	}

	
	
	[self.view addSubview:bg];
	[bg	release];
	
	[self initPreferences];
	[self initCurrentFont];
    self.view.multipleTouchEnabled = NO;
    self.view.exclusiveTouch = YES;
	
	
	panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.view addGestureRecognizer:panRecog];
	panRecog.delegate = self;
	[panRecog release];
	
	tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.view addGestureRecognizer:tapRecog];
	tapRecog.delegate = self;
	[tapRecog release];
	
	[self createCards];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(importCardNotification:) name:@"importTerm" object:nil];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"CardFlip" ofType:@"wav"]], &playerCardTurn);
}

-(void)viewDidLoad
{
	if ([Util isPhone] && !withoutAnimations) {
		[self performSelector:@selector(restoreCenterCard)
				   withObject:nil
				   afterDelay:0.25f];
	}
	
	
}


-(void)initCardsArray:(NSArray*)cards
{
	if (cardsArray) {
		[cardsArray release];
		cardsArray = nil;
	}
	
	if (cards) {
		cardsArray = [[NSMutableArray alloc] initWithArray:cards];
	}
	
	if ([cardsArray count]<=0) {
		if (delegate && [delegate respondsToSelector:@selector(editing:)]) {
			[delegate editing:NO];
		}
	}else {
		if (delegate && [delegate respondsToSelector:@selector(editing:)]) {
			[delegate editing:YES];
		}
	}

	
}

-(void)initIgnoredCards:(NSMutableSet*)AignoredCards
{
	if (ignoredCards) {
		[ignoredCards release];
		ignoredCards = nil;
	}
	
	if (AignoredCards) {
		ignoredCards = [[NSMutableSet alloc] initWithSet:AignoredCards];
	}
}

-(void)filterCardsByWord:(NSString*)word
{
	
}

-(void)addCard:(NSArray*)card
{
	if (!cardsArray || !card) {
		return;
	}
	
	[cardsArray addObject:card];
	currentId = [cardsArray count]-1;
	
	isLast = YES;
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
	
	if ([cardsArray count]==1) {
		isFirst = YES;
		centerCard.hidden = NO;
		
		if (delegate && [delegate respondsToSelector:@selector(editing:)]) {
			[delegate editing:YES];
		}
		
		if (delegate && [delegate respondsToSelector:@selector(deleteCard:)]) {
			[delegate deleteCard:YES];
		}
		
	}
	
	[self updateCard:100];
	[self updateCard:101];
	
	[centerCard seeShadow];
}

-(void)updateCurrentCard:(NSArray*)card
{
	if (!cardsArray || !card) {
		return;
	}
	
	[cardsArray replaceObjectAtIndex:currentId withObject:card];
	centerCard = (FICardView*)[self.view viewWithTag:101];
//	if (![Util isPhone]) {
//		[[FIAnimationController sharedAnimation:nil] rotate:centerCard]; changed by sanjeev reddy 
//	}
	[self updateCard:101];
	[centerCard seeShadow];
	
}

-(void)scaleCenterCard:(NSDictionary*)dic
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	FICardView *card = (FICardView*)[self aboveCard:dic];
	[card seeShadow];
	
	if (card) {
		
		if ([Util isPhone]) {
			card.transform = CGAffineTransformMakeScale(0.65,0.65);
        }
		

		[self.view bringSubviewToFront:card];
	}else {
		if (!centerCard.isQuestion) {
			[[FIAnimationController sharedAnimation:nil] flip:centerCard];
			[centerCard changeSide];
		}
		
		if (![Util isPhone]) {
			return;
		}
		
	}

	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	
	centerCard.transform = CGAffineTransformMakeScale(0.65,0.65);
	
		
	if (card) {
		if ([Util isPhone]) {
			card.center = CGPointMake(((IS_IPHONE_5)?284.0:240.0),160.0);
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				card.center = CGPointMake(384.0,512.0);
			}else {
				card.center = CGPointMake(512.0,384.0);
			}
			
		}
		
		
		
		
	}
	
	[UIView commitAnimations];
	
	
	
	
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
	if ([Util isPhone]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}else {
		return YES;
	}

}

-(void)setCurrentId:(NSInteger)c
{
	currentId = c;
	
	isLast = NO;
	isFirst = NO;
	
	if (c==0) {
		isFirst = YES;
	}
	
	if (cardsArray) {
		if (c==[cardsArray count]-1) {
			isLast = YES;
		}	
	}
	
}

-(NSArray*)currentCardId
{
	if (cardsArray &&currentId>=0&&[cardsArray count]>currentId) {
		NSArray *card = [cardsArray objectAtIndex:currentId];
		return card;
	}
	
	return nil;
}

-(void)removeCurrentCard
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card"
													message:@"Are you sure you want to remove this card?"
												   delegate:self
										  cancelButtonTitle:@"YES"
										  otherButtonTitles:@"NO",nil];
	alert.tag = -100;
	alert.delegate = self;
	[alert show];
	[alert release];
}

-(void)makeBothSide
{
	animaId = -300;
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	isBothSide = !isBothSide;
	
	leftCard = (FICardView*)[self.view viewWithTag:100];
	centerCard = (FICardView*)[self.view viewWithTag:101];
	rightCard = (FICardView*)[self.view viewWithTag:102];
	rightCard.hidden = NO;
	
	leftCard.isBothSide = isBothSide;
	rightCard.isBothSide = isBothSide;
	
	[leftCard setSide:YES];
	[rightCard setSide:YES];
	
	centerCard.tag = 102;
	rightCard.tag = 101;
	[self updateCard:101];
	
	[self performSelector:@selector(performBothSideAnimation)
			   withObject:nil afterDelay:0.25f];
}

-(void)performBothSideAnimation
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	rightCard = (FICardView*)[self.view viewWithTag:102];
	
    if ([Util isPhone]) {
       centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
    }else{
        if ([Util isPortrait:(UIViewController*)delegate]) {
			centerCard.center = CGPointMake(384,512);
		}else {
			centerCard.center = CGPointMake(512,384);
		}
    }
	
	[[FIAnimationController sharedAnimation:self] fallAndBounce:centerCard];
    [centerCard updateCardTextView];
	[centerCard seeShadow];
	[UIView beginAnimations:@"centerTraslation" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	[UIView setAnimationDuration:0.25f];
	
    if ([Util isPhone]) {
       [rightCard setCenter:CGPointMake(((IS_IPHONE_5)?284:240),((IS_IPHONE_5)?568:480))];
    }else{
        if ([Util isPortrait:(UIViewController*)delegate]) {
			rightCard.center = CGPointMake(384,1400);
		}else {
			rightCard.center = CGPointMake(512,1000);
		}
    }
	
	
	[UIView commitAnimations];
}

-(void)makeReversed
{
	animaId = -100;
	
	isReversed = !isReversed;
	
	leftCard = (FICardView*)[self.view viewWithTag:100];
	centerCard = (FICardView*)[self.view viewWithTag:101];
	rightCard = (FICardView*)[self.view viewWithTag:102];
	
	leftCard.isReversed = isReversed;
	centerCard.isReversed = isReversed;
	rightCard.isReversed = isReversed;
	
	[centerCard reloadContent];
	[leftCard reloadContent];
	[rightCard reloadContent];
	
	[[FIAnimationController sharedAnimation:self] flip:centerCard];
	[centerCard seeShadow];
}

-(void)makeShuffle
{
	animaId = -100;
	
	if (!cardsArray || [cardsArray count]==0) {
		return;
	}
	
	NSInteger all = [cardsArray count];
	currentId = rand()%all;
	
	[self updateCard:100];
	[self updateCard:101];
	[self updateCard:102];

	centerCard = (FICardView*)[self.view viewWithTag:101];
	[centerCard seeShadow];
	
	if (centerCard) {
		[[FIAnimationController sharedAnimation:self] rotate:centerCard];
	}
	
}

-(void)saveCurrentSession
{
	[self savePreferences];
}

-(void)stopSounds
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	if(centerCard)
		[centerCard stopAudio];
}

-(void)rotateView:(UIInterfaceOrientation)orientation
{
	if (![Util isPhone]) {
		leftCard = (FICardView*)[self.view viewWithTag:100];
		centerCard = (FICardView*)[self.view viewWithTag:101];
		rightCard = (FICardView*)[self.view viewWithTag:102];
		
		if ([Util isPortraitWithOrientation:orientation]) {
			leftCard.center = CGPointMake(-leftCard.frame.size.width/2,512);
			centerCard.center = CGPointMake(384,512);
			rightCard.center = CGPointMake(768+rightCard.frame.size.width/2,512);
		}else {
			leftCard.center = CGPointMake(-leftCard.frame.size.width/2,384);
			centerCard.center = CGPointMake(512,384);
			rightCard.center = CGPointMake(1024+rightCard.frame.size.width/2,384);
		}
	}
}

-(void)quit
{
	if (delegate && [delegate respondsToSelector:@selector(cardsWantToQuit)]) {
		[delegate cardsWantToQuit];
	}
}

-(void)hideCard:(FICardPosition)position hidden:(BOOL)hidden
{
	FICardView *card;
	
	switch (position) {
		case FICardPositionLeft:
			card = (FICardView*)[self.view viewWithTag:100];
			break;
		case FICardPositionCenter:
			card = (FICardView*)[self.view viewWithTag:101];
			break;
		case FICardPositionRight:
			card = (FICardView*)[self.view viewWithTag:102];
			break;
		default:
			break;
	}
	
	if (card) {
		card.hidden = hidden;
	}
	
	return;
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark FICardViewDelegate methods

-(void)checkButtonChangedState:(FICheckboxState)checkedState
{
	NSArray *currArr = [cardsArray objectAtIndex:currentId];
	NSNumber *cardId = [NSNumber numberWithInt:[[currArr objectAtIndex:0] intValue]];
	
	if (checkedState == FICheckboxStateChecked) {
		[ignoredCards addObject:cardId];
	}else {
		[ignoredCards removeObject:cardId];
	}

	
	NSArray *arr = [NSArray arrayWithObjects:currArr,[NSNumber numberWithInt:checkedState],nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cardChecked"
														object:arr];
													 
	
	NSInteger all = [cardsArray count];
	currentId = (currentId+1)%all;
	[self updateCard:100];
	[self updateCard:101];
	[self updateCard:102];
	
	if (currentId == all-1) {
		isLast = YES;
	}else if (currentId == 0) {
				isFirst = YES;
			}
	

	
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
	[centerCard seeShadow];
	[[FIAnimationController sharedAnimation:nil] fallAndTrembell:centerCard];
	
}

-(void)imageNeedFullScreen:(CGPoint)imageCenter forSize:(CGSize)imageSize forSide:(BOOL)isFront
{
	if (![Util isPhone]) {
		return;
	}
	
	if (!bgFullScreenView) {
		
		if ([Util isPhone]) {
			bgFullScreenView = [[FISketchedImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),320)];
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				bgFullScreenView = [[FISketchedImageView alloc] initWithFrame:CGRectMake(0,0,768,1004)];
			}else {
				bgFullScreenView = [[FISketchedImageView alloc] initWithFrame:CGRectMake(0,0,1024,748)];
			}

		}
		bgFullScreenView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnFromFullScreen:)];
		[bgFullScreenView addGestureRecognizer:tap];
		[tap release];
	}
	
	bgFullScreenView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
	
	NSArray *card = [cardsArray objectAtIndex:currentId];
	NSInteger cardId = [[card objectAtIndex:0] intValue];
	
	UIImage *fullImage = [Util imageWithId:category forId:cardId forWhat:isFront];
	
	if (!fullImage) {
		fullImage = [Util imageWithId:category forId:cardId forWhat:!isFront];
	}
	
	
	if (fullImage) {
		NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
		[attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
		[attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
		[attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
		[attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
		[attrib setObject:fullImage forKey:@"image"];
		[bgFullScreenView changeAtributes:attrib];
		centerCard = (FICardView*)[self.view viewWithTag:101];
		panRecog.enabled = NO;
		tapRecog.enabled = NO;
		CGPoint c = [centerCard convertPoint:imageCenter toView:self.view];
		currentCenter = c;
		currentSize = imageSize;
        bgFullScreenView.alpha = 0.0;
		[self.view addSubview:bgFullScreenView];
		
		if (delegate && [delegate respondsToSelector:@selector(fullScreen:)]) {
			[delegate fullScreen:YES];
		}
		
        bgFullScreenView.alpha = 1.0;
		[[FIAnimationController sharedAnimation:nil] grow:bgFullScreenView
											   fromCenter:c
												 fromSize:CGSizeMake(0.1,0.1)];
		if ([Util isPhone]) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:bgFullScreenView
															toPoint:CGPointMake(((IS_IPHONE_5)?284:240),160)];
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				[[FIAnimationController sharedAnimation:nil] moveCenter:bgFullScreenView
																toPoint:CGPointMake(384,502)];
			}else {
				[[FIAnimationController sharedAnimation:nil] moveCenter:bgFullScreenView
																toPoint:CGPointMake(512,374)];
			}
			
		}
		
	}
}

#pragma mark -
#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -100) {
		if (buttonIndex == [alertView cancelButtonIndex]) {
			[self performSelector:@selector(removeCardWithCurrentId)
                       withObject:nil
                       afterDelay:0.0f];
		}
	}
}

#pragma mark alertView delegate ends

#pragma mark -
#pragma mark animation delegate

-(void)didEndAnimation
{
	if (animaId == -100) {
		[bgFullScreenView removeFromSuperview];
		[bgFullScreenView release];
		bgFullScreenView = nil;
		panRecog.enabled = YES;
		tapRecog.enabled = YES;	
	}else if (animaId != -300) {
		centerCard.hidden = YES;
        if ([cardsArray count]>0) {
			[self updateCenterCard];
			FIAnimationController *sharedAnimation = [FIAnimationController sharedAnimation:nil];
			[sharedAnimation performSelector:@selector(pushView:)
								  withObject:centerCard
								  afterDelay:0.4f];
			[self performSelector:@selector(seeCenterCard)
					   withObject:nil
					   afterDelay:0.4f];
		}else {
            [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
			if (delegate && [delegate respondsToSelector:@selector(cardsWantToQuit)]) {
				[delegate cardsWantToQuit];
			}
		}

		
		
	}else {
		rightCard = (FICardView*)[self.view viewWithTag:102];
		centerCard = (FICardView*)[self.view viewWithTag:101];
		rightCard.isBothSide = centerCard.isBothSide;
		[rightCard setSide:YES];
		[self updateCard:102];
        
        if ([Util isPhone]) {
           rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+kCardViewWidth/2,160);     
        }else{
            if ([Util isPortrait:(UIViewController*)delegate]) {
                rightCard.center = CGPointMake(768+rightCard.frame.size.width/2,512);
            }else {
                rightCard.center = CGPointMake(1024+rightCard.frame.size.width/2,384);
            } 
        }
		
		[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	}



	

}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self updateCard:100];
	[self updateCard:102];
}

#pragma mark -
#pragma mark handleFullScreen
-(void)returnFromFullScreen:(UITapGestureRecognizer*)sender
{
	bgFullScreenView.backgroundColor = [UIColor colorWithRed:0.0
													   green:0.0
														blue:0.0
													   alpha:0.0];
	
	animaId = -100;
	
	CGSize sz = [bgFullScreenView drawnedImageSize];
	
	
	
	[[FIAnimationController sharedAnimation:self] small:bgFullScreenView
												toFrame:CGRectMake(currentCenter.x,
																   currentCenter.y,
																   bgFullScreenView.frame.size.width*currentSize.width/sz.width,
																   bgFullScreenView.frame.size.height*currentSize.height/sz.height)];
	if (delegate && [delegate respondsToSelector:@selector(fullScreen:)]) {
		[delegate fullScreen:NO];
	}
	
}

#pragma mark -
#pragma mark private methods

-(void)handleTap:(UITapGestureRecognizer*) sender
{
	if (!cardsArray || [cardsArray count] == 0) {
		return;
	}
	
	if (isBothSide) {
		return;
	}
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
        
	if (centerCard) {
        [self makeSoundCardTurn];
		[centerCard changeSide];
		[[FIAnimationController sharedAnimation:nil] flip:centerCard];
	}
	
}

-(void)handlePan:(UIPanGestureRecognizer*)sender
{
	if (!cardsArray || [cardsArray count] == 0) {
		return;
	}
   	
	CGPoint translate = [sender translationInView:self.view];
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
	leftCard = (FICardView*)[self.view viewWithTag:100];
	rightCard = (FICardView*)[self.view viewWithTag:102];
	
	if (isFirst) {
		
		if ([Util isPhone]) {
			centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240)+translate.x,160);
			rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+kCardViewWidth/2+translate.x,160);
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				centerCard.center = CGPointMake(384+translate.x,512);
				rightCard.center = CGPointMake(768+kFCardLargeWidth/2+translate.x,512);
			}else {
				centerCard.center = CGPointMake(512+translate.x,384);
				rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+translate.x,384);
			}

			
		}
		[rightCard updateCardTextView];
	}
	else {
		if (isLast) {
			
			if ([Util isPhone]) {
				centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240)+translate.x,160);
				leftCard.center = CGPointMake(-kCardViewWidth/2+translate.x,160);
			}else {
				if ([Util isPortrait:(UIViewController*)delegate]) {
					centerCard.center = CGPointMake(384+translate.x,512);
					leftCard.center = CGPointMake(-kFCardLargeWidth/2+translate.x,512);
				}else {
					centerCard.center = CGPointMake(512+translate.x,384);
					leftCard.center = CGPointMake(-kFCardLargeWidth/2+translate.x,384);
				}

			}

					
			[leftCard updateCardTextView];
		}
		else {
			if ([Util isPhone]) {
				centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240)+translate.x,160);
				leftCard.center = CGPointMake(-kCardViewWidth/2+translate.x,160);
				rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+kCardViewWidth/2+translate.x,160);		
			}else {
				if ([Util isPortrait:(UIViewController*)delegate]) {
					centerCard.center = CGPointMake(384+translate.x,512);
					leftCard.center = CGPointMake(-kFCardLargeWidth/2+translate.x,512);
					rightCard.center = CGPointMake(768+kFCardLargeWidth/2+translate.x,512);
				}else {
					centerCard.center = CGPointMake(512+translate.x,384);
					leftCard.center = CGPointMake(-kFCardLargeWidth/2+translate.x,384);
					rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+translate.x,384);
				}

			}


			[rightCard updateCardTextView];
			[leftCard updateCardTextView];
		}

	}

	CGFloat w;
	CGFloat p;
	if ([Util isPhone]) {
		p = ((IS_IPHONE_5)?568:480);
		w = kCardViewWidth;
	}else {
		w = kFCardLargeWidth;
		if ([Util isPortrait:(UIViewController*)delegate]) {
			p = 768;
		}else {
			p = 1024;
		}
		
	}
	
	if (leftCard.center.x<=-w/2 || isFirst) {
		leftCard.hidden = YES;
	}
	else {
		leftCard.hidden = NO;
		[leftCard seeShadow];
	}
	


	
	if (rightCard.center.x>=p+w/2 || isLast) {
		rightCard.hidden = YES;
	}
	else {
		rightCard.hidden = NO;
		[rightCard seeShadow];
	}
	
	/*if (sender.state == UIGestureRecognizerStateBegan)
	{
		[leftCard seeShadow];
		[rightCard seeShadow];
	}*/
	
    if (sender.state == UIGestureRecognizerStateEnded)
	{
		[self compleateDragging];
	}
        
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
	UIButton *centerQuit = (UIButton*)[centerCard viewWithTag:109];
	
	if ([touch.view isDescendantOfView:centerQuit]) {
		return NO;
	}
	
	return YES;
}


-(void)createCards
{
	if (!cardsArray) {
		return;
	}
	
	CGRect quitButtonFrame;
	
	if ([Util isPhone]) {
		quitButtonFrame = CGRectMake(((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)-31.0,
									 0.0,
									 31.0,
									 30.0);
	}else {
		quitButtonFrame = CGRectMake(kFCardLargeWidth-46.0,
									 5.0,
									 41.0,
									 40.0);
	}

	
	centerCard = [[FICardView alloc] initWithContent:[self createContent:currentId] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	centerCard.currentFont = [UIFont fontWithName:currentFont size:cSize];
	[centerCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5f]];
	centerCard.userInteractionEnabled = YES;
	
	if ([Util isPhone] && !withoutAnimations) {
		centerCard.transform = CGAffineTransformMakeScale(0.65,0.65);
	}
	
	centerCard.delegate = self;
	
	if (!cardsArray || [cardsArray count] == 0) {
		centerCard.hidden = YES;
	}
	
	if (cardsArray && [cardsArray count]>currentId) {
		if (ignoredCards && [ignoredCards containsObject:[NSNumber numberWithInt:[[[cardsArray objectAtIndex:currentId] objectAtIndex:0]intValue]]]) {
			[centerCard check:YES];
		}else {
			[centerCard check:NO];
		}
	}

	if ([Util isPhone]) {
		centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
	}else {
		if ([Util isPortrait:(UIViewController*)delegate]) {
			centerCard.center = CGPointMake(384,512);
		}else {
			centerCard.center = CGPointMake(512,384);
		}

	}
	
	
	centerCard.tag = 101;
	
	[self.view addSubview:centerCard];
	[centerCard release];
	
	NSInteger all = [cardsArray count];
	
	if (all <= 0) {
		all = 1;
	}
	
	leftCard = [[FICardView alloc] initWithContent:[self createContent:(currentId-1+all)%all] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	leftCard.currentFont = [UIFont fontWithName:currentFont size:cSize];
	leftCard.userInteractionEnabled = YES;
	[leftCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5f]];
	[leftCard hideShadow];
	leftCard.delegate = self;
    leftCard.hidden = YES;
	
	if (cardsArray && [cardsArray count]>(currentId-1+all)%all) {
	
		if (ignoredCards && [ignoredCards containsObject:[NSNumber numberWithInt:[[[cardsArray objectAtIndex:(currentId-1+all)%all] objectAtIndex:0]intValue]]]) {
			[leftCard check:YES];
		}else {
			[leftCard check:NO];
		}
	}
	
	if ([Util isPhone]) {
		leftCard.center = CGPointMake(-((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
	}else {
		if ([Util isPortrait:(UIViewController*)delegate]) {
			leftCard.center = CGPointMake(-leftCard.frame.size.width/2,512);
		}else {
			leftCard.center = CGPointMake(-leftCard.frame.size.width/2,384);
		}

	}

	leftCard.tag = 100;
	[self.view addSubview:leftCard];
	[leftCard release];
	
	rightCard = [[FICardView alloc] initWithContent:[self createContent:(currentId+1)%all] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	rightCard.currentFont = [UIFont fontWithName:currentFont size:cSize];
	[rightCard setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.5f]];
	rightCard.userInteractionEnabled = YES;
	[rightCard hideShadow];
	rightCard.delegate = self;
	
	if (cardsArray && [cardsArray count]>(currentId+1)%all) {
		if (ignoredCards && [ignoredCards containsObject:[NSNumber numberWithInt:[[[cardsArray objectAtIndex:(currentId+1)%all] objectAtIndex:0]intValue]]]) {
			[rightCard check:YES];
		}else {
			[rightCard check:NO];
		}
	}
	
	if ([Util isPhone]) {
		rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
	}else {
		if ([Util isPortrait:(UIViewController*)delegate]) {
			rightCard.center = CGPointMake(768+rightCard.frame.size.width/2,512);
		}else {
			rightCard.center = CGPointMake(1024+rightCard.frame.size.width/2,384);
		}

	}

	rightCard.tag = 102;
	[self.view addSubview:rightCard];
	[rightCard release];
	
	
}

-(NSDictionary*)createContent:(NSInteger)index
{
	if (!cardsArray || [cardsArray count]<=index || index<0 || !category) {
		return nil;
	}
	
	NSArray *card = [cardsArray objectAtIndex:index];
	NSInteger cardId = [[card objectAtIndex:0] intValue];
	NSString *question = [card objectAtIndex:1];
	NSString *answer = [card objectAtIndex:2];
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
	{
		[dic setObject:answer forKey:@"answer"];
		
	}
	
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
	
	return dic;
	
}

-(void)compleateDragging
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	leftCard = (FICardView*)[self.view viewWithTag:100];
	rightCard = (FICardView*)[self.view viewWithTag:102];

	CGFloat min1;
	CGFloat min2;
	CGFloat min3;
	NSInteger which;
	
	if([Util isPhone])
	{
		min1 = [self calculateDis:centerCard.center forSec:CGPointMake(0,160)];
		min2 = [self calculateDis:centerCard.center forSec:CGPointMake(((IS_IPHONE_5)?284:240),160)];
		min3 = [self calculateDis:centerCard.center forSec:CGPointMake(((IS_IPHONE_5)?568:480),160)];
	}else {
		if ([Util isPortrait:(UIViewController*)delegate]) {
			min1 = [self calculateDis:centerCard.center forSec:CGPointMake(0,512)];
			min2 = [self calculateDis:centerCard.center forSec:CGPointMake(384,512)];
			min3 = [self calculateDis:centerCard.center forSec:CGPointMake(768,512)];
		}else {
			min1 = [self calculateDis:centerCard.center forSec:CGPointMake(0,384)];
			min2 = [self calculateDis:centerCard.center forSec:CGPointMake(512,384)];
			min3 = [self calculateDis:centerCard.center forSec:CGPointMake(1024,384)];
		}


	}

	
	if (min1<=min2 && min1<=min3) {
		which = 0;
	}
	else {
		if (min2<=min1 && min2<=min3) {
			which = 1;
		}
		else {
			if (min3<=min2 && min3<=min1) {
				which = 2;
			}
		}

	}
	
	if (which == 0 && isLast) {
		which = 1;
	}else {
		if (which == 2 && isFirst) {
			which = 1;
		}
	}

	
	
	NSInteger all = [cardsArray count];
	
	switch (which) {
		case 0:
		{
			leftCard.tag = 102;
			centerCard.tag = 100;
			rightCard.tag = 101;
			currentId = (currentId+1)%all;
			break;
		}
		case 2:
		{
			leftCard.tag = 101;
			centerCard.tag = 102;
			rightCard.tag = 100;
			currentId = (currentId-1+all)%all;
			break;
		}
		default:
			break;
	}
	
	if (currentId == 0) {
		isFirst = YES;
	}
	else {
		isFirst = NO;
	}

	
	if (currentId == all-1) {
		isLast = YES;
	}
	else {
		isLast = NO;
	}

	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	
	
	switch (which) {
		case 0:
		{
			if ([Util isPhone]) {
				leftCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+kCardViewWidth/2,160);
				centerCard.center = CGPointMake(-kCardViewWidth/2,160);
				rightCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
			}else {
				if ([Util isPortrait:(UIViewController*)delegate]) {
					leftCard.center = CGPointMake(768+leftCard.frame.size.width/2,512);
					centerCard.center = CGPointMake(-centerCard.frame.size.width/2,512);
					rightCard.center = CGPointMake(384,512);
				}else {
					leftCard.center = CGPointMake(1024+leftCard.frame.size.width/2,384);
					centerCard.center = CGPointMake(-centerCard.frame.size.width/2,384);
					rightCard.center = CGPointMake(512,384);
				}

			}

			break;
		}
		case 1:
		{
			if ([Util isPhone]) {
				leftCard.center = CGPointMake(-kCardViewWidth/2,160);
				centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
				rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+kCardViewWidth/2,160);
			}else {
				if ([Util isPortrait:(UIViewController*)delegate]) {
					leftCard.center = CGPointMake(-leftCard.frame.size.width/2,512);
					centerCard.center = CGPointMake(384,512);
					rightCard.center = CGPointMake(768+rightCard.frame.size.width/2,512);
				}else {
					leftCard.center = CGPointMake(-leftCard.frame.size.width/2,384);
					centerCard.center = CGPointMake(512,384);
					rightCard.center = CGPointMake(1024+rightCard.frame.size.width/2,384);
				}

			}

			
			
			[leftCard hideShadow];
			[rightCard hideShadow];
			break;
		}
		case 2:
		{
			if ([Util isPhone]) {
				leftCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
				centerCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+centerCard.frame.size.width/2,160);
				rightCard.center = CGPointMake(-rightCard.frame.size.width/2,160);
			}else {
				if ([Util isPortrait:(UIViewController*)delegate]) {
					leftCard.center = CGPointMake(384,512);
					centerCard.center = CGPointMake(768+centerCard.frame.size.width/2,512);
					rightCard.center = CGPointMake(-rightCard.frame.size.width/2,512);
				}else {
					leftCard.center = CGPointMake(512,384);
					centerCard.center = CGPointMake(1024+centerCard.frame.size.width/2,384);
					rightCard.center = CGPointMake(-rightCard.frame.size.width/2,384);
				}

			}

			break;
		}
		default:
			break;
	}
	
	if (which!=1) {
		SEL	 stopSel = @selector(animationDidStop:finished:context:);
		[UIView setAnimationDidStopSelector:stopSel];
	}
	

	[UIView commitAnimations];
	
	
	
}

/*-(void)updateCardd:(NSString*)tags
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSInteger tag = [tags intValue];
	FICardView *card = (FICardView*)[self.view viewWithTag:tag];
	NSInteger curId = 101-tag;
	NSInteger all = [cardsArray count];
	curId = (currentId-curId+all)%all;
	NSDictionary *dic = [self createContent:curId];
	[card changeContent:dic];
	for (int i=0;i<100;i++) {
		NSLog(@"%d",i);
	}
	[pool release];
}*/

-(void)removeCardWithCurrentId
{
	animaId = -200;
	
	centerCard = (FICardView*)[self.view viewWithTag:101];
	
	if (delegate && [delegate respondsToSelector:@selector(removeCardWithId:)]) {
		NSArray *card = [cardsArray objectAtIndex:currentId];
		NSInteger cardId = [[card objectAtIndex:0] intValue];
		[delegate removeCardWithId:cardId];
	}
	
	[cardsArray removeObjectAtIndex:currentId];
	
	if (cardsArray && [cardsArray count]>0) {
		currentId = currentId%[cardsArray count];
		if (currentId>=[cardsArray count]-1) {
			isLast = YES;
		}else {
			isLast = NO;
		}

		
		if (currentId==0 ) {
			isFirst = YES;
		}else {
			isFirst = NO;
		}

	}
	
	if (delegate && [delegate respondsToSelector:@selector(catchRemovedCard)]) {
		[delegate catchRemovedCard];
	}
	
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
	if ([cardsArray count]<=0) {
		currentId = 0;
		if ([Util isPhone]) {
			[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(((IS_IPHONE_5)?284:240),288) withView:centerCard];
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(384,939) withView:centerCard];	
			}else {
				[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(512,684) withView:centerCard];	
			}

		}

		if (delegate && [delegate respondsToSelector:@selector(editing:)]) {
			[delegate editing:NO];
		}
		if (delegate && [delegate respondsToSelector:@selector(deleteCard:)]) {
			[delegate deleteCard:NO];
		}
		
	}else {
		[self updateCard:100];
		[self updateCard:102];
		
		if ([Util isPhone]) {
			[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(((IS_IPHONE_5)?284:240),288) withView:centerCard];
		}else {
			if ([Util isPortrait:(UIViewController*)delegate]) {
				[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(384,939) withView:centerCard];	
			}else {
				[[FIAnimationController sharedAnimation:self] leakToPoint:CGPointMake(512,684) withView:centerCard];	
			}
			
		}	
	}
	
	
}

-(void)updateCard:(NSInteger)tag
{
	/*FICardView *card = (FICardView*)[self.view viewWithTag:tag];
	NSInteger curId = 101-tag;
	NSInteger all = [cardsArray count];
	curId = (currentId-curId+all)%all;
	
	if (ignoredCards && [ignoredCards containsObject:[NSNumber numberWithInt:[[[cardsArray objectAtIndex:curId] objectAtIndex:0]intValue]]]) {
		[card check:YES];
	}else {
		[card check:NO];
	}
	
	NSDictionary *dic = [self createContent:curId];*/
	//[card changeContent:dic];
	//[card hideShadow];
	//[card performSelectorOnMainThread:@selector(hideShadow) withObject:nil waitUntilDone:NO];
	FICardView *card = (FICardView*)[self.view viewWithTag:tag];
	self.view.userInteractionEnabled = NO;
	[self updateCardWithView:card];
}

-(void)updateCenterCard
{
	[self updateCard:101];
}

-(void)updateCardWithView:(FICardView*)cardView
{
	NSInteger tag = cardView.tag;
	NSInteger curId = 101-tag;
	NSInteger all = [cardsArray count];
	curId = (currentId-curId+all)%all;
	
	if (ignoredCards && [ignoredCards containsObject:[NSNumber numberWithInt:[[[cardsArray objectAtIndex:curId] objectAtIndex:0]intValue]]]) {
		[cardView check:YES];
	}else {
		[cardView check:NO];
	}
	
	NSDictionary *dic = [self createContent:curId];
	[cardView changeContent:dic];
	[cardView hideShadow];
	self.view.userInteractionEnabled = YES;
}


-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP
{
	return sqrt((fP.x-sP.x)*(fP.x-sP.x)+(fP.y-sP.y)*(fP.y-sP.y));
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

-(void)savePreferences
{
	if (category) {
		NSArray *prefArray = [NSArray arrayWithObjects:[NSNumber numberWithBool:isBothSide],[NSNumber numberWithBool:isReversed],nil];
		[[NSUserDefaults standardUserDefaults] setObject:prefArray forKey:[NSString stringWithFormat:@"%@_Setings",category]];
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
			cSize = [[currentSettings objectAtIndex:1] intValue];
			return;
		}
	}
	
	currentFont = [[NSString alloc] initWithString:@"Helvetica"];
	
	if ([Util isPhone]) {
		cSize = 21;
	}else {
		cSize = 30;
	}

}

-(void)hideCenterCard
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	centerCard.hidden = YES;
}

-(void)seeCenterCard
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	centerCard.hidden = NO;
	[centerCard seeShadow];
}

-(void)restoreCenterCard
{
	centerCard = (FICardView*)[self.view viewWithTag:101];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	centerCard.transform = CGAffineTransformIdentity;
	[centerCard seeShadow];
	
	[UIView commitAnimations];
}

-(FICardView*)aboveCard:(NSDictionary*)dic
{
	leftCard = (FICardView*)[self.view viewWithTag:100];
	leftCard.hidden = NO;
	if (dic) {
		NSInteger cardId = [[dic objectForKey:@"id"] intValue];
		NSArray *card = [cardsArray objectAtIndex:currentId];
		NSInteger currCardId = [[card objectAtIndex:0] intValue];
		
		
		if (cardId != currCardId) {
			NSDictionary *newDic = [self traslateDictionary:dic];
			[leftCard changeContent:newDic];
			return leftCard;
		}
		
	}
	
	return nil;
}

-(NSDictionary*)traslateDictionary:(NSDictionary*)dic
{
	if (!dic) {
		return nil;
	}
	
	NSNumber *cardN = [dic objectForKey:@"id"];
	
	NSString *question = nil;
	NSString *answer = nil;
	UIImage *qImage = nil;
	UIImage *aImage = nil;
	NSData *qSound = nil;
	NSData *aSound = nil;
	
	if (cardN) {
		NSInteger cardId = [cardN intValue];
		question = [dic objectForKey:@"q"];
		answer = [dic objectForKey:@"a"];
		
		if (category) {
			qImage = [Util imageWithId:category forId:cardId forWhat:YES];
			aImage = [Util imageWithId:category forId:cardId forWhat:NO];
			qSound = [Util getSoundForCard:category forId:cardId forWhat:YES];
			aSound = [Util getSoundForCard:category forId:cardId forWhat:NO];
		}
	}
	
	NSNumber* cardNumber = [dic objectForKey:@"cardNumber"];
	NSNumber *allCard = [dic objectForKey:@"cardsCount"];
	
	
	NSMutableDictionary *newdic = [NSMutableDictionary dictionary];
	
	if(question)
		[newdic setObject:question forKey:@"question"];
	
	if (answer) 
	{
		[newdic setObject:answer forKey:@"answer"];
		
	}
	
	if (qImage) {
		[newdic setObject:qImage forKey:@"qImage"];
	}
	
	if (aImage) {
		[newdic setObject:aImage forKey:@"aImage"];
	}
	
	if (qSound) {
		[newdic setObject:qSound forKey:@"qSound"];
	}
	
	if (aSound) {
		[newdic setObject:aSound forKey:@"aSound"];
	}
	
	[newdic setObject:cardNumber forKey:@"number"];
	[newdic setObject:allCard forKey:@"allNumber"];
	
	return newdic;
}

-(void)seeCenterCardShadow
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationOptionCurveEaseInOut];
	[UIView setAnimationDuration:0.25];
	
	[centerCard seeShadow];
	
	[UIView commitAnimations];
}

-(void)makeSoundCardTurn
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
		AudioServicesPlaySystemSound(playerCardTurn);
	}
    
}

#pragma mark -

#pragma mark -
#pragma mark Notifications

-(void)importCardNotification:(NSNotification*)sender{
	NSArray *card = (NSArray*)sender.object;
	[self addCard:card];
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
	[cardsArray release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"importTerm" object:nil];
	
	if (ignoredCards) {
		[ignoredCards release];
	}
	
	if (bgFullScreenView) {
		[bgFullScreenView release];
	}
	
	if (category) {
		[category release];
	}
	
	if (currentFont) {
		[currentFont release];
	}
	
	[super dealloc];
}


@end
