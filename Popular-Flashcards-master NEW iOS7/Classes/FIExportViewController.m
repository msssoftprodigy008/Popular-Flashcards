//
//  FIExportViewController.m
//  flashCards
//
//  Created by Ruslan on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIExportViewController.h"
#import "FDBController.h"
#import "FPrepareToExport.h"
#import <QuartzCore/QuartzCore.h>
#import "FISRHeader.h"
#import "DBTime.h"
#import "FIFontController.h"
#import "FTextAlertView.h"
#import "FINavigationBar.h"
#import "FISceneViewController.h"
#import "RIChooseGroupController.h"
#import "FDBController.h"
#import "ModalAlert.h"
#import "JSON.h"
#import "Util.h"
#import "Constant.h"
#define kMainTableViewTag 100
#define kSecondaryTableViewTag 101

@interface FIExportViewController(Private)

-(void)initTopBar;
-(void)sendToMail:(NSString*)path forFilename:(NSString*)fileName;
-(void)removeArchive;
-(void)generateSetResults:(NSString*)path forCategory:(NSString*)categoryName;
-(BOOL)generateSetBackup:(NSString*)path;
-(void)clearPaths;
-(void)sendCards;
-(void)initCurrentFont;
-(void)initTableViews;
-(void)initProgressView;
-(void)initCurrentPreference;
-(BOOL)testOn;
-(void)setTest:(BOOL)test;
-(void)saveCurrentPreference;
-(void)saveCurrentFont;
-(void)editCards;
-(void)changeCategory;
-(void)upgrade:(NSNotification*)sender;

-(void)updateProgressView;
//notifications
-(void)fontChanged:(NSNotification*)sender;

-(void)progressValueChanged:(id)sender;

-(void)languageChoose;
-(void)postCardsToQuizlet:(NSArray*)cards imIDs:(NSArray*)imIDs l1:(NSString*)l1 l2:(NSString*)l2;
- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
-(void)handleQuizletNotification:(NSNotification*)sender;
@end


