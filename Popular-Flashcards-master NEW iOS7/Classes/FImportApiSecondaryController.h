//
//  FImportApiSecondaryController.h
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FImportApiSecondaryController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView* importTable;
	id delegate;
	NSMutableArray *subsets;
	NSString *category;
	NSInteger categoryId;
}

-(void)setDelegate:(id)Adelegate forId:(NSInteger)Aid forCategory:(NSString*)Acategory;

@end
