//
//  FIAboutController.h
//  flashCards
//
//  Created by Ruslan on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FIAboutController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,UIWebViewDelegate> {
	UITableView *aboutTableView;
	UIWebView *webView;
}

@end
