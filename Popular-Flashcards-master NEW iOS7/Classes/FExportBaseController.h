//
//  FExportBaseController.h
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTextAlertView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "FAdMobController.h"
#import <SSToolkit/SSToolkit.h>
#import "FIPickerView.h"
#import "QIRequest.h"
#import "FBLoginDialog.h"
#import "FIndicatorView.h"

@class FExportBaseController;

@protocol FExportBaseDelegate
@optional
-(void)categoryRenamed:(NSString*)newName;
-(void)setWasReseted:(NSString*)categoryId;
-(void)loadCardEditing:(NSString*)setId;
-(void)dissmisMe;

@end


@interface FExportBaseController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,FIPickerViewDelegate,FBLoginDialogDelegate,QIRequestDelegate,FIndicatorViewDelegate> {
	UITableView *exportTable;
	NSString *categoryToExport;
    NSString *r_group;
	NSMutableArray *filesToClean;
	FTextAlertView *textAlert;
	NSString *currentFont;
	NSInteger currentSize;
    NSMutableDictionary *_langDic;
    NSString *_l1;
    NSString *_l2;
    
    FIndicatorView *_indicatorView;
    BOOL isLoadingSet;
    
	id delegate;
	BOOL isReqToClean;
	BOOL isBothSide;
	BOOL isReversed;
}

@property(nonatomic,assign)id delegate;

-(void)exportCategory:(NSString*)category group:(NSString*)group;

@end
