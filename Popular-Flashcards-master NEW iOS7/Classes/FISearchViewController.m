//
//  FISearchViewController.m
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HTMLParser.h"
#import "Constant.h"

#import "FIAnimationController.h"
#import "Util.h"


@interface FISearchViewController(Private)

//init
-(void)initTopBar;
-(void)initTopBarIpad;
-(void)initBottomBar;

//targets
-(void)saveImagesPressed:(id)sender;
-(void)saveHTMLasText:(id)sender;
-(void)webViewBack:(id)sender;
-(void)segmentChanged:(id)sender;
-(void)addToCard:(id)sender;
-(void)doneButtonPressed:(id)sender;
-(void)switchToMainMenu:(id)sender;
-(void)switchToSecondMenu:(id)sender;

//notifications
-(void)replaceMenu:(id)sender;

-(void)pastePressed;
-(void)getUrlsForImage;
-(void)loadChooseImages;
-(NSString*)lanCodeForStr:(NSString*)lang;
-(void)backPressed;

@end

@implementation FISearchViewController
@synthesize MyDelegate;
@synthesize orientation;
@synthesize isImageDownloadingAvailable;
@synthesize set;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(id)initWithDelegateAndSearchStr:(NSString*)SStr;
{
	if (SStr) {
		searchStr = [[NSString alloc] initWithString:[SStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	
	return [self init];
}
- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        if ([Util isPhone]) {
            if (IS_IPHONE_5) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    contentView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,568,320)];//iphone 5c
                }
                else{
                    contentView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,568,300)];
                }
                
            }
            else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    contentView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,480,320)];
                }
                else{
                    contentView	= [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
                }
            }
        }
    }
	else
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,540.0,580.0)];
    
	
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		self.view.backgroundColor = [UIColor whiteColor];
	
	[contentView release];
	
	if (![Util isPhone])
	{
		[self initTopBarIpad];
	}
    
	
	if (!webView)
	{
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
            if (IS_IPHONE_5) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,568,260)];//iphone5c
                }
                else{
                    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,568,300)];
                }
                
            }
            else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,480,320)];
                }
                else{
                    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,480,300)];
                }
            }
        }
		else {
			webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,540,535)];
		}
        
	}
	else
	{
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
            if ([Util isPhone]) {
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        webView.frame = CGRectMake(0,0,568,320);
                    }
                    else{
                        webView.frame = CGRectMake(0,0,568,300);
                    }
                    
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        webView.frame = CGRectMake(0,0,480,320);
                    }
                    else{
                        webView.frame = CGRectMake(0,0,480,300);
                    }
                }
            }
        }
		else {
			webView.frame = CGRectMake(0,0,540,535);
		}
        
	}
    
	webView.backgroundColor = [UIColor clearColor];
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.delegate = self;
	[self.view addSubview:webView];
    
	menuLockFlag = NO;
	customMenu = [UIMenuController sharedMenuController];
	UIMenuItem *addToCard = [[UIMenuItem alloc] initWithTitle:@"Add to Card" action:@selector(addToCardPressed:)];
	[customMenu setMenuItems:[NSArray arrayWithObject:addToCard]];
	[addToCard release];
	
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/search?Agent=Iphone&q=%@",searchStr]]]];
	
	isSearch = YES;
	isMainPanel = YES;
	
	[self initBottomBar];
}

-(void)cancelDownload
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	
}



/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		return YES;
	}else {
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (webView) {
		[webView stopLoading];
	}
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)AwebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)AwebView
{
	// starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	if (isImageDownloadingAvailable) {
        
		if (saveImageButton) {
			saveImageButton.enabled = NO;
		}
		
	}
	
}

- (void)webViewDidFinishLoad:(UIWebView *)AwebView
{
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self getUrlsForImage];
    
    ////////////////////////////////////////// changed by sanjeev reddy for web to fit in view(ipad)
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.minimumZoomScale = rw;
    webView.scrollView.maximumZoomScale = rw;
    webView.scrollView.zoomScale = rw;
    ///////////////////////////////////////

    
	if (isImageDownloadingAvailable) {
		
		if (urls && [urls count]>0) {
			if (saveImageButton) {
				saveImageButton.enabled = YES;
			}
		}
		
	}
	
    
}
//#pragma mark -
//#pragma mark - UIScrollView Delegate Methods
//
//- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
//{
//    webView.scrollView.maximumZoomScale = 20; // set similar to previous.
//}

