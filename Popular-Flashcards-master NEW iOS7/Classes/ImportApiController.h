//
//  ImportApiController.h
//  flashCards
//
//  Created by Ruslan on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FQuizletImport.h"
#import "FImportSet.h"
#import "FIndicatorView.h"
#import "FAdMobController.h"

@protocol ApiControllerDelegate

-(void)importFinished:(BOOL)result newCat:(NSString*)cat;

@end


@interface ImportApiController : UIViewController<UITableViewDelegate,UITableViewDataSource,FQuizletImportDelegate,FImportSetDelegate,FIndicatorViewDelegate> {
	NSMutableArray *currentSets;
	NSDictionary *currDic;
	NSString *category;
	UITableView *setTable;
	UIView *proccesView;
	UIActivityIndicatorView *indicator;
	
	NSInteger curPageNum;
	NSInteger totalPages;
	NSInteger currSetVisible;
	NSInteger totalSets;
	
	id delegate;
	
	NSInteger total_images;
	NSInteger downloaded_images;
	
	FQuizletImport *quizlet;
	FImportSet *importSet;
	
	FIndicatorView *progressView;
	UISegmentedControl *segment;
	
	UITextField *editField;
}

-(void)setDelegate:(id)Adelegate;

@end
