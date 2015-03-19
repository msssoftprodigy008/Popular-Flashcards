//
//  FITemplateViewController.h
//  flashCards
//
//  Created by Ruslan on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FINavigationBar.h"

@protocol FITemplateViewControllerDelegate<NSObject>

-(void)createCategory:(NSInteger)templateType;

@end


@interface FITemplateViewController : UIViewController<UIScrollViewDelegate> {
	FINavigationBar *_navBar;
	NSMutableArray *_templateContents;
	UINavigationItem *_barTopItem; 
	
	UIScrollView *_templateScrollView;
	UIPageControl *_pageControl;
	
	UIBarButtonItem* _imageButton;
	UIBarButtonItem* _soundButton;
	UIBarButtonItem* _sideButton;
	
	NSInteger _currentPage;
	
	UIButton *_soundIphoneButton;
	UIButton *_imageIphoneButton;
	
	NSIndexPath *_templatePath;
	
	id<FITemplateViewControllerDelegate> delegate;
}

@property(nonatomic,assign)id<FITemplateViewControllerDelegate> delegate;
-(NSArray*)templates;


@end
