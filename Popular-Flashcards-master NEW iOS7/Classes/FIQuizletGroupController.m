    //
//  FIQuizletGroupController.m
//  flashCards
//
//  Created by Ruslan on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIQuizletGroupController.h"
#import "FIQuizletAvailableSetsController.h"
#import "FDBController.h"
#import "QISearchViewController.h"
#import "FINavigationBar.h"
#import "Util.h"
#import "Constants.h"

@interface FIQuizletGroupController(Private)

-(void)initTopBar;
-(void)backPressed;

@end



@implementation FIQuizletGroupController
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
	UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
	self.view = contentView;
	[contentView release];
	self.view.backgroundColor = [UIColor clearColor];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	groups = [[UITableView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),((IS_IPHONE_5)?285:265)) style:UITableViewStylePlain];
	groups.delegate = self;
	groups.dataSource = self;
	groups.backgroundColor = [UIColor whiteColor];
    groups.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	[self.view addSubview:groups];
	[groups release];
	
	[self initTopBar];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)setGroupArray:(NSMutableArray*)gArray
{
	if (groupArray) {
		[groupArray release];
		groupArray = nil;
	}
	
	if(gArray)
		groupArray = [[NSArray alloc] initWithArray:gArray];
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
	if (groupArray) 
		return [groupArray count];
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
        
        UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
        
        cell.backgroundView = bgImageView;
        cell.selectedBackgroundView = bgImageViewHighligthed;
        
        [bgImageView release];
        [bgImageViewHighligthed release];
	}
	
	NSString *subSetName = [groupArray objectAtIndex:indexPath.row];
	cell.textLabel.text = subSetName;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 39;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	QISearchViewController *qiuzletAvailableController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
	
	NSString *setName = [groupArray objectAtIndex:indexPath.row];
	
	NSDictionary *fDic = [NSDictionary dictionaryWithObject:setName forKey:@"category"];
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet category" withParam:fDic];
	
	qiuzletAvailableController.searchString = setName;
	[self.navigationController pushViewController:qiuzletAvailableController animated:YES];
	[qiuzletAvailableController release];
	
}


#pragma mark -
#pragma mark Private

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
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:subset];
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

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
		
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
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
	
	if (groupArray) {
		[groupArray release];
	}
	
	if (subset) {
		[subset release];
	}
	
    [super dealloc];
}


@end
