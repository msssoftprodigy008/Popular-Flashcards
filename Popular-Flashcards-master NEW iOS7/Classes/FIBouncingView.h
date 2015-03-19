//
//  FIBouncingView.h
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FIBouncingViewDelegate

-(void)stateChanged:(BOOL)newState;

@end


@interface FIBouncingView : UIImageView {
	UIImage* activeImage;
	UIImage* notActiveImage;
	BOOL state;
	id delegate;
}

@property(nonatomic,readwrite)BOOL state;

-(id)initWithImages:(CGRect)frame  forActive:(UIImage*)active forNoneActive:(UIImage*)noneActive forDelegate:(id)Adelegate;
-(void)changeImages:(UIImage*) active forNoneActive:(UIImage*)noneActive;
-(void)changeState:(BOOL)newState;

@end
