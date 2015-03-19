    //
//  RISimpleTableViewController.m
//  flashCards
//
//  Created by Ruslan on 5/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RISimpleTableViewController.h"

@interface RISimpleTableViewController(Private)

#pragma mark init
-(void)initTableView;

@end


@implementation RISimpleTableViewController
@synthesize r_delegate;

#pragma mark -
#pragma mark main

-(id)initWithRows:(NSArray*)rows forFrame:(CGRect)frame;
{
	r_frame = frame;
	
	if (rows) {
		r_rows = [[NSMutableArray alloc] initWithArray:rows];
	}
	
	return [self init];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:r_frame];
	self.view = contentView;
	[contentView release];
	self.view.backgroundColor = [UIColor whiteColor];
	[self initTableView];
	
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
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	if (r_rows) {
		[r_rows release];
	}
	
    [super dealloc];
}

#pragma mark main ends

#pragma mark -
#pragma mark UITableView delegate

#pragma mark UITableView delegate ends

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (r_rows) {
		return [r_rows count];
		
	}else {
		return 0;
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"RISimplCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
									   reuseIdentifier:CellIdentifier] autorelease];
		
	}
	
	cell.textLabel.text = [r_rows objectAtIndex:indexPath.row];
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(selectedRow:)]) {
		[r_delegate selectedRow:indexPath.row];
	}
	
}

#pragma mark -

#pragma mark init

-(void)initTableView
{
	r_tableView = [[UITableView alloc] initWithFrame:self.view.frame
											   style:UITableViewStylePlain];
	r_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	r_tableView.delegate = self;
	r_tableView.dataSource = self;
	[self.view addSubview:r_tableView];
	[r_tableView release];
}

#pragma mark init ends


@end
