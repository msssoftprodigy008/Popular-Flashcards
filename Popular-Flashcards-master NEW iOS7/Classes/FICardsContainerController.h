//
//  FICardsContainerController.h
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardView.h"
#import "FIAnimationController.h"
#import "FISketchedImageView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol FICardsContainerDelegate <NSObject>
@optional

-(void)editing:(BOOL)enable;
-(void)deleteCard:(BOOL)enable;
-(void)removeCardWithId:(NSInteger)cardId;
-(void)fullScreen:(BOOL)enabled;
-(void)catchRemovedCard;
-(void)cardsWantToQuit;

@end


@interface FICardsContainerController : UIViewController<UIScrollViewDelegate,FIAnimationControllerDelegate,
FICardViewDelegate,UIGestureRecognizerDelegate> {
	
	FICardView *centerCard;
	FICardView *leftCard;
	FICardView *rightCard;
	
	NSMutableArray *cardsArray;
	NSMutableArray *currentCards;
	NSString *category;
	
	id<FICardsContainerDelegate> delegate;
	
	//image grow needed begin
	FISketchedImageView *bgFullScreenView;
	CGPoint currentCenter;
	CGSize currentSize;
	//image grow needed end
	
	NSMutableSet *ignoredCards;
	
	NSInteger currentId;
	
	NSInteger animaId;
	
	UIPanGestureRecognizer *panRecog;
	UITapGestureRecognizer *tapRecog;
	
	NSString *currentFont;
	NSInteger cSize;
	
	BOOL isBothSide;
	BOOL isReversed;
	
	BOOL isLast;
	BOOL isFirst;
	
	BOOL isAllChecked;
    BOOL withoutAnimations;
    
    SystemSoundID playerCardTurn;
}

@property(nonatomic,copy)NSString* category;
@property(nonatomic,readwrite)NSInteger currentId;
@property(nonatomic,readonly)BOOL isBothSide;
@property(nonatomic,readonly)BOOL isReversed;
@property(nonatomic,assign)id<FICardsContainerDelegate> delegate;
@property(nonatomic,readwrite)BOOL withoutAnimations;

-(void)makeBothSide;
-(void)makeReversed;
-(void)makeShuffle;
-(void)saveCurrentSession;
-(void)setCurrentId:(NSInteger)c;
-(void)initCardsArray:(NSArray*)cards;
-(void)initIgnoredCards:(NSMutableSet*)AignoredCards;
-(void)stopSounds;
-(void)filterCardsByWord:(NSString*)word;
-(void)addCard:(NSArray*)card;
-(void)updateCurrentCard:(NSArray*)card;
-(NSArray*)currentCardId;
-(void)removeCurrentCard;
-(void)scaleCenterCard:(NSDictionary*)dic;
-(void)rotateView:(UIInterfaceOrientation)orientation;
-(void)hideCard:(FICardPosition)position hidden:(BOOL)hidden;
-(void)quit;

@end
