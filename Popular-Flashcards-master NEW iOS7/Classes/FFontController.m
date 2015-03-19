    //
//  FFontController.m
//  flashCards
//
//  Created by Ruslan on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FFontController.h"
#import "FRootConstants.h"
#import "Constants.h"
#import "Util.h"

@interface FFontController(Private)

-(void)initTopBar;
-(void)backPressed;
-(void)createFontArray;
-(void)initCurrentSettings;
-(void)initSlider;
-(void)sliderChanged:(UISlider*)sender;


@end


@implementation FFontController
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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,624)];
	self.view = contentView;
	self.view.backgroundColor  = kDefaultBgColor;
	[contentView release];
	
	isFontChanged = NO;
	self.view.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
	[self initTopBar];
	[self initCurrentSettings];
	[self createFontArray];
	fontTable = [[UITableView alloc] initWithFrame:CGRectMake(0,44,540,624-2*44) style:UITableViewStylePlain];
	fontTable.delegate = self;
	fontTable.dataSource = self;
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


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


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
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		
	}
	
	UIFont *cellFont = [UIFont fontWithName:[fonts objectAtIndex:indexPath.row]
									   size:currentSize];
	cell.textLabel.font = cellFont;
	
	cell.textLabel.text = [NSString stringWithFormat:@"Flashcards %@",[fonts objectAtIndex:indexPath.row]];
	
	if (currentFont && [currentFont isEqualToString:[fonts objectAtIndex:indexPath.row]]) {
		[fontTable selectRowAtIndexPath:indexPath
							   animated:NO
						 scrollPosition:UITableViewScrollPositionNone];
		

		currentPath = indexPath.row;
		
	}
	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (currentPath != -1) {
		[tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:currentPath inSection:0] animated:YES];
		currentPath = -1;
	}
	
	currentPath = indexPath.row;
	[tableView selectRowAtIndexPath:indexPath
						   animated:YES
					 scrollPosition:UITableViewScrollPositionNone];
	
	if (currentFont) {
		[currentFont release];
	}
	
	currentFont = [[NSString alloc] initWithString:[fonts objectAtIndex:indexPath.row]];
	
	isFontChanged = YES;
	
	
}

#pragma mark -
#pragma mark private

-(void)createFontArray
{
	fonts = [[NSMutableArray alloc] init];
	NSArray *fontsFamily = [UIFont familyNames];
	
	for (NSString *familyName in fontsFamily) {
        
       // NSLog(@"Family: %@  Font: %@  ", fontsFamily,familyName);

        
      
        if ([familyName isEqualToString:@"Academy Engraved LET"]) { //changed by sanjeev reddy for unsized font
            
            [fonts removeObjectsInArray:[UIFont fontNamesForFamilyName:familyName]];
        }else
        {
        [fonts addObjectsFromArray:[UIFont fontNamesForFamilyName:familyName]];
        }
        
		
	}
    
    }

-(void)backPressed
{
	if (category && isFontChanged) {
		
		NSArray *saveArray = [NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil];
		[[NSUserDefaults standardUserDefaults] setObject:saveArray forKey:[NSString stringWithFormat:@"%@Font",category]];
		NSDictionary *dicFont = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil]
															forKeys:[NSArray arrayWithObjects:@"font",@"size",nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"fontChanged"
															object:dicFont];
	}
	
	[self dismissModalViewControllerAnimated:YES];
	
	
	
}

-(void)initTopBar
{
	UIToolbar *topBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,540,44)];
	[self.view addSubview:topBar];
	[topBar release];
	
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,540,44)];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.textAlignment = UITextAlignmentCenter;
	titleLabel.font = [UIFont boldSystemFontOfSize:16];
	titleLabel.text = @"Font";
	[topBar addSubview:titleLabel];
	[titleLabel release];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																   style:UIBarButtonItemStyleDone
																  target:self 
																  action:@selector(backPressed)];
	topBar.items = [NSArray arrayWithObject:backButton];
	[backButton release];
	
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
	currentSize = 30;
	
}

-(void)initSlider
{
	slider = [[UISlider alloc] initWithFrame:CGRectMake(5,624-44,430,44)];
	slider.minimumValue = 20.0;
	slider.maximumValue = 40.0;//changed by sanjeev reddy
	slider.continuous = NO;
	slider.backgroundColor = [UIColor clearColor];
	[self.view addSubview:slider];
	[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
	slider.value = currentSize;
	[slider	release];
	
	sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(440,624-44,535-440,44)];
	sliderLabel.backgroundColor = [UIColor clearColor];
	sliderLabel.font = [UIFont boldSystemFontOfSize:18];
	sliderLabel.textAlignment = UITextAlignmentCenter;
	sliderLabel.text = [NSString stringWithFormat:@"%d",currentSize];
	[self.view addSubview:sliderLabel];
	[sliderLabel release];
	
}

-(void)sliderChanged:(UISlider*)sender
{
	currentSize = ceil(slider.value);
	sliderLabel.text = [NSString stringWithFormat:@"%d",currentSize];
	isFontChanged = YES;
	[fontTable reloadData];
	
	NSDictionary *dicFont = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil]
														forKeys:[NSArray arrayWithObjects:@"font",@"size",nil]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fontChanged"
														object:dicFont];
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
