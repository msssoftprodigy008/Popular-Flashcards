//
//  FIExportViewController.h
//  flashCards
//
//  Created by Ruslan on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FAdMobController.h"
#import "FRootConstants.h"
#import "QIRequest.h"
#import "FBLoginDialog.h"
#import "FIExportViewController.h"
#import "FIndicatorView.h"
#import "FIPickerView.h"
#import "FIPickerViewIOS7.h"

@protocol FIExportViewControllerDelegate<NSObject>
@optional
-(void)reloadCurrentCategory:(NSString*)categoryId;

@end


@interface FIExportViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,FIPickerViewDelegate,FBLoginDialogDelegate,QIRequestDelegate,FIndicatorViewDelegate> {
	UITableView *exportTable;
	UITableView *secondaryTable;
	UILabel *progressLabel;
	UISlider *progressView;
	NSString *categoryToExport;
	NSMutableArray *filesToClean;
	NSMutableArray *fonts;
	NSInteger currentPath;
	NSString *currentFont;
	NSInteger currentSize;
	NSString *group;
	FIOrientation orientation;
	
    FIndicatorView *_indicatorView;
    
    NSMutableDictionary *_langDic;
    NSString *_l1;
    NSString *_l2;
    
	BOOL isReqToClean;
	BOOL isReloadCategory;
	BOOL isBothSide;
	BOOL isReversed;
    BOOL isLoadingSet;
	
	id delegate;
}

@property(nonatomic,copy)NSString* categoryToExport;
@property(nonatomic,copy)NSString *group;
@property(nonatomic,readwrite)FIOrientation orientation;
@property(nonatomic,assign)id delegate;

@end
