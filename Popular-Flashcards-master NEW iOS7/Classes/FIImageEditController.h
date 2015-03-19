//
//  FIImageEditController.h
//  flashCards
//
//  Created by Ruslan on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FISketchedImageView.h"
#import "FINavigationBar.h"
#import "FRootConstants.h"

@protocol FIImageEditControllerDelegate<NSObject>
@optional
-(void)imageWasDeleted;

@end


@interface FIImageEditController : UIViewController<UIGestureRecognizerDelegate> {
	UIImageView *_imageView;
	UIImage *_image;
	id<FIImageEditControllerDelegate> delegate;
	FINavigationBar *_navBar;
	
	UIBarButtonItem *_deleteButton;
	
	BOOL isPanelHidden;
	
	NSTimer *_navShowTimer;
}

@property(nonatomic,assign)id<FIImageEditControllerDelegate> delegate;

-(id)initWithImage:(UIImage*)image;

@end
