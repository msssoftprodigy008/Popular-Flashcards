//
//  FIDefinitionViewController.m
//  flashCards
//

//  Created by Nilesh on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIDefinitionViewController.h"
#import "Constant.h"

#import <QuartzCore/QuartzCore.h>
#import "Util.h"

@interface FIDefinitionViewController(Private)

-(void)initSearchBar;
-(void)initSegmentedController;
-(void)segmentChanged;
-(void)initTopBar;
-(void)backPressed;
-(void)addToCardButtonPressed:(id)sender;

@end


@implementation FIDefinitionViewController
@synthesize delegate;
@synthesize term;
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
    
    UIView *contentView;
    if (IS_IPHONE_5) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,320)];
        }
        else{
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,300)];
        }
    }
    else{
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,320)];
        }
        else{
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
        }
        
        
    }
	//UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[contentView release];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"i_bg.png"]];
	
	isNewDef = YES;
	isNewPhr = YES;
	isNewExm = YES;
	isNewRel = YES;
	
	[self initSearchBar];
	
	if (term) {
		DefsearchBar.text = term;
	}
	[self initSegmentedController];
	
	CGRect frame;
	
    if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                frame = CGRectMake(0,44,284,213);
            }
            else{
                frame = CGRectMake(0,44,284,213);
            }
            
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                frame = CGRectMake(0,44,240,213);
            }
            else{
                frame = CGRectMake(0,44,240,193);
            }
        }
    }
    
	
    rowIndex = -1;
    
	definitionTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	definitionTable.delegate = self;
	definitionTable.dataSource = self;
	definitionTable.backgroundColor = [UIColor whiteColor];
	definitionTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	
    UIImageView *headerBg = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"i_def_panel.png"]];
    UIImageView *headerBg1 = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"i_def_panel.png"]];
    UILabel* header1 = [[UILabel alloc] init];
    header = [[UILabel alloc] init];
    if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            headerBg.frame = CGRectMake(0,257, 284,23);
            headerBg.contentMode = UIViewContentModeScaleToFill;
            header.frame = CGRectMake(0,259,284,20);
            headerBg1.frame = CGRectMake(284,257,284,23);
            headerBg1.contentMode = UIViewContentModeScaleToFill;
            header1.frame = CGRectMake(284,259,284,20);
        }
        else {
            headerBg.frame = CGRectMake(0,257, 284,23);
            headerBg.contentMode = UIViewContentModeScaleToFill;
            header.frame = CGRectMake(0,238,240,20);
            headerBg1.frame = CGRectMake(284,257, 284,23);
            headerBg1.contentMode = UIViewContentModeScaleToFill;
            header1.frame = CGRectMake(240,238,240,20);
        }
    }
    
    [self.view addSubview:headerBg];
    [headerBg release];
    
    [self.view addSubview:headerBg1];
    [headerBg1 release];
	
    
	header1.shadowColor = [UIColor whiteColor];
	header1.shadowOffset = CGSizeMake(0.5,0.5);
	header1.font = [UIFont fontWithName:@"Helvetica" size:15];
	header1.backgroundColor = [UIColor clearColor];
	header1.textColor = [UIColor colorWithRed:211.0/255.0 green:164.0/255.0 blue:121.0/255.0 alpha:1.0];
	header1.textAlignment = UITextAlignmentCenter;
	header1.text = @"Powered by Wordnik.com";
    [self.view addSubview:header1];
    [header1 release];
    
	
	header.shadowColor = [UIColor whiteColor];
	header.shadowOffset = CGSizeMake(0.5,0.5);
	header.font = [UIFont fontWithName:@"Helvetica" size:15];
	header.backgroundColor = [UIColor clearColor];
	header.textColor = [UIColor colorWithRed:211.0/255.0 green:164.0/255.0 blue:121.0/255.0 alpha:1.0];
	header.textAlignment = UITextAlignmentCenter;
	header.text = @"";
    
	[self.view addSubview:header];
	[self.view addSubview:definitionTable];
	segment.selectedSegmentIndex = 0;
	
    
    definitionView = [[UITextView alloc] init];
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            definitionView.frame = CGRectMake(284.0,43.0,284,214);
        }
        else{
            definitionView.frame = CGRectMake(284.0,43.0,284,194);
        }
        
    }
    else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            definitionView.frame = CGRectMake(240.0,43.0,240,214);
        }
        else{
            definitionView.frame = CGRectMake(240.0,43.0,240,194);
        }
    }
	definitionView.backgroundColor = [UIColor whiteColor];
    definitionView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
	definitionView.editable = NO;
    definitionView.layer.borderWidth = 1.0;
    definitionView.layer.borderColor = [UIColor colorWithRed:224.0/255.0
                                                       green:224.0/255.0
                                                        blue:224.0/255.0
                                                       alpha:1.0].CGColor;
	[self.view addSubview:definitionView];
	[definitionView release];
    
	[definitionTable release];
	[header release];
    
    [self.view bringSubviewToFront:DefsearchBar];
    [self.view bringSubviewToFront:definitionToolbar];
    [self.view bringSubviewToFront:segment];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (![DefsearchBar.text isEqualToString:@""]) {
		[self searchBarSearchButtonClicked:DefsearchBar];
	}
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark -
#pragma mark FDefinitionControllerDelegate
-(void)definitionsForTerm:(NSString*)Aterm forDef:(NSArray*)definitions whichDef:(NSInteger)whatDef
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (!definitions) {
		return;
	}
	
	switch (whatDef) {
		case 0:
		{
			if (currentDefinitions) {
				[currentDefinitions release];
			}
			isNewDef = NO;
			currentDefinitions = [[NSMutableArray alloc] initWithArray:definitions];
			header.text = [NSString stringWithFormat:@"%d definitions",[currentDefinitions count]];
			break;
		}
		case 1:
		{
			if (currentPhrases) {
				[currentPhrases release];
			}
			isNewPhr = NO;
			currentPhrases = [[NSMutableArray alloc] initWithArray:definitions];
			header.text = [NSString stringWithFormat:@"%d phrases",[currentPhrases count]];
			break;
		}
		case 2:
		{
			if (currentExamples) {
				[currentExamples release];
			}
			isNewExm = NO;
			currentExamples = [[NSMutableArray alloc] initWithArray:definitions];
			header.text = [NSString stringWithFormat:@"%d examples",[currentExamples count]];
			break;
		}
		case 3:
		{
			if (currentRelate) {
				[currentRelate release];
			}
			isNewRel = NO;
			currentRelate = [[NSMutableArray alloc] initWithArray:definitions];
			header.text = [NSString stringWithFormat:@"%d related words",[currentRelate count]];
			break;
		}
		default:
			break;
	}
	
	
	segment.enabled = YES;
	[definitionTable reloadData];
}

