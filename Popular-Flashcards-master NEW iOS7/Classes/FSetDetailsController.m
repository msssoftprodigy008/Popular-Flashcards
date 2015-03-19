    //
//  FSetDetailsController.m
//  flashCards
//
//  Created by Ruslan on 7/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FSetDetailsController.h"
#import "DBTime.h"
#import "Util.h"
#import "FIImageUtilits.h"
#import "FDBController.h"
#import "FHTMLConverter.h"

@interface FSetDetailsController(Private)

-(void)downloadButtonPressed;
-(void)initToolbar;
-(void)initProccesView;
-(void)reverseButtonPressed;
-(void)donePressed;
@end


@implementation FSetDetailsController

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
	self.view.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
	
	CGRect tabFrame = CGRectMake(0,0,540,536);
    if (infoTableView == nil) {
        infoTableView = [[UITableView alloc] initWithFrame:tabFrame style:UITableViewStyleGrouped];
        infoTableView.delegate = self;
        infoTableView.dataSource = self;
        infoTableView.backgroundColor = [UIColor clearColor];
		
    } else {
        infoTableView.frame = tabFrame;
    }
    
    UIView *tableViewBgView = [[UIView alloc] initWithFrame:tabFrame];
    tableViewBgView.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
	
    infoTableView.backgroundView = tableViewBgView;
    [tableViewBgView release];
        
	[self.view addSubview:infoTableView];
	[infoTableView release];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(donePressed)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	if (currentDic) {
		
		NSString *tmpStr = [currentDic objectForKey:@"title"];
		
		if (tmpStr) {
			
			FHTMLConverter *convert = [[FHTMLConverter alloc] init];
			NSString *resultStr = [convert convertEntiesInString:tmpStr];
			[convert release];
			
			self.navigationItem.title = resultStr;
            [resultStr release];
		}
		
	}
	
	thumbImages = [[NSMutableDictionary alloc] init];
	downloaders = [[NSMutableDictionary alloc] init];
	
	total_images = 0;
	downloaded_images = 0;
	isReversed = NO;
	
	progressView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,0,540,40)];
	progressView.delegate = self;
	
	[self initToolbar];

	[self initProccesView];
	
		
}

-(void)setDelegate:(id)Adelegate
{
	delegate = Adelegate;
}

-(void)setInformation:(NSDictionary*)info
{
	if (currentDic) {
		[currentDic release];
	}
	
	currentDic = [[NSDictionary alloc] initWithDictionary:info];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[QIRequest sharedRequest] cancelFetch];
	if (importSet) {
		[importSet cancelDownload];
	}
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString* index = [currentDic objectForKey:@"id"];
		
	proccesView.hidden = NO;
	[indicator startAnimating];
	
	importSet = [[FImportSet alloc] initWithDelegate:self];
	if (index) {
        [[QIRequest sharedRequest] fetchSetCards:self set:index];
    }
    
}


