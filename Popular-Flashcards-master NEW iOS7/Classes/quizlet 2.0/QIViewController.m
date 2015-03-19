//
//  QIViewController.m
//  flashCards
//
//  Created by Ruslan on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QIViewController.h"
#import "FINavigationBar.h"
#import "FIAnimationController.h"
#import "QISearchViewController.h"
#import "FIQuizletController.h"
#import "Util.h"

@interface QIViewController(Private)
#pragma mark init
-(void)initTopBar;
-(void)initTableView;

#pragma mark private
-(void)startLoading;
-(void)stopLoading;

#pragma mark targets
-(void)backButtonPressed:(id)sender;
-(void)loginButtonPressed:(id)sender;
-(NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;
-(void)showCategories;
-(void)handleQuizletNotification:(NSNotification*)sender;

@end

@implementation QIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    _isLoading = NO;
    [self initTableView];
    [self initTopBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleQuizletNotification:) name:@"QuizletCode" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([[QIRequest sharedRequest] isAuthorized] && !_userInfo) {
        [self startLoading];
        [[QIRequest sharedRequest] fetchUserInfo:self];
    }
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[QIRequest sharedRequest] cancelFetch];
    [_loginButton release];
    if (_userInfo) {
        [_userInfo release];
    }
    [super dealloc];
}

#pragma mark init
-(void)initTopBar{
    //Iphone 5 Code
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            _topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
        }
        else{
            _topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
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
            _topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
        }
        else{
            _topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,40)];
        }
    }
    
    
	_topBar.bgImage	= [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@"Powered by Quizlet.com"];
	[_topBar pushNavigationItem:topItem animated:NO];
	[topItem release];
	[self.view addSubview:_topBar];
	[_topBar release];
	
	UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *customBackButtonImage = [UIImage imageNamed:@"i_panel_back1.png"];
	customBackButton.frame = CGRectMake(0,0,customBackButtonImage.size.width,customBackButtonImage.size.height);
	[customBackButton setImage:customBackButtonImage
					  forState:UIControlStateNormal];
	[customBackButton setImage:[UIImage imageNamed:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
	[customBackButton addTarget:self
						 action:@selector(backButtonPressed:)
			   forControlEvents:UIControlEventTouchUpInside];
	
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
	topItem.leftBarButtonItem = backButton;
	[backButton release];
	
    _loginButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleBordered
                                                   target:self
                                                   action:@selector(loginButtonPressed:)];
    topItem.rightBarButtonItem = _loginButton;
    if ([[QIRequest sharedRequest] isAuthorized]) {
        if ([[QIRequest sharedRequest] userId]) {
            topItem.title = [[QIRequest sharedRequest] userId];
        }
        _loginButton.title = @"Logout";
    }
    
}

-(void)initTableView{
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, ((IS_IPHONE_5)?568:480), ((IS_IPHONE_5)?285:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?285:265))) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView release];
}

#pragma mark -

#pragma mark UITableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([[QIRequest sharedRequest] isAuthorized]) {
        return 5;
    }else{
        return 3;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"CellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
        
        UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
        bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
        
        cell.backgroundView = bgImageView;
        cell.selectedBackgroundView = bgImageViewHighligthed;
        
        [bgImageView release];
        [bgImageViewHighligthed release];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[QIRequest sharedRequest] isAuthorized]) {
        switch (indexPath.row) {
            case 0:{
                if (_userInfo) {
                    QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
                    [searchViewController setArray:[_userInfo objectForKey:@"groups"]];
                    [self.navigationController pushViewController:searchViewController animated:YES];
                    [searchViewController release];
                    
                }else{
                    [Util showMessage:@""
                           forMessage:@"User group not loaded."
                       forButtonTitle:@"Close"];
                }
            }
                break;
            case 1:{
                if (_userInfo) {
                    QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeSets];
                    [searchViewController setArray:[_userInfo objectForKey:@"sets"]];
                    [self.navigationController pushViewController:searchViewController animated:YES];
                    [searchViewController release];
                    
                }else{
                    [Util showMessage:@""
                           forMessage:@"User sets not loaded."
                       forButtonTitle:@"Close"];
                }
            }
                break;
            case 2:
                [self showCategories];
                break;
            case 3:{
                if (_isLoading) {
                    [[QIRequest sharedRequest] cancelFetch];
                    [self stopLoading];
                }
                QISearchViewController *searchViewController = [[QISearchViewController alloc] initWithType:QISearchTypeGroup];
                [self.navigationController pushViewController:searchViewController animated:YES];
                [searchViewController release];
                break;
            }
            case 4:{
                if (_isLoading) {
                    [[QIRequest sharedRequest] cancelFetch];
                    [self stopLoading];
                }
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 39;
}

#pragma mark -

#pragma mark private
-(void)startLoading{
    _loginButton.enabled = NO;
    _isLoading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)stopLoading{
    _loginButton.enabled = YES;
    _isLoading = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -

#pragma mark targets

-(void)backButtonPressed:(id)sender{
    [self stopLoading];
    [[QIRequest sharedRequest] cancelFetch];
    [self.navigationController popViewControllerAnimated:YES];
}

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

-(void)handleQuizletNotification:(NSNotification*)sender{
    [self startLoading];
    [self fbDialogLogin:sender.object expirationDate:nil];
}

-(void)showCategories{
    FIQuizletController *categories = [[FIQuizletController alloc] init];
    [self.navigationController pushViewController:categories animated:YES];
    [categories release];
}

#pragma mark -

#pragma mark Login delegates

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
    _topBar.topItem.title = user;
    _loginButton.title = @"Logout";
    [[QIRequest sharedRequest] fetchUserInfo:self];
    [_tableView reloadData];
}

-(void)qiLogoutSucceed:(QIRequest*)request{
    _topBar.topItem.title = @"Powered by Quizlet.com";
    _loginButton.title = @"Login";
    [self stopLoading];
    [_tableView reloadData];
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
    [_tableView reloadData];
}

#pragma mark -

@end
