//
//  FExportBaseController.m
//  flashCards
//
//  Created by Ruslan on 7/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FExportBaseController.h"
#import "FDBController.h"
#import "FPrepareToExport.h"
#import "DBTime.h"
#import "Util.h"
#import "ModalAlert.h"
#import "FTextAlertView.h"
#import "FFontController.h"
#import "RIChooseGroupController.h"
#import "JSON.h"
#import "FIPickerViewIOS7.h"

@interface FExportBaseController(Private)

-(void)sendToMail:(NSString*)path forFilename:(NSString*)fileName;
-(void)removeArchive;
-(void)generateSetResults:(NSString*)path forCategory:(NSString*)categoryName;
-(void)clearPaths;
-(void)serverPressed;
-(void)chooseFont;
-(BOOL)generateSetBackup:(NSString*)path;
-(void)initCurrentFont;
-(void)initCurrentPreference;
-(void)saveCurrentPreference;
-(void)fontChanged:(NSNotification*)sender;
-(void)editCards;
-(void)changeCategory;
-(void)upgrade:(NSNotification*)sender;
-(void)languageChoose;
-(void)uploadToQuizlet:(NSString*)l1 secLan:(NSString*)l2;
-(void)postCardsToQuizlet:(NSArray*)cards imIDs:(NSArray*)imIDs l1:(NSString*)l1 l2:(NSString*)l2;
- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
-(BOOL)testOn;
-(void)setTest:(BOOL)test;
-(void)updateProgressView;

@end


@implementation FExportBaseController
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
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,400,450)];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
	[contentView release];
	
	[self initCurrentFont];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 450)];
    bgView.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
    	
	exportTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0,400,450) style:UITableViewStyleGrouped];
    exportTable.backgroundView = bgView;
	exportTable.delegate = self;
	exportTable.dataSource = self;
    exportTable.backgroundColor = [UIColor clearColor];
	[self.view addSubview:exportTable];
    [bgView release];
	[exportTable release];
    _indicatorView = [[FIndicatorView alloc] initWithFrame:CGRectMake(0,410,400,40)];
	_indicatorView.delegate = self;
    [self updateProgressView];
    isLoadingSet = NO;
	
	isReqToClean = NO;
	
	[self initCurrentPreference];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(fontChanged:)
												 name:@"fontChanged"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upgrade:)
                                                 name:@"upgraded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizletNotification:) name:@"QuizletCode" object:nil];
}

