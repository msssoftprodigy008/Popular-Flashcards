//
//  FIQuizletGroupController.h
//  flashCards
//
//  Created by Ruslan on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"


@interface FIQuizletGroupController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *groups;
	NSArray *groupArray;
	NSString *subset;
}


@property(nonatomic,copy)NSString* subset;

-(void)setGroupArray:(NSMutableArray*)gArray;


@end
