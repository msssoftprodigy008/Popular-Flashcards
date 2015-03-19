//
//  FICardView.h
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardsConstants.h"
#import "FIBouncingView.h"
#import "FISketchedImageView.h"
#import <AVFoundation/AVFoundation.h>

@class DTAttributedTextView;

@protocol FICardViewDelegate

-(void)checkButtonChangedState:(FICheckboxState)checkedState;
-(void)imageNeedFullScreen:(CGPoint)imageCenter forSize:(CGSize)imageSize forSide:(BOOL)isFront;

@end

@interface FICardView : UIImageView<FIBouncingViewDelegate> {
	UITextView *cardTextView;
	FISketchedImageView *cardImageView;
	FIBouncingView *checkButton;
	AVAudioPlayer *audioPlayer;
	UIImageView *cardView;
	UIImageView *lineImageView;
	UILabel *cardNumberLabel;
	UILabel *slashNumerLabel;
	UILabel *allNumberLabel;
	UILabel *questionLabel;
	UIButton *soundButton;
	NSDictionary *cardContentDictionary;
	
	UIFont *currentFont;
		
	BOOL isQuestion;
	
	BOOL isBothSide;
	BOOL isReversed;

	BOOL isCheckBoxExist;
	
	id delegate;
}

@property(nonatomic,readwrite)BOOL isBothSide;
@property(nonatomic,readwrite)BOOL isReversed;
@property(nonatomic,readwrite)BOOL isCheckBoxExist;
@property(nonatomic,assign)id delegate;
@property(nonatomic,retain)UIFont *currentFont;
@property(nonatomic,readonly)UITextView *cardTextView;
@property(nonatomic,readonly)BOOL isQuestion;

-(id)initWithContent:(NSDictionary*)content forSide:(BOOL)isB forRev:(BOOL)isRev forCheckBox:(BOOL)isChEx;

-(void)changeContent:(NSDictionary*)newContent;
-(void)changeSide;
-(void)setSide:(BOOL)isQ;
-(void)reloadContent;
-(void)check:(BOOL)isChecked;
-(void)setShadowOffset:(CGPoint)offset;
-(void)setShadowColor:(UIColor*)shadowColor;
-(void)hideShadow;
-(void)seeShadow;
-(void)stopAudio;
-(void)updateCardTextView;
-(void)handleTapOnImage:(BOOL)handle;

@end
