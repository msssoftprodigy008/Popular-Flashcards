//
//  FImportCategoryController.m
//  flashCards
//
//  Created by Ruslan on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FImportCategoryController.h"
#import "FDBController.h"
#import "Util.h"
#import "FImportApiSecondaryController.h"
#import "QISearchViewController.h"
#import "Constants.h"

@interface FImportCategoryController(Private)
#pragma mark init
-(void)initTableView;

#pragma mark targets
-(void)searchButtonPressed:(id)sender;

@end

@implementation FImportCategoryController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    availableSetsArray = [[NSMutableArray alloc] initWithArray:[[FDBController sharedDatabase] quizletCategories]];
    [self initTableView];
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                  target:self
                                                                                  action:@selector(searchButtonPressed:)];
    self.navigationItem.rightBarButtonItem = searchButton;
    [searchButton release];
    self.navigationItem.title = @"Categories";
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.title = @"Back";
}

-(void)viewWillAppear:(BOOL)animated{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationItem.title = @"Categories";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void)dealloc{
    if (availableSetsArray) {
        [availableSetsArray release];
    }
    [super dealloc];
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (availableSetsArray) 
		return [availableSetsArray count];
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [availableSetsTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	NSString *catName = [[availableSetsArray objectAtIndex:indexPath.row] objectAtIndex:1];
	cell.textLabel.text = catName;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[availableSetsTable deselectRowAtIndexPath:indexPath animated:NO];
	
	if (availableSetsArray) {
		NSArray *categoryInfoArray = [availableSetsArray objectAtIndex:indexPath.row];
        
		if (categoryInfoArray) 
		{
			NSString *category = [categoryInfoArray objectAtIndex:1];
			NSInteger categoryId = [[categoryInfoArray objectAtIndex:0] intValue];
			FImportApiSecondaryController *subsetController = [[FImportApiSecondaryController alloc] init];
            [subsetController setDelegate:self forId:categoryId forCategory:category];
			[self.navigationController pushViewController:subsetController animated:YES];
			[subsetController release];
		}
		
	}
	
}

#pragma mark init
-(void)initTableView{
    CGRect tableFrame = CGRectMake(0,0,540,580);
	availableSetsTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    availableSetsTable.delegate = self;
    availableSetsTable.dataSource = self;
	[self.view addSubview:availableSetsTable];
	[availableSetsTable release];
}

#pragma mark targets
-(void)searchButtonPressed:(id)sender{
    QISearchViewController *search = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
    [self.navigationController pushViewController:search animated:YES];
    [search release];
}

@end
