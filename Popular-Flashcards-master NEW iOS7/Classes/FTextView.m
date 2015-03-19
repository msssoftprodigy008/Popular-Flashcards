    //
//  FTextView.m
//  flashCards
//
//  Created by Ruslan on 7/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTextView.h"
#import "ModalAlert.h"
#import "FRootConstants.h"

@interface FTextView(Private)

-(void)addToCardPressed;

@end


@implementation FTextView
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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,580)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	textView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,540,527)];
	textView.backgroundColor = [UIColor whiteColor];
	textView.font = [UIFont fontWithName:@"Helvetica" size:26];
	textView.textColor = [UIColor blackColor];
	textView.editable = NO;
	
	[self.view addSubview:textView];
	[textView release];
	
	if (currText) {
		textView.text = currText;
	}
	
	UIToolbar *bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,527,540,53)];
	bottomBar.tintColor = [UIColor lightGrayColor];
	UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"Add to card"
															style:UIBarButtonItemStyleBordered
														   target:self
														   action:@selector(addToCardPressed)];
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil];
	bottomBar.items = [NSArray arrayWithObjects:space,addItem,space,nil];
	[self.view addSubview:bottomBar];
	[bottomBar release];
	[addItem release];
	[space release];
		
}

-(void)showText:(NSString*)Atext
{
	if (currText) {
		[currText release];
	}
	
	currText = [[NSString alloc] initWithString:Atext];
	
	if (textView) {
		textView.text = currText;
	}
	
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

#pragma mark -
#pragma mark private

-(void)addToCardPressed
{
	if (delegate && [delegate respondsToSelector:@selector(addTextToCard:)]) {
		[delegate addTextToCard:currText];
	}
	
	[ModalAlert say:@"This text added to card"];
	[self.navigationController popViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
	
	if (currText) {
		[currText release];
	}
	
    [super dealloc];
}


@end
