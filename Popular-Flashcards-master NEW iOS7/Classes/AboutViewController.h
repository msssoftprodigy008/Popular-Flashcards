//
//  AboutViewController.h
//  ArtPuzzles
//
//  Created by Developer on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FINewsletter_SignupViewController.h"
#import "UIView.h"

typedef	enum{
	aboutStateWebView,
	aboutStateNewsletter
}aboutState;

@class AboutViewController;

@protocol IPadAboutControllerDelegate<NSObject>

-(void)aboutClosed:(AboutViewController*)about;

@end


@interface AboutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate,
MFMailComposeViewControllerDelegate,FINewsletterDelegate> {
	UITableView* aboutTableView;
	UIWebView* aboutWebView;
	FINewsletter_SignupViewController *newsletterController;
	aboutState state;
	
	id<IPadAboutControllerDelegate> delegate;
}

@property(nonatomic,assign)id<IPadAboutControllerDelegate> delegate;

@end
