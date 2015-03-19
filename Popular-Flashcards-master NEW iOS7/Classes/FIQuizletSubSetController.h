//
//  FIQuizletSubSetController.h
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FIQuizletSubSetController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	NSString *category;
	NSInteger categoryId;
	NSArray *availableSubCategoriesArray;
	UITableView *availableSubCategoriesTable;
}

@property(nonatomic,retain)NSString* category;
@property(nonatomic,readwrite)NSInteger categoryId;

@end