-(void)definitionFailed
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	segment.enabled = YES;
	
	switch (segment.selectedSegmentIndex) {
		case 0:
		{
			if (currentDefinitions)
				header.text = [NSString stringWithFormat:@"%d definitions",[currentDefinitions count]];
			else
				header.text = [NSString stringWithFormat:@"%d definitions",0];
			
			break;
		}
		case 1:
		{
			if (currentPhrases)
				header.text = [NSString stringWithFormat:@"%d phrases",[currentPhrases count]];
			else
				header.text = [NSString stringWithFormat:@"%d phrases",0];
			
			break;
		}
		case 2:
		{
			if (currentExamples)
				header.text = [NSString stringWithFormat:@"%d examples",[currentExamples count]];
			else
				header.text = [NSString stringWithFormat:@"%d examples",0];
			
			break;
		}
		case 3:
		{
			if (currentRelate)
				header.text = [NSString stringWithFormat:@"%d related words",[currentRelate count]];
			else
				header.text = [NSString stringWithFormat:@"%d related words",0];
			
			break;
		}
		default:
			break;
	}
	
	
	[definitionTable reloadData];
}

-(void)addTextForCard:(NSString*)Atext
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if (delegate && [delegate respondsToSelector:@selector(definitionWasPicked:)]) {
		[delegate definitionWasPicked:Atext];
	}
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 39;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int count = 0;
	
	switch (segment.selectedSegmentIndex) {
		case 0:
			if (currentDefinitions)
				count = [currentDefinitions count];
			break;
		case 1:
			if (currentPhrases)
				count = [currentPhrases	count];
			break;
		case 2:
			if (currentExamples)
				count = [currentExamples count];
			break;
		case 3:
			if (currentRelate)
				count = [currentRelate count];
			break;
		default:
			break;
	}
	
	if (count>0) {
		addToCardButton.enabled = YES;
	}else {
		addToCardButton.enabled = NO;
		definitionView.text = @"";
	}
    
	return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 39)];
        bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
        
        UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 240, 39)];
        bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
        
        cell.backgroundView = bgImageView;
        cell.selectedBackgroundView = bgImageViewHighligthed;
        
        [bgImageView release];
        [bgImageViewHighligthed release];
	}
	
	cell.textLabel.numberOfLines = 1;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
	
	switch (segment.selectedSegmentIndex) {
		case 0:
			cell.textLabel.text = [currentDefinitions objectAtIndex:indexPath.row];
			break;
		case 1:
			cell.textLabel.text = [currentPhrases objectAtIndex:indexPath.row];
			break;
		case 2:
			cell.textLabel.text = [currentExamples objectAtIndex:indexPath.row];
			break;
		case 3:
			cell.textLabel.text = [currentRelate objectAtIndex:indexPath.row];
			break;
		default:
			break;
	}
	
	if (orientation == FIOrientationLandscape) {
		if (rowIndex!=-1 && rowIndex == indexPath.row) {
			[definitionTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
			definitionView.text = cell.textLabel.text;
		}
		
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *resultStr;
	
	switch (segment.selectedSegmentIndex) {
		case 0:
			resultStr = [currentDefinitions objectAtIndex:indexPath.row];
			break;
		case 1:
			resultStr = [currentPhrases objectAtIndex:indexPath.row];
			break;
		case 2:
			resultStr = [currentExamples objectAtIndex:indexPath.row];
			break;
		case 3:
			resultStr = [currentRelate objectAtIndex:indexPath.row];
			break;
		default:
			break;
	}
	
	if (rowIndex != -1 && rowIndex != indexPath.row) {
		[tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0] animated:YES];
		rowIndex = indexPath.row;
		definitionView.text = resultStr;
	}
    
}