#pragma mark -
#pragma mark TableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section==0) {
		return 4;
	}
	else {
		if (previewCards) {
			return [previewCards count];
		}
		else {
			return 0;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory1";
	static NSString *CellId = @"CellForCategory2";
    UITableViewCell *cell;
	
	if (indexPath.section == 0) 
		cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	else
		cell = [theTableView dequeueReusableCellWithIdentifier:CellId];


    if (cell == nil) {
		if (indexPath.section == 0) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			BOOL isImage = [[currentDic objectForKey:@"has_images"] boolValue];
			
			if (isImage) 
				cell.imageView.image = [UIImage imageNamed:@"pic.png"];
			
		}
        
	}
	
	if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
	
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [NSString stringWithFormat:@"created by %@",[currentDic objectForKey:@"creator"]];
				break;
			case 1:
			{
				NSInteger date = [[currentDic objectForKey:@"created"] intValue];
				NSDate *curDate = [DBTime dateFromDBTime:date];
				NSString *dateStr = [Util fullTimeStringFromDate:curDate];
				cell.textLabel.text = [NSString stringWithFormat:@"created on %@",dateStr];
				break;
			}
			case 2:
				cell.textLabel.text = [NSString stringWithFormat:@"%d cards",[[currentDic objectForKey:@"term_count"] intValue]];
				break;
			case 3:
			{
				BOOL isImage = [[currentDic objectForKey:@"has_images"] boolValue];
			
				if (isImage) 
					cell.textLabel.text = @"contains images";
				else
					cell.textLabel.text = @"";

			}
			default:
			break;
		}
	}
	else {
		if (previewCards) {
			NSArray *qArr = [previewCards objectAtIndex:indexPath.row];
			FHTMLConverter *converterQ = [[FHTMLConverter alloc] init];
			FHTMLConverter *converterA = [[FHTMLConverter alloc] init];
			
			
			NSString *q; 
			NSString *a;
			
			if (isReversed) {
				a = [qArr objectAtIndex:0];
				q = [qArr objectAtIndex:1];
			}
			else {
				a = [qArr objectAtIndex:1];
				q = [qArr objectAtIndex:0];
			}

		
			a = [converterA convertEntiesInString:a];
			q = [converterQ convertEntiesInString:q];
		
			[converterA release];
			[converterQ release];
		
			cell.textLabel.text = q;
			cell.detailTextLabel.text = a;
			
			[q release];
			[a release];
			
			cell.textLabel.text = [cell.textLabel.text stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
			cell.detailTextLabel.text = [cell.detailTextLabel.text stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
			
			NSString *imUrl = [qArr objectAtIndex:2];
			
			if (imUrl && !([imUrl isEqualToString:@"\"\""]) && !([imUrl isEqualToString:@""])) {
                NSString* urlStr = [imUrl stringByReplacingOccurrencesOfString:@"_m." withString:@"_s."];
                urlStr = [urlStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                NSURL *url = [NSURL URLWithString:urlStr];
                
                if ([thumbImages objectForKey:url]) {
                    cell.imageView.hidden = NO;
                    NSMutableArray *info = [thumbImages objectForKey:url];
                    if ([info count]==2) {
                        cell.imageView.image = [info objectAtIndex:1];
                    }else {
                        cell.imageView.image = [UIImage imageNamed:@"i_pic.png"];
                    }
                }else {
                    NSMutableArray *info = [NSMutableArray arrayWithObject:indexPath];
                    [thumbImages setObject:info forKey:url];
                    SDWebImageDownloader *d = [SDWebImageDownloader downloaderWithURL:url delegate:self];
                    [downloaders setObject:d forKey:url];
                    cell.imageView.image = [UIImage imageNamed:@"i_pic.png"];
                }
					
            }else {
				cell.imageView.hidden = YES;
			}
		}
	}

	cell.userInteractionEnabled = NO;
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) 
		return 40;
	else 
		return 50;

}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section==1) {
		return @"Preview";
	}
	else {
		return @"";
	}

}

#pragma mark -
#pragma mark FImportSetDelegate
-(void)justForget
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	dowloadButton.enabled = YES;
	reverseButton.enabled = YES;
	[progressView dissmis];
	proccesView.hidden = YES;
	[indicator stopAnimating];
	[self.navigationController popViewControllerAnimated:YES];
	
}

-(void)recivedCards:(NSArray*)cards
{
	proccesView.hidden = YES;
	[indicator stopAnimating];
	
	if (previewCards) {
		[previewCards release];
	}
	
	previewCards = [[NSMutableArray alloc] initWithArray:cards];
	
	[infoTableView reloadData];
	
}

