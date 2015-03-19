//
//  FIImageChooseViewController.h
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRootConstants.h"

@protocol FIImageChooseDelegate
-(void)selectedImage:(UIImage*)image;	
@end

@interface FIImageChooseViewController : UIViewController<UIScrollViewDelegate> {
	UIScrollView *templateView;
	UIButton *next;
	UIButton *prev;
	UILabel *countTitle;
	UITextView *description;
	NSArray *images;
	NSArray *titles;
	NSInteger currentPage;
	NSInteger numberOfPages;
	id delegate;
	
	FIOrientation orientation;
}

@property(nonatomic,readwrite)FIOrientation orientation;

-(void)setDelegate:(id)Adelegate forImages:(NSArray*)Aimages forTitles:(NSArray*)Atitles;

@end
