//
//  FICardsDeckController.h
//  flashCards
//
//  Created by Ruslan on 7/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardView.h"
#import "FIAnimationController.h"
#import "FRootConstants.h"
#import "FIBoxControllerDefines.h"

@protocol FICardsDeckDelegate
@optional

-(void)draggingBeganAtPoint:(CGPoint)beganPoint;
-(void)cardMovedToPoint:(CGPoint)movedPointTo;
-(void)draggingEndedAtPoint:(CGPoint)endedPoint;
-(void)cardFallingWillBegin;
-(void)cardFallingDidEnd;
-(FILearningProccesType)learningType;
-(void)deckEnded;
-(void)cardIdChangedTo:(NSInteger)cardId;
-(void)cardTurned:(BOOL)isQuestion;

@end


@interface FICardsDeckController : UIViewController<FICardViewDelegate> {
	FICardView *mainCard;
	FICardView *nextCard;
	
	NSMutableArray *cardsArray;
	NSInteger currentId;
	
	NSString *category;
	
	BOOL isReversed;
	BOOL isBothSide;
	BOOL isResized;
	
	UITapGestureRecognizer *tapRecog;
	UILongPressGestureRecognizer *longPressRecog;
	
	id delegate;
	
	CGPoint currLoc;
	CGSize currScale;
	CGFloat currRotation;
	
	UILabel *centerLabel;
	NSInteger allCardsNumber;
	
	NSInteger currAnimation;
	NSString *currentFont;
	NSInteger currentSize;
	
    BOOL isSoundOn;
	BOOL isAwakedInfo;
	BOOL isUsingPref;
    BOOL isShouldChangeCard;
}

@property(nonatomic,assign)id delegate;
@property(nonatomic,readonly)NSInteger currentId;
@property(nonatomic,readwrite)BOOL isUsingPref;

-(id)initWithCardsArray:(NSArray*)cards forCategory:(NSString*)Acategory;
-(NSInteger)getCurrentId;
-(void)animateFallingAtCenter:(CGPoint)fallPoint;
-(void)goAway:(FIDirection)direction;
-(void)normalizeState;
-(NSInteger)allCards;
-(NSInteger)viewedCards;
-(void)handleNonDraggingFalling;
-(void)stopSounds;
-(void)restoreCenterCard:(FILearningProccesType)proccesType;

@end
