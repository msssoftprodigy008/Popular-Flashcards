    //
//  FIFlickerViewController.m
//  flashCards
//
//  Created by Ruslan on 2/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIFlickerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FIAnimationController.h"
#import "FDefinitionController.h"
#import "FIToolBar.h"
#import "FIDrawController.h"
#import "FDrawController.h"
#import "Constant.h"
#import "flashCardsAppDelegate.h"
#import "UIImagePickerController+ImagePicker.h"//sanjeev reddy

#import "NonRotatingUIImagePickerController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>


#define kPicperPage 8
#define kPicperPageLand 8
#define kPicperPageLandiPhone5 8

#define kScaleConstIPhone 300
#define kScaleConstIPad 300
#define kScaleConstThumbIPhone 75
#define kScaleConstThumbIPad 112.5


@interface FIFlickerViewController(Private)

//init
-(void)initTopBar;
-(void)initIpadTopBar;
-(void)initBottomBar;
-(void)initSearchBar;
-(void)initPictureFrame;
-(void)initAnimationView;

-(void)initpotraitBottomBar;

//targets
-(void)backButtonPressed:(id)sender;
-(void)nextButtonPressed:(id)sender;
-(void)prevButtonPressed:(id)sender;
-(void)photoButtonPressed:(id)sender;
-(void)drawButtonPressed:(id)sender;
-(void)cameraButtonPressed:(id)sender;
-(void)picTapped:(UITapGestureRecognizer*)tap;

//private
-(void)searchPicture;
-(void)cleanViews;
-(void)bingDownloadForCurrentPage;
-(void)updateViews;
-(void)updateViewForTag:(NSInteger)tag;
-(UIImage*)generateTumbnailImage:(UIImage*)fromImage;
-(UIImage*)generateReturnImage:(UIImage*)fromImage;


@end


@implementation FIFlickerViewController
@synthesize delegate;
@synthesize orientation;	
@synthesize currentImage;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(id)initWithTerm:(NSString*)Aterm forMode:(FIserverMode)mode
{
	if (self=[super init]) {
		if (Aterm) {
			term = [[NSString alloc] initWithString:Aterm];
		}
		imageServerMode = mode;
	}
	
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView;
    imagesCount = 8;     //sanjeev reddy
    	if ([Util isPhone])
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,((IS_IPHONE_5)?568:480),300.0)];
	else
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,540.0,580.0)];
	
	self.view = contentView;
	
	if ([Util isPhone]){
		UIImageView* backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
		backgroundImage.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90];
		[self.view addSubview:backgroundImage];
		[backgroundImage release];
	}
	else{
		self.view.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
    }

	[contentView release];
	
	
	[self initAnimationView];
	[self initSearchBar];
	
	if ([Util isPhone])	
		[self initTopBar];
	else
		[self initIpadTopBar];

	[self initPictureFrame];
	[self initBottomBar];
	isDraw = NO;
	page = 1;
	isFirstSearch = YES;
	allpages = -1;
	
	if (term) {
		[self searchPicture];
	}
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Find image" withParam:nil];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)setCurrentImage:(UIImage *)image{
	if (currentImage) {
		[currentImage release];
		currentImage = nil;
	}
	
	if (image) {
		currentImage = [[UIImage alloc] initWithCGImage:image.CGImage];
	}
}

-(void)dismissPopover:(BOOL)animated
{
	if (imagePickerPopover && [imagePickerPopover isPopoverVisible]) {
		[imagePickerPopover dismissPopoverAnimated:animated];
		[imagePickerPopover release];
		imagePickerPopover = nil;
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (![Util isPhone] && !isDraw) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"restorePopover"
															object:nil];
	}
    
    if (isDraw) {
        isDraw = NO;
    }
}


- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape ;//|UIInterfaceOrientationMaskPortrait;
}

//// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    if (![Util isPhone])
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	else
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
    //return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;

    return YES;
    
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
//    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight)
//        return YES;
//    else
//        return NO;
//}
#pragma mark -
#pragma mark SearchBar delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[pictureSearchBar resignFirstResponder];
	
	if (term) {
		[term release];
	}
	
	
	term = [[NSString alloc] initWithString:searchBar.text];
	
	isFirstSearch = YES;
	page = 1;
	allpages = -1;
	
	[self searchPicture];
	
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
	[pictureSearchBar resignFirstResponder];
}

