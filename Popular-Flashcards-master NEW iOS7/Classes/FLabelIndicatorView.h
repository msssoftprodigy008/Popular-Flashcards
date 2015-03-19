//
//  FLabelIndicatorView.h
//  flashCards
//
//  Created by Ruslan on 3/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIndicatorView.h"

@interface FLabelIndicatorView : UIView {
	FIndicatorView *indicatorView;
	UILabel *messageLabel;
}

@property(nonatomic,readonly)FIndicatorView *indicatorView;
@property(nonatomic,readonly)UILabel *messageLabel;

@end
