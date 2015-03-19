//
//  FImportGroupController.h
//  flashCards
//
//  Created by Ruslan on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"

@interface FImportGroupController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	
	UITableView *groupTable;
	NSArray *groupArray;
	NSString *subset;
	id delegate;
	
}

@property(nonatomic,copy)NSString* subset;
@property(nonatomic,assign)id delegate;

-(void)setGroup:(NSArray*)gArray;




@end
