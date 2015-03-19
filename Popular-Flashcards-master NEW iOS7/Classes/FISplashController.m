    //
//  FISplashController.m
//  flashCards
//
//  Created by Ruslan on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FISplashController.h"


@implementation FISplashController
@synthesize splashImage;
@synthesize delegate;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.view.layer.contents = (id)self.splashImage.CGImage;
	self.view.contentMode = UIViewContentModeScaleAspectFill;
    [super viewDidLoad];
}

- (void)showInWindow:(UIWindow *)window {
	[window addSubview:self.view];
}

-(UIImage*)splashImage
{
	if (splashImage==nil) {
		

		
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			UIImage *tmpImage = [UIImage imageNamed:@"Default.png"];
			if (tmpImage) {
				splashImage = [[UIImage alloc] initWithCGImage:tmpImage.CGImage];
			}
		}else {
			NSString *defaultPath;
			UIDeviceOrientation orient = self.interfaceOrientation;
			if (orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight) {
				defaultPath = [[NSBundle mainBundle] pathForResource:@"Default-Landscape" ofType:@"png"];
			}else {
				defaultPath = [[NSBundle mainBundle] pathForResource:@"Default-Portrait" ofType:@"png"];
			}
			
			splashImage = [[UIImage alloc] initWithContentsOfFile:defaultPath];
		}
		
		
	}
	
	return splashImage;
}

-(void)viewDidAppear:(BOOL)animated
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(splashScreenDidAppear:)] ) {
		[self.delegate splashScreenDidAppear:self];
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(splashScreenWillDisappear:)]) {
		[self.delegate splashScreenWillDisappear:self];
	}
	
	[self performTransition];
}

-(void)performTransition
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	SEL stopSelector = @selector(splashFadeDidStop:finished:context:);
	[UIView setAnimationDidStopSelector:stopSelector];
	self.view.alpha = 0;
	[UIView commitAnimations];
}


- (void)splashFadeDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self.view removeFromSuperview];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(splashScreenDidDisappear:)]) {
		[self.delegate splashScreenDidDisappear:self];
	}
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
	else {
		return YES;
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
	self.delegate = nil;
	self.splashImage = nil;
	[super dealloc];
}


@end
