    //
//  FAdMobController.m
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FAdMobController.h"
#import "Util.h"

FAdMobController *sharedAdMob = nil;
id<FAdMobControllerDelegate> adDelegate;
NSMutableDictionary *adMobDic = nil;
NSTimer *sharedTimer = nil;
UIView *banner = nil;

#define kRefreshTime 30.0f
#define kFlurryAPIID @"KZ1QMT4STC6I3UDDCJX7"


@implementation FAdMobController

+(id)sharedAdMobController
{
	if (!sharedAdMob) {
		sharedAdMob = [[FAdMobController alloc] init];
		adMobDic  = [[NSMutableDictionary alloc] init];
	}
	
	return sharedAdMob;
}

+(id)sharedAdMobController:(id<FAdMobControllerDelegate>)d{
	adDelegate = d;
	return [FAdMobController sharedAdMobController];
}

-(void)clearAdvertisement
{
	if (sharedTimer && [sharedTimer isValid]) {
		[sharedTimer invalidate];
		sharedTimer = nil;
	}
	
	if (sharedAdMob) {
		[sharedAdMob release];
		sharedAdMob = nil;
	}
	
	adDelegate = nil;
}

#pragma mark -
#pragma mark FlurryAPI

void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

-(void)setFlurryVersion:(NSString*)version
{
	[Flurry setAppVersion:version];
}

-(void)startFlurySession
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	[Flurry startSession:kFlurryAPIID];
}

-(void)logFlurryEnvent:(NSString*)event withParam:(NSDictionary*)param
{
	[Flurry logEvent:event withParameters:param];
}

#pragma mark -
#pragma mark fullscreen

-(BOOL)isCompatibleWithIAd{
    if (![Util isPhone] && [[UIDevice currentDevice].systemVersion doubleValue]>4.2) {
        return YES;
    }else{
        return NO;
    }
}

-(void)requestForFullScreen:(NSInteger)advType{
    _advType = advType;
    
    if ([self isCompatibleWithIAd]) {
        [self clearFullscreen];
        iAdFullscreen = [[ADInterstitialAd alloc] init];
        iAdFullscreen.delegate = self;
    }else{
        [self loadAdMob:_advType];    
    }
}

-(void)loadAdMob:(NSInteger)type{
    [self clearFullscreen];
    
    fullscreen = [[GADInterstitial alloc] init];
    
    if (type == 1) {
        fullscreen.adUnitID = @"a14e61276c36c14";
    }else{
        fullscreen.adUnitID = @"a14e6104f80d17a";    
    }
    
    fullscreen.delegate = self;
    [fullscreen loadRequest:[GADRequest request]];
}

-(void)clearFullscreen{
    
    if (iAdFullscreen) {
        [iAdFullscreen cancelAction];
        [iAdFullscreen release];
        iAdFullscreen = nil;
    }
    
    if (fullscreen) {
        [fullscreen release];
        fullscreen = nil;
    }
}


#pragma mark -

#pragma mark -
#pragma iAd delegate

- (void)interstitialAdWillLoad:(ADInterstitialAd *)interstitialAd{
    NSLog(@"iAd adv will load");
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd{
    
    if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
        [r_popoverContoller dismissPopoverAnimated:YES];
        [r_popoverContoller release];
        r_popoverContoller = nil;
    }else
    {
    
    NSLog(@"iAd adv did recieved!");
    [interstitialAd presentFromViewController:(UIViewController*)adDelegate];
    }
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd{
    NSLog(@"iAdv adv did unload");
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error{
    NSLog(@"iAd adv failed to recieve ad!");
    if (error) {
        NSLog(@"%@",error);
    }
    [self loadAdMob:_advType];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave{
    NSLog(@"User interected with ad");
    return YES;
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd{
    NSLog(@"User interection finished");
}

#pragma mark -

#pragma mark -
#pragma mark google ad

// Sent when an interstitial ad request succeeded.  Show it at the next
// transition point in your application such as when transitioning between view
// controllers.
-(void)interstitialDidReceiveAd:(GADInterstitial *)ad{
    NSLog(@"Did recieved ad");
    [ad presentFromRootViewController:(UIViewController*)adDelegate];
}

// Sent when an interstitial ad request completed without an interstitial to
// show.  This is common since interstitials are shown sparingly to users.
-(void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"Fail to recieve ad");
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

#pragma mark -

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
