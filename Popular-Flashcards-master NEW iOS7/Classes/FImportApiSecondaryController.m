    //
//  FImportApiSecondaryController.m
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FImportApiSecondaryController.h"
#import "QISearchViewController.h"
#import "FImportGroupController.h"
#import "FDBController.h"

@implementation FImportApiSecondaryController

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
		
	subsets = [[NSMutableArray alloc] initWithArray:[[FDBController sharedDatabase] quizletSubsets:categoryId]];
	
	if (!subsets) {
		NSLog(@"%@",@"quizlet error");
	}
   
	CGRect tableFrame = CGRectMake(0,0,540,580);
    
	if (importTable == nil) {
        importTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        importTable.delegate = self;
        importTable.dataSource = self;
    } else {
        importTable.frame = tableFrame;
    }
	[self.view addSubview:importTable];
	[importTable release];
	self.navigationItem.title = category;
	
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationItem.title = @"Back";
}

-(void)viewWillAppear:(BOOL)animated{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    self.navigationItem.title = category;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)setDelegate:(id)Adelegate forId:(NSInteger)Aid forCategory:(NSString*)Acategory
{
	delegate = Adelegate;
	
	if (category) {
		[category release];
	}
	
	category = [[NSString alloc] initWithString:Acategory];
	categoryId = Aid;
	
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [subsets count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [importTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.textLabel.text = [[subsets objectAtIndex:indexPath.row] objectAtIndex:1];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[importTable deselectRowAtIndexPath:indexPath animated:NO];
	
	NSInteger catId = [[[subsets objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
	NSString* groupName = [[subsets objectAtIndex:indexPath.row] objectAtIndex:1];
	NSMutableArray *groups = [[FDBController sharedDatabase] quizletGroups:catId];
	
	if (groups && [groups count]>0) {
		FImportGroupController *groupController = [[FImportGroupController alloc] init];
		[groupController setGroup:groups];
		groupController.subset = groupName;
		groupController.delegate = delegate;
		[self.navigationController pushViewController:groupController animated:YES];
		[groupController release];
	}else {
		QISearchViewController *mainController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
		mainController.searchString = groupName;
		mainController.contentSizeForViewInPopover = CGSizeMake(550,500);
		[self.navigationController pushViewController:mainController animated:YES];
		[mainController release];
	}
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
	[category release];
	[subsets release];
    [super dealloc];
}


@end
