//
//  FITimerView.h
//  flashCards
//
//  Created by Ruslan on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRootConstants.h"


@interface FITimerView : UIImageView {
	NSTimer *clockTimer;
	UILabel *timerLabel;
	
	NSInteger hours;
	NSInteger minutes;
	NSInteger seconds;
}

-(id)initTimerWithTime:(CGRect)newFrame withTime:(NSString*)time withFont:(UIFont*)font;
-(void)clearTimer;
-(void)stopTimer;
-(void)startTimer;
-(NSString*)time;

@end