- (void)webView:(UIWebView *)AwebView didFailLoadWithError:(NSError *)error
{
	if ([error code]!=NSURLErrorCancelled) {
		// load error, hide the activity indicator in the status bar
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
		// report the error inside the webview
		NSString* errorString = [NSString stringWithFormat:
								 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
								 error.localizedDescription];
		[AwebView loadHTMLString:errorString baseURL:nil];
		
	}
}

#pragma mark -
#pragma mark FSettingsTemplateDelegate methods

-(void)selectedImage:(UIImage*)image
{
	if (image) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		[dic setObject:image forKey:@"image"];
		if (MyDelegate && [MyDelegate respondsToSelector:@selector(someDataToSave:)])
			[MyDelegate someDataToSave:dic];
	}
}

-(void)selectedItemWithImage:(UIImage*)image
{
	if (image) {
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		[dic setObject:image forKey:@"image"];
		if (MyDelegate && [MyDelegate respondsToSelector:@selector(someDataToSave:)])
			[MyDelegate someDataToSave:dic];
	}
}

#pragma mark -
#pragma mark FDownload delegate methods
-(void)downloadedDataRecived:(NSData*)downloadedData
{
	if (downloadedData) {
		
		UIImage *image = [UIImage imageWithData:downloadedData];
		[allImages addObject:image];
		currVal++;
		[progressView setCurVal:currVal];
		[downloadedData release];
	}
}

-(void)downloadingFinished:(BOOL)result
{
	NSString *message;
	if (result) {
		[self loadChooseImages];
	}
	else {
		message = @"Getting image failed";
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	
	[progressView dissmis];
	NSLog(@"%d",[allImages count]);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark FIndicatorView delegate

-(void)cancelButtonPressed
{
	[self cancelDownload];
	[progressView dissmis];
	[progressView release];
	progressView = nil;
}

#pragma mark -
#pragma mark targets

-(void)saveImagesPressed:(id)sender
{
	if (urls && [urls count]>0) {
		
		if (allImages) {
			[allImages release];
		}
		
		if (titles) {
			[titles release];
		}
		
		allImages = [[NSMutableArray alloc] init];
		titles = [[NSMutableArray alloc] init];
		
		NSMutableArray *arrTodownload = [NSMutableArray array];
		
		for (NSString *contentStr in urls) {
			
			NSArray *tempArr1 = [contentStr componentsSeparatedByString:@"(^|^)"];
			
			if (tempArr1 && [tempArr1 count]>0) {
				NSString *pathStr = [tempArr1 objectAtIndex:0];
				[arrTodownload addObject:[tempArr1 objectAtIndex:0]];
				
				pathStr = [pathStr lastPathComponent];
				
				if ([tempArr1 count]>1) {
					NSString *temp2Str = [tempArr1 objectAtIndex:1];
					[titles addObject:[NSArray arrayWithObjects:pathStr,temp2Str,nil]];
				}
				else {
					[titles addObject:[NSArray arrayWithObjects:pathStr,@" ",nil]];
				}
			}
			
			
		}
		
		[[FDownLoader sharedDownloader:nil] cancelDownloading];
		[[FDownLoader sharedDownloader:self] download:arrTodownload];
		
		if (!progressView) {
			if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
            {
				progressView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,212,480,44)];
    
            }
			else {
				progressView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,492,540,40)];
			}
            
		}
		
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			progressView.progressView.frame = CGRectMake(5,17,380,10);
			progressView.cancelButton.center = CGPointMake(410,22);
			progressView.progressViewLabel.frame = CGRectMake(445,6,50,30);
		}else // changed progress position for ipad tto centre sanjeev redddy
        {
            progressView.progressView.frame = CGRectMake(5,17,380,10);
            progressView.cancelButton.center = CGPointMake(415,22);
            progressView.progressViewLabel.frame = CGRectMake(445,6,50,30);
        
        }
        
		
		[progressView setImportLen:[urls count]];
		progressView.delegate = self;
		[progressView setCurVal:0];
		currVal = 0;
		[progressView showInView:self.view];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

