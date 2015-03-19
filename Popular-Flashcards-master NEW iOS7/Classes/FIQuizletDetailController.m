//
//  FIQuizletDetailController.m
//  flashCards
//
//  Created by Ruslan on 7/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIQuizletDetailController.h"
#import "FILoadingView.h"
#import "FHTMLConverter.h"
#import "FIImageUtilits.h"
#import "FDBController.h"
#import "Util.h"
#import "DBTime.h"
#import "Constants.h"

@interface FIQuizletDetailController(Private)

-(void)initTopBar;
-(void)initBottomBar;
-(void)reversePressed;
-(void)downloadPressed;
-(void)updateProgressView;
-(void)backPressed;
-(void)fetchImportSet:(NSString*)title;

@end


@implementation FIQuizletDetailController
@synthesize categoryId;
@synthesize setInfoDictionary;
@synthesize previewCards;

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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?320:300))];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	setsDetailTable = [[UITableView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?250:230)) style:UITableViewStyleGrouped];
	setsDetailTable.delegate = self;
	setsDetailTable.dataSource = self;
	setsDetailTable.backgroundColor = [UIColor clearColor];
	setsDetailTable.showsVerticalScrollIndicator = NO;
	[self.view addSubview:setsDetailTable];
	[setsDetailTable release];
	
	[self initTopBar];
	[self initBottomBar];
	
	isReversed = NO;
	
	thumbImages = [[NSMutableDictionary alloc] init];
	downloaders = [[NSMutableDictionary alloc] init];
	
	loadingView = [[FILoadingView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?252:232))];
	importSet = [[FImportSet alloc] initWithDelegate:self];
	progressView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,210,((IS_IPHONE_5)?568:480),44)];
	progressView.delegate = self;
	[self updateProgressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
	if (importSet)
		[importSet cancelDownload];
	
	NSArray *dl = [downloaders allValues];
	
	for (SDWebImageDownloader *d in dl) {
		[d cancel];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (setInfoDictionary) {
        NSString *setId = [setInfoDictionary objectForKey:@"id"];
		NSString *titleStr = [setInfoDictionary objectForKey:@"title"];
		if (titleStr)
		{
			reverse.enabled = NO;
			download.enabled = NO;
			[loadingView showInView:self.view];
			[self.view bringSubviewToFront:topBar];
			[self.view bringSubviewToFront:bottomBar];
            if (!previewCards) {
                [[QIRequest sharedRequest] fetchSetCards:self set:setId];
            }
		}
	}
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
			
			BOOL isImage = [[setInfoDictionary objectForKey:@"has_images"] boolValue];
            
			if (isImage)
				cell.imageView.image = [UIImage imageNamed:@"i_pic.png"];
		}
		
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
		cell.textLabel.textColor = [UIColor darkTextColor];
		cell.detailTextLabel.textColor = [UIColor darkTextColor];
		cell.textLabel.highlightedTextColor = [UIColor darkTextColor];
		cell.detailTextLabel.highlightedTextColor = [UIColor darkTextColor];
	}
	
	if (indexPath.section == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [NSString stringWithFormat:@"created by %@",[setInfoDictionary objectForKey:@"creator"]];
				break;
			case 1:
			{
				NSInteger date = [[setInfoDictionary objectForKey:@"created"] intValue];
				NSDate *curDate = [DBTime dateFromDBTime:date];
				NSString *dateStr = [Util fullTimeStringFromDate:curDate];
				cell.textLabel.text = [NSString stringWithFormat:@"created on %@",dateStr];
				break;
			}
			case 2:
				cell.textLabel.text = [NSString stringWithFormat:@"%d cards",[[setInfoDictionary objectForKey:@"term_count"] intValue]];
				break;
			case 3:
			{
				BOOL isImage = [[setInfoDictionary objectForKey:@"has_images"] boolValue];
				
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
				
                cell.imageView.hidden = NO;
                if ([thumbImages objectForKey:url]) {
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
		return 35;
	else
		return 45;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	
	UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0,0,240,20.0)] autorelease];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,100,20)];
	
	if (section == 0) {
		titleLabel.text = @"Info";
	}else {
		titleLabel.text = @"Preview";
	}
	
	titleLabel.textColor = [UIColor colorWithRed:104.0/255.0 green:56.0/255.0 blue:12.0/255.0 alpha:1.0];;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	titleLabel.shadowOffset = CGSizeMake(0,1.0);
	titleLabel.shadowColor = [UIColor whiteColor];
	[customView addSubview:titleLabel];
	[titleLabel release];
	
	
	return customView;
	
}

#pragma mark -
#pragma mark FImportSetDelegate
-(void)justForget
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	download.enabled = YES;
	reverse.enabled = YES;
	[loadingView dismiss];
	[progressView dissmis];
}

-(void)recivedCards:(NSArray*)cards
{
	[loadingView dismiss];
	
	if (previewCards) {
		[previewCards release];
	}
	
	previewCards = [[NSMutableArray alloc] initWithArray:cards];
	reverse.enabled = YES;
	download.enabled = YES;
	[setsDetailTable reloadData];
	
}

