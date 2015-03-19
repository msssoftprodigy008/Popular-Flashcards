//
//  FIQuizletController.h
//  flashCards
//
//  Created by Ruslan on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FIQuizletDelegate

-(void)quizletSetAded:(NSString*)newSet;

@end


@interface FIQuizletController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *availableSetsTable;
	NSArray *availableSetsArray;
}


@end
