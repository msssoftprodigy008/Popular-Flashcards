    //
//  FImportApiBaseController.m
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FImportApiBaseController.h"
#import "FDBController.h"
#import "FImportApiSecondaryController.h"
#import "QISearchViewController.h"
#import "ImportApiController.h"
#import "FImportCategoryController.h"
#import "FBLoginDialog.h"
#import "Constants.h"
#import "Util.h"

@interface FImportApiBaseController(Private)

-(void)initToolBar;
-(void)initLabelsAndButtons;
-(void)searchButtonPressed;
-(void)valChanged;
-(void)donePressed;
-(void)upgrade:(NSNotification*)sender;
-(void)showLoadView;
-(void)showCategories;

-(void)startLoading;
-(void)stopLoading;

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;

#pragma mark targets
-(void)loginButtonPressed;

@end


@implementation FImportApiBaseController

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
	UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0,0,540,580)];
	self.view = contentView;
	[contentView release];
	CGRect tableFrame;
    
    if ([Util isFullVersion]) {
        tableFrame = CGRectMake(0,0,540,536);
    }else{
        tableFrame = CGRectMake(0,0,540,580);
    }
    
	if (categoryTable == nil) {
        categoryTable = [[[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain] autorelease];
        categoryTable.delegate = self;
        categoryTable.dataSource = self;
    } else {
        categoryTable.frame = tableFrame;
    }
	[self.view addSubview:categoryTable];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
																   style:UIBarButtonItemStyleDone
																  target:self
																  action:@selector(donePressed)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	
	[self initToolBar];
	[self initLabelsAndButtons];
	
	csvController = [[ImportViewController alloc] init];
	csvController.delegate = delegate;
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(upgrade:)
                                                 name:@"upgraded"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizletNotification:) name:@"QuizletCode" object:nil];
    
	if ([[QIRequest sharedRequest] isAuthorized]) {
        [self startLoading];
        [[QIRequest sharedRequest] fetchUserInfo:self];
    }
}

-(void)setDelegate:(id)Adelegate
{
	delegate = Adelegate;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

-(void)viewWillDisappear:(BOOL)animated{
    if (![Util isPhone]) {
        self.navigationItem.title = @"Back";
    }
}

-(void)viewWillAppear:(BOOL)animated{
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    if (![[QIRequest sharedRequest] userId]) {
        self.navigationItem.title = @"Powered by Quizlet.com";
    }else{
        self.navigationItem.title = [[QIRequest sharedRequest] userId];
    }
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[QIRequest sharedRequest] isAuthorized]) {
        return 5;
    }else{
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [categoryTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
    
    cell.detailTextLabel.text = @"";
    
    if ([[QIRequest sharedRequest] isAuthorized]) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"My Groups";
                if (_userInfo && [_userInfo objectForKey:@"groups"]) {
                    NSArray *groups = [_userInfo objectForKey:@"groups"];
                    if ([groups count] == 1) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"1 group"];
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d groups",[groups count]];
                    }
                    
                }
                break;
            case 1:
                cell.textLabel.text = @"My Sets";
                if (_userInfo && [_userInfo objectForKey:@"sets"]) {
                    NSArray *sets = [_userInfo objectForKey:@"sets"];
                    if ([sets count] == 1) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"1 set"];
                    }else{
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sets",[sets count]];
                    }
                    
                }
                break;
            case 2:
                cell.textLabel.text = @"Categories";
                break;
            case 3:
                cell.textLabel.text = @"Find Group";
                break;
            case 4:
                cell.textLabel.text = @"Find Set";
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Categories";
                break;
            case 1:
                cell.textLabel.text = @"Find Group";
                break;
            case 2:
                cell.textLabel.text = @"Find Set";
                break;
            default:
                break;
        }
    }
    
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return kCellHight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[categoryTable deselectRowAtIndexPath:indexPath animated:NO];
	if ([[QIRequest sharedRequest] isAuthorized]) {
        switch (indexPath.row) {
            case 0:{
                if (_userInfo) {
                    QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
                    [searchViewController setArray:[_userInfo objectForKey:@"groups"]];
                    [self.navigationController pushViewController:searchViewController animated:YES];
                    [searchViewController release];
                    
                }
            }
                break;
            case 1:{
                if (_userInfo) {
                    QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
                    [searchViewController setArray:[_userInfo objectForKey:@"sets"]];
                    [self.navigationController pushViewController:searchViewController animated:YES];
                    [searchViewController release];
                    
                }
            }
                break;
            case 2:
                [self showCategories];
                break;
            case 3:{
                QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
                [self.navigationController pushViewController:searchViewController animated:YES];
                [searchViewController release];
                break;
            }
            case 4:{
                QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
                [self.navigationController pushViewController:searchViewController animated:YES];
                [searchViewController release];
                break;
            }
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
                [self showCategories];
                break;
            case 1:{
                QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
                [self.navigationController pushViewController:searchViewController animated:YES];
                [searchViewController release];
                break;
            }
            case 2:{
                QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
                [self.navigationController pushViewController:searchViewController animated:YES];
                [searchViewController release];
                break;
            }
            default:
                break;
        }
    }	
}

#pragma mark Login delegates

-(void)handleQuizletNotification:(NSNotification*)sender{
    [self startLoading];
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
    [self stopLoading];
}

#pragma mark -

#pragma mark QIRequest delegate
-(void)qiLoginSucceed:(QIRequest*)request user_id:(NSString*)user{
    self.navigationItem.title = user;
    _loginButton.title = @"Logout";
    [[QIRequest sharedRequest] fetchUserInfo:self];
    [categoryTable reloadData];
}

