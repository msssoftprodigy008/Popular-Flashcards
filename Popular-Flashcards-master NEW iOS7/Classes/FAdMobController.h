//
//  FAdMobController.h
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flurry.h"
#import "GADInterstitial.h"
#import "GADInterstitialDelegate.h"
#import <iAd/iAd.h>


@class FAdMobController;

@protocol FAdMobControllerDelegate<NSObject>
@optional
-(void)advRecieveFailed:(FAdMobController*)sender;
-(void)advRecieveSuccess:(FAdMobController*)sender;


@end


@interface FAdMobController : UIViewController<GADInterstitialDelegate,ADInterstitialAdDelegate> {
    GADInterstitial *fullscreen;
    ADInterstitialAd *iAdFullscreen;
    NSInteger _advType;
    UIPopoverController *r_popoverContoller;

    
}



+(id)sharedAdMobController;
+(id)sharedAdMobController:(id<FAdMobControllerDelegate>)d;
-(void)requestForFullScreen:(NSInteger)advType;
-(void)loadAdMob:(NSInteger)type;
-(BOOL)isCompatibleWithIAd;
-(void)clearFullscreen;
-(void)clearAdvertisement;
-(void)startFlurySession;
-(void)setFlurryVersion:(NSString*)version;
-(void)logFlurryEnvent:(NSString*)event withParam:(NSDictionary*)param;


@end