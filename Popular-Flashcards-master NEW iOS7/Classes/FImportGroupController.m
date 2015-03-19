    //
//  FImportGroupController.m
//  flashCards
//
//  Created by Ruslan on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FImportGroupController.h"
#import "FImportApiMainController.h"
#import "QISearchViewController.h"
#import "FDBController.h"

@implementation FImportGroupController
@synthesize delegate;
@synthesize subset;

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
	self.view = contentView;
	[contentView release];
	[self setContentSizeForViewInPopover:CGSizeMake(540,580)];
	
	CGRect tableFrame = CGRectMake(0,0,540,580);
	
	groupTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    groupTable.delegate = self;
    groupTable.dataSource = self;
    [self.view addSubview:groupTable];
	[groupTable release];
	
	self.navigationItem.title = subset;
	
}

-(void)setGroup:(NSArray*)gArray
{
	if (groupArray) {
		[groupArray release];
		groupArray = nil;
	}
	
	if (gArray) {
		groupArray = [[NSArray alloc] initWithArray:gArray];
	}
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.title = @"Back";
}

-(void)viewWillAppear:(BOOL)animated{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationItem.title = subset;
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (groupArray) 
		return [groupArray count];
	else
		return 0;

}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.textLabel.text = [groupArray objectAtIndex:indexPath.row];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSDictionary *fDic = [NSDictionary dictionaryWithObject:[groupArray objectAtIndex:indexPath.row]
													 forKey:@"category"];
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet default categories" withParam:fDic];
	
	QISearchViewController *mainController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
    mainController.searchString = [groupArray objectAtIndex:indexPath.row];
	mainController.contentSizeForViewInPopover = CGSizeMake(550,500);
	[self.navigationController pushViewController:mainController animated:YES];
	[mainController release];
}



#pragma mark -

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	
	if (groupArray) {
		[groupArray release];
	}
	
	if(subset)
		[subset release];
	
    [super dealloc];
}


@end
