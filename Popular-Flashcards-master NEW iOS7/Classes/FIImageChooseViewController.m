    //
//  FIImageChooseViewController.m
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIImageChooseViewController.h"
#import "FISketchedImageView.h"
#import "FINavigationBar.h"
#import "Util.h"

@interface FIImageChooseViewController(Private)

- (void)loadScrollView;
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
-(void)selectDesign;
-(void)initLabel;
-(void)initTopBar;
-(void)initLandscapeTopBar;
-(void)backPressed;

@end


@implementation FIImageChooseViewController
@synthesize orientation;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    
    UIView *contentView;
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,320)];

        }else
        {
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,320)];
        }
    }else
    {
    
     contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    }
	
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIImageView *backgroundView ;
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
           backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,568,300)];
            
        }else
        {
           backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,480,300)];
        }
    }else
    {
    backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
    }
	
	backgroundView.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90];
	[self.view addSubview:backgroundView];
	[backgroundView release];
	[contentView release];
	
	[self initLandscapeTopBar];	
	

    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            templateView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,520,300-60)];
            
        }else
        {
       templateView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,480,300-60-44)];        }
    }else
    {
     templateView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,44,768,300-60-44)];
    }

	
		
	templateView.pagingEnabled = YES;
	templateView.directionalLockEnabled = YES;
	templateView.backgroundColor = [UIColor clearColor];
	templateView.contentSize = CGSizeMake(480*[images count],200);
	templateView.showsHorizontalScrollIndicator = NO;
    templateView.showsVerticalScrollIndicator = NO;
    templateView.scrollsToTop = NO;
    templateView.delegate = self;
	templateView.contentMode = UIViewContentModeScaleToFill;
	numberOfPages = [images count];
	[self.view addSubview:templateView];
	[self loadScrollView];
	[self initLabel];
	
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

#pragma mark -
#pragma mark private					

- (void)loadScrollView
{
	CGFloat t;
	
	t = 480;

	CGFloat curX = 140.0f;

	for(int i=0;i<numberOfPages;i++)
	{
		FISketchedImageView *curView = [[FISketchedImageView alloc] init];
		curView.tag = i+100;
		UIImage *currImage = [images objectAtIndex:i];
		CGRect frame;
		
		frame = CGRectMake(curX,5,200,190);
				
		curView.frame = frame;
		
		NSMutableDictionary *attrib =[NSMutableDictionary dictionary];
		[attrib setObject:[UIColor whiteColor] forKey:@"borderColor"];
		[attrib setObject:[UIColor colorWithRed:214.0/255.0 green:214.0/255.0 blue:214.0/255.0 alpha:1.0] forKey:@"strokeColor"];
		[attrib setObject:[NSNumber numberWithInt:2] forKey:@"strokeWidth"];
		[attrib setObject:[NSNumber numberWithInt:1] forKey:@"borderWidth"];
		[attrib setObject:currImage forKey:@"image"];
		[curView changeAtributes:attrib];
		
		curX+=t;
		[templateView addSubview:curView];
		[curView release];
	}
	
	[templateView setContentSize:CGSizeMake(numberOfPages*480,300-60-44)];
	currentPage = 0;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
		
	
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = templateView.frame.size.width;
	CGFloat offsetX = templateView.contentOffset.x;
	NSInteger page = floor(offsetX/pageWidth);
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
	
}

-(void)initTopBar
{
    
    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;

	UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,50)];
	topBar.userInteractionEnabled = YES;
	topBar.image = [UIImage imageNamed:@"i_top_panel.png"];
	[self.view addSubview:topBar];
	[topBar release];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,0,120,45)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.textColor = [UIColor colorWithRed:0.298 green:0.192 blue:0.106 alpha:1.0];
	titleLabel.shadowColor = [UIColor colorWithRed:0.647 green:0.565 blue:0.486 alpha:1.0];
	titleLabel.shadowOffset = CGSizeMake(0.5,0.5);
	titleLabel.text = @"Saved images";
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5,5,59,34);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
	
	UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
	saveButton.frame = CGRectMake(320-5-59,6,59,32);
	[saveButton setImage:[UIImage imageNamed:@"i_save_1.png"] forState:UIControlStateNormal];
	[saveButton setImage:[UIImage imageNamed:@"i_save_2.png"] forState:UIControlStateHighlighted];
	[saveButton addTarget:self action:@selector(selectDesign) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:saveButton];
	
}

-(void)initLandscapeTopBar
{
    FINavigationBar *navBar;
    if ([Util isPhone]) {
        
    
        if (IS_IPHONE_5) {
           navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,37.0)];
         }else
            {
          navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,37.0)];
    
            }
        
    }else
    {
     navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,768,37.0)];
    
    }
	
	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Images"];
    navBar.bgImage = [Util imageFromBundle:@"i_panel_bg.png"];
	
    UIButton *customSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *saveImage = [Util imageFromBundle:@"i_panel_done1.png"];
    customSaveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
    [customSaveButton setImage:saveImage forState:UIControlStateNormal];
    [customSaveButton setImage:[Util imageFromBundle:@"i_panel_done2.png"] forState:UIControlStateHighlighted];
    [customSaveButton addTarget:self
                         action:@selector(selectDesign)
               forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
    
    UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [Util imageFromBundle:@"i_panel_back1.png"];
    customBackButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    [customBackButton setImage:backImage forState:UIControlStateNormal];
    [customBackButton setImage:[Util imageFromBundle:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
    [customBackButton addTarget:self
                         action:@selector(backPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
	item.leftBarButtonItem = doneButton;
	item.rightBarButtonItem = saveButton;
	
	[navBar pushNavigationItem:item animated:NO];
	[self.view addSubview:navBar];
	[doneButton release];
	[saveButton release];
	[item release];
	[navBar release];
}

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)selectDesign
{
	if(delegate && [delegate respondsToSelector:@selector(selectedImage:)])
	{
		UIImage *retImage = [images objectAtIndex:currentPage];
		[delegate selectedImage:retImage];
		
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

-(void)initLabel
{
	countTitle = [[UILabel alloc] initWithFrame:CGRectMake(120,205+44,80,30)];
	countTitle.center = CGPointMake(240,285);
		
	countTitle.font = [UIFont fontWithName:@"Helvetica" size:16];
	countTitle.backgroundColor = [UIColor clearColor];
	countTitle.textAlignment = UITextAlignmentCenter;
	countTitle.textColor = [UIColor whiteColor];
	countTitle.text = [NSString stringWithFormat:@"%d/%d",currentPage+1,[images count]];
	[self.view addSubview:countTitle];
	[countTitle release];
	
	description = [[UITextView alloc] initWithFrame:CGRectMake(10,225+44,460,30)];
	description.center = CGPointMake(240,305);
		
	
	//description.userInteractionEnabled = NO;
	description.textColor = [UIColor whiteColor];
	description.textAlignment = UITextAlignmentCenter;
	description.font = [UIFont fontWithName:@"Helvetica" size:14];
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
	[templateView release];
	
	if (images) {
		[images release];
	}
	
	if (titles) {
		[titles release];
	}
	
    [super dealloc];
}


@end
