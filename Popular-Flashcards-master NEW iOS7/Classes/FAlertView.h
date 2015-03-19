//
//  FAlertView.h
//  flashCards
//
//  Created by Руслан Руслан on 4/1/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Util.h"
#import "Constants.h"

@protocol FAlertViewDelegate

-(void)quitButtonPressed;
-(void)continueButtonPressed;

@end


@interface FAlertView : UIImageView {
	id delegate;
	NSString *category;
	FAlert alertMode;
	
	UILabel *plannedLabel;
	UILabel *viewLabel;
	
	UIImageView *shader;
	UIImageView *alertView;
	UIImageView *succesView;
	UIImageView *failedView;
	
	UIImageView *shadowForSuccess;
	UIImageView *shadowForFailed;
	
	UILabel *succesLabel;
	UILabel *failedLabel;
	
	UILabel *titleLabel;
	
	UILabel *timeLabel;
	
	NSInteger succesVal;
	NSInteger failedVal;
	NSInteger doubtVal;
	NSInteger plannedCards;

    SystemSoundID playerCalc;
	
	NSTimer* succesTimer;
	NSTimer* doubtTimer;
	NSTimer* failedTimer;
    
}

-(id)initWithFrame:(CGRect)frame forCategory:(NSString*)Acategory forMode:(FAlert)mode forDelegate:(id)Adelegate;
-(void)setValues:(NSArray*)values forTime:(NSString*)Atime;
-(void)show:(UIView*)inView;
-(void)dissmissWithoutResponse;
-(void)rotateToPortrait:(BOOL)isPort;

@end
