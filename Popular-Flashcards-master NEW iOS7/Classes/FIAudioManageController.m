    //
//  FIAudioManageController.m
//  flashCards
//
//  Created by Ruslan on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIAudioManageController.h"
#import "FDefinitionController.h"

#define kRowPerSection 9

@interface FIAudioManageController(Private)

//targets
-(void)backButtonPressed:(id)sender;
-(void)audioTapped:(UITapGestureRecognizer*)sender;

//init
-(void)initAnimationView;
-(void)initCollectionView;
-(void)initSearchBar;
-(void)initLoadingView;
-(void)initIphoneTopBar;
-(void)initIpadTopBar;

//private
-(void)searchAudio;
-(void)deselectCollectionUsingIndexPath;
-(void)playForIndex:(NSNumber*)index;
-(void)showErrorMsg:(NSString*)msg;

@end


@implementation FIAudioManageController
@synthesize delegate;
@synthesize orientation;
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

-(id)initWithTerm:(NSString*)Aterm
{
	self = [super init];
	if (self) {
		if (Aterm) {
			term = [[NSString alloc] initWithString:Aterm];
		}
	}
	
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,480.0)];
	else
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,540.0,580.0)];

	self.view = contentView;
	[contentView release];
	
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) 
	{
		self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"i_bg.png"]];
		
		if (orientation == FIOrientationPortrait) {
			[self initIphoneTopBar];
		}
		
		
	}
	else
	{
		self.view.backgroundColor = [UIColor whiteColor];
		[self initIpadTopBar];
	}

	currTag = -1;
	
	[self initSearchBar];
	[self initAnimationView];
	[self initCollectionView];
	[self initLoadingView];
	
	dicForSound = [[NSMutableDictionary alloc] init];
	
	if (term) {
		[self searchAudio];
	}
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Wordnik audio" withParam:nil];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	else
		return YES;

}



#pragma mark -
#pragma mark SearchBar delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	if (term) {
		[term release];
	}
	
	if (dicForSound) {
		[dicForSound release];
		dicForSound = nil;
	}
	
	
	term = [[NSString alloc] initWithString:searchBar.text];
	[self searchAudio];
	
}

#pragma mark -

#pragma mark -
#pragma mark FDefinitionController delegate

-(void)audioForTerm:(NSMutableArray*)audioArr
{
	if (audioInfo) {
		[audioInfo release];
		audioInfo = nil;
	}
	
	if (audioArr) {
		audioInfo = [[NSMutableArray alloc] initWithArray:audioArr];
	}
	if (loadingView) {
		[loadingView dismiss];
	}
	
	if (audioInfo && [audioInfo count]>0) {
		int count = [audioInfo count];
		
		if (count>kRowPerSection) {
			count = kRowPerSection;
		}
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.2];
		
		for (int i=0;i<count;i++) {
			UIView *subView = [animationView viewWithTag:i+1];
			if (subView) {
				subView.alpha = 1.0;
			}
		}
		
		[UIView commitAnimations];
	}else {
		audioLabel.hidden = NO;
		audioLabel.text = @"No audio found";
	}

	
}