#pragma mark -

#pragma mark -
#pragma mark Downloader delegate

-(void)downloadedDataRecived:(NSData*)downloadedData
{
	if (downloadedData) {
		UIImage *img = [UIImage imageWithData:downloadedData];
		int tag = [pictureArray count];
		[pictureArray addObject:img];
		
		if (tag%2!=0) 
			[self updateViewForTag:tag/2];
		
	}
}

-(void)downloadingFinished:(BOOL)result
{
	if(!result){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Flickr"
														message:@"Downloading failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		if (isFirstSearch) {
			isFirstSearch = NO;
            nextButton.enabled = YES;
		}
		
        if (imagesCount==8) {
            prevButton.enabled=NO;
        }else
        {
            prevButton.enabled=YES;
            
        }
//		if (page<=1) {
//			prevButton.enabled = NO;
//		}else {
//			prevButton.enabled = YES;
//		}
//		
//		if (page>=allpages) {
//			nextButton.enabled = NO;
//		}else {
			//nextButton.enabled = YES;
  //  }
		
	}


}

#pragma mark -

#pragma mark -
#pragma mark UIPopoverController delegate 

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    photosButton.enabled = YES;
    drawButton.enabled = YES;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return YES;
}

#pragma mark UIPopoverController delegate ends

#pragma mark -
#pragma mark FIAnimationController delegate

-(void)didEndAnimation
{
	if (delegate && imageForDelegate && [delegate respondsToSelector:@selector(pictureForTerm:pop:)]) {
		[delegate pictureForTerm:imageForDelegate pop:YES];
	}
	
	/*if ([Util isPhone])
		[self.navigationController popViewControllerAnimated:YES];
	else
		[self dismissModalViewControllerAnimated:YES];*/

}

#pragma mark -

#pragma mark -
#pragma mark Flicker delegate

-(void)flickerRespForTerm:(NSDictionary*)flicDic
{
	if (pictureArray) {
		[pictureArray release];
	}
	
	pictureArray = [[NSMutableArray alloc] init];
	
	if (flicDic) {
		NSMutableArray *urls = [NSMutableArray array];
		NSDictionary *photos = [flicDic objectForKey:@"photos"];
		NSArray *photo = [photos objectForKey:@"photo"];
		NSInteger total = [[photos objectForKey:@"total"] intValue];
		
		if (total>0) {
			allpages = [[photos objectForKey:@"pages"] intValue];
			for (NSDictionary *dic in photo) {
				NSString *farm = [dic objectForKey:@"farm"];
				NSString *server = [dic objectForKey:@"server"];
				NSString *secret = [dic objectForKey:@"secret"];
				NSString *pic_id = [dic objectForKey:@"id"];
				if (farm && server && secret && pic_id) {
					NSString *urlStr2 = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg",farm,server,pic_id,secret];
					NSString *urlStr1;
				
					if ([Util isPhone])
						urlStr1 = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_m.jpg",farm,server,pic_id,secret];
					else
						urlStr1 = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_z.jpg",farm,server,pic_id,secret];

								
					if (urlStr1 && urlStr2) {
						[urls addObject:urlStr1];
						[urls addObject:urlStr2];
					}
				
				}
			}
			[[FDownLoader sharedDownloader:self] cancelDownloading];
			[[FDownLoader sharedDownloader:self] download:urls];
		}else {
			NSString *message = @"Image not found";
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
															message:message
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}

	}
}

-(void)definitionFailed
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"List Request failed"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -

#pragma mark -
#pragma mark bingAPIDelegate

