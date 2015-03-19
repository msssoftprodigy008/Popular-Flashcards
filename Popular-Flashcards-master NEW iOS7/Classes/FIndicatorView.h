//
//  FIndicatorView.h
//  flashCards
//
//  Created by Ruslan on 6/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDColoredProgressView.h"

@protocol FIndicatorViewDelegate

-(void)cancelButtonPressed;

@end


@interface FIndicatorView : UIView {
	UIView *downloadView;
	UIProgressView *progressView;
	UILabel *progressViewLabel;
	UIButton *cancelButton;
	CGFloat importLen;
	CGFloat currentLen;
	id delegate;
}

@property(nonatomic,retain) id delegate;
@property(nonatomic,readonly,retain)UIProgressView *progressView;
@property(nonatomic,readonly,retain)UILabel* progressViewLabel;
@property(nonatomic,readonly,retain)UIButton* cancelButton;

-(void)setDelegate:(id)Adelegate;
-(void)setImportLen:(NSInteger)Alen;
-(void)setCurVal:(NSInteger)currVal;
-(void)setBgColor:(UIColor*)bgColor;
//-(void)setFrame:(CGRect*)Aframe;
-(void)showInView:(UIView*)inView;
-(void)dissmis;

@end
