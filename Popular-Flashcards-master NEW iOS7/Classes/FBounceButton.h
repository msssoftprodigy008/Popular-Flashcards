//
//  FBounceButton.h
//  flashCards
//
//  Created by Ruslan on 7/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FBounceButtonDelegate

-(void)animationFinished:(id)sender;

@end


@interface FBounceButton : UIButton {
	NSInteger bounceNum;
	CGFloat oneBounceTime;
	NSInteger count;
	NSTimer *bounceTimer;
	id delegate;
}

@property(nonatomic,readwrite)NSInteger bounceNum;
@property(nonatomic,readwrite)CGFloat oneBounceTime;
@property(nonatomic,assign)id delegate;

-(void)startBounceAnimation;
-(void)stopAnimation;



@end
