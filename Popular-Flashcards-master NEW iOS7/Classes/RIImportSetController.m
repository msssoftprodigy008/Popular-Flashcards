//
//  RIImportSetController.m
//  flashCards
//
//  Created by Ruslan on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIImportSetController.h"
#import "FDBController.h"
#import "FIFCImport.h"
#import "Util.h"

@interface RIImportSetController(Private)

#pragma mark private
-(void)importDefaultSets:(NSString*)dir;
-(void)stopImporting;
-(void)setLen:(NSNumber*)len;
-(void)setText:(NSString*)text;
-(void)setValue:(NSNumber*)value;

@end

@implementation RIImportSetController
@synthesize delegate;
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}*/

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 568, 320)];
            }
            else{
                _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 568, 300)];
            }
        }
        else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 500, 320)];
            }
            else{
                _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 480, 300)];
            }
            
        }
    }else{
        
        _bgViewLand = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Landscape.png"]];
        _bgViewLand.frame =CGRectMake(0, 20, 1024, 1024);
        [self.view addSubview:_bgViewLand];
        [_bgViewLand release];
        
        _bgViewPort = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Portrait.png"]];
        [self.view addSubview:_bgViewPort];
        [_bgViewPort release];
        
        if ([Util isPortrait:self]) {
            _bgViewLand.alpha = 0.0;
        }else{
            _bgViewPort.alpha = 0.0;
        }
        
        if ([Util isPortrait:self]) {
            _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 768, 1004)];
        }else{
            _loadingView = [[RILoadingView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
        }
    }
    
    [self.view addSubview:_loadingView];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([Util isPhone]) {
       return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    }else{
        return YES;
    }

}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (![Util isPhone]) {
        if ([Util isPortraitWithOrientation:toInterfaceOrientation]) {
            _loadingView.frame = CGRectMake(0, 0, 768, 1004);
            _bgViewPort.alpha = 1.0;
            _bgViewLand.alpha = 0.0;
        }else{
            _bgViewPort.alpha = 0.0;
            _bgViewLand.alpha = 1.0;
            _loadingView.frame = CGRectMake(0, 0, 1024, 748);
        }
        [_loadingView reset];
    }
}

-(void)dealloc{
    [super dealloc];
    if (_loadingView) {
        [_loadingView release];
    }
}


-(void)startImporting{
    [_loadingView performSelector:@selector(start) withObject:nil afterDelay:0.0];
    [self performSelectorInBackground:@selector(importDefaultSets:) withObject:@"DefaultSets"];
}

#pragma mark -
#pragma mark private
-(void)importDefaultSets:(NSString*)dirName{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL defaultSetsImp = [[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultSetsImp"];
	if(defaultSetsImp){
		return;
	}
	
	NSString *pathToDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dirName];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:pathToDir];
	NSString *file;
	
	NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSInteger count = [[dirEnum allObjects] count];
    NSInteger curVal = 0;
    dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:pathToDir];
    [self performSelectorOnMainThread:@selector(setLen:) withObject:[NSNumber numberWithDouble:count] waitUntilDone:YES];
	while (file = [dirEnum nextObject]) {
        
        curVal++;
        [self performSelectorOnMainThread:@selector(setValue:) withObject:[NSNumber numberWithDouble:curVal] waitUntilDone:YES];
        
		NSString *source = [pathToDir stringByAppendingPathComponent:file];
		BOOL isDir;
		NSLog(@"Analizing %@",file);
		if([[NSFileManager defaultManager] fileExistsAtPath:source isDirectory:&isDir] && isDir)
		{
			NSLog(@"Missed %@",file);
			continue;
		}
		
		NSString *target = [documents stringByAppendingPathComponent:[file lastPathComponent]];
		NSError *error = nil;
		if (![[NSFileManager defaultManager] copyItemAtPath:source
													 toPath:target
													  error:&error])
		{
			if (error) {
				NSLog(@"%@",[error localizedDescription]);
			}
			NSLog(@"Copy %@ failed",file);
			continue;
		}	
        
        NSString *setName = [[file lastPathComponent] stringByDeletingPathExtension];
        NSString *text = [NSString stringWithFormat:@"Importing %@...",setName];
        [self performSelectorOnMainThread:@selector(setText:) withObject:text waitUntilDone:YES];
		
		NSArray *pathComp = [file pathComponents];
		NSString *grName = [NSString stringWithString:dirName];
		
		NSLog(@"%@",file);
		
		if([pathComp count]>1){
			grName = [pathComp objectAtIndex:[pathComp count]-2];
		}
		
		NSString *grId = [[FDBController sharedDatabase] idForGroupName:grName];
		
		if(!grId){
			grId = [[FDBController sharedDatabase] addGroup:grName];
			if(!grId){
				continue;
			}
		}
		
		NSString *setId = [FIFCImport importFCFileWithPath:target];
		if(setId){
			[[FDBController sharedDatabase] insertCategory:setId toGroup:grId];
			[[FDBController sharedDatabase] insertTemplate:setId withTemplate:kCustomTemplate];
		}
        

	}
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"DefaultSetsImp"];
    [self performSelectorOnMainThread:@selector(stopImporting) withObject:nil waitUntilDone:NO];
    [pool release];
}

-(void)setLen:(NSNumber*)len{
    [_loadingView setLen:[len doubleValue]];
}
-(void)setValue:(NSNumber*)value{
    [_loadingView setCurValue:[value doubleValue]];
}

-(void)setText:(NSString*)text{
    [_loadingView setText:text];
}

-(void)stopImporting{
    [_loadingView performSelector:@selector(stop) withObject:nil afterDelay:0.0];
    
    if (delegate && [delegate respondsToSelector:@selector(importEnded)]) {
        [delegate importEnded];
    }
}


@end
