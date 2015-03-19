//
//  myAdView.m
//  easylearningapps_coredata
//
//  Created by Developer on 9/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "myAdView.h"

@interface myAdView(Private)

-(void)TryCustomBanner;
-(void)removeAd:(NSNotification*)notification;

@end

@implementation myAdView
@synthesize ViewController;
@synthesize _delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<myAdViewDelegate>) delegate{
    
    self = [super initWithFrame:frame];
    if (self) {
        self._delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAd:)
                                                     name:@"upgraded"
                                                   object:nil];
	}
    return self;
}

- (void)dealloc {
    self._delegate = nil;
    NSLog(@"%@",@"delegate nil");
	ViewController = nil;
	if (sharedTimer){
		[sharedTimer invalidate];
		sharedTimer = nil;	
	}
	
	if (adView){
		adView.delegate = nil;
		[adView removeFromSuperview];
		[adView release];
		adView = nil;
	}
	
	    
    if (gadView) {
        gadView.delegate = nil;
       [gadView removeFromSuperview];
       [gadView release];
        gadView = nil; 
    }

	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)showInView:(UIView*)view animated:(BOOL)animated{
    self.alpha = 0.0;
    [view addSubview:self];
    if (animated) {
        [UIView beginAnimations:@"show" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25];
    }
    self.alpha = 1.0;
    
    if (animated) {
        [UIView commitAnimations];
    }
}

-(void)hide:(BOOL)animated{
    if (animated) {
        [UIView beginAnimations:@"hide" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.25];
        
        self.alpha = 0.0;
        
        [UIView commitAnimations];
    }else{
        [self removeFromSuperview];
    }
}

-(void)clearAdv{
    if (sharedTimer){
		[sharedTimer invalidate];
		sharedTimer = nil;	
	}
	
	if (adView){
		adView.delegate = nil;
		[adView removeFromSuperview];
		[adView release];
		adView = nil;
	}
	
	if (gadView) {
        gadView.delegate = nil;
        [gadView removeFromSuperview];
        [gadView release];
        gadView = nil; 
    }
}

#pragma mark iAd
- (void)tryiAd:(NSString*)iAdType{
	adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
	adView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait,ADBannerContentSizeIdentifierLandscape,nil];
	adView.currentContentSizeIdentifier = iAdType;
	adView.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
	adView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
	adView.delegate = self;
	[self addSubview:adView];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    NSLog(@"%@",@"Did recieved iAd");
	if (_delegate && [_delegate respondsToSelector:@selector(iAdRecievedSuccessfully)]) {
        [_delegate iAdRecievedSuccessfully];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
	return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(iAdFailed)]) {
        [_delegate iAdFailed];
    }
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }else{
        NSLog(@"iAd Error");
    }
	if (adView){
		adView.delegate = nil;
		[adView removeFromSuperview];
		[adView release];
		adView = nil;
	}
    
    
}

#pragma mark -
#pragma mark GAD

- (void)tryGAD:(CGSize)gadSize{
    
    if (gadView) {
        return;
    }
    
    CGRect gadFrame = CGRectMake(0, 0, gadSize.width, gadSize.height);
    gadView = [[GADBannerView alloc] initWithFrame:gadFrame];
    gadView.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    gadView.rootViewController = ViewController;
    gadView.adUnitID = kGADKey1;
    gadView.delegate = self;
    // Place the ad view onto the screen.
    [self addSubview:gadView];
    
    // Request an ad without any additional targeting information.
    [gadView loadRequest:nil];
}

#pragma mark -
#pragma mark GAD delegate
- (void)adViewDidReceiveAd:(GADBannerView *)view{
    NSLog(@"%@",@"Did recieved GAD");
    if (_delegate && [_delegate respondsToSelector:@selector(gAdRecievedSuccessfully)]) {
        [_delegate gAdRecievedSuccessfully];
    }
}

- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(gAdFailed)]) {
        [_delegate gAdFailed];
    }
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }else{
        NSLog(@"%@",@"Did fail to recieve gad");
    }
    
    if (gadView) {
        [gadView removeFromSuperview];
        [gadView release];
        gadView = nil;
    }
}

#pragma mark -
#pragma mark UIView animation delegate

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    if (animationID && [animationID isEqualToString:@"hide"]) {
        [self removeFromSuperview];
    }
    
    if (animationID && [animationID isEqualToString:@"show"]) {
     
    }
}

#pragma mark -
#pragma mark notifications

-(void)removeAd:(NSNotification*)notification{
    [self hide:YES];
}

#pragma mark Custom Banner
- (void)TryCustomBanner{
	UIImageView *img =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	img.contentMode = UIViewContentModeCenter;
//	img.image = [CommonActions imageWithName:@"shelf/adImage.png" forAppWithID:-1];
	img.autoresizingMask = UIViewAutoresizingNone; // (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
	[self addSubview:img];
	[img release];	
}
@end
