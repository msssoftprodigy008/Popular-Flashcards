//
//  FDefinitionViewController.h
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDefinitionController.h"
#import "FTextView.h"
#import "FAdMobController.h"

@protocol FDefinitionViewControllerDelegate
@optional
-(void)definitionPicked:(NSString*)definition;
-(void)dissmisDefinition;
@end


@interface FDefinitionViewController : UIViewController<FDefinitionControllerDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,FTextViewDelegate> {
	UITableView *definitionTable;
	UISegmentedControl *segment;
	UISearchBar *DefsearchBar;
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
	
	id delegate;
}

@property(nonatomic,assign)id delegate; 
@property(nonatomic,copy)NSString *term;


@end