-(void)exportCategory:(NSString*)category group:(NSString*)group
{
	if (!category) {
		return;
	}
	
	if (categoryToExport) {
		[categoryToExport release];
	}
	
	categoryToExport = [[NSString alloc] initWithString:category];
    
    if (r_group) {
        [r_group release];
        r_group = nil;
    }
    
    if (!group) {
        return;
    }
    r_group = [[NSString alloc] initWithString:group];
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[ModalAlert say:@"If you want to add your set results to export turn on appropriate switcher"];
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([Util isFullVersion]) {
        return 4;     
    }else{
        return 3; 
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
        case 0:
            return 3;
            break;
		case 1:
            if ([Util isFullVersion]) {
                return 5; 
            }else{
                return 4;
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
			return 4;
			break;
        default:
			break;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
        case 0:
            return @"Edit";
            break;
		case 1:
            if ([Util isFullVersion]) {
                return @"Share";
            }else{
                return @"Settings";
            }
			break;
		case 2:
            if ([Util isFullVersion]) {
               return @"Backup"; 
            }else{
               return @"Upgrade"; 
            }
			
			break;
		case 3:
			return @"Settings";
			break;
	
		default:
			break;
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"CellForCategory";
	static NSString *CellCheckIdentifier = @"CellForCategoryChecked";
	
	
	if((![Util isFullVersion] && indexPath.section == 1 && indexPath.row == 0) || ([Util isFullVersion] && indexPath.section == 3 && indexPath.row == 0))
	{
		SSBadgeTableViewCell* cell = (SSBadgeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (!cell) {
			
			cell = [[[SSBadgeTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		}
		
		cell.badgeView.hidden = NO;
		cell.detailTextLabel.font = [UIFont fontWithName:currentFont size:16];
		cell.detailTextLabel.text = currentFont;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.badgeView.text = [NSString stringWithFormat:@"%d",currentSize];
		cell.textLabel.text = @"Change font";
		return cell;
	}
	else {
	   	UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellCheckIdentifier];
		if (!cell) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellCheckIdentifier] autorelease];
		}
		
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Reset sessions progress";
                    break;
                case 1:
                    cell.textLabel.text = @"Edit cards";
                    break;
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
                    case 1:
                    {
                        cell.textLabel.text = @"Reversed cards";
                        if(isReversed)
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        break;
                    }
                    case 2:
                        cell.textLabel.text = @"Both sided cards";
                        if(isBothSide)
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        break;
                    case 3:
                        cell.textLabel.text = @"Shuffle test cards";
                        if ([self testOn]) {
                            cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        }
                        break;
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
                case 1:
                {
                    cell.textLabel.text = @"Reversed cards";
                    if(isReversed)
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                }
                case 2:
                    cell.textLabel.text = @"Both sided cards";
                    if(isBothSide)
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    break;
                case 3:
                    cell.textLabel.text = @"Shuffle test cards";
                    if ([self testOn]) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                default:
                    break;
            }
		}
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (isLoadingSet) {
        [Util showMessage:@""
               forMessage:@"This set is uploading to Quizlet.com. Please try later..."
           forButtonTitle:@"OK"];
        return;
    }
    
	
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
				if(categoryToExport)
				{
                    //changed sanjeev reddy for ipad working
                        [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Reset session" withParam:nil];
                        NSString *message = @"Are you sure you want to reset all sessions progress associted with this set?";
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset Sessions"
                                                                        message:message
                                                                       delegate:self
                                                              cancelButtonTitle:@"YES"
                                                              otherButtonTitles:@"NO",nil];
                        alert.tag = -444;
                        [alert show];
                        [alert release];
                

//					NSString *message = @"Are you sure you want to reset all settings and statistics associted with this set?";
//					
//					if([ModalAlert ask:message])
//					{
//						[[FDBController sharedDatabase] clearSetSession:categoryToExport];
//						
//						if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])
//							[delegate setWasReseted:categoryToExport];
//					}
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
                            [Util showMessage:@"FlashCardPlus Mail"
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
                            [Util showMessage:@"Archive"
                                   forMessage:[NSString stringWithFormat:@"%@ Set Data was archived and saved to Documents. Please use iTunes to download the file",name]
                               forButtonTitle:@"OK"];	
                        }
                        else {
                            [Util showMessage:@"Archive"
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
                            [Util showMessage:@"Anki mail"
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
                            [Util showMessage:@"Anki mail"
                                   forMessage:[NSString stringWithFormat:@"Can't archive %@ Set Data to Documents",name]
                               forButtonTitle:@"OK"];
                        }
                        else {
                            [Util showMessage:@"Anki mail"
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
                    [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change font" withParam:nil];
                    [self chooseFont];
                    break;
                case 1:
                {
                    isReversed = !isReversed;
                    UITableViewCell* cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                    
                    if(isReversed){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    [self saveCurrentPreference];
                    if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])	
                        [delegate setWasReseted:categoryToExport];
                    break;
                }
                case 2:
                {
                    isBothSide = !isBothSide;
                    UITableViewCell* cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                    
                    if(isBothSide){
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    [self saveCurrentPreference];
                    if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])	
                        [delegate setWasReseted:categoryToExport];
                    break;
                }	
                case 3:{
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
					}else {
						[Util showMessage:@"Backup"
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
                [[FAdMobController sharedAdMobController] logFlurryEnvent:@"Change font" withParam:nil];
                [self chooseFont];
                break;
            case 1:
            {
                isReversed = !isReversed;
                UITableViewCell* cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                
                if(isReversed){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                [self saveCurrentPreference];
                if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])	
                    [delegate setWasReseted:categoryToExport];
                break;
            }
            case 2:
            {
                isBothSide = !isBothSide;
                UITableViewCell* cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
                
                if(isBothSide){
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                [self saveCurrentPreference];
                if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])	
                    [delegate setWasReseted:categoryToExport];
                break;
            }	
            case 3:{
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
	
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(FTextAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == -444) {
        
        if (buttonIndex == [alertView cancelButtonIndex]) {
            [[FDBController sharedDatabase] clearSetSession:categoryToExport];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reset" object:nil];
            
            if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])
                [delegate setWasReseted:categoryToExport];
        }
    }
    
}
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
                NSLog(@"account %@",acType);
                if (acType && [acType isEqualToString:@"plus"]) {
                    [self.view addSubview:_indicatorView];
                    [_indicatorView setCurVal:0];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                    isLoadingSet = YES;
                    [[QIRequest sharedRequest] fetchImageUpload:self images:imagePaths];  
                }else{
                    NSString *message = @"Your account type isn't plus. Are you sure you want to upload set without images?";
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
#pragma mark mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self clearPaths];
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Notifications
-(void)fontChanged:(NSNotification*)sender
{
	NSDictionary *fontDic = [sender object];
	
	if(fontDic)
	{
		NSString *font = [fontDic objectForKey:@"font"];
		
		if(font)
		{
			if(currentFont)
			{
				[currentFont release];
			}
			currentFont = [[NSString alloc] initWithString:font];
		}
		
		NSNumber *size = [fontDic objectForKey:@"size"];
		
		if(size)
		{
			currentSize = [size intValue];
		}
		
		if(delegate && [delegate respondsToSelector:@selector(setWasReseted:)])
			[delegate setWasReseted:categoryToExport];
		
		[exportTable reloadData];
	}
	
}

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
	
	[setDictionary setObject:[NSNumber numberWithInt:template]
					  forKey:@"template"];
	
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
		
		NSData *sound1 = nil;
		NSData *sound2 = nil;
		
		if([Util checkSoundForCard:categoryToExport forId:cardId forWhat:YES])
		{
			sound1 = [Util getSoundForCard:categoryToExport
									 forId:cardId
								   forWhat:YES];
		}
		
		if([Util checkSoundForCard:categoryToExport forId:cardId forWhat:NO])
		{
			sound2 = [Util getSoundForCard:categoryToExport
									 forId:cardId
								   forWhat:NO];
		}
		
		NSMutableArray *cStatistic = [[FDBController sharedDatabase] getStatistic:categoryToExport forIndex:cardId];
		NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:cardId],q,a,cStatistic,nil]
																	  forKeys:[NSArray arrayWithObjects:@"id",@"q",@"a",@"s",nil]];
		
		if (qImage) {
			[dic setObject:UIImagePNGRepresentation(qImage) forKey:@"qIm"];
		}
		
		if (aImage) {
			[dic setObject:UIImagePNGRepresentation(aImage) forKey:@"aIm"];
		}
		
		if(sound1){
			[dic setObject:sound1 forKey:@"qS"];
		}
		
		if(sound2){
			[dic setObject:sound2 forKey:@"aS"];
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
		[ModalAlert say:@"result creating failed."];
		return;
	}
	
	if(![[FDBController sharedDatabase] checkCategoryExisting:categoryName])
	{
		[ModalAlert say:@"This category not exist"];
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
		[ModalAlert say:@"Can't send mail"];
		return;
	}
	
	if(delegate)
	{
		
		if([MFMailComposeViewController canSendMail])
		{
		
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.mailComposeDelegate = self;
			picker.navigationBar.tintColor = kDefaultNavColor;
			[picker setSubject:@"Email from FlashcardsPlus"];
			NSData *imageData = [NSData dataWithContentsOfFile:path];
	
			if (imageData) {
				[picker addAttachmentData:imageData mimeType:@"set/flashCardPlus" fileName:fileName];
				[picker setMessageBody:@"<html><head></head><body>Sent from http://bit.ly/flashcardsplus</body></html>" isHTML:YES];
				picker.modalPresentationStyle = UIModalPresentationFormSheet;
				[delegate presentModalViewController:picker animated:YES];
			}
	
			[picker release];
		}else {
			NSString *message = @"Can't send mail. Please check your internet connection and mail account.";
			[Util showMessage:@"Mail"
				   forMessage:message
			   forButtonTitle:@"OK"];
		}

	}
	
}

-(void)serverPressed
{
	
	/*if(delegate)
	{
		FISendCards *server = [[FISendCards alloc] init];
		server.category = categoryToExport;
		server.modalPresentationStyle = UIModalPresentationFormSheet;
		[delegate presentModalViewController:server animated:YES];
		[server release];
	}*/
}

-(void)initCurrentFont
{
	if (currentFont) {
		[currentFont release];
		currentFont = nil;
	}
	
	if (categoryToExport) {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",categoryToExport]];
		
		if (currentSettings) {
			currentFont = [[NSString alloc] initWithString:[currentSettings objectAtIndex:0]];
			currentSize = [[currentSettings objectAtIndex:1] intValue];
			return;
		}
	}
	
	currentFont = [[NSString alloc] initWithString:@"Helvetica"];
	currentSize = 30;
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


-(void)chooseFont
{
	if(delegate)
	{
		FFontController *fontController = [[FFontController alloc] init];
		fontController.category = categoryToExport;
		fontController.modalPresentationStyle = UIModalPresentationFormSheet;
		[delegate presentModalViewController:fontController animated:YES];
		[fontController release];
	}
}

-(void)editCards{
    if (delegate && [delegate respondsToSelector:@selector(loadCardEditing:)]) {
        [delegate loadCardEditing:categoryToExport];
    }
    return;
}

-(void)changeCategory{
    RIChooseGroupController *chooseController = [[RIChooseGroupController alloc] init];
    chooseController.delegate = delegate;
    chooseController.group = r_group;
    chooseController.modalPresentationStyle = UIModalPresentationFormSheet;
    [delegate presentModalViewController:chooseController animated:YES];
    [chooseController release];
    
    if (delegate && [delegate respondsToSelector:@selector(dissmisMe)]) {
        [delegate dissmisMe];
    }
}

-(void)upgrade:(NSNotification*)sender{
    [exportTable reloadData];
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

//                FIPickerView *lanPicker = [[FIPickerView alloc] initWithDicAndDelegate:_langDic andForDelegate:self forFLan:@"English" forSLan:@"English"];
//                [lanPicker show];
//                [lanPicker release];
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
	_indicatorView.progressView.frame = CGRectMake(5,17,300,10);
	_indicatorView.progressViewLabel.frame = CGRectMake(315,6,50,30);
}

#pragma mark -


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
    [[QIRequest sharedRequest] cancelFetch];
    if (isLoadingSet) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;      
    }
	[_indicatorView release];
	if (categoryToExport) {
		[categoryToExport release];
	}
    
    if (_langDic) {
        [_langDic release];
    }
    
    if (r_group) {
        [r_group release];
        r_group = nil;
    }
	
    if (_l1) {
        [_l1 release];
        _l1 = nil;
    }
    if (_l2) {
        [_l2 release];
        _l2 = nil;
    }
    
	if(filesToClean)
		[filesToClean release];
	
	if(currentFont)
		[currentFont release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end
