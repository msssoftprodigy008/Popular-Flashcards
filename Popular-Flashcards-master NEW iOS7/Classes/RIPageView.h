//
//  RIPageView.h
//  flashCards
//
//  Created by Ruslan on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIRoundedButton.h"

@class RIPageView;

@protocol RIPageViewDelegate<NSObject>

-(void)viewDidSelected:(RIPageView*)page;

@end


@interface RIPageView : UIView {
	FIRoundedButton *r_pageview;
	UILabel *r_titleLabel;
	id<RIPageViewDelegate> r_delegate;
}

@property(nonatomic,readonly)FIRoundedButton *r_pageview;
@property(nonatomic,readonly)UILabel *r_titleLabel;
@property(nonatomic,assign)id<RIPageViewDelegate> r_delegate;

@end