-(void)importFinished:(BOOL)result forCat:(NSString*)cat
{
	if (result) {
		
		NSString *message;
		
		if (cat) {
			message = [NSString stringWithFormat:@"Set %@ imported.\n Would you like to go to this set?",[[FDBController sharedDatabase] nameForCategory:cat]];
                
                if (category) {
                    [category release];
                }
                
				category = [[NSString alloc] initWithString:cat];
			}
			
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import"
													message:message
												   delegate:self
											  cancelButtonTitle:@"NO"
											  otherButtonTitles:@"YES",nil];
		[alert show];
		[alert release];
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import"
														message:@"Connection failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	dowloadButton.enabled = YES;
	reverseButton.enabled = YES;
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
#pragma mark SDWebImageDownloader delegate
-(void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image
{
	NSURL *url = downloader.url;
	if (url) {
		NSMutableArray *info = [thumbImages objectForKey:url];
		if (info) {
			NSIndexPath *indexPath = [info objectAtIndex:0];
			[info addObject:[FIImageUtilits roundedImage:image forRadius:image.size.width/8.0]];
			[thumbImages setObject:info forKey:url];
			[downloaders removeObjectForKey:url];
			[infoTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}

- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error
{
	NSURL *url = downloader.url;
	if (url) {
		[thumbImages removeObjectForKey:url];
		[downloaders removeObjectForKey:url];
	}
}

- (void)imageDownloaderDidFinish:(SDWebImageDownloader *)downloader
{
	NSURL *url = downloader.url;
	if (url) {
		[downloaders removeObjectForKey:url];
	}
}

#pragma mark SDWebImageDownloader delegate ends

#pragma mark -
#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"quizletAdded" object:category];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SetAdded" object:category];
		[self.navigationController popViewControllerAnimated:YES];
	}
	
}


#pragma mark -
#pragma mark FIndicatorView delegate
-(void)cancelButtonPressed
{
	if (importSet) {
		[importSet cancelDownload];
	}

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	dowloadButton.enabled = YES;
    reverseButton.enabled = YES;
	[progressView dissmis];
}

#pragma mark -
#pragma mark QIRequest delegate

-(void)qiSetCards:(QIRequest*)request cards:(NSDictionary*)cards{
    proccesView.hidden = YES;
	[indicator stopAnimating];
    if (previewCards) {
        [previewCards release];
    }
    previewCards = [[NSMutableArray alloc] init];
    if (cards) {
        NSArray *pcards = [cards objectForKey:@"terms"];
        for (NSDictionary *card in pcards) {
            NSMutableArray *pcard = [NSMutableArray array];
            NSString *q = [card objectForKey:@"term"];
            NSString *a = [card objectForKey:@"definition"];
            NSDictionary *imageDic = [card objectForKey:@"image"];
            if (q) {
                [pcard addObject:q];
            }else{
                [pcard addObject:@""];
            }
            if (a) {
                [pcard addObject:a];
            }else{
                [pcard addObject:@""];
            }
            if (imageDic && ![imageDic isKindOfClass:[NSNull class]] && [imageDic objectForKey:@"url"]) {
                [pcard addObject:[imageDic objectForKey:@"url"]];
            }else{
                [pcard addObject:@""];
            }
            [previewCards addObject:pcard];
        }
    }
    reverseButton.enabled = YES;
	dowloadButton.enabled = YES;
    [infoTableView reloadData];
    
}

#pragma mark -
#pragma mark private methods

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

-(void)downloadButtonPressed
{
	if (!previewCards) {
		return;
	}
	
	NSString *titleStr = [currentDic objectForKey:@"title"];
	NSDictionary *fDic = [NSDictionary dictionaryWithObject:titleStr forKey:@"title"];
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet import" withParam:fDic];
	
	if (importSet) {
		[importSet release];
	}
	
	[progressView setImportLen:100];
	[progressView setCurVal:0];
	
	dowloadButton.enabled = NO;
	reverseButton.enabled = NO;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	[progressView showInView:self.view];
	
	importSet = [[FImportSet alloc] initWithDelegate:self];
	[importSet addArrToCategory:titleStr forArr:previewCards forRev:isReversed];
	
}

-(void)initToolbar
{
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,536,540,44)];
	
	dowloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Download"
																	  style:UIBarButtonItemStyleBordered
																	 target:self
																	 action:@selector(downloadButtonPressed)];
	
	reverseButton = [[UIBarButtonItem alloc] initWithTitle:@"Reverse cards"
													 style:UIBarButtonItemStyleBordered
													target:self
													action:@selector(reverseButtonPressed)];
	
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil];
	
	toolbar.items = [NSArray arrayWithObjects:space,reverseButton,space,dowloadButton,space,nil];
	
	[self.view addSubview:toolbar];
	[dowloadButton release];
	[reverseButton release];
	[space release];
	[toolbar release];
}

-(void)donePressed
{
    [[QIRequest sharedRequest] cancelFetch];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)reverseButtonPressed
{
	isReversed = !isReversed;
	[infoTableView reloadData];
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
	if (importSet) {
		[importSet release];
	}
	
	if (previewCards) {
		[previewCards release];
	}
	
	if (thumbImages) {
		[thumbImages release];
	}
	
	if (downloaders) {
        for (SDWebImageDownloader *d in [downloaders allValues]) {
            [d cancel];
        }
		[downloaders release];
	}
	
    if (category) {
        [category release];
    }
    
	[currentDic release];
	[progressView release];
    [super dealloc];
}


@end