-(void)segmentChanged:(id)sender
{
	UISegmentedControl *segment = (UISegmentedControl*)sender;
	
	[webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	switch (segment.selectedSegmentIndex) {
		case 0:
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://en.m.wikipedia.org/wiki/%@",searchStr]]]];
			break;
		case 1:{
            if (set) {
                NSArray *langArr = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_lang",set]];
                NSString *urlStr = [NSString stringWithFormat:@"http://translate.google.com/?text=%@",searchStr];
                if (langArr && [langArr count]>0) {
                    NSString *code = [self lanCodeForStr:[langArr objectAtIndex:0]];
                    if (code) {
                        urlStr = [urlStr stringByAppendingFormat:@"&hl=%@",code];
                    }
                    
                    if ([langArr count]>1) {
                        code = [self lanCodeForStr:[langArr objectAtIndex:1]];
                        if (code) {
                            urlStr = [urlStr stringByAppendingFormat:@"&tl=%@",code];
                        }
                    }
                    
                }
                [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
            }else{
            	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://translate.google.com/?text=%@",searchStr]]]];
            }
            break;
        }
		case 2:
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.wordnik.com/words/%@",searchStr]]]];
			break;
			
		default:
			break;
	}
	
}

-(void)saveHTMLasText:(id)sender
{
	NSString* htmlString = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
	
	if (htmlString) {
		NSError *error = nil;
		HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
		HTMLNode *parsedNode = [parser body];
		NSString *parsedStr = [parsedNode allContents];
        
		[parser release];
		
		NSArray *articleArr = [parsedStr componentsSeparatedByString:@"\n"];
		NSMutableString *resultStr = [NSMutableString string];
		NSCharacterSet *filterSet = [NSCharacterSet characterSetWithCharactersInString:@"{}="];
		for (NSString *s in articleArr) {
			int slen = [s length];
			if (slen>=100) {
				NSRange range = [s rangeOfCharacterFromSet:filterSet];
				if (range.location == NSNotFound)
					[resultStr appendFormat:@"%@\n",s];
			}
			
		}
		
		[resultStr replaceOccurrencesOfString:@"\"" withString:@"'"
									  options:NSCaseInsensitiveSearch range:NSMakeRange(0,[resultStr length])];
        
		NSString *msg;
        
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		if (resultStr && [resultStr length]>0) {
			NSURL *curUrl = [webView.request URL];
			NSString *path = [curUrl absoluteString];
			if (path)
				[resultStr appendFormat:@"\n\n%@",path];
			[dic setObject:resultStr forKey:@"text"];
			if (MyDelegate && [MyDelegate respondsToSelector:@selector(someDataToSave:)]) {
				[MyDelegate someDataToSave:dic];
			}
			msg = @"Text successfuly saved";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
		}else {
            
			msg = @"No text found";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
		}
        
		
		
		
	}
}

-(void)webViewBack:(id)sender
{
	if ([webView canGoBack]) {
		[webView goBack];
	}else {
		isMainPanel = YES;
		[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://google.com/search?Agent=Iphone&q=%@",searchStr]]]];
		
	}
    
}

-(void)addToCardPressed:(id)sender
{
	NSString *selection = [webView stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	NSString *msg;
    NSString *title;
	if (selection && [selection length]>0) {
		[dic setObject:selection forKey:@"text"];
		if (MyDelegate && [MyDelegate respondsToSelector:@selector(someDataToSave:)]) {
			[MyDelegate someDataToSave:dic];
		}
        title = @"Text Added";
		msg = @"Selected text added to card";
	}else {
        title = @"No Text Selected";
		msg = @"Selection must be text. Pictures can be added from the Add Image screen.";
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:msg
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
    
	
    
	
	
    
}

-(void)doneButtonPressed:(id)sender
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)switchToMainMenu:(id)sender
{
	isMainPanel = YES;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.25f];
	[animation setType:@"oglFlip"];
	[animation setSpeed:1.0];
	
	contextMenu.hidden = YES;
	mainMenu.hidden = NO;
	
	[[animationView layer] addAnimation:animation forKey:@"push"];
}

-(void)switchToSecondMenu:(id)sender
{
	isMainPanel = NO;
	
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.25f];
	[animation setType:@"oglFlip"];
	[animation setSpeed:1.0];
   
    
	contextMenu.hidden = NO;
	mainMenu.hidden = YES;
	
	[[animationView layer] addAnimation:animation forKey:@"push"];
}


#pragma mark -

#pragma mark -
#pragma mark notifications

-(void)replaceMenu:(id)sender
{
	
    
    
}

#pragma mark -

#pragma mark -
#pragma mark private methods

-(void)initTopBar
{
    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;

	UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,50)];
	topBar.userInteractionEnabled = YES;
	topBar.image = [UIImage imageNamed:@"i_top_panel.png"];
	[self.view addSubview:topBar];
	[topBar release];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160-100,0,200,44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor colorWithRed:0.298 green:0.192 blue:0.106 alpha:1.0];
	titleLabel.shadowColor = [UIColor colorWithRed:0.647 green:0.565 blue:0.486 alpha:1.0];
	titleLabel.shadowOffset = CGSizeMake(1,1);
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	titleLabel.text = @"Search";
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5,5,59,34);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
	
    
}

