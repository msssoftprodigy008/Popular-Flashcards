//
//  flashCardsAppDelegate.h
//  flashCards
//
//  Created by Руслан Руслан on 1/8/10.
//  Copyright МГУ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FISplashController.h"
#import "RIImportSetController.h"


@class RIMainViewCotroller;

@interface flashCardsAppDelegate : NSObject <UIApplicationDelegate,FISplashControllerDelegate,RIImportSetControllerDelegate> {
	
    UIWindow *window;
	//Ipad/Iphone controllers
  	RIImportSetController *r_loadingController;
	RIMainViewCotroller *rootForIphone;
	UINavigationController *iphoneRootNavigation;
    NSMutableData *currData;
    NSThread *badgeThread;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

