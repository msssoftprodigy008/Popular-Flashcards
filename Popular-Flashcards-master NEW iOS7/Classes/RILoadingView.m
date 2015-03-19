//
//  RILoadingView.m
//  CostApp
//
//  Created by Ruslan on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RILoadingView.h"
#import "Util.h"

@interface RILoadingView(Private)

#pragma mark private
-(void)startRotation;
-(void)updateRotation;
-(void)stopRotation;

@end

@implementation RILoadingView
@synthesize delegate;
@synthesize visible;

#pragma mark -
#pragma mark main

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5f];
        
        if ([Util isPhone]) {
            _rotateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sync_ani.png"]];
        }else{
            _rotateView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sync_ani_p.png"]];
        }
        _rotateView.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        [self addSubview:_rotateView];
        [_rotateView release];
        
        if ([Util isPhone]) {
            _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        }else{
            _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 60)];
        }
        _progressLabel.backgroundColor = [UIColor clearColor];
        _progressLabel.center = CGPointMake(frame.size.width/2.0, frame.size.height/2.0);
        if ([Util isPhone]) {
            _progressLabel.font = [UIFont boldSystemFontOfSize:18];  
        }else{
            _progressLabel.font = [UIFont boldSystemFontOfSize:24];  
        }
        
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        _progressLabel.textAlignment = UITextAlignmentCenter;
        _progressLabel.textColor = [UIColor whiteColor];
        [self addSubview:_progressLabel];
        [_progressLabel release];
        
        if ([Util isPhone]) {
            _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _rotateView.frame.origin.y+_rotateView.frame.size.height+10, frame.size.width, 30)];
        }else{
            _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _rotateView.frame.origin.y+_rotateView.frame.size.height+40, frame.size.width, 30)];
        }
        if ([Util isPhone]) {
            _textLabel.font = [UIFont boldSystemFontOfSize:18];  
        }else{
            _textLabel.font = [UIFont boldSystemFontOfSize:24];  
        }
        _textLabel.adjustsFontSizeToFitWidth = YES;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_textLabel];
        [_textLabel release];
        
        visible = NO;
    }
    return self;
}

-(void)reset{
    _rotateView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    _progressLabel.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    if ([Util isPhone]) {
       _textLabel.center = CGPointMake(_rotateView.center.x, _rotateView.frame.origin.y+_rotateView.frame.size.height+10+_textLabel.frame.size.height/2.0);     
    }else{
        _textLabel.center = CGPointMake(_rotateView.center.x, _rotateView.frame.origin.y+_rotateView.frame.size.height+40+_textLabel.frame.size.height/2.0);
    }
    
}

-(void)setLen:(CGFloat)len{
    _len = len;
    _curVal = 0.0;
    
    if (_len<1e-14) {
       _progressLabel.text = @"0%";
    }else{
        if (_curVal>=_len) {
          _progressLabel.text = @"100%";
        }else{
          _progressLabel.text = [NSString stringWithFormat:@"%d%%",(NSInteger)(100.0*_curVal/_len)];  
        } 
    }

}

-(void)setCurValue:(CGFloat)curVal{
    _curVal = curVal;
    if (_len<1e-14) {
        _progressLabel.text = @"0%";
    }else{
        if (_curVal>=_len) {
            _progressLabel.text = @"100%";
        }else{
            _progressLabel.text = [NSString stringWithFormat:@"%d%%",(NSInteger)(100.0*_curVal/_len)];  
        } 
    }
}

-(void)setText:(NSString*)text{
    if (_textLabel) {
        _textLabel.text = text;
    }
}

-(void)start{
    [self startRotation];
}


-(void)stop{
    visible = NO;
    [UIView beginAnimations:@"hide" context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationDelegate:self];
    
    self.alpha = 0.0;
    
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -

#pragma mark -
#pragma mark private
-(void)startRotation{
    [self stopRotation];
    _step = 5.0;
    _curAngle = 0.0;
    _rotateTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f
                                                    target:self
                                                  selector:@selector(updateRotation)
                                                  userInfo:nil
                                                   repeats:YES];
    
}

-(void)updateRotation{
    _curAngle+=_step;
    
    if (_curAngle>360) {
        _curAngle = 0;
    }
    
    [UIView beginAnimations:nil context:nil];
    
    _rotateView.transform = CGAffineTransformMakeRotation(M_PI*_curAngle/180.0);
     
    [UIView commitAnimations];
}

-(void)stopRotation{
    [_rotateTimer invalidate];
    _rotateTimer = nil;
    _rotateView.transform = CGAffineTransformIdentity;
}

#pragma mark -

#pragma mark -
#pragma mark animation delegate
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if(animationID && [animationID isEqualToString:@"hide"]){
        [self stopRotation];
        [self removeFromSuperview];
    }
    
    if (animationID && [animationID isEqualToString:@"show"]) {
        [self performSelector:@selector(startRotation)
                   withObject:nil
                   afterDelay:0.25f];
    }
}

@end
