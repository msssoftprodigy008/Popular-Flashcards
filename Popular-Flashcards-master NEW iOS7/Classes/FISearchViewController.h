//
//  FISearchViewController.h
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDownLoader.h"
#import "FIndicatorView.h"
#import "FIImageChooseViewController.h"
#import "FCustomSegmentedController.h"
#import "FRootConstants.h"
#import "FSettingsTemplate.h"
#import "FIToolBar.h"


@protocol FISearchViewControllerDelegate
@optional

-(void)someDataToSave:(NSDictionary*)dic;

@end


@interface FISearchViewController : UIViewController<UIWebViewDelegate,FDownloaderDelegate,FIImageChooseDelegate,
FIndicatorViewDelegate,FSettingsTemplateDelegate,UIApplicationDelegate,UIAlertViewDelegate,UIScrollViewDelegate> {
    NSString *set;
    UIWebView *webView;
	FIToolBar *mainMenu;
	FIToolBar *contextMenu;
	UIView *animationView;
    
   
	NSString *searchStr;
	
	NSMutableArray *allImages;
	NSMutableArray *titles;
	NSMutableArray *urls;
	
	UIMenuController *customMenu;
	UIBarButtonItem *saveImageButton;
	FIndicatorView *progressView;
	
	NSInteger currVal;
	
	BOOL isSearch;
	BOOL isMainPanel;
	BOOL isImageDownloadingAvailable;
	
	BOOL menuLockFlag;
	
	FIOrientation orientation;
	
	id MyDelegate;
	
}

@property(nonatomic,assign)id MyDelegate;
@property(nonatomic,readwrite)FIOrientation orientation;
@property(nonatomic,readwrite)BOOL isImageDownloadingAvailable;
@property(nonatomic,copy)NSString* set;

-(id)initWithDelegateAndSearchStr:(NSString*)SStr;
-(void)cancelDownload;

@end
