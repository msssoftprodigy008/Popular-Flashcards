//
//  FIQuizletAvailableSetsController.h
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIRequest.h"

@class FILoadingView;
@class FQuizletImport;
@class FINavigationBar;

@interface FIQuizletAvailableSetsController : UIViewController<UITableViewDelegate,UITableViewDataSource,QIRequestDelegate> {
	FINavigationBar *topBar;
	NSString *category;
    NSString *title;
	UITableView* availableQuizletSetsTable;
	NSMutableArray *availableQuizletSetsArray;
	FILoadingView *loadingView;
    BOOL isSearch;
}

@property(nonatomic,copy)NSString* category;
@property(nonatomic,copy)NSString* title;

@end
