    //
//  FITemplateViewController.m
//  flashCards
//
//  Created by Ruslan on 7/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FITemplateViewController.h"
#import "FICardView.h"
#import "FRootConstants.h"
#import "Util.h"
#import "Constant.h"
#define kScrollPageNum 3

@interface FITemplateViewController(Private)

#pragma mark init
-(void)initTopBar;
-(void)initBottomBar;
-(void)initScrollView;
-(void)initPageControl;
-(void)loadViewScrollView;

#pragma mark targets
-(void)cancelButtonPressed:(id)sender;
-(void)createSetButtonPressed:(id)sender;
-(void)imageIphoneButtonPressed:(id)sender;
-(void)soundIphoneButtonPressed:(id)sender;

#pragma mark private
-(void)translateTemplate:(NSMutableArray*)template;
-(void)definitionTemplate:(NSMutableArray*)template;
-(void)customTemplate:(NSMutableArray*)template;
-(void)setButtonForSide;
-(void)updatePageControl;
-(void)updateCurrentScrollPage;
-(void)updateIphoneButtons;

@end


@implementation FITemplateViewController
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView;
	
	contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];

	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight	|
	UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	[contentView release];
	
	UIImageView *bgView = [[UIImageView alloc] initWithImage:[Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90]];
    bgView.frame = CGRectMake(0,0,((IS_IPHONE_5)?568:480),320);
	[self.view addSubview:bgView];
	[bgView release];
	
	_templateContents = [[NSMutableArray alloc] init];
	[self translateTemplate:_templateContents];
	[self definitionTemplate:_templateContents];
	[self customTemplate:_templateContents];
	[self initScrollView];
	[self initPageControl];
	
	[self initTopBar];
	[self initBottomBar];
}

-(NSArray*)templates
{
	return [NSArray arrayWithObjects:@"Traslate",@"Definition",@"Custom",nil];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape ;//|UIInterfaceOrientationMaskPortrait;
}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (![Util isPhone]) {
		if ([Util isPortraitWithOrientation:interfaceOrientation]) {
			_navBar.frame = CGRectMake(0,0,768,44);
		}else {
			_navBar.frame = CGRectMake(0,0,1024,44);
		}
	}
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
	
	if (_templateContents) {
		[_templateContents release];
	}
	
	[super dealloc];
}

#pragma mark main methods ends

#pragma mark -
#pragma mark UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = _templateScrollView.frame.size.width;
	CGFloat offsetX = _templateScrollView.contentOffset.x;
	NSInteger page = floor(offsetX/pageWidth);
	_currentPage = page;
	
	[self updatePageControl];
	[self updateIphoneButtons];
	
}

#pragma mark -


#pragma mark -
#pragma mark targets