-(void)qiLogoutSucceed:(QIRequest*)request{
    self.navigationItem.title = @"Powered by Quizlet.com";
    _loginButton.title = @"Login";
    [self stopLoading];
    [categoryTable reloadData];
}

-(void)qiLoginFailed:(QIRequest*)request canceled:(BOOL)isCanceled{
    if (!isCanceled) {
        [Util showMessage:@"Quizlet Error"
               forMessage:@"Please, check your login and password. Try again later."
           forButtonTitle:@"Close"];
    }
    [self stopLoading];
}

-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo{
    if (errorInfo && [errorInfo objectForKey:@"errorMsg"]) {
        [Util showMessage:@"Quizlet Error"
               forMessage:[errorInfo objectForKey:@"errorMsg"]
           forButtonTitle:@"Close"];
    }
    [self stopLoading];
}

-(void)qiUserInfo:(QIRequest*)request info:(NSDictionary*)info{
    if (_userInfo) {
        [_userInfo release];
        _userInfo = nil;
    }
    if (info) {
        _userInfo = [[NSDictionary alloc] initWithDictionary:info];
    }
    [self stopLoading];
    [categoryTable reloadData];
}

#pragma mark targets

-(void)loginButtonPressed:(id)sender{
    if (![[QIRequest sharedRequest] isAuthorized]) {
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
            NSString *fbAppUrl = [QIRequest AuthUrl];
            NSDictionary* param = [QIRequest parametersForOAuth];
            NSURL *fbUrl = [self generateURL:fbAppUrl params:param];
            NSLog(@"%@",[fbUrl absoluteString]);
            [[UIApplication sharedApplication] openURL:fbUrl];
        }else{
            [self startLoading];
            FBLoginDialog *loginView = [[FBLoginDialog alloc] initWithURL:[QIRequest AuthUrl]
                                                              loginParams:[QIRequest parametersForOAuth]
                                                                 delegate:self];
            [loginView show];
            [loginView release];
        }
    }else{
        [[QIRequest sharedRequest] logout:self];
    }
    
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

-(void)showCategories{
    FImportCategoryController *category = [[FImportCategoryController alloc] init];
    [self.navigationController pushViewController:category animated:YES];
    [category release];
}

#pragma mark -


#pragma mark -
#pragma mark private methods

-(void)initToolBar
{
	toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,536,540,44)];
	
	segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Quizlet.com",@"ITunes",nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = 0;
	CGRect frame = segmentedControl.frame;
	frame.origin = CGPointMake(275-frame.size.width/2,7);
	segmentedControl.frame = frame;
	[segmentedControl addTarget:self action:@selector(valChanged) forControlEvents:UIControlEventValueChanged];
	[toolbar addSubview: segmentedControl];
	[segmentedControl release];
	
	[self.view addSubview:toolbar];
	[toolbar release];
    
    if (![Util isFullVersion]) {
        toolbar.hidden = YES;
    }
   
}

-(void)initLabelsAndButtons
{
    
	self.navigationItem.title = @"Powered by Quizlet.com";
	_loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                    style:UIBarButtonItemStyleBordered
                                                   target:self
                                                   action:@selector(loginButtonPressed:)];
    if ([[QIRequest sharedRequest] isAuthorized]) {
        _loginButton.title = @"Logout";
        if ([[QIRequest sharedRequest] userId]) {
             self.navigationItem.title = [[QIRequest sharedRequest] userId];    
        }

    }
    self.navigationItem.rightBarButtonItem = _loginButton;
}

-(void)searchButtonPressed
{
	ImportApiController *import  = [[ImportApiController alloc] init];
	[import setDelegate:delegate];
	import.contentSizeForViewInPopover = CGSizeMake(550,500);
	[self.navigationController pushViewController:import animated:YES];
	[import release];
}

-(void)donePressed
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[QIRequest sharedRequest] cancelFetch];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)valChanged
{
	NSInteger index = segmentedControl.selectedSegmentIndex;
	
	if (index==0) {
		[csvController.view removeFromSuperview];
		[self initLabelsAndButtons];
        self.navigationItem.rightBarButtonItem = _loginButton;
        if ([[QIRequest sharedRequest] isAuthorized]) {
            self.navigationItem.title = [[QIRequest sharedRequest] userId];
        }else{
            self.navigationItem.title = @"Powered by Quizlet.com";
        }
	}
	else {
		[self.view addSubview:csvController.view];
		self.navigationItem.title = @"ITunes";
		self.navigationItem.rightBarButtonItem = nil;
	}

	
}

-(void)upgrade:(NSNotification*)sender{
    toolbar.hidden = NO;
    CGRect frame = categoryTable.frame;
    frame.size.height = 536;
    categoryTable.frame = frame;
}

-(void)showLoadView{
    NSString *url = @"https://quizlet.com/authorize/";
    /*FBLoginDialog *dialog = [[FBLoginDialog alloc] initWithURL:url
                                                   loginParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                @"code",@"response_type",
                                                                @"write_group",@"scope",
                                                                [UIDevice currentDevice].uniqueIdentifier,@"state",
                                                                @"4ujbB4kPCT",@"client_id",
                                                                @"http://adssg.com/",@"redirect_uri",nil]
                                                      delegate:nil];
    [dialog show];
    [dialog release];*/
}

-(void)startLoading{
    _loginButton.enabled = NO;
    segmentedControl.userInteractionEnabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)stopLoading{
    _loginButton.enabled = YES;
    segmentedControl.userInteractionEnabled = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[csvController release];
    [_loginButton release];
    
    if (_userInfo) {
        [_userInfo release];
    }
    
    [super dealloc];
}


@end
