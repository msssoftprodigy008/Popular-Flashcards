//
//  FImportCategoryController.h
//  flashCards
//
//  Created by Ruslan on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FImportCategoryController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *availableSetsTable;
	NSArray *availableSetsArray;
}

@end
