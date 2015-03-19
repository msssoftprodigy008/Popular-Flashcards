//
//  FBoxSceneController.h
//  flashCards
//
//  Created by Ruslan on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardView.h"
#import "FILearningController.h"
#import "FRootConstants.h"
#import <AudioToolbox/AudioToolbox.h>
#import "FAlertView.h"
#import "Constants.h"

@protocol FBoxSceneControllerDelegate <NSObject>

-(void)learningWillEnd:(NSString*)categoryId animated:(BOOL)isAnimate;
-(void)rotated:(UIInterfaceOrientation)orientation;
@end


@interface FBoxSceneController : UIViewController<FAlertViewDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate> {
	FICardView *mainCard;
	FICardView *nextCard;
	FAlertView* alert;
	
	UILabel *totalLabel;
	
	UIImageView *leftBox;
	UIImageView *rightBox;
	UIImageView *bottomBox;
	
	UIButton *unButton;
	UIButton *knButton;
	UIButton *botButton;
	
	UILabel *dontLabel;
	UILabel *knowLabel;
	UILabel *notSureLabel;
	
	UIImage *imageForBot;
	UIImage *imageForBot2;
	
	NSInteger numInLeft;
	NSInteger numInRight;
	NSInteger numInBottom;
	NSInteger numInCenter;
	
	UIImageView *topBar;
	UIImageView *bottomBar;
	UIButton *pauseButton;
	UIImageView *r_bgPortView;
    UIImageView *r_bgLandView;
	NSMutableArray *cardsArray;
	NSInteger currentId;
	
	NSString *category;
	
	FILearningController *learningController;
	FILearningProccesType learningType;
	UIImageView *r_slideView;
    UILabel *r_slideLabel;
	
	NSMutableDictionary *coordinate;
	
	UITapGestureRecognizer *tapRecog;
	UILongPressGestureRecognizer *longPressRecog;
	UIView *touchView;
	
	NSString *currentFont;
	NSInteger currentSize;
	
	NSInteger currentAnimation;
	CGPoint outPoint;
	
	FCard currentBox;
	
	id<FBoxSceneControllerDelegate> delegate;
	
    SystemSoundID playerInBox;
	SystemSoundID playerOutBox;
	SystemSoundID playerCardFalls;
	SystemSoundID playerCardTurn;
    
    BOOL isBothSide;
	BOOL isReversed;
	BOOL isResized;
	BOOL isSoundOn;
	BOOL isInfoChecked;
	BOOL isPaused;
	
	BOOL isLeftBoxExist;
	BOOL isRightBoxExist;
	BOOL isBottomBoxExist;
	
	BOOL isBoxInBlock;
	BOOL isBoxOutBlock;
	BOOL isFallBlock;
	BOOL isTurnBlock;
    BOOL isPauseVisible;
	
	BOOL isDeckEnded;
    BOOL isUsingPref;
    BOOL isShouldChangeCard;
}



-(id)initWithCards:(NSArray*)cards forCategory:(NSString*)prCategory forMode:(FILearningProccesType)mode forDelegate:(id<FBoxSceneControllerDelegate>)prDelegate;
-(void)pauseTest;
@end