-(void)bingRespForTerm:(NSMutableArray*)imageArr
{
	if (isFirstSearch) {
		isFirstSearch = NO;
	}
	
		
	if (imageArr) {
		if(picturesInfoArr)
			[picturesInfoArr release];
		picturesInfoArr = [[NSMutableArray alloc] initWithArray:imageArr];
        
        NSLog(@"picturesInfoArr %@",picturesInfoArr);
		if ([Util isPhone]) {
			allpages = [picturesInfoArr count]/((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
		}else {
			allpages = [picturesInfoArr count]/kPicperPage;
		}

				
		page = 1;
		if (allpages>0) {
			[self bingDownloadForCurrentPage];
		}
	}
	
}

#pragma mark -

#pragma mark -
#pragma mark SDWebImageManagerDelegate

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
	if (image) {
		int tag = [pictureArray count];
		[pictureArray addObject:image];
		[self updateViewForTag:tag];
	}
}

#pragma mark -

#pragma mark -
#pragma mark targets

-(void)backButtonPressed:(id)sender
{
	if (imageServerMode == serverModeFlickr) {
		[[FDownLoader sharedDownloader:nil] cancelDownloading];
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	}else {
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
		[[SDWebImageManager sharedManager] cancelForDelegate:self];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
		
}

-(void)nextButtonPressed:(id)sender
{
	if (imageServerMode == serverModeFlickr) {
		[[FDownLoader sharedDownloader:nil] cancelDownloading];
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	}else {
		[[SDWebImageManager sharedManager] cancelForDelegate:self];
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	}

	
	page++;
    
    
    imagesCount +=8;

    
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: kCATransitionFromRight];
	[animation setSpeed:2.5];
	
	if (imageServerMode == serverModeFlickr) {
		[self searchPicture];
	}else {
        
        if (imagesCount>=56)  { // max google images loading is 56 , changed sanjeev reddy
            
           [self searchPicture];
            
           
            nextButton.enabled=NO;
        
        }else if(imagesCount>8)
        {
            nextButton.enabled=YES;

         prevButton.enabled=YES;
          [self searchPicture];
        }

		//[self bingDownloadForCurrentPage];
	}

	[[animationView layer] addAnimation:animation forKey:@"next"];
}

-(void)prevButtonPressed:(id)sender
{
	if (imageServerMode == serverModeFlickr) {
		[[FDownLoader sharedDownloader:nil] cancelDownloading];
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	}else {
		[[SDWebImageManager sharedManager] cancelForDelegate:self];
		[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	}
	
	page--;
	
    imagesCount-=8;
    
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType: kCATransitionPush];
	[animation setSubtype: kCATransitionFromLeft];
	[animation setSpeed:2.5];
	
	if (imageServerMode == serverModeFlickr) {
		[self searchPicture];
	}else {// google images loading, changed sanjeev reddy
        
        if(imagesCount<=8)
        {
            prevButton.enabled=NO;
            //[self searchPicture];
        }else if(imagesCount>=8 && imagesCount<=56)
        {
            nextButton.enabled=YES;
            [self searchPicture];
        }else
        {
        [self searchPicture];
        }
        
        
    }
        
        
        
		//[self bingDownloadForCurrentPage];
	
	
	[[animationView layer] addAnimation:animation forKey:@"prev"];
	
}
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return  UIInterfaceOrientationMaskLandscapeLeft |   UIInterfaceOrientationMaskLandscapeRight;
//}



-(void)photoButtonPressed:(id)sender
{
    
	imagePicker = [[NonRotatingUIImagePickerController alloc] init];
    imagePicker.delegate = self;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
   
    
	if ([Util isPhone]) {
    
    //[imagePicker supportedInterfaceOrientations];   // changed sanjeev reddy
////
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];

        
		[self.navigationController presentViewController:imagePicker animated:YES completion:nil];

        
   
	}else {
		photosButton.enabled = NO;
        drawButton.enabled = NO;
		if (imagePickerPopover && [imagePickerPopover isPopoverVisible]) {
			return;
		}
		
		if (imagePickerPopover) {
			[imagePickerPopover release];
		}
		
		imagePickerPopover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        imagePickerPopover.delegate = self;
		[imagePickerPopover presentPopoverFromBarButtonItem:photosButton permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	}
	
	[imagePicker release];
}

-(void)drawButtonPressed:(id)sender
{
    isDraw = YES;
    
	if ([Util isPhone]) {
		FIDrawController *drawControler = [[FIDrawController alloc] init];
		drawControler.delegate = self;
		drawControler.orientation = FIOrientationLandscape;
		[self.navigationController pushViewController:drawControler animated:YES];
		[drawControler release];
	}else {
		FDrawController *drawController = [[FDrawController alloc] init];
		drawController.contentSizeForViewInPopover = CGSizeMake(500.0,600.0);
		drawController.delegate = self;
		[self.navigationController pushViewController:drawController animated:YES];
		[drawController release];
	}
	
}

-(void)cameraButtonPressed:(id)sender
{
   imagePicker = [[UIImagePickerController alloc] init];
   imagePicker.delegate = self;
   imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
   [self presentViewController:imagePicker animated:YES completion:nil];
   [imagePicker release];

}

-(void)picTapped:(UITapGestureRecognizer*)tap
{
	UIView *subView = (UIView*)tap.view;
	
	if (imageServerMode == serverModeFlickr)
	{
		UIImage *image = [pictureArray objectAtIndex:2*(subView.tag-1)];

		if (subView && image) {
			if (imageForDelegate) {
				[imageForDelegate release];
			}
			image = [self generateReturnImage:image];
			imageForDelegate = [[UIImage alloc] initWithCGImage:image.CGImage];
			[[FIAnimationController sharedAnimation:self] bounceView:subView];
		}
	}else {
		UIImage *image = [pictureArray objectAtIndex:subView.tag-1];

		if (subView && image) {
			if (imageForDelegate) {
				[imageForDelegate release];
			}
			image = [self generateReturnImage:image];	
			imageForDelegate = [[UIImage alloc] initWithCGImage:image.CGImage];
			[[FIAnimationController sharedAnimation:self] bounceView:subView];
		}
	}

}

#pragma mark -

#pragma mark -
#pragma mark FIDrawControllerDelegate

-(void)drawnedImage:(UIImage*)img
{
	CGFloat scale;
	
	if ([Util isPhone]) {
		scale = [UIScreen mainScreen].scale*kScaleConstIPhone/img.size.width;
	}else {
		scale = [UIScreen mainScreen].scale*kScaleConstIPad/img.size.width;
	}

	
	if (img) {
		
		CGSize imageSize = CGSizeMake(scale*img.size.width,
									  scale*img.size.height);
		UIImage *tmpImage = [Util createImageWithSize:imageSize withImage:img];
		
		if (delegate && [delegate respondsToSelector:@selector(pictureForTerm:pop:)]) {
			[delegate pictureForTerm:tmpImage pop:YES];
		}
	}
}

#pragma mark -



#pragma mark -
#pragma mark imagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
		
		UIImage *tmpImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		
		tmpImage = [self generateReturnImage:tmpImage];
		
		if (currentImage) {
			[currentImage release];
		}
		
		currentImage = [[UIImage alloc] initWithCGImage:tmpImage.CGImage];
		
		if (delegate && [delegate respondsToSelector:@selector(pictureForTerm:pop:)]) {
			[delegate pictureForTerm:tmpImage pop:NO];
		}
	}
	
	if ([Util isPhone]) {
        [picker dismissModalViewControllerAnimated:YES];
	}else {
        photosButton.enabled = YES;
        drawButton.enabled = YES;
        [imagePickerPopover dismissPopoverAnimated:YES];
        [imagePickerPopover release];
        imagePickerPopover = nil;
	}
    
    [self performSelector:@selector(backButtonPressed:)
               withObject:nil
               afterDelay:0.25f];
}


