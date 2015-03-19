//
//  FIWebViewController.h
//  flashCards
//
//  Created by Ruslan on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"

@interface FIWebViewController : UIViewController<UIWebViewDelegate> {
	UIWebView *webView;
	BOOL isHTML;
	NSString *path;
	NSString *titleStr;
}

@property(nonatomic,readwrite)BOOL isHTML;
@property(nonatomic,copy)NSString* path;
@property(nonatomic,copy)NSString* titleStr; 

@end