-(void)initTopBarIpad
{
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(doneButtonPressed:)];
	self.navigationItem.leftBarButtonItem = doneButton;
	self.navigationItem.title = @"Search";
	[doneButton release];
}



-(void)initBottomBar
{
	//main menu
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
        if ([Util isPhone]) {
            if (IS_IPHONE_5) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    mainMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,568,48.0)];
                }
                else{
                    mainMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,568,48.0)];
                }
                
            }
            else {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    mainMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,480,48.0)];//iphone 4s 7.1 (0,20,480,48.0)
                }
                else{
                    mainMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,480,48.0)];
                }
            }
        }
		
        mainMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];
	}
	else
	{
		mainMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,0,540,48)];
      	mainMenu.tintColor = [UIColor darkGrayColor];
        mainMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];
    }
    
    if ([Util isPhone]) {
        
        NSArray *wikiArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set2_wiki1.png"],
                            [UIImage imageNamed:@"i_set2_wiki2.png"],
                            [UIImage imageNamed:@"i_set2_wiki3.png"],nil];
        
        NSArray *wiktionArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_googletr1.png"],
                               [UIImage imageNamed:@"i_googletr2.png"],
                               [UIImage imageNamed:@"i_googletr3.png"],nil];
        
        NSArray *wordnikArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set2_wordniki1.png"],
                               [UIImage imageNamed:@"i_set2_wordniki2.png"],
                               [UIImage imageNamed:@"i_set2_wordniki3.png"],nil];
        
        
        
        FCustomSegmentedController* segment = [[FCustomSegmentedController alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                                 wikiArr,
                                                                                                 wiktionArr,
                                                                                                 wordnikArr,nil                                     ]];
        
		segment.center = CGPointMake(240.0,26.0);
        UIButton *button = (UIButton*)[segment viewWithTag:301];
        CGRect frame = button.frame;
        if ([UIScreen mainScreen].scale>1) {
            frame.origin.y+=0.5;
        }
        
        button.frame = frame;
        
        [segment addTarget:self
                    action:@selector(segmentChanged:)
          forControlEvents:UIControlEventValueChanged];
		
        [mainMenu addSubview:segment];
        [segment release];
    }else{///////////////ipad
        
        NSArray *wikiArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set2_wiki1.png"],
                            [UIImage imageNamed:@"i_set2_wiki2.png"],
                            [UIImage imageNamed:@"i_set2_wiki3.png"],nil];
        
        NSArray *wiktionArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_googletr1.png"],
                               [UIImage imageNamed:@"i_googletr2.png"],
                               [UIImage imageNamed:@"i_googletr3.png"],nil];
        
        NSArray *wordnikArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set2_wordniki1.png"],
                               [UIImage imageNamed:@"i_set2_wordniki2.png"],
                               [UIImage imageNamed:@"i_set2_wordniki3.png"],nil];
        
        
        
        FCustomSegmentedController* segment = [[FCustomSegmentedController alloc] initWithItems:[NSArray arrayWithObjects:
                                                                                                 wikiArr,
                                                                                                 wiktionArr,
                                                                                                 wordnikArr,nil                                     ]];
        
        segment.center = CGPointMake(240.0,26.0);
        UIButton *button = (UIButton*)[segment viewWithTag:301];
        CGRect frame = button.frame;
        if ([UIScreen mainScreen].scale>1) {
            frame.origin.y+=0.5;
        }
        
        button.frame = frame;
        
        [segment addTarget:self
                    action:@selector(segmentChanged:)
          forControlEvents:UIControlEventValueChanged];
        
        [mainMenu addSubview:segment];
        
