//
//  FImportApiBaseController.h
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportViewController.h"
#import "QIRequest.h"
#import "FBLoginDialog.h"

@interface FImportApiBaseController : UIViewController<UITableViewDelegate,UITableViewDataSource,QIRequestDelegate,FBLoginDialogDelegate> {
	UITableView *categoryTable;
    UIToolbar *toolbar;
    NSDictionary *_userInfo;
    UIBarButtonItem *_loginButton;
	UISegmentedControl *segmentedControl;
	id delegate;
	
	ImportViewController *csvController;
}

-(void)setDelegate:(id)Adelegate;
@end
