    //
//  ImportApiController.m
//  flashCards
//
//  Created by Ruslan on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImportApiController.h"
#import "FSetDetailsController.h"
#import "FHTMLConverter.h"
#import "JSON.h"
#import "DBTime.h"
#import "Util.h"
#import "Constants.h"

@interface ImportApiController(Private)

-(void)initProccesView;
-(void)initTextFild;
-(void)findButtonPressed;
-(void)moreButtonPressed;
-(void)initSegment;

@end


@implementation ImportApiController

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
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect tableFrame = CGRectMake(0,105+60+10,540,475-60-10);
	
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
	
	progressView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,540,540,40)];
	progressView.delegate = self;
	
	[self initSegment];
	[self initTextFild];
	[self initProccesView];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)setDelegate:(id)Adelegate
{
	delegate = Adelegate;
}


#pragma mark -
#pragma mark Import Delegate

-(void)importFinished:(BOOL)result forCat:(NSString*)cat
{
	if ([delegate respondsToSelector:@selector(importFinished:newCat:)]) {
		[delegate importFinished:result newCat:cat];
	}
	
	proccesView.hidden = YES;
	[indicator stopAnimating];
	[progressView dissmis];
	
}

-(void)dataContentLen:(NSInteger)cL
{
	[progressView setImportLen:cL];
	total_images = cL;
}

-(void)dataRecived:(NSInteger)len
{
	downloaded_images+=len;
	[progressView setCurVal:downloaded_images];
}

#pragma mark -
#pragma mark FIndicatorView delegate
-(void)cancelButtonPressed
{
	if (importSet) {
		[importSet cancelDownload];
	}
	
	[progressView dissmis];
	proccesView.hidden = YES;
	[indicator stopAnimating];
}

#pragma mark -
#pragma mark FQuizletImport delegate

-(void)listFormed:(BOOL)isSucces forData:(NSDictionary*)dic forError:(NSString*)errorMsg;
{
	if (isSucces) {
		
		if (currDic) {
			[currDic release];
		}
		
		currDic = dic;
		
		NSArray *currSets = [currDic objectForKey:@"sets"];
		currSetVisible = currSetVisible+[currSets count];
		totalSets = [[dic objectForKey:@"total"] intValue];
        totalPages = [[dic objectForKey:@"total_pages"] intValue];
		
		[currentSets addObjectsFromArray:currSets];
		[setTable reloadData];
		
		proccesView.hidden = YES;
		[indicator stopAnimating];
		
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
		
		proccesView.hidden = YES;
		[indicator stopAnimating];
	}
	
	
}



#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([currentSets count]>0) {
        if (curPageNum < totalPages) {
            return [currentSets count]+1;
        }else{
            return [currentSets count];
        }
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
	
	if (indexPath.row != [currentSets count]) {
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
		
		NSInteger date = [[subject objectForKey:@"created"] intValue];
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
		
	}
	else {
		
		if (detailLabel) {
			[detailLabel removeFromSuperview];
		}
		
		if (textLabel) {
			[textLabel removeFromSuperview];
		}
		
		if (imageView) {
			[imageView	 removeFromSuperview];
		}
		
		NSString *text = [NSString stringWithFormat:@"%d out of %d sets.",currSetVisible,totalSets];
		
		if (currSetVisible!=totalSets) {
			text = [text stringByAppendingString:@"\nTap here to see more"];
		}
		
		cell.textLabel.text = text;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.textLabel.numberOfLines = 0;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.imageView.image = nil;
		[theTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
		
		if (currSetVisible == totalSets) {
			cell.userInteractionEnabled = NO;
		}
		
	}
	
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
	
	if (indexPath.row != [currentSets count]) {
		FSetDetailsController *detail = [[FSetDetailsController alloc] init];
		[detail setDelegate:delegate];
		[detail setInformation:[currentSets objectAtIndex:indexPath.row]];
		detail.contentSizeForViewInPopover = CGSizeMake(550,500);
		[self.navigationController pushViewController:detail animated:YES];
		[detail release];
	}
	else {
		[self moreButtonPressed];
	}

}

