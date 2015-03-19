    //
//  FIQuizletSearchController.m
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIQuizletSearchController.h"
#import "FIQuizletDetailController.h"
#import "FINavigationBar.h"
#import "FILoadingView.h"
#import "FHTMLConverter.h"
#import "Util.h"
#import "FRootConstants.h"
#import "DBTime.h"
#import "Constants.h"

@interface FIQuizletSearchController(Private)

-(void)initTopBar;
-(void)initSearchBar;
-(void)initSegmentView;
-(void)morePressed;
-(void)searchTextChanged;
-(void)loadChooseImages;
-(void)backPressed;
-(void)segmentChanged:(id)sender;

@end


@implementation FIQuizletSearchController

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight; 
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	[self initSearchBar];	
	[self initSegmentView];
	availableQuizletSetsArray = [[NSMutableArray alloc] init];
	
	availableQuizletSetsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,3*44-12,480,312-3*44) style:UITableViewStylePlain];
	availableQuizletSetsTable.delegate = self;
	availableQuizletSetsTable.dataSource = self;
	availableQuizletSetsTable.backgroundColor = [UIColor whiteColor];
    availableQuizletSetsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:availableQuizletSetsTable];
	[availableQuizletSetsTable release];
	
	curPageNum = 1;
	totalPages = 2;
	currSetVisible = 0;
	totalSets = 0;
	
	loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0,32,480,268)];
	quizletImport = [[FQuizletImport alloc] initWithDelegate:self];
  	[self initTopBar];
	    
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[searchView becomeFirstResponder];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (availableQuizletSetsArray && [availableQuizletSetsArray count])
	{
		if (curPageNum!=totalPages) 
			return [availableQuizletSetsArray count]+1;
		else
			return [availableQuizletSetsArray count];
		
	}
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
	static NSString *CellIdentifierLast = @"LastCell";
    UITableViewCell *cell;
	
	if ((indexPath.row != [theTableView numberOfRowsInSection:0]-1) || curPageNum == totalPages) 
		cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	else
		cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifierLast];
	
	
    if (cell == nil) {
		
		if ((indexPath.row != [theTableView numberOfRowsInSection:0]-1) || curPageNum==totalPages) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			
			UIImage *accesoryImage = [UIImage imageNamed:@"pic.png"];
			
			UIImageView *accesoryView = [[UIImageView alloc] initWithImage:accesoryImage highlightedImage:accesoryImage];
			accesoryView.backgroundColor = [UIColor clearColor];
			
			cell.accessoryView = accesoryView;
			[accesoryView release];
			
			cell.textLabel.backgroundColor = [UIColor clearColor];
			cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
			cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
			cell.backgroundColor = [UIColor whiteColor];
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 39)];
            bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
            
            UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 39)];
            bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
            
            cell.backgroundView = bgImageView;
            cell.selectedBackgroundView = bgImageViewHighligthed;
            
            [bgImageView release];
            [bgImageViewHighligthed release];
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLast] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
			cell.textLabel.numberOfLines = 0;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
		}
		
	}
	
	if ((indexPath.row != [theTableView numberOfRowsInSection:0]-1) || curPageNum==totalPages) 
	{
		NSDictionary *setInfo = [availableQuizletSetsArray objectAtIndex:indexPath.row];
		
		if (setInfo) {
			NSString *setName = [setInfo objectForKey:@"title"];
			
			if (setName) {
				
				FHTMLConverter *converter = [[FHTMLConverter alloc] init];
				setName = [converter convertEntiesInString:setName];
				[converter release];
				cell.textLabel.text = setName;
			}
			
			NSMutableString *detailStr = [NSMutableString string];
			
			NSInteger cardCount = [[setInfo objectForKey:@"term_count"] intValue];
			[detailStr appendFormat:@"%d cards ",cardCount];
			
			NSInteger dateInt = [[setInfo objectForKey:@"created"] intValue];
			NSDate *date = [DBTime dateFromDBTime:dateInt];
			
			if (date) {
				NSString *dateStr = [Util fullTimeStringFromDate:date];
				
				if (dateStr) {
					[detailStr appendFormat:@"/ %@",dateStr];
				}
				
			}
			
			cell.detailTextLabel.text = detailStr;
			
			BOOL hasImage = [[setInfo objectForKey:@"has_images"] boolValue];
			UIImage *accesoryImage = nil;
			
			if (hasImage) {
				accesoryImage = [UIImage imageNamed:@"pic.png"];
			}
			
			UIImageView *accesoryView = (UIImageView*)cell.accessoryView;
			accesoryView.image = accesoryImage;
			accesoryView.highlightedImage = accesoryImage;
		}
		
	}
	else {
		NSString *text = [NSString stringWithFormat:@"%d out of %d sets.\nTap here to see more",currSetVisible,totalSets];
		cell.textLabel.text = text;
	}
	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ((indexPath.row == [availableQuizletSetsArray count]) && curPageNum!=totalPages) 
		return kCellHight;
	else
		return 39;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	if ((indexPath.row == [tableView numberOfRowsInSection:0]-1) && curPageNum!=totalPages) {
		[self morePressed];
	}
	else {
		FIQuizletDetailController *detailController = [[FIQuizletDetailController alloc] init];
		detailController.setInfoDictionary = [availableQuizletSetsArray objectAtIndex:indexPath.row];
        
        NSLog(@"availableQuizletSetsArray--> %@",availableQuizletSetsArray);
		[self.navigationController pushViewController:detailController animated:YES];
		[detailController release];
	}
	
	
}

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView{
    NSLog(@"%0.2lf",tableView.contentOffset.y);
        /*if (indexPathLast.row == indexPath.row && curPageNum < totalPages) {
            [self morePressed];
        }*/
}

