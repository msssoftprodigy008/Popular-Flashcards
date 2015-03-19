//
//  FAlertViewPort.h
//  flashCards
//
//  Created by Ruslan on 4/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"
#import "Constants.h"

@protocol FAlertViewPortDelegate

-(void)quitButtonPressed;
-(void)continueButtonPressed;

@end

@interface FAlertViewPort : UIImageView {
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
	
	
	NSTimer* succesTimer;
	NSTimer* doubtTimer;
	NSTimer* failedTimer;
}

-(id)initWithFrame:(CGRect)frame forCategory:(NSString*)Acategory forMode:(FAlert)mode forDelegate:(id)Adelegate;
-(void)setValues:(NSArray*)values forTime:(NSString*)Atime;
-(void)show:(UIView*)inView;
-(void)dissmissWithoutResponse;

@end
