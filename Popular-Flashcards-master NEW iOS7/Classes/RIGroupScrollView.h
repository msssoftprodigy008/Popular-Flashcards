//
//  RIGroupScrollView.h
//  flashCards
//
//  Created by Ruslan on 5/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIPageView.h"

@class RIGroupScrollView;

typedef enum{
	RIGroupScrollViewLeft,
	RIGroupScrollViewCenter,
	RIGroupScrollViewRight
}RIGroupScrollViewLocation;

@protocol RIGroupScrollViewDelegate<NSObject>
-(NSInteger)numberOfItemsPerPage:(RIGroupScrollView*)groupScrollView;
-(NSInteger)numberOfPages:(RIGroupScrollView*)groupScrollView;
-(NSInteger)validItemsForPage:(RIGroupScrollView*)groupScrollView forPage:(NSInteger)pageNum;
-(void)viewForItem:(RIGroupScrollView*)groupScrollView
	   forPageView:(RIPageView*)pageView
		forPage:(NSInteger)pageNum
	  forNumInPage:(NSInteger)numberInPage;

-(NSInteger)numberOfButtons:(RIGroupScrollView*)groupScrollView;
-(CGSize)buttonSize:(RIGroupScrollView*)groupScrollView;
-(void)customizeButton:(RIGroupScrollView*)groupScrollView
			 forButton:(FIRoundedButton*)button
			forButtonNum:(NSInteger)buttonNum;

@optional
-(void)selectedViewForItem:(RIGroupScrollView*)groupScrollView
	   forPageView:(RIPageView*)pageView
		   forPage:(NSInteger)pageNum
	  forNumInPage:(NSInteger)numberInPage;



@end


@interface RIGroupScrollView : UIView<UIGestureRecognizerDelegate,RIPageViewDelegate> {
	UIView *r_centerView;
	UIView *r_rightView;
	UIView *r_leftView;
	
	UIPanGestureRecognizer *r_panRecognizer;
	
	CGSize r_viewSize;
	CGSize r_buttonSize;
	NSInteger r_viewsPerPage;
	NSInteger r_pageNum;
	NSInteger r_currentPage;
	NSInteger r_numberOfButtons;
	
	NSMutableArray *r_freePlaces;
	
	id<RIGroupScrollViewDelegate> r_delegate;
	
	BOOL r_isInited;
}

@property(nonatomic,assign)id<RIGroupScrollViewDelegate> r_delegate;
@property(nonatomic,readwrite)CGSize r_viewSize;

-(void)reloadData;
-(void)reloadCurrentPage;
-(void)reloadCurrentMemoryPages;
-(NSInteger)getCurrentPage;
-(BOOL)scrollToPage:(NSInteger)page animated:(BOOL)animated;
-(NSArray*)getFreePlace;


@end