@implementation FIExportViewController
@synthesize categoryToExport;
@synthesize group;
@synthesize orientation;
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
    UIView *contentView;
    if (IS_IPHONE_5) {
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,300)];
    }
    else{
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
    }
    
	self.view = contentView;
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	[self initCurrentFont];
	[self initCurrentPreference];
	[self initTableViews];
	[self initTopBar];
	[self initProgressView];
	
    _indicatorView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?276:256),((IS_IPHONE_5)?568:480),44)];
	_indicatorView.delegate = self;
    
	isReloadCategory = NO;
    isLoadingSet = NO;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upgrade:)
                                                 name:@"upgraded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizletNotification:) name:@"QuizletCode" object:nil];
	
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
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView.tag == kMainTableViewTag) {
        if ([Util isFullVersion]) {
            return 4;
        }else{
            return 3;
        }
        
    }else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (tableView.tag == kMainTableViewTag) {
		switch (section) {
            case 0:
                return 3;
                break;
			case 1:
                if ([Util isFullVersion]) {
                    return 5;
                }else{
                    return 3;
                }
                break;
            case 2:
                if ([Util isFullVersion]) {
                    return 2;
                }else{
                    return 1;
                }
				
				break;
			case 3:
				return 3;
				break;
			default:
				break;
		}
	}else {
		if (fonts) {
			return [fonts count];
		}else {
			return 0;
		}
	}
	
	return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
	static NSString *CellIdentifier2 = @"CellForCategory2";
    UITableViewCell *cell;
	
	if (theTableView.tag == kMainTableViewTag) {
		cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	}else {
		cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier2];
	}
    
	if (cell == nil) {
		if (theTableView.tag == kMainTableViewTag) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
		}
        
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.textColor = [UIColor darkTextColor];
		cell.textLabel.highlightedTextColor = [UIColor darkTextColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	if (theTableView.tag == kMainTableViewTag) {
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
				case 0:
				{
					cell.textLabel.text = @"Reset sessions";
					break;
				}
				case 1:
				{
					cell.textLabel.text = @"Edit cards";
					break;
				}
                case 2:
                    cell.textLabel.text = @"Move to";
                    break;
				default:
					break;
			}
        }else if (indexPath.section == 1) {
            if ([Util isFullVersion]) {
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"Upload to Quizlet.com";
                        break;
                    case 1:
                        cell.textLabel.text = @"Send set data by Email";
                        break;
                    case 2:
                        cell.textLabel.text = @"Save set to Documents";
                        break;
                    case 3:
                        cell.textLabel.text = @"Send set for Anki by Email";
                        break;
                    case 4:
                        cell.textLabel.text = @"Save set for Anki to Documents";
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        cell.textLabel.text = @"Reversed cards";
                        if (isReversed) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    }
                    case 1:
                    {
                        cell.textLabel.text = @"Both sided cards";
                        if (isBothSide) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    }
                    case 2:{
                        cell.textLabel.text = @"Shuffle test cards";
                        if ([self testOn]) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            
		}else if (indexPath.section == 2) {
            if ([Util isFullVersion]) {
                switch (indexPath.row) {
                    case 0:
                        cell.textLabel.text = @"Send backup by email";
                        break;
                    case 1:
                        cell.textLabel.text = @"Save backup to Documents";
                        break;
                    default:
                        break;
                }
            }else{
                cell.textLabel.text = @"Upgrade to unlock Pro features";
            }
            
		}else {
			switch (indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Reversed cards";
                    if (isReversed) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                }
                case 1:
                {
                    cell.textLabel.text = @"Both sided cards";
                    if (isBothSide) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                }
                case 2:{
                    cell.textLabel.text = @"Shuffle test cards";
                    if ([self testOn]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                }
                default:
                    break;
            }
		}
	}else {
		cell.textLabel.text = [fonts objectAtIndex:indexPath.row];
		cell.textLabel.font = [UIFont fontWithName:cell.textLabel.text size:14];
		if (currentFont && [currentFont isEqualToString:cell.textLabel.text]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			currentPath = indexPath.row;
		}else {
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
        
		
	}
    
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
	UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,240,30)] autorelease];
	headerView.backgroundColor = [UIColor clearColor];
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,0,190,30)];
    
	if (tableView.tag == kMainTableViewTag) {
		switch (section) {
            case 0:
                titleLabel.text = @"Edit";
                break;
			case 1:
                if ([Util isFullVersion]) {
                    titleLabel.text = @"Share";
                }else{
                    titleLabel.text = @"Settings";
                }
				break;
			case 2:
                if ([Util isFullVersion]) {
                    titleLabel.text = @"Backup";
                }else{
                    titleLabel.text = @"Upgrade";
                }
				
				break;
			case 3:
				titleLabel.text = @"Settings";
				break;
			default:
				break;
		}
	}else {
		titleLabel.text = @"Fonts";
	}
    
    
	titleLabel.textColor = kDefaultTextColor;
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	titleLabel.shadowOffset = CGSizeMake(0,1);
	titleLabel.shadowColor = [UIColor whiteColor];
	[headerView addSubview:titleLabel];
	[titleLabel release];
    
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isLoadingSet) {
        [Util showMessage:@""
               forMessage:@"This set is uploading to Quizlet.com. Please try later..."
           forButtonTitle:@"OK"];
        return;
    }
	
	if ([tableView isEqual:exportTable]) {
        
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                {
                    if(categoryToExport)
                    {
                        [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Reset session" withParam:nil];
                        NSString *message = @"Are you sure you want to reset all sessions progress associted with this set?";
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Sessions"
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:@"YES"
                                                              otherButtonTitles:@"NO",nil];
                        alert.tag = -222;
                        [alert show];
                        [alert release];
                    }
                }
                    break;
                case 1:
                    [self editCards];
                    break;
                case 2:
                    [self changeCategory];
                    break;
                default:
                    break;
            }
        }else if (indexPath.section == 1) {
            if ([Util isFullVersion]) {
                switch (indexPath.row) {
                    case 0:
                        [self languageChoose];
                        break;
                    case 1:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Mail category data" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *pathToDoc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [pathToDoc objectAtIndex:0];
                            NSString *path = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.flashCardPlus",name]];
                            BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:path];
                            
                            if (isEx) {
                                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                            }
                            
                            if(![FPrepareToExport makeZipFromCategoryAtPath:path forResultsPath:nil fromCategory:categoryToExport])
                            {
                                [Util showMessage:@"Mail"
                                       forMessage:[NSString stringWithFormat:@"Can't sent %@ Set Data by Email.",name]
                                   forButtonTitle:@"OK"];
                                return;
                            }
                            
                            isReqToClean = YES;
                            
                            if(filesToClean)
                                [filesToClean addObject:path];
                            else {
                                filesToClean = [[NSMutableArray alloc] init];
                                [filesToClean addObject:path];
                            }
                            
                            [self sendToMail:path forFilename:[NSString stringWithFormat:@"%@.flashCardPlus",name]];
                            
                        }
                        break;
                    case 2:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Archive category to documents" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *pathToDoc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [pathToDoc objectAtIndex:0];
                            NSString *path = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",name]];
                            BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:path];
                            
                            if (isEx) {
                                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                            }
                            
                            if([FPrepareToExport makeZipFromCategoryAtPath:path forResultsPath:nil fromCategory:categoryToExport])
                            {
                                [Util showMessage:@"Archive Set"
                                       forMessage:[NSString stringWithFormat:@"%@ Set Data was archived and saved to Documents. Please use iTunes to download the file",name]
                                   forButtonTitle:@"OK"];
                            }
                            else {
                                [Util showMessage:@"Archive Set"
                                       forMessage:[NSString stringWithFormat:@"Can't archive %@ Set Data to Documents",name]
                                   forButtonTitle:@"OK"];
                            }
                            
                        }
                        break;
                    case 3:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Mail category using anki format" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *pathToDoc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [pathToDoc objectAtIndex:0];
                            NSString *path = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_for_anki.zip",name]];
                            BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:path];
                            
                            if (isEx) {
                                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                            }
                            
                            if(![FPrepareToExport makeZipFromCategoryAtPathAsAnki:path fromCategory:categoryToExport])
                            {
                                [Util showMessage:@"Mail Anki"
                                       forMessage:[NSString stringWithFormat:@"Can't sent %@ Set Data by Email.",name]
                                   forButtonTitle:@"OK"];
                                return;
                            }
                            
                            isReqToClean = YES;
                            
                            if(filesToClean)
                            {
                                [filesToClean addObject:path];
                            }
                            else {
                                filesToClean = [[NSMutableArray alloc] init];
                                [filesToClean addObject:path];
                            }
                            
                            [self sendToMail:path forFilename:[NSString stringWithFormat:@"%@_for_anki.zip",name]];
                            
                        }
                        break;
                    case 4:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Archive category to documents using anki format" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *pathToDoc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [pathToDoc objectAtIndex:0];
                            NSString *path = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_for_anki.zip",name]];
                            
                            if(![FPrepareToExport makeZipFromCategoryAtPathAsAnki:path fromCategory:categoryToExport])
                            {
                                [Util showMessage:@"Archive anki set"
                                       forMessage:[NSString stringWithFormat:@"Can't archive %@ Set Data to Documents",name]
                                   forButtonTitle:@"OK"];
                            }
                            else {
                                [Util showMessage:@"Archive anki set"
                                       forMessage:[NSString stringWithFormat:@"%@ Set Data was archived and saved to Documents for using by Anki. Please use iTunes to download the file",name]
                                   forButtonTitle:@"OK"];
                            }
                        }
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                    {
                        [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change reverse cards property" withParam:nil];
                        isReloadCategory = YES;
                        isReversed  = !isReversed;
                        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                        if (isReversed) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }else {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                        
                        break;
                    }
                    case 1:
                    {
                        [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change both sided cards property" withParam:nil];
                        isBothSide = !isBothSide;
                        isReloadCategory = YES;
                        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                        if (isBothSide) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }else {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                        break;
                    }
                    case 2:{
                        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                        if ([self testOn]) {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                            [self setTest:NO];
                        }else{
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                            [self setTest:YES];
                        }
                        break;
                    }
                    default:
                        break;
                }
			}
		}else if (indexPath.section == 2) {
            if ([Util isFullVersion]) {
                switch (indexPath.row) {
                    case 0:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Mail category backup" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [path objectAtIndex:0];
                            NSString *zipF = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.flashBackup",name]];
                            
                            if ([self generateSetBackup:zipF]){
                                
                                isReqToClean = YES;
                                if(filesToClean)
                                {
                                    [filesToClean addObject:zipF];
                                }
                                else {
                                    filesToClean = [[NSMutableArray alloc] init];
                                    [filesToClean addObject:zipF];
                                }
                                
                                [self sendToMail:zipF forFilename:[NSString stringWithFormat:@"%@.flashBackup",name]];
                            }else{
                                [Util showMessage:@"Mail"
                                       forMessage:@"Can't send backup"
                                   forButtonTitle:@"OK"];
                            }
                        }
                        break;
                    case 1:
                        if (categoryToExport)
                        {
                            [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Backup category" withParam:nil];
                            NSString *name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
                            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                            NSString *documents = [path objectAtIndex:0];
                            NSString *zipF = [documents stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.flashBackup",name]];
                            if ([self generateSetBackup:zipF])
                            {
                                [Util showMessage:@"Backup"
                                       forMessage:[NSString stringWithFormat:@"Backup for set %@ succesfully saved",name]
                                   forButtonTitle:@"OK"];
                            }else {
                                [Util showMessage:@"Backup"
                                       forMessage:@"Can't save backup"
                                   forButtonTitle:@"OK"];
                            }
                        }
                        break;
                    default:
                        break;
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"upgrade" object:nil];
            }
            
		}else {
			switch (indexPath.row) {
                case 0:
                {
                    [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change reverse cards property" withParam:nil];
                    isReloadCategory = YES;
                    isReversed  = !isReversed;
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if (isReversed) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    
                    break;
                }
                case 1:
                {
                    [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change both sided cards property" withParam:nil];
                    isBothSide = !isBothSide;
                    isReloadCategory = YES;
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if (isBothSide) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                }
                case 2:{
                    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                    if ([self testOn]) {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                        [self setTest:NO];
                    }else{
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        [self setTest:YES];
                    }
                    break;
                }
                default:
                    break;
            }
		}
	}else {
		if (currentPath != indexPath.row) {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentPath inSection:0]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			cell = [tableView cellForRowAtIndexPath:indexPath];
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			
			if (currentFont) {
				[currentFont release];
			}
			currentFont = [[NSString alloc] initWithString:cell.textLabel.text];
			currentPath = indexPath.row;
			isReloadCategory = YES;
		}
	}
    
	
	
	
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(FTextAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == -222) {
		
		if (buttonIndex == [alertView cancelButtonIndex]) {
			[[FDBController sharedDatabase] clearSetSession:categoryToExport];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"reset" object:nil];
			
			if (!isReloadCategory) {
				isReloadCategory = YES;
			}
		}
	}
	
}

