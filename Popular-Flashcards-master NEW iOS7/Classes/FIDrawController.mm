    //
//  FIDrawController.m
//  flashCards
//
//  Created by Ruslan on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FIDrawController.h"
#import "FIDrawView.h"
#import "FIGLView.h"
#import "FIAnimationController.h"
#import "Util.h"
#import "Constant.h"
@interface FIDrawController(Private)


//init
-(void)initTopBar;
-(void)initInstrumentsView;

//targets
-(void)backButtonPressed:(id)sender;
-(void)saveButtonPressed:(id)sender;
-(void)brushButtonPressed:(id)sender;
-(void)eraserButtonPressed:(id)sender;
-(void)colorButtonPressed:(id)sender;
-(void)lineButtonPressed:(id)sender;
-(void)trashButtonPressed:(id)sender;

//private
-(void)showInstruments;
-(void)setCurrentColor;
-(void)setCurrentLine;

@end


@implementation FIDrawController
@synthesize delegate;
@synthesize bgImage;
@synthesize orientation;

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,50,((IS_IPHONE_5)?568:480),300.0)]; //changed sanjeev reddy 0.0 to 50.0
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	if (orientation == FIOrientationPortrait) {
		[self initTopBar];	
	}
	
	
	molbert = [[FIGLView alloc] initWithFrame:CGRectMake(0.0,0.0,((IS_IPHONE_5)?568:480),258)];
	
	[self.view addSubview:molbert];
	[molbert release];
	
	instrumentView = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,((IS_IPHONE_5)?320:300),((IS_IPHONE_5)?568:480),48.0)];
    
 
    instrumentView.bgImage = [Util imageFromBundle:@"i_images_bottombg.png"];

	[self.view addSubview:instrumentView];
	[instrumentView release];
	
	[self initInstrumentsView];
	
	[molbert changeLineWidth:2.0];
	[molbert setColor:0.0 forG:0.0 forB:0.0 forA:1.0];
	[molbert setErraserRadius:10.0];
	colorIndex = 7;
	lineIndex = 8;
	isBrush = YES;
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Draw image" withParam:nil];
	
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}




-(void)viewDidAppear:(BOOL)animated
{
	[self showInstruments];
}


#pragma mark -
#pragma mark init

-(void)initTopBar
{
    
    if ([Util isPhone]){
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                    
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    
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
                    
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                   
                }
                
            }
            else{
                
            }
        }
        
    }
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
	
	titleLabel.text = @"Sketch";
	
	
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5.0,5.0,59.0,34.0);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	/*UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	saveButton.frame = CGRectMake(320.0-5.0-59.0,5.0,55.0,34.0);
	[saveButton setImage:[UIImage imageNamed:@"i_save_1.png"] forState:UIControlStateNormal];
	[saveButton setImage:[UIImage imageNamed:@"i_save_2.png"] forState:UIControlStateHighlighted];
	[saveButton addTarget:self action:@selector(saveButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:saveButton];*/
	
}

