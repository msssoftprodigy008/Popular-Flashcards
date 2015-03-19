//
//  FIQuizletDetailController.h
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FImportSet.h"
#import "FIndicatorView.h"
#import "FAdMobController.h"
#import "FINavigationBar.h"
#import "FIToolBar.h"
#import "UIImage+Resize.h"
#import "SDWebImageDownloader.h"
#import "QIRequest.h"

@class FILoadingView;

@interface FIQuizletDetailController : UIViewController<UITableViewDelegate,UITableViewDataSource,FImportSetDelegate,
FIndicatorViewDelegate,SDWebImageDownloaderDelegate,QIRequestDelegate> {
	NSInteger categoryId;
	UITableView *setsDetailTable;
	NSMutableDictionary *thumbImages;
	NSMutableDictionary *downloaders;
	NSMutableArray *previewCards;
	NSDictionary *setInfoDictionary;
	
	FINavigationBar *topBar;
	FIToolBar *bottomBar;
	
	FImportSet *importSet;
	FILoadingView *loadingView;
	FIndicatorView *progressView;
	
	UIBarButtonItem *reverse;
	UIBarButtonItem *download;
	
	NSInteger total_images;
	NSInteger downloaded_images;
	
	NSString *category;
	
	BOOL isReversed;
	
}

@property(nonatomic,readwrite)NSInteger categoryId;
@property(nonatomic,copy)NSDictionary *setInfoDictionary;
@property(nonatomic,copy)NSMutableArray *previewCards;

@end
