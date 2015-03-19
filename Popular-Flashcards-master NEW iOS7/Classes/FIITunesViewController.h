//
//  FIITunesViewController.h
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"


@interface FIITunesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *availableSetsTable;
	NSMutableArray *fileNames;
	NSString *newCategory;
}



@end