//        UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Wiki",@"Translate",@"Wordnik", nil]];
//        
//       // segment.center = CGPointMake(mainMenu.frame.size.width/2.0+10, mainMenu.frame.size.height/2.0+6);
//        
//        segment.center = CGPointMake(mainMenu.frame.size.width/2.0-40, mainMenu.frame.size.height/2.0+5);//changed Sanjeev reddy
//        [[UISegmentedControl appearance] setContentMode:UIViewContentModeScaleToFill];
//        [[UISegmentedControl appearance] setWidth:100.0 forSegmentAtIndex:0];
//         [[UISegmentedControl appearance] setWidth:100.0 forSegmentAtIndex:1];
//        [[UISegmentedControl appearance] setWidth:100.0 forSegmentAtIndex:2];
//        
//        
//        segment.segmentedControlStyle = UISegmentedControlStyleBar;
//        [segment addTarget:self
//                    action:@selector(segmentChanged:)
//          forControlEvents:UIControlEventValueChanged];
//        
////        segment.backgroundColor=[UIColor darkGrayColor];
//        [mainMenu addSubview:segment];
//        [segment release];
    }
	
	if ([Util isPhone]) {
        
        UIButton *customSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *saveImage = [Util imageFromBundle:@"i_images_back1.png"];
        customSaveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
        customSaveButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customSaveButton setImage:saveImage forState:UIControlStateNormal];
        [customSaveButton setImage:[Util imageFromBundle:@"i_back_back2.png"] forState:UIControlStateHighlighted];
        [customSaveButton addTarget:self
                             action:@selector(backPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
		
        UIButton *customToolsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *toolsImage = [Util imageFromBundle:@"i_butt_tools1.png"];
        customToolsButton.frame = CGRectMake(0, 0, toolsImage.size.width, toolsImage.size.height);
        customToolsButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customToolsButton setImage:toolsImage forState:UIControlStateNormal];
        [customToolsButton setImage:[Util imageFromBundle:@"i_butt_tools2.png"] forState:UIControlStateHighlighted];
        [customToolsButton addTarget:self
                              action:@selector(switchToSecondMenu:)
                    forControlEvents:UIControlEventTouchUpInside];
        
		UIBarButtonItem *toolsButton = [[UIBarButtonItem alloc] initWithCustomView:customToolsButton];
        
		UIBarButtonItem *widthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																					 target:nil
																					 action:nil];
		widthButton.width = 340;
		
		[mainMenu setItems:[NSArray arrayWithObjects:doneButton,widthButton,toolsButton,nil]];
		[doneButton release];
		[toolsButton release];
		[widthButton release];
	}else {/////ipad
        UIButton *customSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *saveImage = [Util imageFromBundle:@"i_images_back1.png"];
        customSaveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
        customSaveButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customSaveButton setImage:saveImage forState:UIControlStateNormal];
        [customSaveButton setImage:[Util imageFromBundle:@"i_back_back2.png"] forState:UIControlStateHighlighted];
        [customSaveButton addTarget:self
                             action:@selector(backPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
        
        UIButton *customToolsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *toolsImage = [Util imageFromBundle:@"i_butt_tools1.png"];
        customToolsButton.frame = CGRectMake(0, 0, toolsImage.size.width, toolsImage.size.height);
        customToolsButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customToolsButton setImage:toolsImage forState:UIControlStateNormal];
        [customToolsButton setImage:[Util imageFromBundle:@"i_butt_tools2.png"] forState:UIControlStateHighlighted];
        [customToolsButton addTarget:self
                              action:@selector(switchToSecondMenu:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *toolsButton = [[UIBarButtonItem alloc] initWithCustomView:customToolsButton];
        
        UIBarButtonItem *widthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                     target:nil
                                                                                     action:nil];
        widthButton.width = 400;//changed
        
        [mainMenu setItems:[NSArray arrayWithObjects:widthButton,toolsButton,nil]];
        [doneButton release];
        [toolsButton release];
        [widthButton release];
//		UIBarButtonItem *toolsButton = [[UIBarButtonItem alloc] initWithTitle:@"Tools"
//																		style:UIBarButtonItemStyleBordered
//																	   target:self
//																	   action:@selector(switchToSecondMenu:)];
//		
//		UIBarButtonItem *widthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//																					 target:nil
//																					 action:nil];
//		widthButton.width = 470;
//		
//		[mainMenu setItems:[NSArray arrayWithObjects:widthButton,toolsButton,nil]];
//		[toolsButton release];
//		[widthButton release];
	}
    
	
	
    
	//context menu
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                contextMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,568.0,48.0)];
                contextMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];/////changed sanjeev reddy
            }
            else{
                contextMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,568.0,48.0)];
                contextMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];/////changed sanjeev reddy
            }

        }else
        {
            contextMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,10,480.0,48.0)];
            contextMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];/////changed sanjeev reddy

        }
        
		
		//contextMenu.barStyle = UIBarStyleBlackTranslucent;
	}
	else//ipad
	{
		contextMenu = [[FIToolBar alloc] initWithFrame:CGRectMake(0,0,540,48)];
// contextMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];
         contextMenu.bgImage = [Util imageFromBundle:@"i_searchBottomBar.png"];/////changed sanjeev reddy
	}
	contextMenu.tintColor = [UIColor darkGrayColor];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
																				target:self
																				action:@selector(webViewBack:)];
   
    float X,Y;
    
    if (![Util isPhone]) {
        X=100;
        Y=60;
    }else
    {
      if (IS_IPHONE_5) {
        X=50;
        Y=100;
    }else
      {
        X=30;
        Y=50;
    
       }
    }
    
	if (isImageDownloadingAvailable) {
        
        if ([Util isPhone]) {
            UIButton *customImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *imageImage = [Util imageFromBundle:@"i_butt_saveimg1.png"];
            customImageButton.frame = CGRectMake(0, 0, imageImage.size.width+X, imageImage.size.height);
            customImageButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
            [customImageButton setImage:imageImage forState:UIControlStateNormal];
            [customImageButton setImage:[Util imageFromBundle:@"i_butt_saveimg1.png"] forState:UIControlStateHighlighted];
            [customImageButton addTarget:self
                                  action:@selector(saveImagesPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            saveImageButton = [[UIBarButtonItem alloc] initWithCustomView:customImageButton];
        }else{
        
//            NSDictionary *barButtonAppearanceDict = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0] , NSForegroundColorAttributeName: [UIColor blackColor]};
//            [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
//            
//            saveImageButton = [[UIBarButtonItem alloc] initWithTitle:@"Save Images"
//                                                               style:UIBarButtonItemStyleBordered
//                                                              target:self
//                                                              action:@selector(saveImagesPressed:)];
            
            UIButton *customImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *imageImage = [Util imageFromBundle:@"i_butt_saveimg1.png"];
            customImageButton.frame = CGRectMake(0, 0, imageImage.size.width+X, imageImage.size.height);
            customImageButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
            [customImageButton setImage:imageImage forState:UIControlStateNormal];
            [customImageButton setImage:[Util imageFromBundle:@"i_butt_saveimg1.png"] forState:UIControlStateHighlighted];
            [customImageButton addTarget:self
                                  action:@selector(saveImagesPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
            saveImageButton = [[UIBarButtonItem alloc] initWithCustomView:customImageButton];
            
            
            
        }
        saveImageButton.enabled = NO;
	}
	
    UIBarButtonItem *saveTextButton;
    
    if ([Util isPhone]) {
        UIButton *customTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *textImage = [Util imageFromBundle:@"i_butt_savetext1.png"];
        customTextButton.frame = CGRectMake(0, 0, textImage.size.width+Y, textImage.size.height);
        customTextButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customTextButton setImage:textImage forState:UIControlStateNormal];
        [customTextButton setImage:[Util imageFromBundle:@"i_butt_savetext2.png"] forState:UIControlStateHighlighted];
        [customTextButton addTarget:self
                             action:@selector(saveHTMLasText:)
                   forControlEvents:UIControlEventTouchUpInside];
        saveTextButton = [[UIBarButtonItem alloc] initWithCustomView:customTextButton];
    }else{
        UIButton *customTextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *textImage = [Util imageFromBundle:@"i_butt_savetext1.png"];
        customTextButton.frame = CGRectMake(0, 0, textImage.size.width+Y, textImage.size.height);
        customTextButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customTextButton setImage:textImage forState:UIControlStateNormal];
        [customTextButton setImage:[Util imageFromBundle:@"i_butt_savetext2.png"] forState:UIControlStateHighlighted];
        [customTextButton addTarget:self
                             action:@selector(saveHTMLasText:)
                   forControlEvents:UIControlEventTouchUpInside];
        saveTextButton = [[UIBarButtonItem alloc] initWithCustomView:customTextButton];
//        saveTextButton = [[UIBarButtonItem alloc] initWithTitle:@"Save Text"
//                                                          style:UIBarButtonItemStyleBordered
//                                                         target:self
//                                                         action:@selector(saveHTMLasText:)];
    }
    
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil];
	UIBarButtonItem *mainPanel;
    if ([Util isPhone]) {
        UIButton *customMainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *mainImage = [Util imageFromBundle:@"i_butt_main1.png"];
        customMainButton.frame = CGRectMake(0, 0, mainImage.size.width+Y, mainImage.size.height);
        customMainButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customMainButton setImage:mainImage forState:UIControlStateNormal];
        [customMainButton setImage:[Util imageFromBundle:@"i_butt_main2.png"] forState:UIControlStateHighlighted];
        [customMainButton addTarget:self
                             action:@selector(switchToMainMenu:)
                   forControlEvents:UIControlEventTouchUpInside];
        mainPanel = [[UIBarButtonItem alloc] initWithCustomView:customMainButton];
    }else{//ipad
        UIButton *customMainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *mainImage = [Util imageFromBundle:@"i_butt_main1.png"];
        customMainButton.frame = CGRectMake(0, 0, mainImage.size.width+Y, mainImage.size.height);
        customMainButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customMainButton setImage:mainImage forState:UIControlStateNormal];
        [customMainButton setImage:[Util imageFromBundle:@"i_butt_main2.png"] forState:UIControlStateHighlighted];
        [customMainButton addTarget:self
                             action:@selector(switchToMainMenu:)
                   forControlEvents:UIControlEventTouchUpInside];
        mainPanel = [[UIBarButtonItem alloc] initWithCustomView:customMainButton];