#pragma mark -
#pragma mark UISearchBarDelegate

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	self.term = searchBar.text;
	
	isNewDef = YES;
	isNewPhr = YES;
	isNewExm = YES;
	isNewRel = YES;
	
	[self segmentChanged];
	
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark private

-(void)initSearchBar
{
	
	if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            DefsearchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(0,0,568,49)];
        }
        else {
            DefsearchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(0,0,480,49)];
        }
       	
        DefsearchBar.bgImage = [Util imageFromBundle:@"i_images_topbg.png"];
    }else{
      	DefsearchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(0,0,480,44)];
        DefsearchBar.barStyle = UIBarStyleBlackOpaque;
        DefsearchBar.tintColor = kDefaultNavColor;
    }
    
	DefsearchBar.delegate = self;
	DefsearchBar.showsCancelButton = NO;
	[self.view addSubview:DefsearchBar];
	[DefsearchBar release];
	
    
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
	backButton.frame = CGRectMake(5,5,59,34);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
    
}

-(void)backPressed
{
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)addToCardButtonPressed:(id)sender
{
	if (rowIndex != -1) {
		NSString *resultStr;
		
		switch (segment.selectedSegmentIndex) {
			case 0:
				resultStr = [currentDefinitions objectAtIndex:rowIndex];
				break;
			case 1:
				resultStr = [currentPhrases objectAtIndex:rowIndex];
				break;
			case 2:
				resultStr = [currentExamples objectAtIndex:rowIndex];
				break;
			case 3:
				resultStr = [currentRelate objectAtIndex:rowIndex];
				break;
			default:
				break;
		}
		
		if (delegate && [delegate respondsToSelector:@selector(definitionWasPicked:)]) {
			[delegate definitionWasPicked:resultStr];
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Definition"
															message:@"Text added to card"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
		
	}
}

-(void)initSegmentedController
{
	NSArray *defArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set1_definition1.png"],
                       [UIImage imageNamed:@"i_set1_definition2.png"],
					   [UIImage imageNamed:@"i_set1_definition3.png"],nil];
	
	NSArray *phaseArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set1_phrases1.png"],
                         [UIImage imageNamed:@"i_set1_phrases2.png"],
                         [UIImage imageNamed:@"i_set1_phrases3.png"],nil];
	
	NSArray *exArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set1_examples1.png"],
                      [UIImage imageNamed:@"i_set1_examples2.png"],
                      [UIImage imageNamed:@"i_set1_examples3.png"],nil];
	
	NSArray *relArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set1_related1.png"],
					   [UIImage imageNamed:@"i_set1_related2.png"],
					   [UIImage imageNamed:@"i_set1_related3.png"],nil];
	
	segment = [[FCustomSegmentedController alloc] initWithItems:[NSArray arrayWithObjects:defArr,
                                                                 phaseArr,
                                                                 exArr,
                                                                 relArr,nil]];
	
    
    if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            segment.center = CGPointMake(289,300);
            
        }
        else {
            segment.center = CGPointMake(245,280);
        }
    }
	
	
	
	
	[segment addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
	
	definitionToolbar = [[FIToolBar alloc] initWithFrame:CGRectMake(0.0,256,480,44)];
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            definitionToolbar.frame = CGRectMake(0.0,276,568,44);
        }
        else {
            definitionToolbar.frame = CGRectMake(0.0,256,480,44);
        }
        
        definitionToolbar.bgImage = [Util imageFromBundle:@"i_images_bottombg.png"];
    }else{
        definitionToolbar.tintColor = kDefaultNavColor;
        definitionToolbar.tintColor = [UIColor colorWithRed:205.0/255.0 green:175.0/255.0 blue:149.0/255.0 alpha:1.0];
    }
    
	[self.view addSubview:definitionToolbar];
	[definitionToolbar release];
	
    UIBarButtonItem *backButton;
    
    if ([Util isPhone]) {
        UIButton *customSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *saveImage = [Util imageFromBundle:@"i_add_done1.png"];
        customSaveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
        [customSaveButton setImage:saveImage forState:UIControlStateNormal];
        [customSaveButton setImage:[Util imageFromBundle:@"i_add_done2.png"] forState:UIControlStateHighlighted];
        customSaveButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        [customSaveButton addTarget:self
                             action:@selector(backPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        backButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
	}else{
        backButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(backPressed)];
    }
    
    if ([Util isPhone]) {
        UIButton *customDefinitionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *tocardImage = [Util imageFromBundle:@"i_butt_tocard1.png"];
        customDefinitionButton.frame = CGRectMake(0, 0, tocardImage.size.width, tocardImage.size.height);
        [customDefinitionButton setImage:tocardImage forState:UIControlStateNormal];
        customDefinitionButton.imageEdgeInsets = UIEdgeInsetsMake(2, -4, -2, 4);
        [customDefinitionButton setImage:[Util imageFromBundle:@"i_butt_tocard2.png"] forState:UIControlStateHighlighted];
        [customDefinitionButton addTarget:self
                                   action:@selector(addToCardButtonPressed:)
                         forControlEvents:UIControlEventTouchUpInside];
        addToCardButton = [[UIBarButtonItem alloc] initWithCustomView:customDefinitionButton];
    }else{
        addToCardButton = [[UIBarButtonItem alloc] initWithTitle:@"To card"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(addToCardButtonPressed:)];
    }
    
	UIBarButtonItem *width = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            
            width.width = 405;
        }
        else {
            width.width = 325;
        }
    }
	
	
	[definitionToolbar setItems:[NSArray arrayWithObjects:addToCardButton,width,backButton,nil]];
	[backButton release];
	[addToCardButton release];
	[width release];
    
	[self.view addSubview:segment];
	
	
	[segment release];
}