- (void)scrollViewDidEndDecelerating:(UITableView *)tableView{
    NSArray *visIndex = [tableView indexPathsForVisibleRows];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[currentSets count] inSection:0];
    
    if ([visIndex count]>0) {
        NSIndexPath *indexPathLast = [visIndex objectAtIndex:[visIndex count]-1];
        if (indexPathLast.row == indexPath.row && curPageNum < totalPages) {
            [self moreButtonPressed];
        }
    }
}

#pragma mark -
#pragma mark privateMethods

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
	[proccesView release];
	[indicator release];
	[loadingLabel release];
	proccesView.hidden = YES;
}

-(void)initSegment
{
	segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Subject",
														 @"Creator",
														 @"Term",nil]];
	segment.segmentedControlStyle = UISegmentedControlStyleBar;
	segment.tintColor = [UIColor grayColor];
	segment.frame = CGRectMake(30,105,540-60,60);

	segment.selectedSegmentIndex = 0;
	[self.view addSubview:segment];
	[segment release];
}

-(void)initTextFild
{
	UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(28,15,329,75)];
	bgView.userInteractionEnabled = YES;
	bgView.image = [UIImage imageNamed:@"search_field_bg.png"];
	[self.view addSubview:bgView];
	[bgView release];
	editField = [[UITextField alloc] initWithFrame:CGRectMake(48,22,309,68)];
	editField.textColor=[UIColor blackColor];
	editField.font = [UIFont systemFontOfSize:50];
	[editField setBorderStyle:UITextBorderStyleNone];
	[self.view addSubview:editField];
		
	editField.placeholder=@"Title"; 
	editField.text =[NSString stringWithString:@""];
	[editField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[editField setKeyboardType:UIKeyboardTypeNamePhonePad];
	editField.enablesReturnKeyAutomatically = NO;
	
	UIButton *getListButton = [UIButton buttonWithType:UIButtonTypeCustom];
	getListButton.frame = CGRectMake(357,15,165,75);
	[getListButton setImage:[UIImage imageNamed:@"find_1.png"] forState:UIControlStateNormal];
	[getListButton setImage:[UIImage imageNamed:@"find_2.png"] forState:UIControlStateHighlighted];
	[getListButton addTarget:self action:@selector(findButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:getListButton];
}

-(void)findButtonPressed
{
	[editField resignFirstResponder];
	
	if (category) {
		[category release];
	}
	
	category = [[NSString alloc] initWithString:editField.text];
	
	NSDictionary *fDic = [NSDictionary dictionaryWithObject:category forKey:@"category"];
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet search category" withParam:fDic];
	
	if ([category isEqualToString:@""]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
														message:@"Empty set"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	
	curPageNum = 1;
	totalPages = 2;
	currSetVisible = 0;
	totalSets = 0;
	
	total_images = 0;
	downloaded_images = 0;
	
	proccesView.hidden = NO;
	[indicator startAnimating];
	
	if (currentSets) {
		[currentSets release];
	}
	
	currentSets = [[NSMutableArray alloc] init];
	
	if (quizlet) {
		[quizlet release];
	}
	
	quizlet = [[FQuizletImport alloc] initWithDelegate:self];
	
	switch (segment.selectedSegmentIndex) {
		case 0:
			[quizlet findBySubject:category sortBy:0 pages:curPageNum];	
			break;
		case 1:
			[quizlet findByCreator:category sortBy:0 pages:curPageNum];
			break;
		case 2:
			[quizlet findByTerm:category sortBy:0 pages:curPageNum];
			break;
			
		default:
			break;
	}
	
		
}


-(void)moreButtonPressed
{
    
    curPageNum++;
    proccesView.hidden = NO;
    [indicator startAnimating];
    switch (segment.selectedSegmentIndex) {
         case 0:
             [quizlet findBySubject:category sortBy:0 pages:curPageNum];	
             break;
         case 1:
             [quizlet findByCreator:category sortBy:0 pages:curPageNum];
             break;
         case 2:
             [quizlet findByTerm:category sortBy:0 pages:curPageNum];
             break;
			
         default:
             break;
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
	if(category)
		[category release];
	
	if (progressView) {
		[progressView release];
	}

	if (quizlet) {
		[quizlet release];
	}
	
	if (currDic) {
		[currDic release];
	}
	
	
	[currentSets release];
	[editField release];
    [super dealloc];
}


@end