#pragma mark -
#pragma mark mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self clearPaths];
	
	if (result == MFMailComposeResultSent) {
		[Util showMessage:@"Mail"
			   forMessage:@"Your mail was sent"
		   forButtonTitle:@"OK"];
	}
	
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark mail delegate ends

#pragma mark FPicker delegate

-(void)languagePicked:(NSString*)fromL next:(NSString*)toLan{
    if (_l1) {
        [_l1 release];
    }
    if (_l2) {
        [_l2 release];
    }
    _l1 = [[NSString alloc] initWithString:[_langDic objectForKey:fromL]];
    _l2 = [[NSString alloc] initWithString:[_langDic objectForKey:toLan]];;
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to upload your set with term language %@ and definition language %@?",fromL,toLan];
    if ([ModalAlert ask:message]) {
        NSArray *cards = [[FDBController sharedDatabase] infoForCategory:categoryToExport];
        if (cards) {
            NSMutableArray *imagePaths = [NSMutableArray array];
            for (NSArray *card in cards) {
                NSInteger cid = [[card objectAtIndex:0] intValue];
                NSString *imPath = [Util pathForImage:categoryToExport forID:cid front:YES];
                NSString *aimPath = [Util pathForImage:categoryToExport forID:cid front:NO];
                if ([[NSFileManager defaultManager] fileExistsAtPath:imPath]) {
                    [imagePaths addObject:imPath];
                }else if([[NSFileManager defaultManager] fileExistsAtPath:aimPath]){
                    [imagePaths addObject:aimPath];
                }
            }
            if ([imagePaths count]>0) {
                NSString *acType = [[QIRequest sharedRequest] account];
                if (acType && [acType isEqualToString:@"plus"]) {
                    [self.view addSubview:_indicatorView];
                    [_indicatorView setCurVal:0];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    isLoadingSet = YES;
                    NSLog(@"send image %d",[imagePaths count]);
                    [[QIRequest sharedRequest] fetchImageUpload:self images:imagePaths];
                }else{
                    NSString *message = [NSString stringWithString:@"Your account type isn't plus. Are you sure you want to upload set without images?"];
                    if ([ModalAlert ask:message]) {
                        [self postCardsToQuizlet:cards imIDs:[NSMutableArray array] l1:_l1 l2:_l2];
                    }
                }
                
            }else{
                [self postCardsToQuizlet:cards imIDs:[NSMutableArray array] l1:_l1 l2:_l2];
            }
            [cards release];
            
        }else{
            [Util showMessage:@"Error" forMessage:@"No cards found for set" forButtonTitle:@"Close"];
        }
        
    }
}

