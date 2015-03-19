//
//  RISimpleTableViewController.h
//  flashCards
//
//  Created by Ruslan on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RISimpleTableViewController;

@protocol RISimpleTableViewControllerDelegate<NSObject>

-(void)selectedRow:(NSInteger)index;

@end



@interface RISimpleTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *r_tableView;
	NSMutableArray* r_rows;
	id<RISimpleTableViewControllerDelegate> r_delegate;
	CGRect r_frame;
}

@property(nonatomic,assign)id<RISimpleTableViewControllerDelegate> r_delegate;

-(id)initWithRows:(NSArray*)rows forFrame:(CGRect)frame;

@end
