//
//  QIViewController.h
//  flashCards
//
//  Created by Ruslan on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBLoginDialog.h"
#import "QIRequest.h"

@class FINavigationBar;

@interface QIViewController : UIViewController<FBLoginDialogDelegate,QIRequestDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    UIBarButtonItem *_loginButton;
    FINavigationBar *_topBar;
    NSDictionary *_userInfo;
    BOOL _isLoading;
}

@end
