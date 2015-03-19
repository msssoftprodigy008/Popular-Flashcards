//
//  RITableListView.h
//  flashCards
//
//  Created by Ruslan on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FINavigationBar.h"

@class RITableListView;

@protocol RITableListViewDelegate<NSObject>
@optional
-(void)leftButtonPressed:(RITableListView*)list;
-(void)rightButtonPressed:(RITableListView*)list;
-(void)topBarPressed:(RITableListView*)list;
@end



@interface RITableListView : UIView {
	UITableView *r_tableView;
	FINavigationBar *r_topBar;
	UIBarButtonItem *r_leftButton;
	UIBarButtonItem *r_rightButton;
	NSArray *r_btitles;
	id r_delegate;
}

@property(nonatomic,readonly)UITableView* r_tableView;
@property(nonatomic,readonly)UINavigationBar *r_topBar;
@property(nonatomic,readonly)UIBarButtonItem* r_leftButton;
@property(nonatomic,readonly)UIBarButtonItem* r_rightButton;

-(id)initWithFrame:(CGRect)frame forDelegate:(id)delegate forBTitles:(NSArray*)btitles forTag:(NSInteger)viewTag;

@end
