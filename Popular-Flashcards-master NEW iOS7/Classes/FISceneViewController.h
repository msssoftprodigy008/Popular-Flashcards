//
//  FISceneViewController.h
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardsContainerController.h"
#import "FIRoundedButton.h"
#import "FIToolBar.h"
#import "myAdView.h"

@protocol FISceneViewControllerDelegate <NSObject>

-(void)stateChanged;
-(NSDictionary*)viewingDidEnd:(BOOL)isEmpty forCategory:(NSString*)categoryId;
-(void)sceneViewWasRotated:(UIInterfaceOrientation)orientation;

@end


@interface FISceneViewController : UIViewController<UISearchBarDelegate,FICardsContainerDelegate,UIGestureRecognizerDelegate,myAdViewDelegate> {
	FICardsContainerController *container;
	NSString *category;
	NSString *categoryName;
	NSInteger initedId;
	
	NSMutableSet *ignoredCards;
	NSMutableArray *cards;
	
	FIToolBar *topBar;
	FIToolBar* bottomBar;	
	UIPopoverController *r_popoverController;
	UIImageView *r_bgPortView;
    UIImageView *r_bgLandView;
	UIButton *quitButton;
	UIButton *trashButton;
	UIButton *addCardButton;
	UIButton *editButton;
	UIButton *deleteButton;
	UIButton *shuffleButton;
	UIButton *bothSideButton;
	UIButton *showButton;
	UIImageView *axilPanel;
	BOOL isAxilPanelHidden;
	UIBarButtonItem *bothSide;
	UIBarButtonItem *reverse;
	UIBarButtonItem *shuffle;
	
	UITapGestureRecognizer *tapRecog;
	
	UIBarButtonItem *deleteCardButton;
	UIBarButtonItem *editCardButton;
	UIBarButtonItem* addCardIPadButton;
	id<FISceneViewControllerDelegate> delegate;
	
    myAdView *adView;
    
	BOOL isFullVersion;
	BOOL r_isTopPanelExist;
	BOOL isStateChanged;
    BOOL withoutAnimation;
}

@property(nonatomic,copy)NSString* category; 
@property(nonatomic,copy)NSString* categoryName;
@property(nonatomic,readwrite)NSInteger initedId;
@property(nonatomic,readwrite)BOOL r_isTopPanelExist;
@property(nonatomic,assign)id<FISceneViewControllerDelegate> delegate;
@property(nonatomic,readwrite)BOOL withoutAnimation;

-(void)initByArray:(NSArray*)Acards;
-(void)initIgnoredCards:(NSMutableSet*)AignoredCards;
-(void)addCardWithText:(NSString*)term;

@end
