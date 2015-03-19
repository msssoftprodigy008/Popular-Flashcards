    //
//  FIQuizletSubSetController.m
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIQuizletSubSetController.h"
#import "FDBController.h"
#import "FINavigationBar.h"
#import "Util.h"
#import "Constants.h"
#import "FIQuizletGroupController.h"
#import "FIQuizletAvailableSetsController.h"
#import "QISearchViewController.h"

@interface FIQuizletSubSetController(Private)

-(void)initTopBar;
-(void)backPressed;

@end


@implementation FIQuizletSubSetController
@synthesize category;
@synthesize categoryId;

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
	UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	if (category) 
		availableSubCategoriesArray = [[NSMutableArray alloc] initWithArray:[[FDBController sharedDatabase] quizletSubsets:categoryId]];
	
	availableSubCategoriesTable = [[UITableView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),((IS_IPHONE_5)?285:265)) style:UITableViewStylePlain];
	availableSubCategoriesTable.delegate = self;
	availableSubCategoriesTable.dataSource = self;
	availableSubCategoriesTable.backgroundColor = [UIColor whiteColor];
    availableSubCategoriesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:availableSubCategoriesTable];
	[availableSubCategoriesTable release];
	
	[self initTopBar];
	
}

-(void)viewWillAppear:(BOOL)animated
{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	self.navigationItem.title = category;
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


#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (availableSubCategoriesArray) 
		return [availableSubCategoriesArray count];
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
        
        UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
        
        cell.backgroundView = bgImageView;
        cell.selectedBackgroundView = bgImageViewHighligthed;
        
        [bgImageView release];
        [bgImageViewHighligthed release];
	}
	
	NSString *subSetName = [[availableSubCategoriesArray objectAtIndex:indexPath.row] objectAtIndex:1];
	cell.textLabel.text = subSetName;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 39;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSInteger catId	= [[[availableSubCategoriesArray objectAtIndex:indexPath.row] objectAtIndex:0] intValue];
	NSString *setName = [[availableSubCategoriesArray objectAtIndex:indexPath.row] objectAtIndex:1];
	
	NSMutableArray *groups = [[FDBController sharedDatabase] quizletGroups:catId];
	
	if (groups && [groups count]>0) {
		FIQuizletGroupController *groupController = [[FIQuizletGroupController alloc] init];
		[groupController setGroupArray:groups];
		groupController.subset = setName;
		[self.navigationController pushViewController:groupController animated:YES];
		[groupController release];
	}else {
		QISearchViewController *availableController = [[QISearchViewController alloc] init];
		availableController.searchString = setName;
		[self.navigationController pushViewController:availableController animated:YES];
		[availableController release];
	}

		
	
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark private methods

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
	FINavigationBar *topBar = [[FINavigationBar alloc] init];
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
        }
        else{
            topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
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
            topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
        }
        else{
            topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
        }
    }

	topBar.bgImage	= [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:category];
	[topBar pushNavigationItem:topItem animated:NO];
	[topItem release];
	[self.view addSubview:topBar];
	[topBar release];
	
	UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *customBackButtonImage = [UIImage imageNamed:@"i_panel_back1.png"];
	customBackButton.frame = CGRectMake(0,0,customBackButtonImage.size.width,customBackButtonImage.size.height);
	[customBackButton setImage:customBackButtonImage
					  forState:UIControlStateNormal];
	[customBackButton setImage:[UIImage imageNamed:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
	[customBackButton addTarget:self
						 action:@selector(backPressed)
			   forControlEvents:UIControlEventTouchUpInside];
	
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
	topItem.leftBarButtonItem = backButton;
	[backButton release];
	
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
	[availableSubCategoriesArray release];
	
	if (category) {
		[category release];
	}
	
    [super dealloc];
}


@end
