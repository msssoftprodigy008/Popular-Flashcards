//
//  RIAlertView.m
//  flashCards
//
//  Created by Ruslan on 8/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIAlertView.h"
#import "FIAnimationController.h"
#import <QuartzCore/QuartzCore.h>

@interface RIAlertView(Private)

-(void)activeButtonPressed:(id)sender;
-(void)animate;

@end

@implementation RIAlertView
@synthesize delegate;

#pragma mark -
#pragma mark main methods

-(id)initWithTitle:(NSString*)title
           message:(NSString*)message
      buttonTitles:(NSArray*)buttonTitles{
    
    if (title) {
        _title = [[NSString alloc] initWithString:title];
    }else{
        _title = [[NSString alloc] initWithString:@""];
    }
    
    if (message) {
        _message = [[NSString alloc] initWithString:message];
    }else{
        _message = [[NSString alloc] initWithString:@""];
    }
    
    if (buttonTitles) {
        _buttonTitles = [[NSArray alloc] initWithArray:buttonTitles];
    }
    
    return [self initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 320)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        // Initialization code
        CGSize mesSz = [_message sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]
                            constrainedToSize:CGSizeMake(kRIAlertViewWidth, 9999)
                                lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = 110+mesSz.height;
        if(_buttonTitles&&[_buttonTitles count]>0){
            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
            [button1 setBackgroundColor:kRIAlertViewButtonBgColor];
            [button1 setTitle:[_buttonTitles objectAtIndex:0] forState:UIControlStateNormal];
            [button1 addTarget:self
                        action:@selector(activeButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
            button1.layer.cornerRadius = 5.0;
            button1.tag = 100;
            
            if ([_buttonTitles count]>1) {
                UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
                [button2 setBackgroundColor:kRIAlertViewButtonBgColor];
                [button2 setTitle:[_buttonTitles objectAtIndex:1] forState:UIControlStateNormal];
                [button2 addTarget:self
                            action:@selector(activeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
                button2.tag = 101;
                button2.frame = CGRectMake(((IS_IPHONE_5)?284:240)+kRIAlertViewWidth/4.0-30.0, 160.0+height/2.0-40.0, 60.0, 30.0);
                button1.frame = CGRectMake(((IS_IPHONE_5)?284:240)-kRIAlertViewWidth/4.0-30.0, 160.0+height/2.0-40.0, 60.0, 30.0);
                [self addSubview:button2];
            }else{
                button1.frame = CGRectMake(((IS_IPHONE_5)?254:210), 160.0+height/2.0-40.0, 60.0,30.0);
            }
            [self addSubview:button1];
        }
    }
    return self;
}

-(void)showInView:(UIView*)viewToShow{
    
    self.center = CGPointMake(160,
                              ((IS_IPHONE_5)?284:240));
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeRotation(-M_PI/2);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.0f];
    
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    
    CGSize mesSz = [_message sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16]
                        constrainedToSize:CGSizeMake(kRIAlertViewWidth, 9999)
                            lineBreakMode:NSLineBreakByWordWrapping];
    CGSize titleSz = [_title sizeWithFont:[UIFont fontWithName:@"Helvetica" size:20]
                        constrainedToSize:CGSizeMake(kRIAlertViewWidth, 9999)
                            lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = 110+mesSz.height;
    CGRect alertRect = CGRectMake(((IS_IPHONE_5)?284:240)-kRIAlertViewWidth/2.0,
                                  160-height/2.0,
                                  kRIAlertViewWidth,
                                  height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:alertRect cornerRadius:10.0];
    [path setLineWidth:kRIAlertViewBorderWidth];
    UIColor *fillColor = kRIAlertViewBgColor;
    UIColor *strokeColor = kRIAlertViewBorderColor;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    
    [path fill];
    [path stroke];
    
    CGContextSetFillColorWithColor(context,strokeColor.CGColor);
    
    [_title drawAtPoint:CGPointMake(((IS_IPHONE_5)?284:240)-titleSz.width/2.0, 165.0-height/2.0)
               withFont:[UIFont fontWithName:@"Helvetica" size:20]];
    
    [_message drawInRect:CGRectMake(((IS_IPHONE_5)?294:250)-kRIAlertViewWidth/2.0, 205-height/2.0, kRIAlertViewWidth-20, mesSz.height)
                withFont:[UIFont fontWithName:@"Helvetica" size:16]
           lineBreakMode:NSLineBreakByWordWrapping
               alignment:NSTextAlignmentCenter];
    
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
    
    UIBezierPath *newPath = [UIBezierPath bezierPath];
    [newPath moveToPoint:CGPointMake(((IS_IPHONE_5)?284:240)-kRIAlertViewWidth/2.0, 190-height/2.0)];
    [newPath addCurveToPoint:CGPointMake(((IS_IPHONE_5)?284:240)+kRIAlertViewWidth/2.0, 190-height/2.0)
               controlPoint1:CGPointMake(((IS_IPHONE_5)?284:240)-kRIAlertViewWidth/4.0, 195-height/2.0)
               controlPoint2:CGPointMake(((IS_IPHONE_5)?284:240)+kRIAlertViewWidth/4.0, 195-height/2.0)];
    [newPath setLineWidth:1.0];
    [newPath stroke];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   
    return YES;
}

-(void)dealloc{
    [super dealloc];
    if (_title) {
        [_title release];
    }
    
    if (_message) {
        [_message release];
    }
    
    if (_buttonTitles) {
        [_buttonTitles release];
    }
}

#pragma mark -

#pragma mark -
#pragma mark targets

-(void)activeButtonPressed:(id)sender{
    [self performSelector:@selector(animate) withObject:nil afterDelay:0.0];
    
    UIButton *button = (UIButton*)sender;
    
    if (delegate && [delegate respondsToSelector:@selector(clickedButtonAtIndex:buttonIndex:)]) {
        [delegate clickedButtonAtIndex:self
                           buttonIndex:button.tag-100];
    }
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0f];
}

-(void)animate{
    
    if (self.alpha < 1e-14) {
        self.alpha = 1.0;
    }else{
        self.alpha = 0.0;
    }
    
    CATransition *animation = [CATransition animation];
    [animation setType:@"rippleEffect"];
    animation.duration = 0.75f;
    [self.layer addAnimation:animation forKey:@"fade"];
}

#pragma mark -



@end
