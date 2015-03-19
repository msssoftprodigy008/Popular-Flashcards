//
//  FIFlickerViewController.h
//  flashCards
//
//  Created by Ruslan on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FICardsConstants.h"
#import "FIFlickerViewController.h"
#import "FRootConstants.h"
#import "Util.h"
#import "Constants.h"
#import "FDownLoader.h"
#import "FILoadingView.h"
#import "FAdMobController.h"
#import "SDWebImageManager.h"
#import "FISearchBar.h"

@protocol FIFlickerControllerDelegate

-(void)pictureForTerm:(UIImage*)pic pop:(BOOL)pop;

@end


@interface FIFlickerViewController : UIViewController<UISearchBarDelegate,SDWebImageManagerDelegate,UIImagePickerControllerDelegate,
UINavigationControllerDelegate,UIPopoverControllerDelegate> {
	FISearchBar *pictureSearchBar;
	UIButton *nextButton;
	UIButton *prevButton;
	UIBarButtonItem *photosButton;
	UIBarButtonItem *drawButton;
	UIBarButtonItem *cameraButton;
	UIPopoverController *imagePickerPopover;
	UIImagePickerController *imagePicker;
	NSMutableArray *pictureArray; 
	NSMutableArray *picturesInfoArr;
	UIView *animationView;
	UIImage *imageForDelegate;
	UIImage *currentImage;
	NSInteger page;
	NSInteger allpages;
	NSString *term;
	FIserverMode imageServerMode;
	FIOrientation orientation;	
	BOOL isFirstSearch;
    BOOL isDraw;
	id delegate;
    
        int  imagesCount; //for google imagescount sanjeev reddy
    
}

@property(nonatomic,assign)id delegate;
@property(nonatomic,readwrite)FIOrientation orientation;
@property(nonatomic,retain)UIImage *currentImage;

-(id)initWithTerm:(NSString*)Aterm forMode:(FIserverMode)mode;
-(void)dismissPopover:(BOOL)animated;

@end