-(void)segmentChanged
{
	if ([DefsearchBar.text isEqualToString:@""]) {
		return;
	}
	
	rowIndex = 0;
    
	switch (segment.selectedSegmentIndex) {
		case 0:
			if (!isNewDef)
			{
				header.text = [NSString stringWithFormat:@"%d definitions",[currentDefinitions count]];
				[definitionTable reloadData];
				return;
			}
			break;
		case 1:
			if (!isNewPhr)
			{
				header.text = [NSString stringWithFormat:@"%d phrases",[currentPhrases count]];
				[definitionTable reloadData];
				return;
			}
			break;
		case 2:
			if (!isNewExm)
			{
				header.text = [NSString stringWithFormat:@"%d examples",[currentExamples count]];
				[definitionTable reloadData];
				return;
			}
			break;
		case 3:
			if (!isNewRel)
			{
				header.text = [NSString stringWithFormat:@"%d related words",[currentRelate count]];
				[definitionTable reloadData];
				return;
			}
			break;
		default:
			break;
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	segment.enabled = NO;
	
	addToCardButton.enabled = NO;
	[definitionTable reloadData];
	[[FDefinitionController sharedDefinitionWithDelegate:self] getDefinitionForTerm:DefsearchBar.text forWhich:segment.selectedSegmentIndex];
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
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	
	if (currentDefinitions) {
		[currentDefinitions release];
	}
	
	if (currentPhrases) {
		[currentPhrases release];
	}
	
	if (currentExamples) {
		[currentExamples release];
	}
	
	if (currentRelate) {
		[currentRelate release];
	}
	
	self.term = nil;
	
    [super dealloc];
}


@end
