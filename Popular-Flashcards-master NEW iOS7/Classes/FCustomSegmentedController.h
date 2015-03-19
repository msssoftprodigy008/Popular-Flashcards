//
//  FCustomSegmentedController.h
//  flashCards
//
//  Created by Ruslan on 7/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FCustomSegmentedController : UIControl {
	NSMutableArray *buttonArray;
	NSInteger selectedSegmentIndex;
}

@property(nonatomic,readwrite)NSInteger selectedSegmentIndex;

-(id)initWithItems:(NSArray*)items;
-(void)setSelectedSegmentIndex:(NSInteger)index;
-(NSInteger)selectedSegmentIndex;

@end
