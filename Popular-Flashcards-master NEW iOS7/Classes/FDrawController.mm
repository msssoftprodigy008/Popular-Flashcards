    //
//  FDrawController.m
//  flashCards
//
//  Created by Ruslan on 1/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FDrawController.h"
#import "FIDrawView.h"
#import "FIAnimationController.h"
#import "FIGLView.h"

@interface FDrawController(Private)

-(void)colorItemPressed:(id)sender;
-(void)lineItemPressed:(id)sender;
-(void)trashItemPressed:(id)sender;
-(void)brushItemPressed:(id)sender;
-(void)eraserItemPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;
-(void)quitButtonPressed:(id)sender;

//private
-(void)initInstruments;
-(void)setCurrentColor;
-(void)setCurrentLineWidth;

@end


@implementation FDrawController
@synthesize delegate;
@synthesize bgImage;

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,500.0,600.0)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	molbert = [[FIGLView alloc] initWithFrame:CGRectMake(0.0,0.0,512,552.0)];
//	molbert.backgroundImage = bgImage;
	[self.view addSubview:molbert];
	[molbert setColor:0.0 forG:0.0 forB:0.0 forA:1.0];
	[molbert changeLineWidth:7.0];
	[molbert setErraserRadius:12];
	[molbert release];
	
	instrumentView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,600.0,500.0,47.0)];
	instrumentView.image = [UIImage	 imageNamed:@"intstrBg.png"];
	instrumentView.hidden = YES;
	instrumentView.userInteractionEnabled = YES;
	[self.view addSubview:instrumentView];
	[instrumentView release];
	
	isBrush = YES;
	selectedLineIndex = 3;
	selectedColorIndex = 10;
	
	[self initInstruments];
	
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(saveButtonPressed:)];
	self.navigationItem.leftBarButtonItem = saveButton;
	
	[saveButton release];
	self.navigationItem.title = @"Sketch";
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Draw image" withParam:nil];
	
}

-(void)showInstruments
{
	instrumentView.hidden = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	[instrumentView setFrame:CGRectMake(0.0,553.0,500.0,47.0)];
	[UIView commitAnimations];
}

-(void)hideInstruments
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	[instrumentView setFrame:CGRectMake(0.0,600.0,500.0,47.0)];
	[UIView commitAnimations];
	instrumentView.hidden = YES;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark target

-(void)colorItemPressed:(id)sender
{
	UIButton *newColorButton = (UIButton*)sender;
	UIButton *currentColorButton = [buttonArray objectAtIndex:selectedColorIndex];
	selectedColorIndex = newColorButton.tag-1;
	currentColorButton.userInteractionEnabled = YES;
	[currentColorButton setSelected:NO];
	newColorButton.userInteractionEnabled = NO;
	[newColorButton setSelected:YES];
	[self setCurrentColor];
	if (!isBrush) {
		[self brushItemPressed:nil];
	}
	[[FIAnimationController sharedAnimation:nil] bounceView:newColorButton];
}

-(void)lineItemPressed:(id)sender
{
	UIButton *newLineButton = (UIButton*)sender;
	UIButton *currentButton = (UIButton*)[buttonArray objectAtIndex:selectedLineIndex];
	selectedLineIndex = newLineButton.tag-1;
	currentButton.userInteractionEnabled = YES;
	[currentButton setSelected:NO];
	newLineButton.userInteractionEnabled = NO;
	[newLineButton setSelected:YES];
	[self setCurrentLineWidth];
	if (!isBrush) {
		[self brushItemPressed:nil];
	}
	[[FIAnimationController sharedAnimation:nil] bounceView:newLineButton];
}

-(void)trashItemPressed:(id)sender
{
	if (!molbert.isClear) {
		NSString *message = @"Are you sure you want to delete current sketch?";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sketch"
														message:message
													   delegate:self
											  cancelButtonTitle:@"NO"
											  otherButtonTitles:@"YES",nil];
		[alert show];
		[alert release];
	}
}

-(void)brushItemPressed:(id)sender
{
	UIButton *brushButton = [buttonArray objectAtIndex:0];
	UIButton *eraserButton = [buttonArray objectAtIndex:1];
	eraserButton.userInteractionEnabled = YES;
	[eraserButton setSelected:NO];
	brushButton.userInteractionEnabled = NO;
	[brushButton setSelected:YES];
	[self setCurrentColor];
	[self setCurrentLineWidth];
	isBrush = YES;
	[molbert errserEnable:NO];
	
	if (sender!=nil) 
		[[FIAnimationController sharedAnimation:nil] bounceView:brushButton];
}

-(void)eraserItemPressed:(id)sender
{
	UIButton *brushButton = [buttonArray objectAtIndex:0];
	UIButton *eraserButton = [buttonArray objectAtIndex:1];
	eraserButton.userInteractionEnabled = NO;
	[eraserButton setSelected:YES];
	brushButton.userInteractionEnabled = YES;
	[brushButton setSelected:NO];
	[molbert setColor:1.0 forG:1.0 forB:1.0 forA:1.0];
	isBrush = NO;
	[molbert errserEnable:YES];
	if (sender!=nil) 
		[[FIAnimationController sharedAnimation:nil] bounceView:eraserButton];
}