#pragma mark -
#pragma mark FQuizletImport delegate

-(void)listFormed:(BOOL)isSucces forData:(NSDictionary*)dic forError:(NSString*)errorMsg;
{
	if (isSucces) {
		
		if (availableSetDictionary) {
			[availableSetDictionary release];
			availableSetDictionary = nil;
		}
		
		if (dic) 
		{
			availableSetDictionary = [[NSDictionary alloc] initWithDictionary:dic];
			
			NSArray *currSets = [availableSetDictionary objectForKey:@"sets"];
			
			if (currSets) {
				currSetVisible = currSetVisible+[currSets count];
				totalSets = [[availableSetDictionary objectForKey:@"total"] intValue];
				totalPages = [[availableSetDictionary objectForKey:@"total_pages"] intValue];
				
				[availableQuizletSetsArray addObjectsFromArray:currSets];
			}
			[dic release];
		}
		
		[availableQuizletSetsTable reloadData];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:errorMsg
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	
	[loadingView dismiss];
	
	
}


#pragma mark -
#pragma mark UISearchBarDelegate

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	if (searchBar && searchBar.text != @"") {
		
		NSDictionary *fDic = [NSDictionary dictionaryWithObject:searchBar.text forKey:@"category"];
		[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet search category" withParam:fDic];
		
		[loadingView showInView:self.view];
		[quizletImport cancel];
		switch (searchType) {
			case FISearchTypeSubject:
				[quizletImport findBySubject:searchBar.text sortBy:0 pages:curPageNum];	
				break;
			case FISearchTypeCreator:
				[quizletImport findByCreator:searchBar.text sortBy:0 pages:curPageNum];
				break;
			case FISearchTypeTerm:
				[quizletImport findByTerm:searchBar.text sortBy:0 pages:curPageNum];
				break;
	
			default:
				break;
		}
		
	}
	
		
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	
	[loadingView dismiss];
	if (quizletImport) {
		[quizletImport cancel];
	}
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if (currSetVisible == 0) {
		return;
	}
	
	curPageNum = 1;
	totalPages = 0;
	currSetVisible = 0;
	totalSets = 0;
	
	if (availableQuizletSetsArray) {
		[availableQuizletSetsArray release];
	}
	
	availableQuizletSetsArray = [[NSMutableArray alloc] init];
    
    NSLog(@"availableQuizletSetsArray--> %@",availableQuizletSetsArray);
	
	if (availableSetDictionary) {
		[availableSetDictionary release];
		availableSetDictionary = nil;
	}
	
	[availableQuizletSetsTable reloadData];
}

#pragma mark -
#pragma mark privateMethods

-(void)backPressed
{
	if (quizletImport) {
		[quizletImport cancel];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
	FINavigationBar *topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,37)];
	topBar.bgImage = [Util imageFromBundle:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@"Powered by Quizlet.com"];
	[topBar pushNavigationItem:topItem animated:NO];
	[topItem release];
	[self.view addSubview:topBar];
	[topBar release];
	
    UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [Util imageFromBundle:@"i_panel_back1.png"];
    customBackButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    [customBackButton setImage:backImage forState:UIControlStateNormal];
    [customBackButton setImage:[Util imageFromBundle:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
    [customBackButton addTarget:self
                         action:@selector(backPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
	topItem.leftBarButtonItem = backButton;
	[backButton release];
	
}

-(void)initSearchBar
{
	searchView = [[FISearchBar alloc] initWithFrame:CGRectMake(0,32,480,49)];
    searchView.bgImage = [Util imageFromBundle:@"i_images_topbg.png"];
	searchView.delegate = self;
	[self.view addSubview:searchView];
	
	[searchView release];
}

-(void)initSegmentView
{
	/*UIToolbar *segmentBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,2*44,480,44)];
	segmentBar.tintColor = kDefaultNavColor; 
	[self.view addSubview:segmentBar];
	[segmentBar release];*/
	
    NSArray *subjectArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_subject1.png"],
                        [UIImage imageNamed:@"i_set3_subject2.png"],
                        [UIImage imageNamed:@"i_set3_subject3.png"],nil];
	
	NSArray *creatorArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_creator1.png"],
                           [UIImage imageNamed:@"i_set3_creator2.png"],
                           [UIImage imageNamed:@"i_set3_creator3.png"],nil];
	
	NSArray *termArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_term1.png"],
                           [UIImage imageNamed:@"i_set3_term2.png"],
                           [UIImage imageNamed:@"i_set3_term3.png"],nil];
    
	segment = [[FCustomSegmentedController alloc] initWithItems:[NSArray arrayWithObjects:subjectArr,
																			 creatorArr,
																			 termArr,nil]];
	segment.center = CGPointMake(240,2*44+10);
	segment.selectedSegmentIndex = 0;
	[segment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:segment];
	[segment release];
}

-(void)morePressed
{
	curPageNum++;
	[loadingView showInView:self.view];
	
	if (searchView && ![searchView.text isEqualToString:@""]) 
		[quizletImport findBySubject:searchView.text sortBy:0 pages:curPageNum];
}

-(void)segmentChanged:(id)sender
{
	searchType = segment.selectedSegmentIndex;
	[self searchBarSearchButtonClicked:searchView];
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
	
	if (availableSetDictionary) {
		[availableSetDictionary release];
	}
	
	[quizletImport release];
	[availableQuizletSetsArray release];
	[loadingView release];
	
    [super dealloc];
}


@end
