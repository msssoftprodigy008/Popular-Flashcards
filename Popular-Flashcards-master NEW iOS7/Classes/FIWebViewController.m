    //
//  FIWebViewController.m
//  flashCards
//
//  Created by Ruslan on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIWebViewController.h"
#import "FINavigationBar.h"
#import "Util.h"

@interface FIWebViewController(Private)

-(void)initTopBar;
-(void)backPressed;


@end


@implementation FIWebViewController
@synthesize isHTML;
@synthesize path;
@synthesize titleStr;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
	UIView *contentView = [[UIView alloc] init];
    webView = [[UIWebView alloc] init];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                contentView.frame = CGRectMake(0,0,568,320);
                webView.frame = CGRectMake(0,33,568,287);
            }
            else{
                contentView.frame = CGRectMake(0,0,568,300);
                webView.frame = CGRectMake(0,33,568,287);
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                contentView.frame = CGRectMake(0,0,480,320);
                webView.frame = CGRectMake(0,33,480,287);
            }
            else{
                contentView.frame = CGRectMake(0,0,480,300);
                webView.frame = CGRectMake(0,33,480,267);
            }
        }
	}else {
		contentView.frame = CGRectMake(0,0,1024,1024);
	}
    
	self.view = contentView;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"i_bg.png"]];
	[contentView release];

	webView.backgroundColor = [UIColor clearColor];
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.delegate = self;
	[self.view addSubview:webView];
	[webView release];
    
   	[self initTopBar];
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Web search" withParam:nil];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (path) {
		if (isHTML) {
			[webView loadHTMLString:path baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
		}else {
			[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
		}
	}

}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
}

- (void)webViewDidFinishLoad:(UIWebView *)AwebView
{
    ////////////////////////////////////////// changed by sanjeev reddy for web to fit in view(ipad)
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = self.view.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.minimumZoomScale = rw;
    webView.scrollView.maximumZoomScale = rw;
    webView.scrollView.zoomScale = rw;
    ///////////////////////////////////////
	// finished loading, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)AwebView didFailLoadWithError:(NSError *)error
{
	if ([error code] !=NSURLErrorCancelled) {
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
#pragma mark private

-(void)backPressed
{
	[webView stopLoading];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self dismissModalViewControllerAnimated:YES];
}

-(void)initTopBar
{
    FINavigationBar *topBar = [[FINavigationBar alloc] init];
    if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
            }
            else{
                topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
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
                topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
            }
            else{
                topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
            }
            
            
        }
	}
    
    topBar.bgImage = [Util imageFromBundle:@"i_panel_bg.png"];
	
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
    if (titleStr) {
        item.title = titleStr;
    }
	
    [topBar pushNavigationItem:item animated:NO];
    [item release];
    
    UIImage *doneImage = [Util imageFromBundle:@"i_panel_done1.png"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0,0,doneImage.size.width,doneImage.size.height);
	[backButton setImage:[UIImage imageNamed:@"i_panel_done1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_panel_done2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    item.rightBarButtonItem = backBarButton;
    [backBarButton release];
	
    [self.view addSubview:topBar];
    [topBar release];
    
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
	
	if (path) {
		[path release];
	}
	
	if (titleStr) {
		[titleStr release];
	}
	
    [super dealloc];
}


@end