#pragma mark -


#pragma mark -
#pragma mark init

-(void)initTopBar
{
    //init navigation bar
	FINavigationBar *navigationBar = [[FINavigationBar alloc] init];
    
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
        }
        else{
            navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
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
            navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
        }
        else{
            navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
        }
        
        
    }
    
    
    
	//init navigation bar
	navigationBar.tintColor = kDefaultNavColor;
	navigationBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
	[self.view addSubview:navigationBar];
	[navigationBar release];
	
	//init navigation item
	NSString *set_name = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
	UINavigationItem *navigationTopItem = [[UINavigationItem alloc] initWithTitle:set_name];
	[navigationBar pushNavigationItem:navigationTopItem animated:NO];
	[navigationTopItem release];
	
	//init back button
	UIButton *backCustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *backButtonImage = [UIImage imageNamed:@"i_panel_main1.png"];
	backCustomButton.frame = CGRectMake(0,0,backButtonImage.size.width,backButtonImage.size.height);
	[backCustomButton setImage:backButtonImage forState:UIControlStateNormal];
	[backCustomButton setImage:[UIImage imageNamed:@"i_panel_main2.png"] forState:UIControlStateHighlighted];
	[backCustomButton addTarget:self
						 action:@selector(backPressed)
			   forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backCustomButton];
	navigationTopItem.leftBarButtonItem = backButton;
	[backButton release];
}

-(void)initTableViews
{
	//init main table
	if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            exportTable = [[UITableView alloc] initWithFrame:CGRectMake(0,32,284,288) style:UITableViewStyleGrouped];
            secondaryTable = [[UITableView alloc] initWithFrame:CGRectMake(284,32,284,288) style:UITableViewStyleGrouped];
        }
        else{
            exportTable = [[UITableView alloc] initWithFrame:CGRectMake(0,32,284,268) style:UITableViewStyleGrouped];
            secondaryTable = [[UITableView alloc] initWithFrame:CGRectMake(284,32,284,268) style:UITableViewStyleGrouped];
        }
        
    }
    else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            exportTable = [[UITableView alloc] initWithFrame:CGRectMake(0,32,240,288) style:UITableViewStyleGrouped];
            secondaryTable = [[UITableView alloc] initWithFrame:CGRectMake(240,32,240,288) style:UITableViewStyleGrouped];
        }
        else{
            exportTable = [[UITableView alloc] initWithFrame:CGRectMake(0,32,240,288) style:UITableViewStyleGrouped];
            secondaryTable = [[UITableView alloc] initWithFrame:CGRectMake(240,32,240,288) style:UITableViewStyleGrouped];
        }
        
        
    }
    
	exportTable.tag = kMainTableViewTag;
	exportTable.delegate = self;
	exportTable.dataSource = self;
	exportTable.backgroundColor = [UIColor clearColor];
	exportTable.showsVerticalScrollIndicator = NO;
	[self.view addSubview:exportTable];
	[exportTable release];
	
	//init secondary table
	
	
	secondaryTable.tag = kSecondaryTableViewTag;
	secondaryTable.delegate = self;
	secondaryTable.dataSource = self;
	secondaryTable.backgroundColor = [UIColor clearColor];
	secondaryTable.scrollEnabled = NO;
	[self.view addSubview:secondaryTable];
	[secondaryTable release];
}

