    //
//  FITextViewController.m
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FITextViewController.h"
#import "Util.h"

@interface FITextViewController(Private)

-(void)addToCardPressed;
-(void)initTopBar;
-(void)initBottomBar;
-(void)backPressed;

@end


@implementation FITextViewController
@synthesize delegate;

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
    
    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;

	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,width,480)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[contentView release];
	
	[self initTopBar];
	
	textView = [[UITextView alloc] initWithFrame:CGRectMake(0,44,width,460-2*44)];
	textView.backgroundColor = [UIColor whiteColor];
	textView.font = [UIFont fontWithName:@"Helvetica" size:16];
	textView.textColor = [UIColor blackColor];
	textView.editable = NO;
	
	[self.view addSubview:textView];
	[textView release];
	
	
	
	if (currText) {
		textView.text = currText;
	}
	
	[self initBottomBar];
}

-(void)showText:(NSString*)Atext forTitle:(NSString*)titleStr
{
	if (Atext) {
		if (currText) {
			[currText release];
		}
	
		currText = [[NSString alloc] initWithString:Atext];
	
		if (textView) {
			textView.text = currText;
		}
	}else {
		currText = nil;
	}
	
	if (titleStr) {
		if (titleText) {
			[titleText release];
		}
		
		titleText = [[NSString alloc] initWithString:titleStr];
		
	}
	
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark private

-(void)addToCardPressed
{
	if (delegate && [delegate respondsToSelector:@selector(addTextForCard:)]) {
		[delegate addTextForCard:currText];
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Definition"
													message:@"Text added to your card"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	[self.navigationController popViewControllerAnimated:YES];
}

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
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,45)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	titleLabel.text = titleText;
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(2,5,59,34);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
}

-(void)initBottomBar
{
    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;

	UIImageView* bottomBar = [[UIImageView alloc] initWithFrame:CGRectMake(0,460-49,width,49)];
	bottomBar.userInteractionEnabled = YES;
	bottomBar.image = [UIImage imageNamed:@"i_bottom_panel.png"];
	[self.view addSubview:bottomBar];
	[bottomBar release];
	
	UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteButton.frame = CGRectMake(160-45.0,49-5-34,90,34);
	[deleteButton setImage:[UIImage imageNamed:@"i_add_to_card_1.png"] forState:UIControlStateNormal];
	[deleteButton setImage:[UIImage imageNamed:@"i_add_to_card_2.png"] forState:UIControlStateHighlighted];
	[deleteButton addTarget:self action:@selector(addToCardPressed) forControlEvents:UIControlEventTouchUpInside];
	[bottomBar addSubview:deleteButton];
}

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

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
	
	if (titleText) {
		[titleText release];
	}
	
	if (currText) {
		[currText release];
	}
	
    [super dealloc];
}


@end
