//
//  FIDefinitionViewController.h
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDefinitionController.h"
#import "FITextViewController.h"
#import "FCustomSegmentedController.h"
#import "FIToolBar.h"
#import "FISearchBar.h"
#import "FRootConstants.h"

@protocol FIDefinitionDelegate

-(void)definitionWasPicked:(NSString*)definition;

@end

@interface FIDefinitionViewController : UIViewController<FDefinitionControllerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FITextViewControllerDelegate> {
	UITableView *definitionTable;
	UITextView *definitionView;
	FCustomSegmentedController *segment;
	FISearchBar *DefsearchBar;
	UILabel *header;
	NSArray *currentDefinitions;
	NSArray *currentPhrases;
	NSArray *currentExamples;
	NSArray *currentRelate;
	NSString *term;
	
	BOOL isNewDef;
	BOOL isNewPhr;
	BOOL isNewExm;
	BOOL isNewRel;
	
	FIOrientation orientation;
	FIToolBar *definitionToolbar;
	UIBarButtonItem *addToCardButton;
	
	NSInteger rowIndex;
	
	id delegate;
}

@property(nonatomic,assign)FIOrientation orientation;
@property(nonatomic,assign)id delegate; 
@property(nonatomic,copy)NSString *term;

@end
