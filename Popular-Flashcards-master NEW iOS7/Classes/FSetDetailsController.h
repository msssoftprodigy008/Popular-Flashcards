//
//  FSetDetailsController.h
//  flashCards
//
//  Created by Ruslan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FImportSet.h"
#import "FIndicatorView.h"
#import "SDWebImageDownloader.h"
#import "FAdMobController.h"
#import "QIRequest.h"

@protocol FSetDetailsControllerDelegate

-(void)importFinished:(BOOL)result newCat:(NSString*)cat;

@end


@interface FSetDetailsController : UIViewController<UITableViewDelegate,UITableViewDataSource,SDWebImageDownloaderDelegate,QIRequestDelegate> {
	
	UITableView *infoTableView;
	
	NSMutableDictionary *thumbImages;
	NSMutableDictionary *downloaders;
	
	UIBarButtonItem *dowloadButton;
	UIBarButtonItem *reverseButton;

	id delegate;
	
	NSDictionary *currentDic;
	UIView *proccesView;
	UIActivityIndicatorView *indicator;
	
	FIndicatorView *progressView;
	
	FImportSet *importSet;
	NSMutableArray *previewCards;
	
	NSInteger total_images;
	NSInteger downloaded_images;
	NSString *category;
	
	
	BOOL isReversed;
}

-(void)setDelegate:(id)Adelegate;
-(void)setInformation:(NSDictionary*)info;

@end