//    	mainPanel = [[UIBarButtonItem alloc] initWithTitle:@"Main"
//                                                     style:UIBarButtonItemStyleBordered
//                                                    target:self
//                                                    action:@selector(switchToMainMenu:)];
    }
   
	if (isImageDownloadingAvailable) {
        
        if ([Util isPhone]) {
            [contextMenu setItems:[NSArray arrayWithObjects:backButton,saveImageButton,saveTextButton,mainPanel,nil]];
        }else
        {
        [contextMenu setItems:[NSArray arrayWithObjects:backButton,space,saveImageButton,space,saveTextButton,space,mainPanel,nil]];
        }
		
	}else {
        if ([Util isPhone]) {
		[contextMenu setItems:[NSArray arrayWithObjects:backButton,saveTextButton,mainPanel,nil]];
        }else
        {
        
        [contextMenu setItems:[NSArray arrayWithObjects:backButton,space,saveTextButton,space,mainPanel,nil]];
        }
	}
    
	[mainPanel release];
	
	
	contextMenu.hidden = YES;
	
    if ([Util isPhone]) {
        animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0,252,480,48.0)];
        
    }else{//ipad
        animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height-8, self.view.frame.size.width, 48)];
        
    }
    
    [animationView addSubview:contextMenu];
    [animationView addSubview:mainMenu];
    [self.view addSubview:animationView];
    [animationView release];
    
    
	[backButton release];
	
	if (isImageDownloadingAvailable) {
		[saveImageButton release];
	}
	
	[saveTextButton release];
	[space release];
	
	[contextMenu release];
	[mainMenu release];
	
}

