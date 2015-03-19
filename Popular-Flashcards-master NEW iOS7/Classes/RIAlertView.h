//
//  RIAlertView.h
//  flashCards
//
//  Created by Ruslan on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIAlertViewDefines.h"

@class RIAlertView;

@protocol RIAlertViewDelegate<NSObject>

-(void)clickedButtonAtIndex:(RIAlertView*)alertView buttonIndex:(NSInteger)index;

@end

@interface RIAlertView : UIView{
    NSString *_title;
    NSString *_message;
    NSArray *_buttonTitles;
    id<RIAlertViewDelegate> delegate;
}

@property(nonatomic,assign)id<RIAlertViewDelegate> delegate;

-(id)initWithTitle:(NSString*)title
           message:(NSString*)message 
      buttonTitles:(NSArray*)buttonTitles;

-(void)showInView:(UIView*)viewToShow;

@end
