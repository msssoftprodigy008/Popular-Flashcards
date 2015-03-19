//
//  FIBoxSceneViewController.h
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardsDeckController.h"
#import "FRootConstants.h"
#import "FIImageUtilits.h"
#import "FITimerView.h"
#import "FILearningResultView.h"
#import "FILearningController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "RISlideInView.h"
#import "FIBoxControllerDefines.h"
#import "myAdView.h"
#import "RIAlertView.h"

@protocol FIBoxSceneViewControllerDelegate
@optional
-(void)learningResult:(FILearningProccesType)proccesType forResult:(NSDictionary*)result;
-(void)learningWillEnd:(NSString*)categoryId animated:(BOOL)isAnimate;

@end


@interface FIBoxSceneViewController : UIViewController<UIGestureRecognizerDelegate,AVAudioPlayerDelegate,FILearningResultDelegate,RIAlertViewDelegate,myAdViewDelegate> {
	UIImageView* leftBox;
	UIImageView* rightBox;
	UIImageView* bottomBox;
	
    UIImageView *leftBoxShadow;
	UIImageView *rightBoxShadow;
	UIImageView *bottomBoxShadow;
    
    UIImageView *leftCoverView;
    UIImageView *rightCoverView;
    UIImageView *bottomCoverView;
    
    UILabel *leftCountLabel;
	UILabel *rightCountLabel;
	UILabel *bottomCountLabel;
    
	BOOL isLeftBoxExist;
	BOOL isRightBoxExist;
	BOOL isBottomBoxExist;
	
	UIButton *leftButton;
	UIButton *rightButton;
	UIButton *bottomButton;
	UIButton *backButton;
	UIButton *soundButton;
	
    myAdView *adView;
    
    FILearningController *learnController;
	
	UIView *_learningBgView;
	FILearningResultView *learnView;
	
	FICardsDeckController *deck;
	NSString *category;
	
	UIImageView *r_slideView;
	UILabel *r_slideLabel;
	
	FILearningProccesType proccesType;
	FIActiveBox activeBox;
	FIActiveBox prevBox;
	
	id delegate;
	
	BOOL isFullVersion;
	BOOL isDeckEnded;
	
	SystemSoundID playerInBox;
	SystemSoundID playerOutBox;
	SystemSoundID playerCardFalls;
	SystemSoundID playerCardTurn;
	
    BOOL isButtonLocked;
    
	BOOL isBoxInBlock;
	BOOL isBoxOutBlock;
	BOOL isFallBlock;
	BOOL isTurnBlock;
	BOOL isPaused;
	
	BOOL isSoundOn;
}

@property(nonatomic,assign)id delegate;

-(id)createLearningProcces:(FILearningProccesType)type forCategory:(NSString*)Acategory;
-(void)pauseTest;

@end