-(void)backPressed
{
	webView.delegate = nil;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	[self.navigationController  popViewControllerAnimated:YES];
}

-(void)getUrlsForImage
{
	if (urls) {
		[urls release];
		urls = nil;
	}
	
	NSString *js_script = @"var resultString=''; function I(u){var t=u.split('.'),e=t[t.length-1].toLowerCase();return {gif:1,jpg:1,jpeg:1,png:1,mng:1}[e]}function hE(s){return s.replace(/&/g,'&amp;').replace(/>/g,'&gt;').replace(/</g,'&lt;').replace(/\"/g,'&quot;');}var q,h,i;for(i=0;q=document.images[i];++i){h=q.src;if(h&&I(h)&&(q.width>100)&&(q.height>100)){resultString+='(^_^)'+q.src+'(^|^)'+q.alt;}}; resultString";
	NSString *resultString = [webView stringByEvaluatingJavaScriptFromString:js_script];
	if ([resultString length]>5) {
		[webView stopLoading];
		resultString = [resultString substringFromIndex:5];
		NSLog(@"%@",resultString);
		NSArray *imagesArray = [resultString componentsSeparatedByString:@"(^_^)"];
		
		if (imagesArray) {
			urls = [[NSMutableArray alloc] initWithArray:imagesArray];
			
		}
		
	}
	
    
}

