//
//  FSettingsTemplate.m
//  flashCards
//
//  Created by Руслан Руслан on 3/11/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import "FSettingsTemplate.h"
#import "Constants.h"
#import "FISketchedImageView.h"
#import "Util.h"

@interface FSettingsTemplate(Private)
- (void)loadScrollView;
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
-(void)selectDesign;
-(void)initButtons;
-(void)initLabel;
-(void)nextButtonPressed;
-(void)prevButtonPressed;
@end


@implementation FSettingsTemplate


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,580)];
	contentView.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
	self.view = contentView;
	[contentView release];
	templateView = [[UIScrollView alloc] initWithFrame:CGRectMake(kCardSettingsScrollX,kCardSettingsScrollY,kCardSettingsScrollWidth,kCardSettingsScrollHeight)];
	templateView.pagingEnabled = YES;
    templateView.contentSize = CGSizeMake(kCardSettingsScrollWidth*[images count], kCardSettingsScrollHeight);
    templateView.showsHorizontalScrollIndicator = NO;
    templateView.showsVerticalScrollIndicator = NO;
    templateView.scrollsToTop = NO;
    templateView.delegate = self;
	templateView.contentMode = UIViewContentModeScaleToFill;
	UIBarButtonItem *selectItem = [[UIBarButtonItem alloc] initWithTitle:@"Save this image" style:UIBarButtonItemStyleDone target:self action:@selector(selectDesign)];
	self.navigationItem.rightBarButtonItem = selectItem;
	numberOfPages = [images count];
	[self.view addSubview:templateView];
	[self loadScrollView];
	[self initLabel];
	[self initButtons];
	[selectItem release];
}

