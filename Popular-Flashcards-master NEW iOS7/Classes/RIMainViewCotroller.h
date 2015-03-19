//
//  RIMainViewCotroller.h
//  FC 1.4
//
//  Created by Ruslan on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RICategoryContainer.h"
#import "FISceneViewController.h"
#import "FIExportViewController.h"
#import "RITableListView.h"
#import "FTextAlertView.h"
#import "FIShapeView.h"
#import "WEPopoverController.h"
#import "FITemplateViewController.h"
#import "FImportApiBaseController.h"
#import "FExportBaseController.h"
#import "FBoxSceneController.h"
#import "FUpgradeManager.h"
#import "AboutViewController.h"
#import "FINavigationBar.h"
#import "FAdMobController.h"
#import "RIChooseGroupController.h"
#import "QIRequest.h"
#import "myAdView.h"

#define kNumberPerGroupPage 8
#define kAlertAdd 100
#define kAlertEdit 101
#define kAlertQuizlet 102
#define kAlertImportTerm 103
#define KAlerTDeleteCategory 109

#define kPContentNone 99
#define kPContentAdd 100
#define kPContentMode 101

typedef enum{
	RIMainModeCategories,
	RIMainModeGroups
}RIMainMode;

typedef enum{
	RIPopoverStateAddCategory,
	RIPopoverStateAddCard,
	RIPopoverStateSettings,
	RIPopoverStateGroup,
	RIPopoverStateNone
}RIPopoverState;

typedef enum{
	RITableListViewTypeGroup,
	RITableListViewTypeTemplates
}RITableListViewType;

@interface RIMainViewCotroller : UIViewController<RICategoryContainerDelegate,FISceneViewControllerDelegate,
FIExportViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,RITableListViewDelegate,
UITextFieldDelegate,UIPopoverControllerDelegate,WEPopoverControllerDelegate,
FExportBaseDelegate,FBoxSceneControllerDelegate,FUpgradeDelegate,IPadAboutControllerDelegate,FAdMobControllerDelegate,
FITemplateViewControllerDelegate,myAdViewDelegate,RIChooseGroupControllerDelegate,QIRequestDelegate> {
	RICategoryContainer *r_categoryContainer;
	RITableListView *r_groupView;
	UIImageView *shape;
	NSMutableArray *r_groupIDArray;
	NSInteger r_changedIndex;
	FINavigationBar *r_navigationBar;
	UINavigationItem *r_navigationItem;
	UIPopoverController *r_popoverContoller;
	WEPopoverController *iphone_popover;
	RIPopoverState r_popoverState;
    UIImageView *r_bgPortView;
    UIImageView *r_bgLandView;
    BOOL isButtonHidden;
	NSInteger r_popoverContentID;
	UIBarButtonItem *r_addButton;
	UIBarButtonItem *r_editButton;
	UIButton* r_upgradeButton;
	UIButton* r_aboutButton;
	NSString* r_category;
	NSString* r_group;
	NSString* r_term;
	UIView* r_popoverBgView;
	NSIndexPath *r_currentSelectedRow;
    
    
    UITableView *myTableView;
	
	BOOL r_isTextChanged;
	
	NSInteger r_animationID;
	
	RIMainMode r_mode;
	
	BOOL r_isEdit;
    BOOL r_editWithCurId;
    
    NSInteger _advTimer;
    
    
    int categoryIndexPath;
    
    
    myAdView *adView;
    
    SystemSoundID addSetID;
}

-(void)enterToBackground;
-(void)makeActive;
-(void)termination;
-(void)importTerm:(NSString*)term;
-(NSString*)getCurrentGroup;
-(void)reloadCurrentGroup:(NSString*)gId category:(NSString*)categoryName;
-(NSDictionary*)infoForCurrentCategory;


@end
