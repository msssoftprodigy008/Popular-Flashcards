//
//  FIFontController.h
//  flashCards
//
//  Created by Ruslan on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FIFontController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView *fontTable;
	NSMutableArray *fonts;
	NSString *currentFont;
	NSIndexPath *currentPath;
	NSInteger currentSize;
	NSString *category;
	UISlider *slider;
	UILabel *sliderLabel;
}

@property(nonatomic,copy)NSString *category;


@end