-(void)importFinished:(BOOL)result forCat:(NSString*)cat
{
	if (result) {
		
		NSString *message;
		
		/*if ([[FDBController sharedDatabase] numOfSets]>=3 && ![Util isFullVersion]) {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"quizletAdded" object:cat];
         }else {*/
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
		//}
		
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
	download.enabled = YES;
	reverse.enabled = YES;
	[loadingView dismiss];
	[progressView dissmis];
    
	
}

-(void)dataContentLen:(NSInteger)cL
{
	[progressView setImportLen:cL];
	downloaded_images = 0;
	total_images = cL;
}

-(void)dataRecived:(NSInteger)len
{
	downloaded_images+=len;
	[progressView setCurVal:downloaded_images];
}

#pragma mark -
#pragma mark QIRequest delegate

-(void)qiSetCards:(QIRequest*)request cards:(NSDictionary*)cards{
  	[loadingView dismiss];
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
    reverse.enabled = YES;
	download.enabled = YES;
    [setsDetailTable reloadData];
    
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
			[info addObject:[image thumbnailImage:45*[UIScreen mainScreen].scale transparentBorder:1 cornerRadius:5 interpolationQuality:kCGInterpolationHigh]];
			[thumbImages setObject:info forKey:url];
			[downloaders removeObjectForKey:url];
			[setsDetailTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
	download.enabled = YES;
	reverse.enabled = YES;
	[progressView dissmis];
}

#pragma mark -
#pragma mark private methods

-(void)backPressed
{
    [[QIRequest sharedRequest] cancelFetch];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
	
	NSString *titleStr;
	
	if (setInfoDictionary) {
		titleStr = [setInfoDictionary objectForKey:@"title"];
	}
	
	FHTMLConverter *converter = [[FHTMLConverter alloc] init];
	titleStr = [converter convertEntiesInString:titleStr];
	[converter release];
	
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
    
	//topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
	topBar.bgImage	= [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:titleStr];
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
    [titleStr release];
	
	
}

-(void)initBottomBar
{
	bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?272:252),((IS_IPHONE_5)?568:480),48)];
	bottomBar.bgImage = [Util imageFromBundle:@"i_images_bottombg.png"];
	[self.view addSubview:bottomBar];
	
	
	UIButton *customReverseButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *customReverseImage = [UIImage imageNamed:@"i_butt_reverse1.png"];
	customReverseButton.frame = CGRectMake(0,0,customReverseImage.size.width,customReverseImage.size.height);
    customReverseButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
	[customReverseButton setImage:customReverseImage forState:UIControlStateNormal];
	[customReverseButton setImage:[UIImage imageNamed:@"i_butt_reverse2.png"] forState:UIControlStateHighlighted];
	[customReverseButton addTarget:self
							action:@selector(reversePressed)
				  forControlEvents:UIControlEventTouchUpInside];
	
	reverse = [[UIBarButtonItem alloc] initWithCustomView:customReverseButton];
	
	UIButton *customDownloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *customDownloadImage = [UIImage imageNamed:@"i_butt_download1.png"];
	customDownloadButton.frame = CGRectMake(0,0,customDownloadImage.size.width,customDownloadImage.size.height);
    customDownloadButton.imageEdgeInsets = UIEdgeInsetsMake(2, 0, -2, 0);
	[customDownloadButton setImage:customDownloadImage forState:UIControlStateNormal];
	[customDownloadButton setImage:[UIImage imageNamed:@"i_butt_download2.png"] forState:UIControlStateHighlighted];
	[customDownloadButton addTarget:self
							 action:@selector(downloadPressed)
				   forControlEvents:UIControlEventTouchUpInside];
	
	download = [[UIBarButtonItem alloc] initWithCustomView:customDownloadButton];
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		  target:self
																		  action:nil];
    if (IS_IPHONE_5) {
        bottomBar.items = [NSArray arrayWithObjects:flex,reverse,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,flex,download,flex,nil];
    }
    else{
        bottomBar.items = [NSArray arrayWithObjects:flex,reverse,flex,download,flex,nil];
    }
	
	[self.view addSubview:bottomBar];
	[bottomBar release];
	[download release];
    [flex release];
	[reverse release];
}

-(void)reversePressed
{
	isReversed = !isReversed;
	[setsDetailTable reloadData];
}

-(void)downloadPressed
{
	if (!previewCards) {
		return;
	}
	
	NSString *titleStr = [setInfoDictionary objectForKey:@"title"];
	NSDictionary *fDic = [NSDictionary dictionaryWithObject:titleStr forKey:@"title"];
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Quizlet import" withParam:fDic];
	
	if (importSet) {
		[importSet release];
	}
	
	[progressView setImportLen:100];
	[progressView setCurVal:0];
	
	download.enabled = NO;
	reverse.enabled = NO;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	[progressView showInView:self.view];
	
	importSet = [[FImportSet alloc] initWithDelegate:self];
	//[self performSelectorInBackground:@selector(fetchImportSet:) withObject:titleStr];
    [self fetchImportSet:titleStr];
}

-(void)updateProgressView
{
	
	progressView.progressView.frame = CGRectMake(5,17,200,10);
	progressView.cancelButton.center = CGPointMake(230,22);
	progressView.progressViewLabel.frame = CGRectMake(265,6,50,30);
	
    
}

-(void)fetchImportSet:(NSString*)title{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [importSet addArrToCategory:title forArr:previewCards forRev:isReversed];
    //[pool release];
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
	self.previewCards = nil;
    self.setInfoDictionary = nil;
	
	if (category) {
		[category release];
	}
	
	if (importSet) {
		[importSet release];
	}
	
	if(thumbImages){
		[thumbImages release];
	}
	
    
	if (downloaders) {
        for (SDWebImageDownloader *d in [downloaders allValues]) {
            [d cancel];
        }
		[downloaders release];
	}
    
	
	[loadingView release];
	[progressView release];
	
	
	
    [super dealloc];
}


@end