-(void)initInstrumentsView
{
	if (orientation == FIOrientationLandscape) {
        UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *doneImage = [Util imageFromBundle:@"i_add_done1.png"];
        customBackButton.frame = CGRectMake(0, 0, doneImage.size.width, doneImage.size.height);
        customBackButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customBackButton setImage:doneImage forState:UIControlStateNormal];
        [customBackButton setImage:[Util imageFromBundle:@"i_add_done2.png"] forState:UIControlStateHighlighted];
        [customBackButton addTarget:self
                             action:@selector(backButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
		[instrumentView setItems:[NSArray arrayWithObject:back]];
		[back release];
	}
	
	buttonArray = [[NSMutableArray alloc] init];
	
	float t = 0.0;
	float trashT = 0.0;
	
	if (orientation == FIOrientationLandscape) {
		t = ((IS_IPHONE_5)?165:100);
		trashT = ((IS_IPHONE_5)?80:60);
	}
	
	for (int i=0;i<12;i++) {
		
		UIButton *panelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
		switch (i) {
			case 0:
				panelButton.frame = CGRectMake(9.0+t,11.0,30.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_brush_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_brush_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_brush_3.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(brushButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				[panelButton setSelected:YES];
				panelButton.userInteractionEnabled = NO;
				break;
			case 1:
				panelButton.frame = CGRectMake(39.0+t,11.0,30.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_eraser_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_eraser_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_eraser_3.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(eraserButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 2:
				panelButton.frame = CGRectMake(78.0+t,12.0,17.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_yellow_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_yellow_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_yellow_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 3:
				panelButton.frame = CGRectMake(95.0+t,12.0,16.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_red_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_red_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_red_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 4:
				panelButton.frame = CGRectMake(111.0+t,12.0,16.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_green_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_green_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_green_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 5:
				panelButton.frame = CGRectMake(127.0+t,12.0,16.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_blue_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_blue_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_blue_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 6:
				panelButton.frame = CGRectMake(143.0+t,12.0,16.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_purple_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_purple_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_purple_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 7:
				panelButton.frame = CGRectMake(159.0+t,12.0,17.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_black_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_black_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_black_2.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(colorButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				[panelButton setSelected:YES];
				panelButton.userInteractionEnabled = NO;
				break;
			case 8:
				panelButton.frame = CGRectMake(185.0+t,12.0,30.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_thick1_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_thick1_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_thick1_3.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(lineButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				[panelButton setSelected:YES];
				panelButton.userInteractionEnabled = NO;
				break;
			case 9:
				panelButton.frame = CGRectMake(215.0+t,12.0,29.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_thick2_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_thick2_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_thick2_3.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(lineButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 10:
				panelButton.frame = CGRectMake(244.0+t,12.0,30.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_thick3_1.png"] forState:UIControlStateNormal];
				[panelButton setImage:[UIImage imageNamed:@"i_thick3_1.png"] forState:UIControlStateHighlighted];
				[panelButton setImage:[UIImage imageNamed:@"i_thick3_3.png"] forState:UIControlStateSelected];
				[panelButton addTarget:self
								action:@selector(lineButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
			case 11:
				panelButton.frame = CGRectMake(284.0+t+trashT,12.0,28.0,30.0);
				[panelButton setImage:[UIImage imageNamed:@"i_trash.png"] forState:UIControlStateNormal];
				[panelButton addTarget:self
								action:@selector(trashButtonPressed:)
					  forControlEvents:UIControlEventTouchUpInside];
				break;
				
			default:
				break;
		}
		
		[instrumentView addSubview:panelButton];
		panelButton.tag = i+1;
		[buttonArray addObject:panelButton];
		
		
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

-(void)backButtonPressed:(id)sender
{
	if(!molbert.isClear)
	{
		if(delegate && [delegate respondsToSelector:@selector(drawnedImage:)])
		{
			[delegate drawnedImage:[molbert getImage]];
			return;
		}
	}
	
	if (molbert) {
		[molbert invalidate];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender
{
	if(delegate && [delegate respondsToSelector:@selector(drawnedImage:)])
	{
		[delegate drawnedImage:[molbert getImage]];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)brushButtonPressed:(id)sender
{
	UIButton *brushButton = [buttonArray objectAtIndex:0];
	UIButton *eraserButton = [buttonArray objectAtIndex:1];
	[brushButton setSelected:YES];
	[eraserButton setSelected:NO];
	brushButton.userInteractionEnabled = NO;
	eraserButton.userInteractionEnabled = YES;
	isBrush = YES;
	[molbert errserEnable:NO];
	
	if (sender!=nil) {
		[instrumentView bringSubviewToFront:brushButton];
		[[FIAnimationController sharedAnimation:nil] bounceView:brushButton];
	}
}

-(void)eraserButtonPressed:(id)sender
{
	UIButton *brushButton = [buttonArray objectAtIndex:0];
	UIButton *eraserButton = [buttonArray objectAtIndex:1];
	[brushButton setSelected:NO];
	[eraserButton setSelected:YES];
	brushButton.userInteractionEnabled = YES;
	eraserButton.userInteractionEnabled = NO;
	isBrush = NO;
	[molbert errserEnable:YES];
	
	if (sender!=nil) {
		[instrumentView bringSubviewToFront:eraserButton];
		[[FIAnimationController sharedAnimation:nil] bounceView:eraserButton];
	}
}

-(void)colorButtonPressed:(id)sender
{
	UIButton *newButtonColor = (UIButton*)sender;
	UIButton *currButton = (UIButton*)[buttonArray objectAtIndex:colorIndex];
	colorIndex = newButtonColor.tag-1;
	[currButton setSelected:NO];
	currButton.userInteractionEnabled = YES;
	[newButtonColor setSelected:YES];
	newButtonColor.userInteractionEnabled = NO;
	[self setCurrentColor];
	
	if (!isBrush) {
		[self brushButtonPressed:nil];
	}
	[instrumentView bringSubviewToFront:newButtonColor];
	[[FIAnimationController sharedAnimation:nil] bounceView:newButtonColor];
}

-(void)lineButtonPressed:(id)sender
{
	UIButton *newButtonLine = (UIButton*)sender;
	UIButton *currButton = (UIButton*)[buttonArray objectAtIndex:lineIndex];
	lineIndex = newButtonLine.tag-1;
	[newButtonLine setSelected:YES];
	newButtonLine.userInteractionEnabled = NO;
	[currButton setSelected:NO];
	currButton.userInteractionEnabled = YES;
	[self setCurrentLine];
	
	if (!isBrush) {
		[self brushButtonPressed:nil];
	}
	[instrumentView bringSubviewToFront:newButtonLine];
	[[FIAnimationController sharedAnimation:nil] bounceView:newButtonLine];
}

-(void)trashButtonPressed:(id)sender
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


#pragma mark -

#pragma mark -
#pragma mark AlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex!=[alertView cancelButtonIndex]) {
		UIButton *trashButton = [buttonArray objectAtIndex:11];
		[molbert clear];
		
		if (!isBrush) {
			[self brushButtonPressed:nil];
		}
		
		[[FIAnimationController sharedAnimation:nil] bounceView:trashButton];
	}
}

#pragma mark -

#pragma mark -
#pragma mark Private

-(void)showInstruments
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	[instrumentView setFrame:CGRectMake(0.0,((IS_IPHONE_5)?272:252),((IS_IPHONE_5)?568:480),48.0)];
		
	[UIView commitAnimations];
}

-(void)setCurrentColor
{
	switch (colorIndex) {
		case 2:
			[molbert setColor:1.0 forG:1.0 forB:0.0 forA:1.0];
			break;
		case 3:
			[molbert setColor:1.0 forG:0.0 forB:0.0 forA:1.0];
			break;
		case 4:
			[molbert setColor:0.0 forG:1.0 forB:0.0 forA:1.0];
			break;
		case 5:
			[molbert setColor:0.0 forG:0.0 forB:1.0 forA:1.0];
			break;
		case 6:
			[molbert setColor:128.0/255.0 forG:0.0 forB:128.0/255.0 forA:1.0];
			break;
		case 7:
			[molbert setColor:0.0 forG:0.0 forB:0.0 forA:1.0];
			break;
		default:
			break;
	}
}

-(void)setCurrentLine
{
	switch (lineIndex) {
		case 8:
			[molbert changeLineWidth:2.0];
			break;
		case 9:
			[molbert changeLineWidth:5.0];
			break;
		case 10:
			[molbert changeLineWidth:10.0];
			break;
		default:
			break;
	}
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
	
	if (bgImage) {
		[bgImage release];
	}
	
	if (buttonArray) {
		[buttonArray release];
	}
	
    [super dealloc];
}


@end