-(void)cancelButtonPressed:(id)sender
{
    if ([Util isPhone]) {
       [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"restorePopover"
															object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
	
}

-(void)createSetButtonPressed:(id)sender
{
	if (delegate && [delegate respondsToSelector:@selector(createCategory:)]) {
		NSMutableDictionary *templateDic;
		templateDic = [_templateContents objectAtIndex:_currentPage];
		NSInteger options = [[templateDic objectForKey:@"options"] intValue];
		[delegate createCategory:options];
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


-(void)imageIphoneButtonPressed:(id)sender{
	NSMutableDictionary *templateDic = [_templateContents objectAtIndex:_currentPage];
	NSInteger options = [[templateDic objectForKey:@"options"] intValue];
		
	if (kt_isBothPic(options)) {
		options = options^kFrontPicTemplate;
		options = options^kBackPicTemplate;
		[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	}else {
		options = options | kFrontPicTemplate;
		options = options | kBackPicTemplate;
		[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	}
	
	[_templateContents replaceObjectAtIndex:_currentPage withObject:templateDic];
	[self updateIphoneButtons];
	[self updateCurrentScrollPage];

}

-(void)soundIphoneButtonPressed:(id)sender{
	NSMutableDictionary *templateDic = [_templateContents objectAtIndex:_currentPage];
	NSInteger options = [[templateDic objectForKey:@"options"] intValue];
	
	if (kt_isBothAudio(options)) {
		options = options^kFrontAudioTemplate;
		options = options^kBackAudioTemplate;
        options = options^kAudioTemplate;
		[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	}else {
		options = options | kFrontAudioTemplate;;
		options = options | kBackAudioTemplate;
        options = options | kAudioTemplate;
		[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	}
	
	[_templateContents replaceObjectAtIndex:_currentPage withObject:templateDic];
	[self updateIphoneButtons];
	[self updateCurrentScrollPage];
}

#pragma mark targets ends

#pragma mark -
#pragma mark init

-(void)initTopBar
{
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,37)];
        }
        else{
            _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,37)];
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
            _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,37)];
        }
        else{
            _navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,37)];
        }
    }
    _navBar.tintColor = [UIColor blackColor];
	_navBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
    
    
	[self.view addSubview:_navBar];
	[_navBar release];
	
	_barTopItem = [[UINavigationItem alloc] initWithTitle:@"Templates"];
    
	[_navBar pushNavigationItem:_barTopItem animated:NO];
	[_barTopItem release];
	
	UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *customCancelImage = [UIImage imageNamed:@"i_panel_cancel1.png"];
	customCancelButton.frame = CGRectMake(0,0,customCancelImage.size.width,customCancelImage.size.height);
	[customCancelButton setImage:customCancelImage forState:UIControlStateNormal];
	[customCancelButton setImage:[UIImage imageNamed:@"i_panel_cancel2.png"] forState:UIControlStateHighlighted];
	[customCancelButton addTarget:self
						   action:@selector(cancelButtonPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithCustomView:customCancelButton];
	_barTopItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	UIButton *createSetCustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *createSetCustomImage = [UIImage imageNamed:@"i_panel_create_set1.png"];
	createSetCustomButton.frame = CGRectMake(0,0,createSetCustomImage.size.width,createSetCustomImage.size.height);
	[createSetCustomButton setImage:createSetCustomImage forState:UIControlStateNormal];
	[createSetCustomButton setImage:[UIImage imageNamed:@"i_panel_create_set2.png"] forState:UIControlStateHighlighted];
	[createSetCustomButton addTarget:self
							  action:@selector(createSetButtonPressed:)
					forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *createSetButton = [[UIBarButtonItem alloc] initWithCustomView:createSetCustomButton];
	_barTopItem.rightBarButtonItem = createSetButton;
	[createSetButton release];
	
}

-(void)initBottomBar
{

    _imageIphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *imageIphoneImage = [UIImage imageNamed:@"i_create_image1.png"];
	_imageIphoneButton.frame = CGRectMake(((IS_IPHONE_5)?279:235)-imageIphoneImage.size.width,
										  300-imageIphoneImage.size.height,
										  imageIphoneImage.size.width,
										  imageIphoneImage.size.height);
	[_imageIphoneButton setImage:imageIphoneImage forState:UIControlStateNormal];
	[_imageIphoneButton setImage:[UIImage imageNamed:@"i_create_image2.png"] forState:UIControlStateHighlighted];
	[_imageIphoneButton addTarget:self
						   action:@selector(imageIphoneButtonPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_imageIphoneButton];
		
	_soundIphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *soundIphoneImage = [UIImage imageNamed:@"i_create_sound1.png"];
	_soundIphoneButton.frame = CGRectMake(((IS_IPHONE_5)?289:245),300-soundIphoneImage.size.height,soundIphoneImage.size.width,soundIphoneImage.size.height);
	[_soundIphoneButton setImage:soundIphoneImage forState:UIControlStateNormal];
	[_soundIphoneButton setImage:[UIImage imageNamed:@"i_create_sound2.png"] forState:UIControlStateHighlighted];
	[_soundIphoneButton addTarget:self
						   action:@selector(soundIphoneButtonPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_soundIphoneButton];
	

}

-(void)initScrollView{
	_templateScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),245-_imageIphoneButton.frame.size.height)];
	_templateScrollView.delegate = self;
	_templateScrollView.showsVerticalScrollIndicator = NO;
	_templateScrollView.showsHorizontalScrollIndicator = NO;
	_templateScrollView.pagingEnabled = YES;
	_templateScrollView.directionalLockEnabled = YES;
	_templateScrollView.contentSize = CGSizeMake(kScrollPageNum*((IS_IPHONE_5)?568:480),245-_imageIphoneButton.frame.size.height);
	[self.view addSubview:_templateScrollView];
	[_templateScrollView release];
	[self loadViewScrollView];
	_currentPage = 0;
}

-(void)initPageControl{
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(((IS_IPHONE_5)?244:200),215,80,20)];
	_pageControl.userInteractionEnabled = NO;
	_pageControl.numberOfPages = kScrollPageNum;
	[self.view addSubview:_pageControl];
	[_pageControl release];
	[self updatePageControl];
}

