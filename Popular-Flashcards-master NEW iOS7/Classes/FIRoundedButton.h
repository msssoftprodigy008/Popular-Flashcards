//
//  FIRoundedButton.h
//  flashCards
//
//  Created by Ruslan on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>

@interface FIRoundedButton : UIView {
	UILabel *r_titleLabel;
	NSInteger r_innerRadius;
	NSInteger r_outerRadius;
	UIColor *r_outerColor;
	UIColor *r_innerColor;
	UIColor *r_houterColor;
	UIColor *r_hinnerColor;
	NSInteger r_distance;
	
	id r_target;
	SEL r_selector;
	
	BOOL r_isTouched;
	
}

@property(nonatomic,readonly,retain)UILabel *r_titleLabel;
@property(nonatomic,readwrite)NSInteger r_innerRadius;
@property(nonatomic,readwrite)NSInteger r_outerRadius;
@property(nonatomic,readwrite)NSInteger r_distance;
@property(nonatomic,retain)UIColor *r_outerColor;
@property(nonatomic,retain)UIColor *r_innnerColor;
@property(nonatomic,retain)UIColor *r_houterColor;
@property(nonatomic,retain)UIColor *r_hinnnerColor;
@property(nonatomic,readonly)BOOL r_isTouched;

-(void)addTarget:(id)target forAction:(SEL)selector;
@end