#pragma mark -
#pragma mark FDrawControllerDelegate IPAD

-(void)imageSaved:(UIImage*)img
{
	
	[self drawnedImage:img];
}


#pragma mark -
#pragma mark init

-(void)initIpadTopBar
{
	[self.navigationItem setTitle:@"Powered by bing.com"];
	/*UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(backButtonPressed:)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];*/
}

-(void)initTopBar
{
	
}

-(void)initpotraitBottomBar;
{

}


-(void)initBottomBar
{
    
	FIToolBar *bottomBar;
	if ([Util isPhone]){
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                    bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,272,((IS_IPHONE_5)?568:480),48.0)];  //bottombar iphone
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,252,((IS_IPHONE_5)?568:480),48.0)];
                }
                
            }
            else{
                
            }
            
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                    bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,272,((IS_IPHONE_5)?568:480),48.0)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,252,((IS_IPHONE_5)?568:480),48.0)];
                }
                
            }
            else{
                
            }
        }

    }
	else
	{
		bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,530.0,540.0,50.0)];
		bottomBar.bgImage = [Util imageFromBundle:@"add_bg.png"];
	}
    bottomBar.bgImage = [Util imageFromBundle:@"i_images_bottombg.png"];
	bottomBar.barStyle = UIBarStyleBlackTranslucent;
	[self.view addSubview:bottomBar];
	
	
    nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *nextButtonImage = [Util imageFromBundle:@"i_images_next1.png"];
    nextButton.frame = CGRectMake(self.view.frame.size.width-nextButtonImage.size.width,
                                  self.view.frame.size.height/2.0-nextButtonImage.size.height/2.0,
                                  nextButtonImage.size.width,
                                  nextButtonImage.size.height);
    [nextButton setImage:nextButtonImage forState:UIControlStateNormal];
    [nextButton setImage:[Util imageFromBundle:@"i_images_next2.png"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self
				   action:@selector(nextButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	nextButton.enabled = NO;
	[self.view addSubview:nextButton];
	
    prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *prevButtonImage = [Util imageFromBundle:@"i_images_prev1.png"];
	prevButton.frame = CGRectMake(0,
                                  self.view.frame.size.height/2.0-prevButtonImage.size.height/2.0,
                                  prevButtonImage.size.width,
                                  prevButtonImage.size.height);
    [prevButton setImage:prevButtonImage forState:UIControlStateNormal];
    [prevButton setImage:[Util imageFromBundle:@"i_images_prev2.png"] forState:UIControlStateHighlighted];
    
	[prevButton addTarget:self
				   action:@selector(prevButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	prevButton.enabled = NO;
	[self.view addSubview:prevButton];

	
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		  target:nil
																		  action:nil];
	
    UIButton *customPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *photoButtomImage = [Util imageFromBundle:@"i_images_import1.png"];
    customPhotoButton.frame = CGRectMake(0, 0, photoButtomImage.size.width, photoButtomImage.size.height);
    customPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    [customPhotoButton setImage:photoButtomImage forState:UIControlStateNormal];
    [customPhotoButton setImage:[Util imageFromBundle:@"i_images_import2.png"] forState:UIControlStateHighlighted];
    [customPhotoButton addTarget:self
                          action:@selector(photoButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    photosButton = [[UIBarButtonItem alloc] initWithCustomView:customPhotoButton];
        
    UIButton *customDrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *drawImage = [Util imageFromBundle:@"i_images_draw1.png"];
    customDrawButton.frame = CGRectMake(0, 0, drawImage.size.width, drawImage.size.height);
    customDrawButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
    [customDrawButton setImage:drawImage forState:UIControlStateNormal];
    [customDrawButton setImage:[Util imageFromBundle:@"i_images_draw2.png"] forState:UIControlStateHighlighted];
    [customDrawButton addTarget:self
                           action:@selector(drawButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    drawButton = [[UIBarButtonItem alloc] initWithCustomView:customDrawButton];
    	
	if ([Util isPhone]) {
        
        UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *doneImage = [Util imageFromBundle:@"i_images_back1.png"];
        customDoneButton.frame = CGRectMake(0, 0, doneImage.size.width, doneImage.size.height);
        customDoneButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customDoneButton setImage:doneImage forState:UIControlStateNormal];
        [customDoneButton setImage:[Util imageFromBundle:@"i_images_back2.png"] forState:UIControlStateHighlighted];
        [customDoneButton addTarget:self
                             action:@selector(backButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:customDoneButton];
        
       if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIButton *customCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *cameraImage = [Util imageFromBundle:@"i_images_camera1.png"];
            customCameraButton.frame = CGRectMake(0, 0, cameraImage.size.width, cameraImage.size.height);
            customCameraButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
            [customCameraButton setImage:cameraImage forState:UIControlStateNormal];
            [customCameraButton setImage:[Util imageFromBundle:@"i_images_camera2.png"] forState:UIControlStateHighlighted];
            [customCameraButton addTarget:self
                                      action:@selector(cameraButtonPressed:)
                            forControlEvents:UIControlEventTouchUpInside];
			cameraButton = [[UIBarButtonItem alloc] initWithCustomView:customCameraButton];
           
           if (IS_IPHONE_5) {
                [bottomBar setItems:[NSArray arrayWithObjects:doneButton,flex,flex,photosButton,flex,flex,drawButton,flex,cameraButton,nil]];
           }
           else {
               [bottomBar setItems:[NSArray arrayWithObjects:doneButton,flex,photosButton,flex,drawButton,flex,cameraButton,flex,nil]];
           }
			[cameraButton release];
		}else {
            if (IS_IPHONE_5) {
                    [bottomBar setItems:[NSArray arrayWithObjects:doneButton,flex,flex,photosButton,flex,flex,drawButton,nil]];
            }
            else {
                    [bottomBar setItems:[NSArray arrayWithObjects:doneButton,flex,photosButton,flex,drawButton,flex,nil]];
            }
		}
        
		[doneButton release];
		
	}else {
        [bottomBar setItems:[NSArray arrayWithObjects:flex,photosButton,flex,drawButton,flex,nil]];	
    }    

	[flex release];
	[photosButton release];
	[drawButton release];
	[bottomBar release];
	
	
}

-(void)initSearchBar
{
	if ([Util isPhone]){
		pictureSearchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,((IS_IPHONE_5)?568:480),49.0)];
        pictureSearchBar.bgImage = [Util imageFromBundle:@"i_images_topbg.png"];
    }
	else
	{
		pictureSearchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,540.0,50.0)];
		 pictureSearchBar.bgImage = [Util imageFromBundle:@"images_topbg.png"];
	}

	//pictureSearchBar.barStyle = UIBarStyleBlackTranslucent;
	pictureSearchBar.delegate = self;
	pictureSearchBar.placeholder = @"Search from web";
    pictureSearchBar.showsCancelButton = TRUE;

	if (term) {
		pictureSearchBar.text = term;
	}
	
	[self.view addSubview: pictureSearchBar];
	[pictureSearchBar release];
}

-(void)initPictureFrame
{
	
	NSInteger dx;
	NSInteger dy;
    NSInteger yOff;
    NSInteger xOff;
	CGSize frSize;
	
	if ([Util isPhone])
	{
		dx = 23.5;
		dy = 26.5;
        yOff = 18;
        xOff = 25;
		frSize.width = 75.0;
		frSize.height = 75.0;
	}else {
		dx = 51.0;
		dy = 26.5;
        yOff = dy;
        xOff = dx;
		frSize.width = 112.5;
		frSize.height = 112.5;
	}

	int picPerPage;
	int div;
	int tr;
	
	if ([Util isPhone]) {
		picPerPage = ((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
		div = ((IS_IPHONE_5)?5:4);
		tr = 30.0;
	}else {
		picPerPage = kPicperPage;
		div = 3;
		tr = 0;	
	}

	
	
	for (int i=0;i<picPerPage;i++) {
		
		CGRect frame = CGRectMake(0.0,0.0,frSize.width,frSize.height);
		
		NSInteger x = i%div;
		NSInteger y = i/div;
		
		frame.origin.x = xOff+dx*x+frSize.width*x+tr;
		frame.origin.y = yOff+dy*y+frSize.height*y;
		
		UIView *subanimationView = [[UIView alloc] initWithFrame:frame];
		subanimationView.backgroundColor = [UIColor clearColor];
		UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,frSize.width,frSize.height)];
		picImageView.userInteractionEnabled = YES;
		picImageView.backgroundColor = [UIColor whiteColor];
		picImageView.layer.shadowColor = [UIColor blackColor].CGColor;
		//picImageView.layer.borderColor = [UIColor whiteColor].CGColor;
		picImageView.layer.shadowOpacity = 0.5f;
		picImageView.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
		//picImageView.layer.shouldRasterize = YES;
        if ([Util isPhone]) {
            picImageView.layer.contentsScale = [UIScreen mainScreen].scale;
        }
        picImageView.contentMode = UIViewContentModeScaleAspectFit;
      //  picImageView.layer.borderWidth = 3;
		
		picImageView.layer.shadowRadius = 10.0f;
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:picImageView.bounds];
		picImageView.layer.shadowPath = path.CGPath;

		
		UITapGestureRecognizer *choosePic = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(picTapped:)];
		
		[subanimationView addGestureRecognizer:choosePic];
		
		[choosePic release];
		
		FILoadingView *loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0.0,0.0,frSize.width,frSize.height)];
		loadingView.userInteractionEnabled = NO;
		loadingView.center = picImageView.center;
		loadingView.backgroundColor = [UIColor clearColor];
		loadingView.messageLabel.text = @"";
		
		subanimationView.tag = i+1;
		picImageView.tag = 100;
		loadingView.tag = 101;

		
		[subanimationView addSubview:picImageView];
		[subanimationView addSubview:loadingView];
		[animationView addSubview:subanimationView];
		
		
		[subanimationView release];
		[picImageView release];
		[loadingView release];
	}
	
}