-(void)setDelegate:(id)Adelegate forImages:(NSArray*)Aimages forTitles:(NSArray*)Atitles
{
	delegate = Adelegate;
	
	if (Aimages) {
		
		if (images) {
			[images release];
		}
		
		images = [[NSArray alloc] initWithArray:Aimages];
		
		if (Atitles) {
			
			if (titles) {
				[titles release];
			}
			
			titles = [[NSArray alloc] initWithArray:Atitles];
		}
	}
	
	
	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)selectDesign
{
	if([delegate respondsToSelector:@selector(selectedItemWithImage:)])
	{
		UIImage *retImage = [images objectAtIndex:currentPage];
		[delegate selectedItemWithImage:retImage];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Search"
														message:@"Image added to the card"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = templateView.frame.size.width;
	CGFloat offsetX = templateView.contentOffset.x;
	NSInteger page = floor((offsetX - pageWidth / 2) / pageWidth) + 1;
	currentPage = page;
		
	countTitle.text = [NSString stringWithFormat:@"%d/%d",currentPage+1,[images count]];
	
	int c = -1;
	
	if (titles) 
		c = [titles count];
	
	if (currentPage<c && c>=0) {
		NSArray *des = [titles objectAtIndex:currentPage];
		
		if (des && [des count]==2) {
			description.text = [NSString stringWithFormat:@"%@",[des objectAtIndex:1]];
		}
		
	}
	
	
	if (currentPage == 0) {
		prev.hidden = YES;
	}
	else {
		prev.hidden = NO;
	}
	
	if (currentPage == [images count]-1) {
		next.hidden = YES;
	}
	else {
		next.hidden = NO;
	}
	
}



- (void)loadScrollView{
	CGFloat curX = 0.0f;
	for(int i=0;i<numberOfPages;i++)
	{
		FISketchedImageView *curView = [[FISketchedImageView alloc] init];
		curView.tag = i+100;
		UIImage *currImage = [images objectAtIndex:i];
		CGSize imageSz = [currImage size];
		CGRect frame;
		
		if (imageSz.width>imageSz.height) {
			frame.size.width = 279;
			frame.size.height = 234;
			frame.origin.x = 110+curX;
			frame.origin.y = 107;
		}
		else {
			frame.size.width = 234;
			frame.size.height = 279;
			frame.origin.x = 133+curX;
			frame.origin.y = 84;
		}

		
		curView.frame = frame;
		
		NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
		[attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
		[attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
		[attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
		[attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
		[attrib setObject:currImage forKey:@"image"];
		[curView changeAtributes:attrib];
		curX+=kCardSettingsScrollWidth;
		[templateView addSubview:curView];
		[curView release];
	}
	[templateView setContentSize:CGSizeMake(numberOfPages*kCardSettingsScrollWidth,kCardSettingsScrollHeight)];
	currentPage = 0;
}

#pragma mark -
#pragma mark private methods
-(void)initButtons
{
	next = [UIButton buttonWithType:UIButtonTypeCustom];
	next.frame = CGRectMake(486,202,36,44);
	[next setImage:[UIImage imageNamed:@"arrow_right_1.png"] forState:UIControlStateNormal];
	[next setImage:[UIImage imageNamed:@"arrow_right_2.png"] forState:UIControlStateHighlighted];
	[next addTarget:self action:@selector(nextButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	if (!images || [images count]<=1) {
		next.hidden = YES;
	}
	
	[self.view addSubview:next];
	
	prev = [UIButton buttonWithType:UIButtonTypeCustom];
	prev.frame = CGRectMake(20,202,36,44);
	[prev setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
	[prev setImage:[UIImage imageNamed:@"arrow_left_2.png"] forState:UIControlStateHighlighted];
	[prev addTarget:self action:@selector(prevButtonPressed) forControlEvents:UIControlEventTouchUpInside];
	
	prev.hidden = YES;
	
	[self.view addSubview:prev];
	
}

-(void)initLabel
{
	countTitle = [[UILabel alloc] initWithFrame:CGRectMake(210,360,80,60)];
	countTitle.font = [UIFont fontWithName:@"Helvetica" size:24];
	countTitle.backgroundColor = [UIColor clearColor];
	countTitle.textAlignment = UITextAlignmentCenter;
	countTitle.textColor = [UIColor grayColor];
    countTitle.shadowColor = [UIColor whiteColor];
    countTitle.shadowOffset = CGSizeMake(1, 1);
	countTitle.text = [NSString stringWithFormat:@"%d/%d",currentPage+1,[images count]];
	[self.view addSubview:countTitle];
	[countTitle release];
	
	description = [[UITextView alloc] initWithFrame:CGRectMake(50,440,440,120)];
	description.userInteractionEnabled = YES;
	description.scrollEnabled = YES;
	description.textColor = [UIColor whiteColor];
	description.textAlignment = UITextAlignmentCenter;
	description.font = [UIFont fontWithName:@"Helvetica" size:26];
	description.backgroundColor = [UIColor clearColor];
	[self.view addSubview:description];
	[description release];
	
	int c = -1;
	
	if (titles) 
		c = [titles count];
	
	if (currentPage<c && c>=0) {
		NSArray *des = [titles objectAtIndex:currentPage];
		
		if (des && [des count]==2) {
			description.text = [NSString stringWithFormat:@"%@",[des objectAtIndex:1]];
		}
		
	}
	
	
}

-(void)nextButtonPressed
{
	currentPage++;
	
	if (currentPage == [images count]-1) {
		next.hidden = YES;
	}
	else {
		next.hidden = NO;
	}
	
	prev.hidden = NO;

	CGRect frame = templateView.frame;
	frame.origin.x = frame.size.width * currentPage;
	frame.origin.y = 0;
	[templateView scrollRectToVisible:frame animated:YES];
	
	countTitle.text = [NSString stringWithFormat:@"%d/%d",currentPage+1,[images count]];
	
	int c = -1;
	
	if (titles) 
		c = [titles count];
	
	if (currentPage<c && c>=0) {
		NSArray *des = [titles objectAtIndex:currentPage];
		
		if (des && [des count]==2) {
			description.text = [NSString stringWithFormat:@"%@",[des objectAtIndex:1]];
		}
		
	}
}

-(void)prevButtonPressed
{
	currentPage--;
	
	if (currentPage == 0) {
		prev.hidden = YES;
	}
	else {
		prev.hidden = NO;
	}
	
	next.hidden = NO;
	
	CGRect frame = templateView.frame;
	frame.origin.x = frame.size.width * currentPage;
	frame.origin.y = 0;
	[templateView scrollRectToVisible:frame animated:YES];
	
	countTitle.text = [NSString stringWithFormat:@"%d/%d",currentPage+1,[images count]];
	
	int c = -1;
	
	if (titles) 
		c = [titles count];
	
	if (currentPage<c && c>=0) {
		NSArray *des = [titles objectAtIndex:currentPage];
		
		if (des && [des count]==2) {
			description.text = [NSString stringWithFormat:@"%@",[des objectAtIndex:1]];
		}
		
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	if (images) {
		[images release];
	}
	
	if (titles) {
		[titles release];
	}
	
	[templateView release];
    [super dealloc];
}


@end
