    //
//  FIQuizletAvailableSetsController.m
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIQuizletAvailableSetsController.h"
#import "FIQuizletSearchController.h"
#import "FIQuizletDetailController.h"
#import "FINavigationBar.h"
#import "FRootConstants.h"
#import "FILoadingView.h"
#import "FQuizletImport.h"
#import "FHTMLConverter.h"
#import "Util.h"
#import "DBTime.h"
#import "Constants.h"

@interface FIQuizletAvailableSetsController(Private)

-(void)initTopBar;
-(void)backPressed;
-(NSDictionary*)generateInfoDic:(NSInteger)index;

@end


@implementation FIQuizletAvailableSetsController
@synthesize category;
@synthesize title;

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
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,300)];

        }else
        {
        
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];

        }
        
    }
	
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;	
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	availableQuizletSetsArray = [[NSMutableArray alloc] init];
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            availableQuizletSetsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,35,568,265) style:UITableViewStylePlain];
        }else
        {
            
           availableQuizletSetsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,35,480,265) style:UITableViewStylePlain];
            
        }
        
    }
	
	availableQuizletSetsTable.delegate = self;
	availableQuizletSetsTable.dataSource = self;
	availableQuizletSetsTable.backgroundColor = [UIColor whiteColor];
    availableQuizletSetsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:availableQuizletSetsTable];
	[availableQuizletSetsTable release];

   	[self initTopBar];
    loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0,35,480,265)];
	
	if (category) {
		[loadingView showInView:self.view];
        [[QIRequest sharedRequest] fetchSetsForGroup:self group:category page:0];
	}
	
    [self.view bringSubviewToFront:topBar];
}

-(void)viewWillAppear:(BOOL)animated
{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	isSearch = NO;
	

}

-(void)viewDidDisappear:(BOOL)animated
{
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
	if (availableQuizletSetsArray && [availableQuizletSetsArray count]>0)
	{
		return [availableQuizletSetsArray count];
	}
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		
			UIImage *accesoryImage = [UIImage imageNamed:@"i_pic.png"];
		
			UIImageView *accesoryView = [[UIImageView alloc] initWithImage:accesoryImage highlightedImage:accesoryImage];
			accesoryView.backgroundColor = [UIColor clearColor];
		
			cell.accessoryView = accesoryView;
			[accesoryView release];
			
			cell.textLabel.backgroundColor = [UIColor clearColor];
			cell.detailTextLabel.backgroundColor = [UIColor clearColor];
			cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
			cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
            
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 39)];
            bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
            
            UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 39)];
            bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
            
            cell.backgroundView = bgImageView;
            cell.selectedBackgroundView = bgImageViewHighligthed;
            
            [bgImageView release];
            [bgImageViewHighligthed release];
    }
	
	NSDictionary *setInfo = [availableQuizletSetsArray objectAtIndex:indexPath.row];
    
    if (setInfo) {
        NSString *setName = [setInfo objectForKey:@"title"];
        
        if (setName) {
            
            FHTMLConverter *converter = [[FHTMLConverter alloc] init];
            setName = [converter convertEntiesInString:setName];
            [converter release];
            cell.textLabel.text = setName;
            [setName release];
        }
        
        NSMutableString *detailStr = [NSMutableString string];
        
        NSInteger cardCount = [[setInfo objectForKey:@"term_count"] intValue];
        [detailStr appendFormat:@"%d cards ",cardCount];
        
        NSInteger dateInt = [[setInfo objectForKey:@"created_date"] intValue];
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
            accesoryImage = [UIImage imageNamed:@"i_pic.png"];
        }
        
        UIImageView *accesoryView = (UIImageView*)cell.accessoryView;
        accesoryView.image = accesoryImage;
        accesoryView.highlightedImage = accesoryImage;
    }
	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 39;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	FIQuizletDetailController *detailController = [[FIQuizletDetailController alloc] init];
	detailController.setInfoDictionary = [self generateInfoDic:indexPath.row];
	[self.navigationController pushViewController:detailController animated:YES];
	[detailController release];
}

#pragma mark -
#pragma mark FQuizletImport delegate

-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo{
    [loadingView dismiss];
    NSString *errorMsg = [errorInfo objectForKey:@"errorMsg"];
    [Util showMessage:@"Quizlet" forMessage:errorMsg forButtonTitle:@"Close"];
}

-(void)qiGroupSet:(QIRequest*)request set:(NSArray*)set
{
	if (set) {
		if (availableQuizletSetsArray) {
            [availableQuizletSetsArray removeAllObjects];
        }else{
            availableQuizletSetsArray = [[NSMutableArray alloc] init];
        }
		[availableQuizletSetsArray addObjectsFromArray:set];
		[availableQuizletSetsTable reloadData];
	}
		
	[loadingView dismiss];
	
	
}

#pragma mark -
#pragma mark private methods


-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
            
        }else
        {
            
           topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
            
        }
        
    }
	
	topBar.bgImage	= [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:title];
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

-(NSDictionary*)generateInfoDic:(NSInteger)index{
    if (availableQuizletSetsArray && index<[availableQuizletSetsArray count]) {
        NSDictionary *set = [availableQuizletSetsArray objectAtIndex:index];
        return [NSDictionary dictionaryWithObjectsAndKeys:[set objectForKey:@"id"],@"id",
                [set objectForKey:@"title"],@"title",
                [set objectForKey:@"has_images"],@"has_images",
                [set objectForKey:@"created_by"],@"creator",
                [set objectForKey:@"created_date"],@"created",
                [set objectForKey:@"term_count"],@"term_count",nil];
    }else{
        return nil;
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
	
	self.category = nil;
    self.title = nil;
	
	[availableQuizletSetsArray release];
	[loadingView release];
	
    [super dealloc];
}


@end
