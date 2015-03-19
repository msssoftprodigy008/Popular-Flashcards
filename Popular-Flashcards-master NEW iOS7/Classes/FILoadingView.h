//
//  FILoadingView.h
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FILoadingView : UIImageView {
	UIActivityIndicatorView *indicator;
	UILabel *messageLabel;
}

@property(nonatomic,readonly,retain)UIActivityIndicatorView *indicator;
@property(nonatomic,readonly,retain)UILabel* messageLabel;

-(void)showInView:(UIView*)view;
-(void)dismiss;


@end
