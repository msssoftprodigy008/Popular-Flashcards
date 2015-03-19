//
//  FIQuizletSearchController.h
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQuizletImport.h"
#import "FIQuizletHeader.h"
#import "FAdMobController.h"
#import "FISearchBar.h"
#import "FCustomSegmentedController.h"

@class FILoadingView;

@interface FIQuizletSearchController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FQuizletImportDelegate> {
	UITableView* availableQuizletSetsTable;
	NSMutableArray *availableQuizletSetsArray;
	NSDictionary *availableSetDictionary;
	FILoadingView *loadingView;
	FQuizletImport *quizletImport;
	
	NSInteger curPageNum;
	NSInteger totalPages;
	NSInteger currSetVisible;
	NSInteger totalSets;
	
	FISearchBar *searchView;
	FISearchType searchType;
	
	FCustomSegmentedController *segment;
}

@end