-(void)pastePressed
{
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	
	if (board && [board numberOfItems]>0) {
		
		NSString *str = [board string];
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		if (str) {
			[dic setObject:str forKey:@"text"];
		}
		
		board.items = nil;
		
		if (MyDelegate && [MyDelegate respondsToSelector:@selector(someDataToSave:)]) {
			[MyDelegate someDataToSave:dic];
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search"
														message:@"Clipboard text added to card"
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	else {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search"
														message:@"No items have been selected"
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

-(void)loadChooseImages
{
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		FIImageChooseViewController *chooseImage = [[FIImageChooseViewController alloc] init];
		chooseImage.orientation = orientation;
		[chooseImage setDelegate:self forImages:allImages forTitles:titles];
		[self.navigationController pushViewController:chooseImage animated:YES];
		[chooseImage release];
	}else {
		FSettingsTemplate *chooseImage = [[FSettingsTemplate alloc] init];
		chooseImage.contentSizeForViewInPopover = CGSizeMake(500,500);
		[chooseImage setDelegate:self forImages:allImages forTitles:titles];
		[self.navigationController pushViewController:chooseImage animated:YES];
		[chooseImage release];
	}
}

-(NSString*)lanCodeForStr:(NSString*)lang
{
	if (lang) {
		NSDictionary *langCode = [Util lanCode];
        
		if (langCode && [langCode objectForKey:lang]) {
			return [langCode objectForKey:lang];
		}
	}
    
	return nil;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.set = nil;
	[searchStr release];
    
    if (webView) {
        [webView release];
        webView = nil;
    }
    
	if (allImages) {
		[allImages release];
	}
	
	if (titles) {
		[titles release];
	}
	
	if (progressView) {
		[progressView release];
	}
	
	if (urls) {
		[urls release];
	}
	
    [super dealloc];
}


@end