-(void)loadViewScrollView{
	
	CGFloat curX = 10;
	
	for (int i=0; i<kScrollPageNum; i++) {
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*((IS_IPHONE_5)?568:480), -3, ((IS_IPHONE_5)?568:480), 36)];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textColor = [UIColor colorWithRed:104.0/255.0 green:56.0/255.0 blue:12.0/255.0 alpha:1.0];
		titleLabel.shadowOffset = CGSizeMake(0.0,1.0);
		titleLabel.shadowColor = [UIColor whiteColor];
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.font = [UIFont fontWithName:@"Helvetica" size:21];
		[_templateScrollView addSubview:titleLabel];
		[titleLabel release];
		
		UIImageView *frontSide = [[UIImageView alloc] initWithFrame:CGRectMake(curX, 30, ((IS_IPHONE_5)?274:230), 153)];
		[_templateScrollView addSubview:frontSide];
		frontSide.tag = (i+1)*100;
		[frontSide release];
		
		UIImageView *backSide = [[UIImageView alloc] initWithFrame:CGRectMake((i+1)*((IS_IPHONE_5)?568:480)-((IS_IPHONE_5)?284:240), 30, ((IS_IPHONE_5)?274:230), 153)];
		backSide.tag = (i+1)*100+1;
		[_templateScrollView addSubview:backSide];
		[backSide release];
		
		switch (i) {
			case 0:{
				titleLabel.text = @"Translate";
				frontSide.image = [UIImage imageNamed:@"i_create_term1.png"];
				backSide.image = [UIImage imageNamed:@"i_create_trans1.png"];
				break;
			}
			case 1:{
				titleLabel.text = @"Definition";
				frontSide.image = [UIImage imageNamed:@"i_create_term1.png"];
				backSide.image = [UIImage imageNamed:@"i_create_def1.png"];
				break;
			}
			case 2:{
				titleLabel.text = @"Custom";
				frontSide.image = [UIImage imageNamed:@"i_create_term3.png"];
				backSide.image = [UIImage imageNamed:@"i_create_def3.png"];
				break;
			}
	
			default:
				break;
		}
		
		curX+=((IS_IPHONE_5)?568:480);
	}
}

#pragma mark init ends
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark private