-(void)initProgressView
{
    progressView = [[UISlider alloc] init];
    progressLabel = [[UILabel alloc] init];
    if (IS_IPHONE_5) {
        progressView.frame = CGRectMake(314,260,150,30);
        progressLabel.frame = CGRectMake(474,260,50,30);
    } else {
        progressView.frame = CGRectMake(270,260,150,30);
        progressLabel.frame = CGRectMake(430,260,50,30);
    }
    
	progressView.minimumValue = 21;
	progressView.maximumValue = 35;
	progressView.backgroundColor = [UIColor clearColor];
	[self.view addSubview:progressView];
	[progressView addTarget:self
					 action:@selector(progressValueChanged:)
		   forControlEvents:UIControlEventValueChanged];
	[progressView release];
	
	progressLabel.textAlignment = UITextAlignmentCenter;
	progressLabel.backgroundColor = [UIColor clearColor];
	progressLabel.textColor = kDefaultTextColor;
	progressLabel.shadowColor = [UIColor whiteColor];
	progressLabel.shadowOffset = CGSizeMake(0,1);
	progressLabel.text = [NSString stringWithFormat:@"%d",currentSize];
	progressLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
	[self.view addSubview:progressLabel];
	[progressLabel release];
	
	if (currentSize>=10 && currentSize<=35) {
		progressView.value = currentSize;
	}
	
}

-(void)initCurrentFont
{
	if (currentFont) {
		[currentFont release];
		currentFont = nil;
	}
	
	fonts = [[NSMutableArray alloc] initWithObjects:@"Courier",
             @"ChalkboardSE-Regular",
             @"Helvetica",
             @"MarkerFelt-Thin",nil];
	
	
	
	
	if (categoryToExport) {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",categoryToExport]];
		
		if (currentSettings) {
			currentFont = [[NSString alloc] initWithString:[currentSettings objectAtIndex:0]];
			currentSize = [[currentSettings objectAtIndex:1] intValue];
			return;
		}
	}
	
	currentFont = [[NSString alloc] initWithString:@"Helvetica"];
	currentSize = 21;
}

-(void)saveCurrentFont
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:currentSize],nil]
											  forKey:[NSString stringWithFormat:@"%@Font",categoryToExport]];
}

-(void)initCurrentPreference
{
	if (categoryToExport) {
		NSArray *cardSettings = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_Setings",categoryToExport]];
		
		if (cardSettings) {
			isBothSide = [[cardSettings objectAtIndex:0] boolValue];
			isReversed = [[cardSettings objectAtIndex:1] boolValue];
		}
		else {
			isBothSide = NO;
			isReversed = NO;
		}
	}
	else {
		isBothSide = NO;
		isReversed = NO;
	}
    
}

-(void)saveCurrentPreference
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[NSNumber numberWithBool:isBothSide],[NSNumber numberWithBool:isReversed],nil]
											  forKey:[NSString stringWithFormat:@"%@_Setings",categoryToExport]];
}

-(void)languageChoose{
    if ([[QIRequest sharedRequest] isAuthorized]) {
        //         NSString *message = @"Are you sure you want to upload this set to your quizlet account?";
        //        if([ModalAlert ask:message]){
        NSError *error = nil;
        NSString *jsonStr = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"languages" ofType:@"json"] encoding:NSUTF8StringEncoding error:&error];
        if (!jsonStr) {
            if (error) {
                [Util showMessage:@"Error" forMessage:[error localizedDescription] forButtonTitle:@"Close"];
            }else{
                [Util showMessage:@"Error" forMessage:@"Empty language string" forButtonTitle:@"Close"];
            }
        }else{
            NSDictionary *jsonDic = [jsonStr JSONValue];
            NSArray *allObjects = [jsonDic allValues];
            if (!_langDic) {
                _langDic = [[NSMutableDictionary alloc] init];
                for (NSString *lang in allObjects) {
                    NSArray *keys = [jsonDic allKeysForObject:lang];
                    if (keys && [keys count]>0) {
                        [_langDic setObject:[keys objectAtIndex:0] forKey:lang];
                    }
                }
            }
            
            if (jsonDic) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    FIPickerViewIOS7 *lanPicker = [[FIPickerViewIOS7 alloc] initWithDicAndDelegate:_langDic andForDelegate:self forFLan:@"English" forSLan:@"English"];
                    [lanPicker init];
                    [lanPicker show];
                    [lanPicker release];
                }
                else{
                    FIPickerView *lanPicker = [[FIPickerView alloc] initWithDicAndDelegate:_langDic andForDelegate:self forFLan:@"English" forSLan:@"English"];
                    [lanPicker show];
                    [lanPicker release];
                }
                
            }else{
                [Util showMessage:@"Error" forMessage:@"No languages found" forButtonTitle:@"Close"];
            }
        }
    }else{
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
            NSString *fbAppUrl = [QIRequest AuthUrl];
            NSDictionary* param = [QIRequest parametersForOAuth];
            NSURL *fbUrl = [self generateURL:fbAppUrl params:param];
            NSLog(@"%@",[fbUrl absoluteString]);
            [[UIApplication sharedApplication] openURL:fbUrl];
        }else{
            FBLoginDialog *loginView = [[FBLoginDialog alloc] initWithURL:[QIRequest AuthUrl]
                                                              loginParams:[QIRequest parametersForOAuth]
                                                                 delegate:self];
            [loginView show];
            [loginView release];
        }
    }
    //    }
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params) {
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator) {
            NSString* value = [params objectForKey:key];
            NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                          NULL, /* allocator */
                                                                                          (CFStringRef)value,
                                                                                          NULL, /* charactersToLeaveUnescaped */
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
            [escaped_value release];
        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

#pragma mark init ends

#pragma mark Login delegates

-(void)handleQuizletNotification:(NSNotification*)sender{
    [self fbDialogLogin:sender.object expirationDate:nil];
}

- (void)fbDialogLogin:(NSString*)token expirationDate:(NSDate*)expirationDate{
    [QIRequest saveCode:token expTime:expirationDate];
    [[QIRequest sharedRequest] login:self];
}

- (void)fbDialogNotLogin:(BOOL)cancelled{
    if (!cancelled) {
        [Util showMessage:@"Quizlet Error"
               forMessage:@"Please, check your login and password. Try again later."
           forButtonTitle:@"Close"];
    }
}

#pragma mark QIRequest delegate

-(void)qiPostLen:(QIRequest*)request length:(NSInteger)len{
    [_indicatorView setImportLen:len];
    [_indicatorView setCurVal:0];
}

-(void)qiPostedLen:(QIRequest*)request length:(NSInteger)len{
    [_indicatorView setCurVal:len];
}

-(void)qiPostImages:(QIRequest*)request ids:(NSArray*)imagesIDs{
    NSLog(@"recieved image %d",[imagesIDs count]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_indicatorView dissmis];
    isLoadingSet = NO;
    NSArray *cards = [[FDBController sharedDatabase] infoForCategory:categoryToExport];
    [self postCardsToQuizlet:cards imIDs:imagesIDs l1:_l1 l2:_l2];
    if (_l1) {
        [_l1 release];
        _l1 = nil;
    }
    if (_l2) {
        [_l2 release];
        _l2 = nil;
    }
}

-(void)qiPostCards:(QIRequest*)request{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_indicatorView dissmis];
    isLoadingSet = NO;
    [Util showMessage:@"Quizlet"
           forMessage:@"Set was successfully uploaded"
       forButtonTitle:@"OK"];
}

