    //
//  ImportViewController.m
//  flashCards
//
//  Created by Ruslan on 4/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImportViewController.h"
#import "Constants.h"
#import "FCSVParser.h"
#import "Util.h"
#import "ZipArchive.h"
#import "FDBController.h"
#import "FIFCImport.h"

@interface ImportViewController(Private)

-(void)updateFilenameArray;
-(NSString*)filePathToImport:(NSString*)fileName;
-(void)goBack;
@end


@implementation ImportViewController
@synthesize delegate;

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
	UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,536)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	CGRect tabFrame = CGRectMake(0,0,540,536);
    if (importTable == nil) {
        importTable = [[UITableView alloc] initWithFrame:tabFrame style:UITableViewStylePlain];
        importTable.delegate = self;
        importTable.dataSource = self;
        importTable.backgroundColor = [UIColor clearColor];
    } else {
        importTable.frame = tabFrame;
    }
	
	[self.view addSubview:importTable];
	[importTable release];
	[self updateFilenameArray];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
		
    [super viewDidLoad];
}

-(void)upgraded
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	
	upgradeView.hidden = YES;
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView==importTable) 
		return [fileNames count];
	else
		return 1;

}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [importTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
	}
	if (theTableView==importTable) 
		cell.textLabel.text = [[fileNames objectAtIndex:indexPath.row] stringByDeletingPathExtension];	
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Itunes import" withParam:nil];
	
	NSString *filename = [[NSString alloc] initWithString:[fileNames objectAtIndex:indexPath.row]];
    NSString *filePath = [self filePathToImport:filename];
	NSString *item = [NSString stringWithString:[FIFCImport importFCFileWithPath:filePath]];
	[filename release];
	
	if (delegate && [delegate respondsToSelector:@selector(itunesSetImported:)]) {
		[delegate itunesSetImported:item];
    }
    
    [Util showMessage:@"Itunes"
           forMessage:[NSString stringWithFormat:@"%@ set was imported",filename]
       forButtonTitle:@"OK"];
		
	[self updateFilenameArray];
	[importTable reloadData];
}


#pragma mark -
#pragma mark privateMethods

-(void)goBack
{
	[self dismissModalViewControllerAnimated:NO];
}


-(void)updateFilenameArray
{
	if (fileNames)
		[fileNames release];
	
	fileNames = [[NSMutableArray alloc] init];
	
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
        NSLog(@"%@ %@",oldPath,ext);
        return oldPath;
    }else{
        [[NSFileManager defaultManager] moveItemAtPath:oldPath
                                                toPath:newPath
                                                 error:nil];
        [Util removeFile:oldPath];
        return newPath;
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
	[upgradeView release];
	
	if (fileNames) {
		[fileNames release];
	}
	
	[super dealloc];
}


@end