-(void)saveButtonPressed:(id)sender
{
	if (!molbert.isClear && delegate && [delegate respondsToSelector:@selector(imageSaved:)]) {
		[delegate imageSaved:[molbert getImage]];
	}else {
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)quitButtonPressed:(id)sender
{
	
}

#pragma mark -

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex!=[alertView cancelButtonIndex]) {
		UIButton *trashButton = [buttonArray objectAtIndex:11];
		[molbert clear];
		
		if (!isBrush) {
			[self brushItemPressed:nil];
		}
		
		[[FIAnimationController sharedAnimation:nil] bounceView:trashButton];
	}
}

#pragma mark -

#pragma mark -
#pragma mark Private

-(void)initInstruments
{
	buttonArray = [[NSMutableArray alloc] init];
	
	for (int i=0;i<12;i++) {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		switch (i) {
			case 0:
				//init brush
				button.frame = CGRectMake(17,8,30,30);
				[button setImage:[UIImage imageNamed:@"brush_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"brush_2.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"brush_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(brushItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				[button setSelected:YES];
				button.userInteractionEnabled = NO;
				break;
			case 1:
				//init eraser
				button.frame = CGRectMake(57,8,30,30);
				[button setImage:[UIImage imageNamed:@"eraser_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"eraser_2.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"eraser_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(eraserItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 2:
				//line min
				button.frame = CGRectMake(118,8,30,30);
				[button setImage:[UIImage imageNamed:@"thick1_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"thick1_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"thick1_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(lineItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 3:
				//line medium
				button.frame = CGRectMake(158,8,30,30);
				[button setImage:[UIImage imageNamed:@"thick2_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"thick2_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"thick2_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(lineItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				[button setSelected:YES];
				button.userInteractionEnabled = NO;
				break;
			case 4:
				//line max
				button.frame = CGRectMake(198,8,30,30);
				[button setImage:[UIImage imageNamed:@"thick3_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"thick3_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"thick3_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(lineItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 5:
				//color purple
				button.frame = CGRectMake(258,11,24,24);
				[button setImage:[UIImage imageNamed:@"purple_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"purple_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"purple_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 6:
				//color yellow
				button.frame = CGRectMake(285,11,24,24);
				[button setImage:[UIImage imageNamed:@"yellow_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"yellow_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"yellow_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 7:
				//color red
				button.frame = CGRectMake(312,11,24,24);
				[button setImage:[UIImage imageNamed:@"red_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"red_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"red_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 8:
				//color green
				button.frame = CGRectMake(339,11,24,24);
				[button setImage:[UIImage imageNamed:@"green_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"green_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"green_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 9:
				//color blue
				button.frame = CGRectMake(366,11,24,24);
				[button setImage:[UIImage imageNamed:@"blue_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"blue_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"blue_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
			case 10:
				//color black
				button.frame = CGRectMake(393,11,24,24);
				[button setImage:[UIImage imageNamed:@"black_1.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"black_1.png"] forState:UIControlStateHighlighted];
				[button setImage:[UIImage imageNamed:@"black_3.png"] forState:UIControlStateSelected];
				[button addTarget:self
						   action:@selector(colorItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				[button setSelected:YES];
				button.userInteractionEnabled = NO;
				break;
			case 11:
				//trash
				button.frame = CGRectMake(448,7,28,32);
				[button setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateNormal];
				[button setImage:[UIImage imageNamed:@"trash.png"] forState:UIControlStateHighlighted];
				[button addTarget:self
						   action:@selector(trashItemPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
				break;
	
	
			default:
				break;
		}
		[instrumentView addSubview:button];
		button.tag = i+1;
		[buttonArray addObject:button];
		
	}
	
}

-(void)setCurrentColor
{
	switch (selectedColorIndex) {
		case 5:
			[molbert setColor:128.0/255.0 forG:0.0 forB:128.0/255.0 forA:1.0];
			break;
		case 6:
			[molbert setColor:1.0 forG:1.0 forB:0.0 forA:1.0];
			break;
		case 7:
			[molbert setColor:1.0 forG:0.0 forB:0.0 forA:1.0];
			break;
		case 8:
			[molbert setColor:0.0 forG:1.0 forB:0.0 forA:1.0];
			break;
		case 9:
			[molbert setColor:0.0 forG:0.0 forB:1.0 forA:1.0];
			break;
		case 10:
			[molbert setColor:0.0 forG:0.0 forB:0.0 forA:1.0];
			break;
			
		default:
			break;
	}
}

-(void)setCurrentLineWidth
{
	switch (selectedLineIndex) {
		case 2:
			[molbert changeLineWidth:2.0];
			break;
		case 3:
			[molbert changeLineWidth:7.0];
			break;
		case 4:
			[molbert changeLineWidth:12.0];
			break;
		default:
			break;
	}
}

#pragma mark -

-(void)viewDidAppear:(BOOL)animated
{
	[self showInstruments];
}

-(void)viewWillDisappear:(BOOL)animated
{
	/*if (!molbert.isClear) {
		if (delegate && [delegate respondsToSelector:@selector(imageSaved:)]) {
			[delegate imageSaved:[molbert getImage]];
		}
	}*/
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"restorePopover"
														object:nil];
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
	
	if (bgImage) {
		[bgImage release];
	}
	
	if (buttonArray) {
		[buttonArray release];
	}
	
    [super dealloc];
}


@end
