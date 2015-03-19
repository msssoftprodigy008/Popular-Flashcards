    //
//  FDefinitionViewController.m
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FDefinitionViewController.h"
#import "ModalAlert.h"
#import "FRootConstants.h"
#import "Constants.h"
#import "Util.h"

@interface FDefinitionViewController(Private)

-(void)initSearchBar;
-(void)initSegmentedController;
-(void)segmentChanged;
-(void)doneButtonPressed;
@end


@implementation FDefinitionViewController
@synthesize delegate;
@synthesize term;

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kDefinitionControllerWidth,kDefinitionControllerHieght)];
	self.view = contentView;
	[contentView release];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];       
	
	isNewDef = YES;
	isNewPhr = YES;
	isNewExm = YES;
	isNewRel = YES;
	
	[self initSearchBar];
	
	if (term) {
		DefsearchBar.text = term;
	}
	
	[self initSegmentedController];
	CGRect frame = CGRectMake(0,60+segment.frame.size.height,kDefinitionControllerWidth,kDefinitionControllerHieght-(60+segment.frame.size.height)-30);
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem	alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				 action:@selector(doneButtonPressed)];
	self.navigationItem.leftBarButtonItem = doneButton;
	
	definitionTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	definitionTable.delegate = self; 
	definitionTable.dataSource = self;
	
	header = [[UILabel alloc] initWithFrame:CGRectMake(0,kDefinitionControllerHieght-32,kDefinitionControllerWidth,30)];
	header.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
	header.shadowOffset = CGSizeMake(1,1);
	header.font = [UIFont fontWithName:@"Helvetica" size:24];
	header.backgroundColor = [UIColor clearColor];
	header.textColor = [UIColor whiteColor];
    header.shadowColor = [UIColor darkGrayColor];
    header.shadowOffset = CGSizeMake(1, 1);
	header.textAlignment = UITextAlignmentCenter;
	header.text = @"";
	
	[self.view addSubview:header];
	
	self.navigationItem.title = @"Powered by Wordnik.com";	
	[self.view addSubview:definitionTable];
	[doneButton release];
	[definitionTable release];
	[header release];
	
}

-(void)setTerm:(NSString*) Aterm{
	if (term) {
		[term release];
		term = nil;
	}
	
	if (Aterm) {
		term = [[NSString alloc] initWithString:Aterm];
	}
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

#pragma mark -
#pragma mark private

-(void)addTextToCard:(NSString*)Atext
{
	if (delegate && [delegate respondsToSelector:@selector(definitionPicked:)]) {
		[delegate definitionPicked:Atext];
	}
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (segment.selectedSegmentIndex) {
		case 0:
			if (currentDefinitions) 
				return [currentDefinitions count];
			break;
		case 1:
			if (currentPhrases) 
				return [currentPhrases	count];
			break;
		case 2:
			if (currentExamples) 
				return [currentExamples count];
			break;
		case 3:
			if (currentRelate)
				return [currentRelate count];
			break;
		default:
			break;
	}
	
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	
	cell.textLabel.numberOfLines = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:24];
	
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
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (delegate && [delegate respondsToSelector:@selector(definitionPicked:)]) {
		
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
		
		FTextView *textView = [[FTextView alloc] init];
		textView.delegate = self;
		[textView showText:resultStr];
		textView.contentSizeForViewInPopover = CGSizeMake(500,500);
		[self.navigationController pushViewController:textView animated:YES];
		[textView release];
		
	}
	
}

#pragma mark -
#pragma mark private

-(void)doneButtonPressed
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	[self dismissModalViewControllerAnimated:YES];
}

-(void)initSearchBar
{
	DefsearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0,kDefinitionControllerWidth,50)];
	DefsearchBar.translucent = YES;
	DefsearchBar.tintColor = [UIColor lightGrayColor];
	DefsearchBar.delegate = self;
	DefsearchBar.showsCancelButton = YES;
	[self.view addSubview:DefsearchBar];
	[DefsearchBar release];
}

-(void)initSegmentedController
{
	segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Definition",
															@"Phrases",
															@"Examples",
														  @"Related words",nil]];
	segment.segmentedControlStyle = UISegmentedControlStyleBar;
	segment.tintColor = [UIColor lightGrayColor];
	segment.center = CGPointMake(250,segment.frame.size.height/2+55);
  	segment.selectedSegmentIndex = 0;
	[segment addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    [self segmentChanged];
	[self.view addSubview:segment];
	[segment release];
}

-(void)segmentChanged
{
	if (!term) {
		return;
	}
	NSMutableDictionary *fDic = [NSMutableDictionary dictionaryWithObject:term forKey:@"term"];
	switch (segment.selectedSegmentIndex) {
		case 0:
			if (!isNewDef) 
			{
				header.text = [NSString stringWithFormat:@"%d definitions",[currentDefinitions count]];
				[fDic setObject:@"definitions" forKey:@"category"];
				[definitionTable reloadData];
				return;
			}
			break;
		case 1:
			if (!isNewPhr) 
			{
				header.text = [NSString stringWithFormat:@"%d phrases",[currentPhrases count]];
				[fDic setObject:@"phrases" forKey:@"category"];
				[definitionTable reloadData];
				return;
			}
			break;
		case 2:
			if (!isNewExm) 
			{
				header.text = [NSString stringWithFormat:@"%d examples",[currentExamples count]];
				[fDic setObject:@"examples" forKey:@"category"];
				[definitionTable reloadData];
				return;
			}
			break;
		case 3:
			if (!isNewRel) 
			{
				header.text = [NSString stringWithFormat:@"%d related words",[currentRelate count]];
				[fDic setObject:@"related words" forKey:@"category"];
				[definitionTable reloadData];
				return;
			}
			break;
		default:
			break;
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	segment.enabled = NO;
	[definitionTable reloadData];
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Wordnik definition" withParam:fDic];
	[[FDefinitionController sharedDefinitionWithDelegate:self] getDefinitionForTerm:term forWhich:segment.selectedSegmentIndex];
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

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[[FDefinitionController sharedDefinitionWithDelegate:self] cancelOperation];
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
	
	if (term) {
		[term release];
	}
	
    [super dealloc];
}


@end