-(void)definitionFailed
{
	if (loadingView) {
		[loadingView dismiss];
	}
	
	audioLabel.hidden = NO;
	audioLabel.text = @"No audio found";
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Audio"
													message:@"Request failed"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -


#pragma mark -
#pragma mark targets

-(void)backButtonPressed:(id)sender
{
	if (delegate && soundData && [delegate respondsToSelector:@selector(audioFromWordnik:)]) {
		[delegate audioFromWordnik:soundData];
	}
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		[self.navigationController popViewControllerAnimated:YES];
	else
		[self dismissModalViewControllerAnimated:YES];

}

-(void)audioTapped:(UITapGestureRecognizer*)sender
{
	UIView *subView = (UIView*)sender.view;
		
	if (subView && currTag != subView.tag) {
		[self deselectCollectionUsingIndexPath];
		currTag = subView.tag;
		UIImageView *imageView = (UIImageView*)[subView viewWithTag:100];
		if (imageView) {
			imageView.backgroundColor = [UIColor greenColor];
		}
		
		[[FIAnimationController sharedAnimation:nil] bounceView:subView];
	}
	
	[self performSelectorInBackground:@selector(playForIndex:) withObject:[NSNumber numberWithInt:currTag-1]];
	
}

#pragma mark -

#pragma mark -
#pragma mark init

-(void)initIpadTopBar
{
	[self.navigationItem setTitle:@"Powered by Wordnik.com"];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(backButtonPressed:)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

-(void)initIphoneTopBar
{

    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;
    
	UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,50.0)];
	topBar.userInteractionEnabled = YES;
	topBar.image = [UIImage imageNamed:@"i_top_panel.png"];
	[self.view addSubview:topBar];
	[topBar release];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor colorWithRed:0.298 green:0.192 blue:0.106 alpha:1.0];
	titleLabel.shadowColor = [UIColor colorWithRed:0.647 green:0.565 blue:0.486 alpha:1.0];
	titleLabel.shadowOffset = CGSizeMake(1,1);
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.text = @"Powered by Wordnik.com";
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0,5.0,59.0,34.0);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
}

-(void)initAnimationView
{
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0,95.0,320.0,365.0)];
		audioLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,132.0,320.0,100.0)];
	}
	else
	{
		animationView = [[UIView alloc] initWithFrame:CGRectMake(0.0,50.0,540.0,530.0)];
		audioLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,215.0,540.0,100.0)];
	}
	
	animationView.backgroundColor = [UIColor clearColor];
	audioLabel.backgroundColor = [UIColor clearColor];
	audioLabel.textAlignment = UITextAlignmentCenter;
	audioLabel.font = [UIFont boldSystemFontOfSize:20.0];

	[animationView addSubview:audioLabel];
	[self.view addSubview:animationView];
	
	
	[audioLabel release];
	[animationView release];
}

-(void)initCollectionView
{
	NSInteger dx;
	NSInteger dy;
	CGSize frSize;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
	{
		dx = 23.5;
		dy = 26.5;
		frSize.width = 75.0;
		frSize.height = 75.0;
	}else {
		dx = 51.0;
		dy = 45.0;
		frSize.width = 112.5;
		frSize.height = 112.5;
	}
	
	
	for (int i=0;i<kRowPerSection;i++) {
		
		CGRect frame = CGRectMake(0.0,0.0,frSize.width,frSize.height);
		
		NSInteger x = i%3;
		NSInteger y = i/3;
		
		frame.origin.x = dx*(x+1)+frSize.width*x;
		frame.origin.y = dy*(y+1)+frSize.height*y;
		
		UIView *subanimationView = [[UIView alloc] initWithFrame:frame];
		subanimationView.backgroundColor = [UIColor clearColor];
		UIImageView *picImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,frSize.width,frSize.height)];
		subanimationView.tag = i+1;
		picImageView.tag = 100;
		picImageView.userInteractionEnabled = YES;
		picImageView.backgroundColor = [UIColor redColor];
		
		UITapGestureRecognizer *choosePic = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(audioTapped:)];
		
		[subanimationView addGestureRecognizer:choosePic];
		
		[choosePic release];
				
		[subanimationView addSubview:picImageView];
		[animationView addSubview:subanimationView];
		
		
		[subanimationView release];
		[picImageView release];
	}
}

-(void)initSearchBar
{
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
		
		if (orientation == FIOrientationPortrait) {
			audioSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,45.0,320.0,50.0)];
		}else {
			audioSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,44.0)];
		}
	}
	else
		audioSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,540.0,50.0)];

	audioSearchBar.delegate = self;
	audioSearchBar.barStyle = UIBarStyleBlackTranslucent;
	audioSearchBar.placeholder = @"Term";
	[self.view addSubview:audioSearchBar];
	[audioSearchBar release];
	
	
	if (term) {
		[audioSearchBar setText:term];
	}
	
}

