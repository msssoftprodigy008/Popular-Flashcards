    //
//  FIITunesViewController.m
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIITunesViewController.h"
#import "FDBController.h"
#import "FCSVParser.h"
#import "FINavigationBar.h"
#import "ZipArchive.h"
#import "FRootConstants.h"
#import "Util.h"
#import "FIFCImport.h"
#import "Constant.h"

@interface FIITunesViewController(Private)

-(void)initTopBar;
-(void)initImportArray;

-(BOOL)unzipFile:(NSString*)fileName;
-(void)removeDir:(NSString*)dirName;
-(void)addArrayToBase:(NSMutableArray*)set fromDir:(NSString*)path forFilename:(NSString*)filename;
-(BOOL)importBackupWithName:(NSString*)fileName;
-(NSString*)filePathToImport:(NSString*)fileName;

@end


@implementation FIITunesViewController

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

// NILESH PATEL 12 September 2014

- (void)loadView {
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,((IS_IPHONE_5)?568:480),300)];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	[self initTopBar];
	[self initImportArray];
	
	availableSetsTable = [[UITableView alloc] initWithFrame:CGRectMake(0,35,((IS_IPHONE_5)?568:480),265)
													  style:UITableViewStylePlain];
	availableSetsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	availableSetsTable.delegate = self;
	availableSetsTable.dataSource = self;
	[self.view addSubview:availableSetsTable];
	[availableSetsTable release];
	
	
	
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
    if ([Util isPhone]) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }else{
        return YES;
    }
}


#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (fileNames) 
		return [fileNames count];
	else
		return 0;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
		cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
		
	}
	
	NSString *importName = [fileNames objectAtIndex:indexPath.row];
	cell.textLabel.text = [importName stringByDeletingPathExtension];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Itunes import" withParam:nil];
	
	NSString *filename = [[NSString alloc] initWithString:[fileNames objectAtIndex:indexPath.row]];
    NSString *importPath = [self filePathToImport:filename];
	NSString *item = [NSString stringWithString:[FIFCImport importFCFileWithPath:importPath]];
	
	if (item) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"itunesAdded" object:item];
		[self initImportArray];
		[tableView reloadData];
		[Util showMessage:@"Itunes"
			   forMessage:[NSString stringWithFormat:@"%@ set was imported",filename]
		   forButtonTitle:@"OK"];
	}
	
	[filename release];
	
}

#pragma mark -
#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex != [alertView cancelButtonIndex]) 
		[[NSNotificationCenter defaultCenter] postNotificationName:@"itunesAdded" object:newCategory];
	
	
}


#pragma mark -
#pragma mark private

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
    FINavigationBar *topBar;
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
	topBar.bgImage	= [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@"Select file to import"];
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

-(void)initImportArray
{
	if (fileNames) {
		[fileNames removeAllObjects];
	}else{
        fileNames = [[NSMutableArray alloc] init];
    }
	
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documents = [paths objectAtIndex:0];
	
	
	NSString *file;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath: documents];
	NSSet *formatSet = [FIFCImport supportedExtensions];
	while (file = [dirEnum nextObject]) {
		BOOL isDir;
		[[NSFileManager defaultManager] fileExistsAtPath:[documents stringByAppendingPathComponent:file]
											 isDirectory:&isDir];
		wchar_t sym = [file characterAtIndex:0];
		if ([formatSet containsObject:[file pathExtension]] && !isDir && sym!='.') {
			NSArray *arr = [file componentsSeparatedByString:@"/"];
			
			if (!arr || [arr count]<=0) {
				continue;
			}
			
			NSString *category = [arr objectAtIndex:0];
			category = [category stringByDeletingPathExtension];
			if (![[FDBController sharedDatabase] checkCategoryExisting:category]) 
				[fileNames addObject:file];		
		}
		
	}
	
}

-(NSString*)filePathToImport:(NSString*)fileName{
    NSString *oldPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *newPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
    oldPath = [oldPath stringByAppendingPathComponent:fileName];
    newPath = [newPath stringByAppendingPathComponent:fileName];
    NSSet *csvSet = [FIFCImport supportedCSVExt];
    NSString *ext = [oldPath pathExtension];
    if ([csvSet containsObject:ext]) {
        return oldPath;
    }else{
        [[NSFileManager defaultManager] moveItemAtPath:oldPath
                                                toPath:newPath
                                                 error:nil];
        [Util removeFile:oldPath];
        return newPath;
    }
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
	
	if (fileNames) {
		[fileNames release];
	}
	
	[super dealloc];
}


@end
