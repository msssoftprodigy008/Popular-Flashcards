//
//  RILoadingView.h
//  CostApp
//
//  Created by Ruslan on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RILoadingView : UIView{
    UIImageView *_rotateView;
    UILabel *_progressLabel;
    UILabel *_textLabel;
    CGFloat _len;
    CGFloat _curVal;
    NSTimer *_rotateTimer;
    CGFloat _step;
    CGFloat _curAngle;
    id delegate;
    BOOL visible;
}

@property(nonatomic,assign)id delegate;
@property(nonatomic,readonly)BOOL visible;

-(void)setLen:(CGFloat)len;
-(void)setCurValue:(CGFloat)curVal;
-(void)setText:(NSString*)text;
-(void)reset;
-(void)start;
-(void)stop;

@end