-(void)translateTemplate:(NSMutableArray*)template
{
	NSInteger options = kFrontTextTemplate | kBackTextTemplate | kTranslateTemplate | kWebTemplate;
	NSMutableDictionary *templateDic = [NSMutableDictionary dictionary];
	[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	[templateDic setObject:@"Text to translate" forKey:@"question"];
	[templateDic setObject:@"Translated text" forKey:@"answer"];
	[templateDic setObject:[NSNumber numberWithBool:YES] forKey:@"side"];
	[template addObject:templateDic];
}

-(void)definitionTemplate:(NSMutableArray*)template
{
	NSInteger options = kFrontTextTemplate | kBackTextTemplate | kDefinitionTemplate | kWebTemplate;
	NSMutableDictionary *templateDic = [NSMutableDictionary dictionary];
	[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	[templateDic setObject:@"Term" forKey:@"question"];
	[templateDic setObject:@"Definition" forKey:@"answer"];
	[templateDic setObject:[NSNumber numberWithBool:YES] forKey:@"side"];
	[template addObject:templateDic];
}

-(void)customTemplate:(NSMutableArray*)template
{
	NSInteger options = kCustomTemplate;
	NSMutableDictionary *templateDic = [NSMutableDictionary dictionary];
	[templateDic setObject:[NSNumber numberWithInt:options] forKey:@"options"];
	[templateDic setObject:@"Term" forKey:@"question"];
	[templateDic setObject:@"Definition" forKey:@"answer"];
	[templateDic setObject:[UIImage imageNamed:@"icon.png"] forKey:@"qImage"];
	[templateDic setObject:[UIImage imageNamed:@"icon.png"] forKey:@"aImage"];
	[templateDic setObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BoxIn" ofType:@"caf"]] forKey:@"qSound"];
	[templateDic setObject:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"BoxIn" ofType:@"caf"]] forKey:@"aSound"];
	[templateDic setObject:[NSNumber numberWithBool:YES] forKey:@"side"];
	[template addObject:templateDic];
}

-(void)setButtonForSide
{
	NSMutableDictionary *templateDic = [_templateContents objectAtIndex:_templatePath.row];
	NSInteger options = [[templateDic objectForKey:@"options"] intValue];
	BOOL side = [[templateDic objectForKey:@"side"] boolValue];
	
	if (side) {
		if (kt_isFrontPic(options)) {
			_imageButton.style = UIBarButtonItemStyleDone;
		}else {
			_imageButton.style = UIBarButtonItemStyleBordered;
		}
		if (kt_isFrontAudio(options)) {
			_soundButton.style = UIBarButtonItemStyleDone;
		}else {
			_soundButton.style = UIBarButtonItemStyleBordered;
		}
		_sideButton.title = @"Back side";
	}else {
		if (kt_isBackPic(options)) {
			_imageButton.style = UIBarButtonItemStyleDone;
		}else {
			_imageButton.style = UIBarButtonItemStyleBordered;
		}
		if (kt_isBackAudio(options)) {
			_soundButton.style = UIBarButtonItemStyleDone;
		}else {
			_soundButton.style = UIBarButtonItemStyleBordered;
		}
		_sideButton.title = @"Front side";
	}
}

-(void)updatePageControl{
	_pageControl.currentPage = _currentPage;
}

-(void)updateCurrentScrollPage{
	NSMutableDictionary *templateDic = [_templateContents objectAtIndex:_currentPage];
	NSInteger options = [[templateDic objectForKey:@"options"] intValue];
	UIImageView *frontSide = (UIImageView*)[_templateScrollView viewWithTag:(_currentPage+1)*100];
	UIImageView *backSide = (UIImageView*)[_templateScrollView viewWithTag:(_currentPage+1)*100+1];
	
	if (kt_isBothAudio(options) && kt_isBothPic(options)) {
		frontSide.image = [UIImage imageNamed:@"i_create_term3.png"];
		
		if (_currentPage==1 || _currentPage==2) {
			backSide.image = [UIImage imageNamed:@"i_create_def3.png"];
		}else {
			backSide.image = [UIImage imageNamed:@"i_create_trans3.png"];
		}

	}else if (kt_isBothAudio(options)) {
		frontSide.image = [UIImage imageNamed:@"i_create_term4.png"];
		
		if (_currentPage==1 || _currentPage==2) {
			backSide.image = [UIImage imageNamed:@"i_create_def4.png"];
		}else {
			backSide.image = [UIImage imageNamed:@"i_create_trans4.png"];
		}
		
	}else if (kt_isBothPic(options)) {
		frontSide.image = [UIImage imageNamed:@"i_create_term2.png"];
		
		if (_currentPage==1 || _currentPage==2) {
			backSide.image = [UIImage imageNamed:@"i_create_def2.png"];
		}else {
			backSide.image = [UIImage imageNamed:@"i_create_trans2.png"];
		}		
	}else {
		frontSide.image = [UIImage imageNamed:@"i_create_term1.png"];
		
		if (_currentPage==1 || _currentPage==2) {
			backSide.image = [UIImage imageNamed:@"i_create_def1.png"];
		}else {
			backSide.image = [UIImage imageNamed:@"i_create_trans1.png"];
		}
	}


	

}

-(void)updateIphoneButtons{
    if (_templateContents.count>=_currentPage) { //added condition by sanjeev reddy to avoid crash when swiping options

	NSMutableDictionary *templateDic = [_templateContents objectAtIndex:_currentPage];
	NSInteger options = [[templateDic objectForKey:@"options"] intValue];
	
	if (kt_isBothAudio(options)) {
		[_soundIphoneButton setImage:[UIImage imageNamed:@"i_create_sound3.png"] forState:UIControlStateNormal];
		[_soundIphoneButton setImage:[UIImage imageNamed:@"i_create_sound4.png"] forState:UIControlStateHighlighted];
	}else {
		[_soundIphoneButton setImage:[UIImage imageNamed:@"i_create_sound1.png"] forState:UIControlStateNormal];
		[_soundIphoneButton setImage:[UIImage imageNamed:@"i_create_sound2.png"] forState:UIControlStateHighlighted];
	}
	
	if (kt_isBothPic(options)) {
		[_imageIphoneButton setImage:[UIImage imageNamed:@"i_create_image3.png"] forState:UIControlStateNormal];
		[_imageIphoneButton setImage:[UIImage imageNamed:@"i_create_image4.png"] forState:UIControlStateHighlighted];
	}else {
		[_imageIphoneButton setImage:[UIImage imageNamed:@"i_create_image1.png"] forState:UIControlStateNormal];
		[_imageIphoneButton setImage:[UIImage imageNamed:@"i_create_image2.png"] forState:UIControlStateHighlighted];
	}
    }

}

#pragma mark private ends



@end