-(void)initAnimationView
{
	if ([Util isPhone]){		
		animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0,44.0,((IS_IPHONE_5)?568:480),210.0)];
	}
	else		
		animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0,50.0,540.0,530.0)];
	
	
	animationView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:animationView];
	[animationView release];
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

#pragma mark -
#pragma mark private

-(void)searchPicture
{
	[self cleanViews];
    
	if (imageServerMode==serverModeFlickr) {
		[[FDefinitionController sharedDefinitionWithDelegate:self] getFlickerForTerm:term forPage:page];
	}else {
		
		if ([Util isPhone]) {
//			[[FDefinitionController sharedDefinitionWithDelegate:self] getBingForTerm:term forImageNum:5*((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand)];
            
          
            [[FDefinitionController sharedDefinitionWithDelegate:self] getBingForTerm:term forImageNum:imagesCount];//changed sanjeev reddy for passing images count
       

		}else {

			[[FDefinitionController sharedDefinitionWithDelegate:self] getBingForTerm:term forImageNum:5*kPicperPage];
      
		}

	}
	
}

-(void)cleanViews
{
    

	if (isFirstSearch) {
		nextButton.enabled = YES;
        
		prevButton.enabled = NO;
	}else {
    //if (page<=1) {
		//	prevButton.enabled = NO;
      //}else {
		//	prevButton.enabled = YES;
		//}
		//if (page>=allpages) {
       // nextButton.enabled = NO;
		//}else {
//			nextButton.enabled = YES;
		//}
    }
	
	int picPerPage;
	
	if ([Util isPhone]) {
		picPerPage = ((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
	}else {
		picPerPage = kPicperPage;
	}

		
	for (int i=0;i<picPerPage;i++) {
		UIView *subView = (UIView*)[animationView viewWithTag:i+1];
		if (subView) {
			subView.userInteractionEnabled = NO;
			UIImageView *picImageView = (UIImageView*)[subView viewWithTag:100];
			FILoadingView *loadingView = (FILoadingView*)[subView viewWithTag:101];
			
			if (picImageView) 
			{
				picImageView.backgroundColor = [UIColor whiteColor];
				picImageView.image = nil;
			}
			
			
			
			if (loadingView) {
				loadingView.hidden = NO;
				loadingView.indicator.hidden = NO;
				[loadingView.indicator startAnimating];
			}
		}
	}
}

-(void)bingDownloadForCurrentPage
{
	[self cleanViews];
	
	if (pictureArray) {
		[pictureArray release];
	}
	
	pictureArray = [[NSMutableArray alloc] init];
	
	int picPerPage;
	if ([Util isPhone]) {
		picPerPage = ((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
	}else {
		picPerPage = kPicperPage;
	}

		
	if (picturesInfoArr) {
		SDWebImageManager *manager = [SDWebImageManager sharedManager];
		for (int i=0;i<picPerPage;i++) {
			NSDictionary *imageInfo = [picturesInfoArr objectAtIndex:picPerPage*(page-1)+i];
			if (imageInfo) {
				NSString *urlStr = [imageInfo objectForKey:@"url"];
				NSURL *url = [NSURL URLWithString:urlStr];
             
     		UIImage *cachedImage = [manager imageWithURL:url];
				if (cachedImage) {
					int tag = [pictureArray count];
					[pictureArray addObject:cachedImage];
					[self updateViewForTag:tag];
				}else {
					[manager downloadWithURL:url delegate:self];
				}
			}
		}
	}
}

-(void)updateViews
{
	if (pictureArray) {
		int n = [pictureArray count];
		
		int picPerPage;
		if ([Util isPhone]) {
			picPerPage = ((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
		}else {
			picPerPage = kPicperPage;
		}

				
		
		for (int i=0;i<picPerPage;i++) {
			if (i<n) {
				UIView *subView = (UIView*)[animationView viewWithTag:i+1];
				
				if (subView) {
					subView.userInteractionEnabled = YES;
					UIImageView *picImageView = (UIImageView*)[subView viewWithTag:100];
					FILoadingView *loadingView = (FILoadingView*)[subView viewWithTag:101];
				
					if (picImageView && loadingView) {
						[loadingView.indicator stopAnimating];
						picImageView.backgroundColor = [UIColor clearColor];
						picImageView.alpha = 0.0;
						loadingView.hidden = YES;
						
						UIImage *image;
						
						if (imageServerMode == serverModeFlickr) {
							image = [pictureArray objectAtIndex:2*i+1];
						}else {
							image = [pictureArray objectAtIndex:i];
						}

											
						[UIView beginAnimations:nil context:nil];
						[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
						[UIView setAnimationDuration:0.5];
				

						picImageView.image = image;
						picImageView.alpha = 1.0;
								
						[UIView commitAnimations];
					}
				}
			}
		}
	}
}

-(void)updateViewForTag:(NSInteger)tag
{
	int picPerPage;
	if ([Util isPhone]) {
		picPerPage = ((IS_IPHONE_5)?kPicperPageLandiPhone5:kPicperPageLand);
	}else {
		picPerPage = kPicperPage;
	}

	
	if (tag>picPerPage || tag<0) {
		return;
	}
	
	UIView *subView = (UIView*)[animationView viewWithTag:tag+1];
	
	if (subView) {
		subView.userInteractionEnabled = YES;
		UIImageView *picImageView = (UIImageView*)[subView viewWithTag:100];
		picImageView.backgroundColor = [UIColor clearColor];
			FILoadingView *loadingView = (FILoadingView*)[subView viewWithTag:101];
	
		if (picImageView && loadingView) {
			[loadingView.indicator stopAnimating];
			loadingView.hidden = YES;
			picImageView.alpha = 0.0;
			UIImage *image;
			
			if (imageServerMode == serverModeFlickr) {
				image = [pictureArray objectAtIndex:2*tag+1];
			}else {
				image = [pictureArray objectAtIndex:tag];
			}
			
			image = [self generateTumbnailImage:image];
            picImageView.contentMode = UIViewContentModeScaleAspectFit;
			
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.5];
			
			picImageView.image = image;
			picImageView.alpha = 1.0;
			
			[UIView commitAnimations];
		}
		
	}
	
}

-(UIImage*)generateTumbnailImage:(UIImage*)fromImage
{
	if (fromImage) {
		CGSize frSize;
		if ([Util isPhone])
		{
			frSize.width = kScaleConstIPhone*[UIScreen mainScreen].scale;
			frSize.height = kScaleConstIPhone*[UIScreen mainScreen].scale;
		}else {
			frSize.width = kScaleConstIPad*[UIScreen mainScreen].scale;
			frSize.height = kScaleConstIPad*[UIScreen mainScreen].scale;
		}
		UIImage *tumbImage = [Util createImageWithSize:frSize withImage:fromImage];
		return tumbImage;
	}else {
		return nil;
	}

}

-(UIImage*)generateReturnImage:(UIImage*)fromImage
{
	if (fromImage) {
		CGSize frSize;
		if ([Util isPhone])
		{
			if (fromImage.size.width>kScaleConstIPhone || fromImage.size.height>kScaleConstIPhone) {
				CGFloat maxSide = fromImage.size.width>fromImage.size.height ? fromImage.size.width : fromImage.size.height;
				frSize.width = fromImage.size.width*[UIScreen mainScreen].scale*kScaleConstIPhone/maxSide;
				frSize.height = fromImage.size.height*[UIScreen mainScreen].scale*kScaleConstIPhone/maxSide;
			}else {
				frSize.width = fromImage.size.width;
				frSize.height = fromImage.size.height;
			}

		}else {
			if (fromImage.size.width>kScaleConstIPad || fromImage.size.height>kScaleConstIPad) {
				CGFloat maxSide = fromImage.size.width>fromImage.size.height ? fromImage.size.width : fromImage.size.height;
				frSize.width = fromImage.size.width*[UIScreen mainScreen].scale*kScaleConstIPad/maxSide;
				frSize.height = fromImage.size.height*[UIScreen mainScreen].scale*kScaleConstIPad/maxSide;
			}else {
				frSize.width = fromImage.size.width;
				frSize.height = fromImage.size.height;
			}
		}
		UIImage *tumbImage = [Util createImageWithSize:frSize withImage:fromImage];
		return tumbImage;
	}else {
		return nil;
	}
}


#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
    
    
	if (term) {
		[term release];
	}
	
	if (pictureArray) {
		[pictureArray release];
	}
	
	if (picturesInfoArr) {
		[picturesInfoArr release];
	}
	
	if (imagePickerPopover) {
		[imagePickerPopover release];
	}
	
	if (currentImage) {
		[currentImage release];
	}
	
	if (delegate) {
		delegate = nil;
	}
	
	if (imageForDelegate) {
		[imageForDelegate release];
	}
	
    [super dealloc];
}


@end
