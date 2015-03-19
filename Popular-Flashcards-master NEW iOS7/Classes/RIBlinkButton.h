//
//  RIBlinkButton.h
//  flashCards
//
//  Created by Ruslan on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIRoundedButton.h"

@interface RIBlinkButton : UIButton {
	float r_blinkAlpha;
	float r_blinkTime;
	NSTimer *r_blinkTimer;
	NSArray *r_images;
	BOOL r_isBlinking;
	NSInteger r_count;
}

@property(nonatomic,readwrite)float r_blinkAlpha;
@property(nonatomic,readwrite)float r_blinkTime;
@property(nonatomic,readonly)BOOL r_isBlinking;

-(void)setImages:(NSArray*)images;
-(void)startBlinking;
-(void)stopBlinking;

@end
