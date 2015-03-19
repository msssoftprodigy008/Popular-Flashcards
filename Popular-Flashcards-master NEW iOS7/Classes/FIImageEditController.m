    //
//  FIImageEditController.m
//  flashCards
//
//  Created by Ruslan on 7/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIImageEditController.h"
#import "Util.h"
#import "Constant.h"
@interface FIImageEditController(Private)

#pragma mark init
-(void)initTopBar;

#pragma mark targets
-(void)backButtonPressed:(id)sender;
-(void)deleteButtonPressed:(id)sender;
-(void)tap;

#pragma mark private
-(void)showNavBar;
-(void)hideNavBar;



@end


@implementation FIImageEditController
@synthesize delegate;

#pragma mark -
#pragma mark main methods

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

-(id)initWithImage:(UIImage*)image{
	if (image) {
		_image = [[UIImage alloc] initWithCGImage:image.CGImage];
	}
	
	return [self init];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
	self.view = contentView;
	[contentView release];
	
	self.view.backgroundColor = [UIColor whiteColor];
    if ([Util isPhone]) {
        UITapGestureRecognizer *tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self
																			   action:@selector(tap)];
        [self.view addGestureRecognizer:tapRecog];
        tapRecog.delegate = self;
        [tapRecog release];
    }
	
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),320)];
        }
        else{
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
        }
        
    }
    else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
           _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),320)];
        }
        else{
            _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
        }
        
        
    }

	
	_imageView.contentMode = UIViewContentModeScaleAspectFit;
	if (_image) {
		_imageView.image = _image;
	}
	[self.view addSubview:_imageView];
	[_imageView release];
	
	[self initTopBar];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (![Util isPhone]) {
      [[NSNotificationCenter defaultCenter] postNotificationName:@"restorePopover" object:nil];
    }  
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	isPanelHidden = NO;
	_navShowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
													 target:self
												   selector:@selector(hideNavBar)
												   userInfo:nil
													repeats:NO];
}




// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


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
	
	if (_image) {
		[_image release];
	}
	
	if (_navShowTimer && [_navShowTimer isValid]) {
		[_navShowTimer invalidate];
		_navShowTimer = nil;
	}
	
    [super dealloc];
}

#pragma mark -

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex]) {
		if (_image) {
			[_image release];
			_image = nil;
			_imageView.image = nil;
		}
		
		if (delegate && [delegate respondsToSelector:@selector(imageWasDeleted)]) {
			[delegate imageWasDeleted];
		}
		
		[self performSelector:@selector(backButtonPressed:)
				   withObject:nil
				   afterDelay:0.25f];
	}
}

#pragma mark -

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
	if ([touch.view isDescendantOfView:_navBar]) {
		return NO;
	}
	
	return YES;
}

#pragma mark -


#pragma mark -
#pragma mark private

-(void)initTopBar{
    if ([Util isPhone]) {
        
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                    _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0,((IS_IPHONE_5)?568:480),48.0)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0,((IS_IPHONE_5)?568:480),48.0)];
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
                    _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0,((IS_IPHONE_5)?568:480),48.0)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0,((IS_IPHONE_5)?568:480),48.0)];
                }
                
            }
            else{
                
            }
        }
        _navBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];

	
        [self.view addSubview:_navBar];
        [_navBar release];
	
        UINavigationItem *barItem = [[UINavigationItem alloc] initWithTitle:@"Image"];
        [_navBar pushNavigationItem:barItem animated:NO];
        [barItem release];
	
	
        UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *customButtonImage = [UIImage imageNamed:@"i_panel_back1.png"];
        backButtonCustom.frame = CGRectMake(0,0,customButtonImage.size.width,customButtonImage.size.height);
        [backButtonCustom setImage:customButtonImage forState:UIControlStateNormal];
        [backButtonCustom setImage:[UIImage imageNamed:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
        [backButtonCustom addTarget:self
                             action:@selector(backButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
		
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
        barItem.leftBarButtonItem = backButton;
        [backButton release];
    
        UIButton *deleteButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *customDeleteImage = [UIImage imageNamed:@"i_panel_delete1.png"];
        deleteButtonCustom.frame = CGRectMake(0, 0, customDeleteImage.size.width, customDeleteImage.size.height);
        [deleteButtonCustom setImage:customDeleteImage forState:UIControlStateNormal];
        [deleteButtonCustom setImage:[UIImage imageNamed:@"i_panel_delete2.png"] forState:UIControlStateHighlighted];
        [deleteButtonCustom addTarget:self
                               action:@selector(deleteButtonPressed:)
                     forControlEvents:UIControlEventTouchUpInside];
    	
        _deleteButton = [[UIBarButtonItem alloc] initWithCustomView:deleteButtonCustom];
        barItem.rightBarButtonItem = _deleteButton;
        [_deleteButton release];
	
        if (!_image) {
            _deleteButton.enabled = NO;
        }
    }else{
        self.navigationItem.title = @"Image";
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                      target:self
                                                                                      action:@selector(deleteButtonPressed:)];
        self.navigationItem.rightBarButtonItem = deleteButton;
        [deleteButton release];
        
        if (!_image) {
            deleteButton.enabled = NO;
        }
    }
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

#pragma mark -
#pragma mark targets

-(void)backButtonPressed:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)tap{
	if (_navShowTimer && [_navShowTimer isValid]) {
		[_navShowTimer invalidate];
		_navShowTimer = nil;
	}
	
	if (isPanelHidden) {
		[self showNavBar];
	}else {
		[self hideNavBar];
	}

}

-(void)deleteButtonPressed:(id)sender{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete"
													message:@"Are you sure you want to delete this image?"
												   delegate:self
										  cancelButtonTitle:@"NO"
										  otherButtonTitles:@"YES",nil];
	alert.delegate = self;
	[alert show];
	[alert release];
}

#pragma mark -

#pragma mark -
#pragma mark private

-(void)showNavBar{
	[UIView beginAnimations:nil context:nil];
	
	_navBar.center = CGPointMake(((IS_IPHONE_5)?284:240),20);

	[UIView commitAnimations];
	
	isPanelHidden = NO;
	
	_navShowTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self
								   selector:@selector(hideNavBar)
								   userInfo:nil
									repeats:NO];
}

-(void)hideNavBar{
	_navShowTimer = nil;
	[UIView beginAnimations:nil context:nil];
	
	_navBar.center = CGPointMake(((IS_IPHONE_5)?284:240),-40);
	
	[UIView commitAnimations];
	
	isPanelHidden = YES;
}

#pragma mark -


@end