-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_indicatorView dissmis];
    isLoadingSet = NO;
    if (errorInfo && [errorInfo objectForKey:@"errorMsg"]) {
        [Util showMessage:@"Quizlet Error"
               forMessage:[errorInfo objectForKey:@"errorMsg"]
           forButtonTitle:@"Close"];
    }
}

-(void)qiLoginSucceed:(QIRequest*)request user_id:(NSString*)user{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[QIRequest sharedRequest] fetchUserInfo:self];
    
}

-(void)qiUserInfo:(QIRequest*)request info:(NSDictionary*)info{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self languageChoose];
}

-(void)qiLoginFailed:(QIRequest*)request canceled:(BOOL)isCanceled{
    if (!isCanceled) {
        [Util showMessage:@"Quizlet Error"
               forMessage:@"Please, check your login and password. Try again later."
           forButtonTitle:@"Close"];
    }
}

#pragma mark -
#pragma mark FIndicatorView delegate
-(void)cancelButtonPressed
{
    [[QIRequest sharedRequest] cancelFetch];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    isLoadingSet = NO;
	[_indicatorView dissmis];
}

#pragma mark -
#pragma mark private methods

#pragma mark -
#pragma mark targets

-(void)backPressed
{
	if (isReloadCategory && delegate && [delegate respondsToSelector:@selector(reloadCurrentCategory:)]) {
		[self saveCurrentPreference];
		[self saveCurrentFont];
		[delegate reloadCurrentCategory:categoryToExport];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)progressValueChanged:(id)sender
{
	isReloadCategory = YES;
	currentSize = progressView.value;
	progressLabel.text = [NSString stringWithFormat:@"%d",currentSize];
}

-(void)editCards{
    NSArray *cards = [[FDBController sharedDatabase] infoForCategory:categoryToExport];
    
    if (cards && [cards count]>0) {
        
        NSArray *tmpSet = nil;
        NSMutableSet *ignCards = nil;
        
        if (categoryToExport)
            tmpSet =  [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ignored",categoryToExport]];
        
        if (!tmpSet) {
            ignCards = [[NSMutableSet alloc] init];
        }
        else {
            ignCards = [[NSMutableSet alloc] initWithArray:tmpSet];
        }
        
        FISceneViewController *scene = [[FISceneViewController alloc] init];
        scene.withoutAnimation = YES;
        scene.delegate = delegate;
        NSString *categoryName = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
        scene.category = categoryToExport;
        scene.categoryName = categoryName;
        scene.initedId = 0;
        scene.r_isTopPanelExist = YES;
        [scene initByArray:cards];
        [scene initIgnoredCards:ignCards];
        [self.navigationController pushViewController:scene
                                             animated:YES];
        [ignCards release];
        [scene release];
        
    }else{
        [Util showMessage:@"Edit" forMessage:@"No cards to edit" forButtonTitle:@"OK"];
    }
    
    if (cards) {
        [cards release];
    }
}

-(void)changeCategory{
    RIChooseGroupController *groupController = [[RIChooseGroupController alloc] init];
    groupController.group = group;
    groupController.delegate = delegate;
    [self.navigationController pushViewController:groupController animated:YES];
    [groupController release];
}

-(void)upgrade:(NSNotification*)sender{
    [exportTable reloadData];
}

#pragma mark targets ends

#pragma mark -
#pragma mark private

-(void)clearPaths
{
	if(!isReqToClean || !filesToClean)
		return;
	
	isReqToClean = NO;
	
	for (NSString *path in filesToClean) {
		if([[NSFileManager defaultManager] fileExistsAtPath:path])
			[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	
	[filesToClean release];
	filesToClean = nil;
}



-(void)removeArchive
{
	if (categoryToExport) {
		NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
		NSString *documents = [path objectAtIndex:0];
		NSString *removingFile = [documents stringByAppendingPathComponent:[categoryToExport stringByAppendingPathExtension:@"flashCardPlus"]];
		BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:removingFile];
		
		if (isExist) {
			[[NSFileManager defaultManager] removeItemAtPath:removingFile error:nil];
		}
		
	}
	
}

-(BOOL)generateSetBackup:(NSString*)path
{
	NSMutableDictionary *setDictionary = [NSMutableDictionary dictionary];
	
	NSString *catName = [[FDBController sharedDatabase] nameForCategory:categoryToExport];
	NSInteger template = [[FDBController sharedDatabase] templateForSet:categoryToExport];
	NSArray *ignoredCards = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ignored",categoryToExport]];
	NSDictionary *lastTest = [Util getLastTestInformation:categoryToExport];
	NSDictionary *lastStudy = [Util getLastTestInformation:categoryToExport];
	NSArray *rb = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_Setings",categoryToExport]];
	NSArray *font = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",categoryToExport]];
	
	if (catName) {
		[setDictionary setObject:catName forKey:@"name"];
	}
	
	[setDictionary setObject:[NSNumber numberWithInt:template] forKey:@"template"];
	
	if (ignoredCards) {
		[setDictionary setObject:ignoredCards forKey:@"ignored"];
	}
	
	if (lastTest) {
		[setDictionary setObject:lastTest forKey:@"test"];
	}
	
	if (lastStudy) {
		[setDictionary setObject:lastStudy forKey:@"study"];
	}
	
	if (rb) {
		[setDictionary setObject:rb forKey:@"rb"];
	}
	
	if (font) {
		[setDictionary setObject:font forKey:@"font"];
	}
	
	NSMutableArray *cContent = [[FDBController sharedDatabase] infoForCategory:categoryToExport];
	NSMutableArray *contentForCategory = [NSMutableArray array];
	
	for (NSArray *card in cContent) {
		NSInteger cardId = [[card objectAtIndex:0] intValue];
		NSString *q = [card objectAtIndex:1];
		NSString *a = [card objectAtIndex:2];
		UIImage *qImage = [Util imageWithId:categoryToExport forId:cardId forWhat:YES];
		UIImage *aImage = [Util imageWithId:categoryToExport forId:cardId forWhat:NO];
		NSData *qSound = [Util getSoundForCard:categoryToExport forId:cardId forWhat:YES];
		NSData *aSound = [Util getSoundForCard:categoryToExport forId:cardId forWhat:NO];
		NSMutableArray *cStatistic = [[FDBController sharedDatabase] getStatistic:categoryToExport forIndex:cardId];
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:cardId],q,a,cStatistic,nil]
																	  forKeys:[NSArray arrayWithObjects:@"id",@"q",@"a",@"s",nil]];
		
		if (qImage) {
			[dic setObject:UIImagePNGRepresentation(qImage) forKey:@"qIm"];
		}
		
		if (aImage) {
			[dic setObject:UIImagePNGRepresentation(aImage) forKey:@"aIm"];
		}
		
		if (qSound) {
			[dic setObject:qSound forKey:@"qS"];
		}
		
		if (aSound) {
			[dic setObject:aSound forKey:@"aS"];
		}
		
		[contentForCategory addObject:dic];
		[cStatistic release];
	}
	
	[cContent release];
	[setDictionary setObject:contentForCategory forKey:@"content"];
	
	
	return [NSKeyedArchiver archiveRootObject:setDictionary toFile:path];
	
}

