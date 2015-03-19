//
//  FFontController.h
//  flashCards
//
//  Created by Ruslan on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FFontController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *fontTable;
	NSMutableArray *fonts;
	NSString *currentFont;
	NSInteger currentPath;
	NSInteger currentSize;
	NSString *category;
	UISlider *slider;
	UILabel *sliderLabel;
	BOOL isFontChanged;
}

@property(nonatomic,copy)NSString *category;

@end
