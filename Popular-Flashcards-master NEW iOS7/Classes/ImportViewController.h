//
//  ImportViewController.h
//  flashCards
//
//  Created by Ruslan on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"

@protocol ImportViewControllerDelegate

-(void)upgradedFromItunes:(id)reqId;
-(void)reloadTable;
-(void)itunesSetImported:(NSString*)setId;
@end


@interface ImportViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView* importTable;
	NSMutableArray *fileNames;
	UIView *upgradeView;
	id delegate;
}

@property(nonatomic,retain)id delegate;  

-(void)upgraded;

@end
