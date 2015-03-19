    //
//  FImportApiMainController.m
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FImportApiMainController.h"
#import "FHTMLConverter.h"
#import "ImportApiController.h"
#import "FSetDetailsController.h"
#import "DBTime.h"
#import "Constants.h"
#import "FDBController.h"
#import "Util.h"
#import "ModalAlert.h"

@interface FImportApiMainController(Private)

-(void)initLabelsAndButtons;
-(void)initProccesView;
-(NSDictionary*)generateInfoDic:(NSInteger)index;

@end


@implementation FImportApiMainController
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
	UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,580)];
	self.view = contentView;
	[contentView release];
	CGRect tableFrame = CGRectMake(0,0,540,580);
	
	currentSets = [[NSMutableArray alloc] init];
	
	if (setTable == nil) {
        setTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
        setTable.delegate = self;
        setTable.dataSource = self;
    } else {
        setTable.frame = tableFrame;
    }
	[self.view addSubview:setTable];
	[setTable release];
	[self initLabelsAndButtons];
	[self initProccesView];
	
	proccesView.hidden = NO;
	[indicator startAnimating]; 
	
	[[QIRequest sharedRequest] fetchSetsForGroup:self group:category page:0];
			
}


-(void)setDelegateAndCategory:(id)Adelegate forCategory:(NSString*)Acategory
{
	delegate = Adelegate;
	
	if (!category) {
		[category release];
	}
	
	category = [[NSString alloc] initWithString:Acategory];
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Overriden to allow any orientation.
//    return YES;
//}

- (void)viewDidDisappear:(BOOL)animated
{
	
}

- (void)viewWillAppear:(BOOL)animated
{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	isSearch = NO;
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([currentSets count]>0) {
        return [currentSets count];
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [setTable dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	
    UILabel *textLabel = (UILabel*)[cell viewWithTag:100];
	UILabel *detailLabel = (UILabel*)[cell viewWithTag:103];
	UIImageView *imageView = (UIImageView*)[cell viewWithTag:101];
	
	NSDictionary *subject = [currentSets objectAtIndex:indexPath.row];
    NSString *setTitle = [subject objectForKey:@"title"];
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,0,400,30)];
        textLabel.font = [UIFont boldSystemFontOfSize:17];
        textLabel.tag = 100;
        [cell addSubview:textLabel];
        [textLabel release];
    }
    
    if (!detailLabel) {
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,30,350,24)];
        detailLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
        detailLabel.textColor = [UIColor lightGrayColor];
        detailLabel.tag = 103;
        [cell addSubview:detailLabel];
        [detailLabel release];
    }
    
    
    FHTMLConverter *convert = [[FHTMLConverter alloc] init];
    NSString *resultStr = [convert convertEntiesInString:setTitle];
    [convert release];
    
    NSInteger date = [[subject objectForKey:@"created_date"] intValue];
    NSDate *curDate = [DBTime dateFromDBTime:date];
    NSString *dateStr = [Util fullTimeStringFromDate:curDate];
    NSInteger termCount = [[subject objectForKey:@"term_count"] intValue];
    
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(450,14,27,28)];
        imageView.userInteractionEnabled = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 101;
        [cell addSubview:imageView];
        [imageView release];
    }
    
    BOOL isImage = [[subject objectForKey:@"has_images"] boolValue];
    textLabel.text = resultStr;
    cell.textLabel.text = @"";
    cell.textLabel.numberOfLines = 1;
    detailLabel.text = [NSString stringWithFormat:@"%d cards/ %@",termCount,dateStr];
    cell.userInteractionEnabled = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [theTableView	deselectRowAtIndexPath:indexPath animated:NO];
    
    if (isImage) {
        imageView.image = [UIImage imageNamed:@"pic.png"];
    }
    else {
        imageView.image = nil;
    }
    
    [resultStr release];	
		
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == [currentSets count]) {
		return kCellHight+20;
	}
	
	return kCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[setTable deselectRowAtIndexPath:indexPath animated:NO];
    FSetDetailsController *detail = [[FSetDetailsController alloc] init];
    [detail setDelegate:delegate];
    [detail setInformation:[self generateInfoDic:indexPath.row]];
    detail.contentSizeForViewInPopover = CGSizeMake(550,500);
    [self.navigationController pushViewController:detail animated:YES];
    [detail release];	
}

#pragma mark -
#pragma mark QIRequest delegate

-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo{
    proccesView.hidden = YES;
    [indicator stopAnimating];
    NSString *errorMsg = [errorInfo objectForKey:@"errorMsg"];
    [Util showMessage:@"Quizlet" forMessage:errorMsg forButtonTitle:@"Close"];
}

-(void)qiGroupSet:(QIRequest*)request set:(NSArray*)set
{
    proccesView.hidden = YES;
    [indicator stopAnimating];
	if (set) {
		if (currentSets) {
            [currentSets removeAllObjects];
        }else{
            currentSets = [[NSMutableArray alloc] init];
        }
		[currentSets addObjectsFromArray:set];
		[setTable reloadData];
	}
}

#pragma mark -
#pragma mark private methods
-(void)initLabelsAndButtons
{
	self.navigationItem.title = title;
}

-(void)initProccesView
{
	proccesView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,580)];
	proccesView.backgroundColor = [UIColor whiteColor];
	proccesView.userInteractionEnabled = YES;
	
	indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(205,243,30,30)];
	indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	
	UILabel *loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(245,243,100,30)];
	loadingLabel.textColor = [UIColor lightGrayColor];
	loadingLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	loadingLabel.text = @"Loading...";
	
	
	[proccesView addSubview:loadingLabel];
	[proccesView addSubview:indicator];
	[self.view addSubview:proccesView];
	
	proccesView.hidden = YES;
	[proccesView release];
	[indicator release];
	[loadingLabel release];
}

-(NSDictionary*)generateInfoDic:(NSInteger)index{
    if (currentSets && index<[currentSets count]) {
        NSDictionary *set = [currentSets objectAtIndex:index];
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
	[currentSets release];
	self.title = nil;
	if (currDic) {
		[currDic release];
	}
	
    [super dealloc];
}


@end
