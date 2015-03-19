    //
//  FIFontController.m
//  flashCards
//
//  Created by Ruslan on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIFontController.h"

@interface FIFontController(Private)

-(void)initTopBar;
-(void)backPressed;
-(void)createFontArray;
-(void)initCurrentSettings;
-(void)initSlider;
-(void)sliderChanged:(UISlider*)sender;

@end


@implementation FIFontController
@synthesize category;

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
    
    float width = 320;
    if(IS_OS_8_OR_LATER)
        width = 568;
    
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,width,460)];
	self.view = contentView;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"i_bg.png"]];
	[contentView release];
	
	[self initTopBar];
	[self initCurrentSettings];
	[self createFontArray];
	
	if (![UIApplication sharedApplication].statusBarHidden) {
		fontTable = [[UITableView alloc] initWithFrame:CGRectMake(0,44,width,460-2*44) style:UITableViewStylePlain];
	}else {
			fontTable = [[UITableView alloc] initWithFrame:CGRectMake(0,44,width,480-2*44) style:UITableViewStylePlain];
	}

	

	fontTable.delegate = self;
	fontTable.dataSource = self;
	fontTable.backgroundColor = [UIColor clearColor];
	[self.view addSubview:fontTable];
	[fontTable release];
	[self initSlider];
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

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	 return [fonts count];
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
	UITableViewCell *cell;
	
	cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
					
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		
        float width = 320;
        if(IS_OS_8_OR_LATER)
            width = 568;
        
		UIImageView *cellBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,45)];
		cellBgView.userInteractionEnabled = YES;
		cellBgView.image = [UIImage imageNamed:@"i_list_bg_menu_1.png"];
			
		UIImageView *cellBgSelecView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width,45)];
		cellBgSelecView.userInteractionEnabled = YES;
		cellBgSelecView.image = [UIImage imageNamed:@"i_list_bg_menu_2.png"];
			
		cell.backgroundView = cellBgView;
		cell.selectedBackgroundView = cellBgSelecView;
			
		[cellBgView release];
		[cellBgSelecView release];
			
	}
	
	UIFont *cellFont = [UIFont fontWithName:[fonts objectAtIndex:indexPath.row]
									   size:currentSize];
	cell.textLabel.font = cellFont;
	
	cell.textLabel.text = [NSString stringWithFormat:@"Flashcards %@",[fonts objectAtIndex:indexPath.row]];
	
	if (currentFont && [currentFont isEqualToString:[fonts objectAtIndex:indexPath.row]]) {
		[fontTable selectRowAtIndexPath:indexPath
							   animated:NO
						 scrollPosition:UITableViewScrollPositionNone];
		
		if (currentPath ) {
			currentPath = nil;
		}
		
		currentPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
		
	}
	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (currentPath) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		currentPath = nil;
	}
	
	currentPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
	[tableView selectRowAtIndexPath:indexPath
						   animated:YES
					 scrollPosition:UITableViewScrollPositionNone];
	
	if (currentFont) {
		[currentFont release];
	}
	
	currentFont = [[NSString alloc] initWithString:[fonts objectAtIndex:indexPath.row]];
	
	NSDictionary *fontDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil]
														forKeys:[NSArray arrayWithObjects:@"font",@"size",nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fontChanged"
														object:fontDic];
	
}

#pragma mark -
#pragma mark private

-(void)createFontArray
{
	fonts = [[NSMutableArray alloc] init];
	NSArray *fontsFamily = [UIFont familyNames];
	
	for (NSString *familyName in fontsFamily) {
		[fonts addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
	}
}

-(void)backPressed
{
	if (category) {
		NSArray *saveArray = [NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil];
		[[NSUserDefaults standardUserDefaults] setObject:saveArray forKey:[NSString stringWithFormat:@"%@Font",category]];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
	
	
	
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
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,width,44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.textColor = [UIColor colorWithRed:0.298 green:0.192 blue:0.106 alpha:1.0];
	titleLabel.shadowColor = [UIColor colorWithRed:0.647 green:0.565 blue:0.486 alpha:1.0];
	titleLabel.shadowOffset = CGSizeMake(1,1);
	titleLabel.font = [UIFont boldSystemFontOfSize:14];
	titleLabel.text = @"Font";
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(5,5,59,34);
	[backButton setImage:[UIImage imageNamed:@"i_back_1.png"] forState:UIControlStateNormal];
	[backButton setImage:[UIImage imageNamed:@"i_back_2.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
	[topBar addSubview:backButton];
	
}

-(void)initCurrentSettings
{
	if (currentFont) {
		[currentFont release];
		currentFont = nil;
	}
	
	if (category) {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",category]];
		
		if (currentSettings) {
			currentFont = [[NSString alloc] initWithString:[currentSettings objectAtIndex:0]];
			currentSize = [[currentSettings objectAtIndex:1] intValue];
			return;
		}
	}
	
	currentFont = [[NSString alloc] initWithString:@"Helvetica"];
	currentSize = 16;
	
}

-(void)initSlider
{
	if (![UIApplication sharedApplication].statusBarHidden) {
		slider = [[UISlider alloc] initWithFrame:CGRectMake(5,460-44,250,44)];
	}else {
		slider = [[UISlider alloc] initWithFrame:CGRectMake(5,480-44,250,44)];
	}

	slider.minimumValue = 10.0;
	slider.maximumValue = 40.0;
	slider.continuous = YES;
	slider.backgroundColor = [UIColor clearColor];
	[self.view addSubview:slider];
	[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
	slider.value = currentSize;
	[slider	release];
	
	if (![UIApplication sharedApplication].statusBarHidden) {
		sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,460-44,315-260,44)];
	}else {
		sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(260,480-44,315-260,44)];
	}

	sliderLabel.backgroundColor = [UIColor clearColor];
	sliderLabel.font = [UIFont boldSystemFontOfSize:16];
	sliderLabel.textAlignment = UITextAlignmentCenter;
	sliderLabel.text = [NSString stringWithFormat:@"%d",currentSize];
	[self.view addSubview:sliderLabel];
	[sliderLabel release];
	
}

-(void)sliderChanged:(UISlider*)sender
{
	currentSize = ceil(slider.value);
	sliderLabel.text = [NSString stringWithFormat:@"%d",currentSize];
	[fontTable reloadData];
	
	NSDictionary *fontDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil]
														forKeys:[NSArray arrayWithObjects:@"font",@"size",nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fontChanged"
														object:fontDic];
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
	
	if (currentFont) {
		[currentFont release];
	}
	
	if (category) {
		[category release];
	}
	
	if (fonts) {
		[fonts release];
	}
	
    [super dealloc];
}


@end
