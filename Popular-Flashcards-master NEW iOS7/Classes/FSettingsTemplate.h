//
//  FSettingsTemplate.h
//  flashCards
//
//  Created by Руслан Руслан on 3/11/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSettingsTemplateDelegate
-(void)selectedItemWithImage:(UIImage*)image;	
@end


@interface FSettingsTemplate : UIViewController<UIScrollViewDelegate> {
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
}

-(void)setDelegate:(id)Adelegate forImages:(NSArray*)Aimages forTitles:(NSArray*)Atitles;
@end