-(void)initLoadingView
{
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		if (orientation == FIOrientationPortrait) {
			loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0.0,50.0,320.0,430.0)];
		}else {
			loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0.0,45.0,480.0,276.0)];
		}

		
	else
		loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0.0,50.0,540.0,530.0)];

	
	loadingView.messageLabel.text = @"Getting audio info...";
	loadingView.backgroundColor = [UIColor blackColor];
	loadingView.alpha = 0.5f;
	loadingView.messageLabel.textColor = [UIColor whiteColor];
}


#pragma mark -

#pragma mark -
#pragma mark private

-(void)searchAudio
{
	if (loadingView) {
		[loadingView showInView:self.view];
	}
	
	if (soundData) {
		[soundData release];
		soundData = nil;
	}
	
	audioLabel.hidden = YES;
	for (int i=0;i<kRowPerSection;i++) {
		UIView *subView = [animationView viewWithTag:i+1];
		if (subView) {
			subView.alpha = 0.0;
		}
	}
	
	
	[[FDefinitionController sharedDefinitionWithDelegate:self] getAudioForTerm:term];
}

-(void)deselectCollectionUsingIndexPath
{
	if (currTag>0) {
		UIView *subView = [animationView viewWithTag:currTag];
		if (subView) {
			UIImageView *imageView = (UIImageView*)[subView viewWithTag:100];
			if (imageView) {
				imageView.backgroundColor = [UIColor redColor];
			}
		}
	}
}

-(void)playForIndex:(NSNumber*)index
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSInteger indexInArr = [index intValue];
		
	NSDictionary *info = [audioInfo objectAtIndex:indexInArr];
	NSString *audioId = [info objectForKey:@"id"];
	
	
	if ((audioId && dicForSound && ![dicForSound objectForKey:audioId]) || !audioId || !dicForSound) {
		
		NSString *urlStr = [info objectForKey:@"fileUrl"];
		
		if (urlStr) {
			urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSURL *url = [NSURL URLWithString:urlStr];
			NSError *error = nil;
			NSData *data = [NSData dataWithContentsOfURL:url];
			if (data) 
			{
				if (soundData) {
					[soundData release];
					soundData = nil;
				}
				
				soundData = [[NSData alloc] initWithData:data];
				[dicForSound setObject:data forKey:audioId];
				audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
			}
			
			if (audioPlayer) {
				[audioPlayer prepareToPlay];
				[audioPlayer play];
			}else {
				if (error) {
					NSString *msg = [error description];
					[self performSelectorOnMainThread:@selector(showErrorMsg:)
										   withObject:msg
										waitUntilDone:NO];	
				}
			}
		}
	}else {
		NSData *data = [dicForSound objectForKey:audioId];
		NSError *error = nil;
		if (data) 
		{
			
			if (soundData) {
				[soundData release];
				soundData = nil;
			}
			
			soundData = [[NSData alloc] initWithData:data];
			audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
		}
		
		if (audioPlayer) {
			[audioPlayer prepareToPlay];
			[audioPlayer play];
		}else {
			if (error) {
				NSString *msg = [error description];
				[self performSelectorOnMainThread:@selector(showErrorMsg:)
									   withObject:msg
									waitUntilDone:NO];	
			}
		}
	}
	
	[pool release];
}

-(void)showErrorMsg:(NSString*)msg
{
	if (msg) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Audio"
														message:msg
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
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
	
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	
	if (loadingView) {
		[loadingView release];
	}
	
	if (audioPlayer) {
		if ([audioPlayer isPlaying]) {
			[audioPlayer stop];
		}
		[audioPlayer release];
		audioPlayer = nil;
	}
	
	if (audioInfo) {
		[audioInfo release];
	}
	
	if (dicForSound) {
		[dicForSound release];
	}
	
	if (term) {
		[term release];
	}
	
	delegate = nil;
	
    [super dealloc];
}


@end