-(void)generateSetResults:(NSString*)path forCategory:(NSString*)categoryName
{
	if(!categoryName || !path)
	{
		[Util showMessage:@"Result"
			   forMessage:@"result creating failed."
		   forButtonTitle:@"OK"];
		return;
	}
	
	if(![[FDBController sharedDatabase] checkCategoryExisting:categoryName])
	{
		[Util showMessage:@"Result"
			   forMessage:@"This category not exist"
		   forButtonTitle:@"OK"];
		return;
	}
	
	NSMutableString *resultStr = [NSMutableString string];
	NSInteger cardCount = [[FDBController sharedDatabase] getNumberOfItems:categoryName];
	NSArray *cards = [[FDBController sharedDatabase] infoForCategory:categoryName];
	[resultStr appendFormat:@"Category: %@\n",[categoryName stringByReplacingOccurrencesOfString:@"_" withString:@" "]];
	[resultStr appendFormat:@"%d cards\n\n",cardCount];
	
	for (NSArray *card in cards) {
		NSInteger cardId = [[card objectAtIndex:0] intValue];
		NSString *term = [card objectAtIndex:1];
		NSString *definition = [card objectAtIndex:2];
		NSArray *statistic = [[FDBController sharedDatabase] getStatistic:categoryName forIndex:cardId];
		NSInteger difficulty;
		NSInteger failedAtempts;
		NSInteger succesAtempts;
		NSInteger nextTestSession;
		NSInteger lastTestSession;
		NSInteger nextStudySession;
		
		if(statistic && [statistic count]>=7)
		{
			difficulty = [[statistic objectAtIndex:1] intValue];
			failedAtempts = [[statistic objectAtIndex:2] intValue];
			succesAtempts = [[statistic objectAtIndex:3] intValue];
			nextTestSession = [[statistic objectAtIndex:4] intValue];
			lastTestSession = [[statistic objectAtIndex:5] intValue];
			nextStudySession = [[statistic objectAtIndex:6] intValue];
		}
		else {
			continue;
		}
		
		NSString *LastTestDate = @"";
		NSString *NextTestDate = @"";
		NSString *studyDate = @"";
		
		if(lastTestSession>=0)
		{
			LastTestDate = [Util fullTimeStringFromDate:[DBTime dateFromDBDay:lastTestSession]];
		}
		
		if(nextTestSession>=0)
		{
			NextTestDate = [Util fullTimeStringFromDate:[DBTime dateFromDBDay:nextTestSession]];
		}
		
		if(nextStudySession>=0)
		{
			studyDate = [Util fullTimeStringFromDate:[DBTime dateFromDBDay:nextStudySession]];
		}
		
		
		[resultStr appendFormat:@"card id: %d\n",cardId];
		[resultStr appendFormat:@"term : %@\n",term];
		[resultStr appendFormat:@"definition: %@\n",definition];
		[resultStr appendFormat:@"card difficulty: %d%\n",difficulty];
		[resultStr appendFormat:@"success attempts in learning sessions: %d\n",succesAtempts];
		[resultStr appendFormat:@"not success attempts in learning sessions: %d\n",failedAtempts];
		[resultStr appendFormat:@"last test session: %@\n",LastTestDate];
		[resultStr appendFormat:@"next test session: %@\n",NextTestDate];
		[resultStr appendFormat:@"next study session: %@\n\n",studyDate];
		
		[statistic release];
	}
	
	BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
	
	if(isExist)
	{
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
	[cards release];
	[resultStr writeToFile:path
				atomically:YES
				  encoding:NSUTF8StringEncoding
					 error:nil];
}

-(void)sendToMail:(NSString*)path forFilename:(NSString*)fileName
{
	if (!path || ![Util connectedToNetwork]) {
		[Util showMessage:@"Mail"
			   forMessage:@"Can't send mail"
		   forButtonTitle:@"OK"];
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.navigationBar.tintColor = kDefaultNavColor;
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Email from FlashcardsPlus"];
	NSData *imageData = [NSData dataWithContentsOfFile:path];
	
	if (imageData) {
		[picker addAttachmentData:imageData mimeType:@"set/flashCards" fileName:fileName];
		[picker setMessageBody:@"<html><head></head><body>Sent from http://bit.ly/flashcardsplus</body></html>" isHTML:YES];
		[self presentModalViewController:picker animated:YES];
	}
	
	[picker release];
	
}

-(void)postCardsToQuizlet:(NSArray*)cards imIDs:(NSArray*)imIDs l1:(NSString*)l1 l2:(NSString*)l2{
    if ([cards count]>=2) {
        NSMutableArray *terms = [NSMutableArray array];
        NSMutableArray *definitions = [NSMutableArray array];
        NSMutableArray *sentImageIDs = [NSMutableArray array];
        NSInteger imIndex = 0;
        for (NSArray *card in cards) {
            NSInteger cid = [[card objectAtIndex:0] intValue];
            NSString *q = [card objectAtIndex:1];
            NSString *a = [card objectAtIndex:2];
            if ([q isEqualToString:@""]) {
                q = @" ";
            }
            
            if ([a isEqualToString:@""]) {
                a = @" ";
            }
            
            [terms addObject:q];
            [definitions addObject:a];
            if ([Util imageWithId:categoryToExport forId:cid forWhat:YES] || [Util imageWithId:categoryToExport forId:cid forWhat:NO]) {
                if ([imIDs count]>0 && imIndex>=0 && imIndex<[imIDs count]) {
                    NSDictionary *idDic = [imIDs objectAtIndex:imIndex];
                    [sentImageIDs addObject:[idDic objectForKey:@"id"]];
                    imIndex++;
                }else{
                    [sentImageIDs addObject:@""];
                }
                
            }else{
                [sentImageIDs addObject:@""];
            }
        }
        [self.view addSubview:_indicatorView];
        [_indicatorView setCurVal:0];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        isLoadingSet = YES;
        [[QIRequest sharedRequest] postSet:self
                                     title:[[FDBController sharedDatabase] nameForCategory:categoryToExport]
                                     terms:terms
                                       def:definitions
                                    images:sentImageIDs
                                     tlang:l1
                                     dlang:l2];
    }else{
        [Util showMessage:@"Error" forMessage:@"Your set must contain at least 2 cards" forButtonTitle:@"Close"];
    }
}

-(BOOL)testOn{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"]){
        return [[[NSUserDefaults standardUserDefaults] objectForKey:@"shuffle_test"] boolValue];
    }
    return NO;
}

-(void)setTest:(BOOL)test{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:test] forKey:@"shuffle_test"];
}

-(void)updateProgressView{
	_indicatorView.progressView.frame = CGRectMake(5,17,200,10);
	_indicatorView.cancelButton.center = CGPointMake(230,22);
	_indicatorView.progressViewLabel.frame = CGRectMake(265,6,50,30);
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
-(void)viewWillAppear:(BOOL)animated
{

 [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [[QIRequest sharedRequest] cancelFetch];
    if (isLoadingSet) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;      
    }
	[_indicatorView release];
	if (categoryToExport) {
		[categoryToExport release];
	}
	
	if (filesToClean) {
		[filesToClean release];
	}
	
	if (currentFont) {
		[currentFont release];
	}
	
	if (fonts) {
		[fonts release];
	}
    
    if (_l1) {
        [_l1 release];
        _l1 = nil;
    }
    if (_l2) {
        [_l2 release];
        _l2 = nil;
    }
    
	self.group = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end
