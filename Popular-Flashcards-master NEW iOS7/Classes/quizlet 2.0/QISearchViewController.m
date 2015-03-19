//
//  QISearchViewController.m
//  flashCards
//
//  Created by Ruslan on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "QISearchViewController.h"
#import "Util.h"
#import "FINavigationBar.h"
#import "FIQuizletAvailableSetsController.h"
#import "FIQuizletDetailController.h"
#import "FImportApiMainController.h"
#import "FSetDetailsController.h"

@interface QISearchViewController(Private)
#pragma mark init
-(void)initView;

#pragma mark targets
-(void)backButtonPressed:(id)sender;
-(void)changeSearchMode:(id)sender;

#pragma mark private
-(NSArray*)convertToSetPreview:(NSInteger)index;
-(NSDictionary*)generateInfoDic:(NSInteger)index;

@end

@implementation QISearchViewController
@synthesize searchString;

-(id)initWithType:(QISearchType)type{
    _searchType = type;
    return [self init];
}

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

-(void)setArray:(NSArray*)array{
    if (array) {
        if (_contentArr) {
            [_contentArr release];
        }
        _contentArr = [[NSMutableArray alloc] initWithArray:array];
    }
}

-(void)dealloc{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [[QIRequest sharedRequest] cancelFetch];
    if (_contentArr) {
        [_contentArr release];
    }
    if (_content) {
        [_content release];
    }
    
    if(searchString){
        [searchString release];
    }
    
    if (![Util isPhone]) {
        [_searchBar release];
    }
    [super dealloc];
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
    self.view.backgroundColor = [UIColor clearColor];
    _shouldReloadTable = NO;
    [self initView];
    if (searchString) {
        _searchBar.text = searchString;
        [self searchBarSearchButtonClicked:_searchBar];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    if (![Util isPhone]) {
        [_searchBar removeFromSuperview];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if (![Util isPhone]) {
        [self.navigationController.navigationBar addSubview:_searchBar];
    }
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

#pragma mark -

#pragma mark QIRequest delegate

-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSString *errorMsg = [errorInfo objectForKey:@"errorMsg"];
    [Util showMessage:@"Quizlet" forMessage:errorMsg forButtonTitle:@"Close"];
}

-(void)qiGroupFind:(QIRequest*)request group:(NSDictionary*)group{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (group) {
        if (_content) {
            [_content release];
        }
        _content = [[NSMutableDictionary alloc] initWithDictionary:group];
        if (!_contentArr) {
            _contentArr = [[NSMutableArray alloc] init];
        }
        [_contentArr addObjectsFromArray:[_content objectForKey:@"classes"]]; //////////////sanju changed groups to classes
        [_searchTableView reloadData];
    }
}

-(void)qiSetFind:(QIRequest*)request set:(NSDictionary*)set{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (set) {
        if (_content) {
            [_content release];
        }
        _content = [[NSMutableDictionary alloc] initWithDictionary:set];
        if (!_contentArr) {
            _contentArr = [[NSMutableArray alloc] init];
        }
        [_contentArr addObjectsFromArray:[_content objectForKey:@"sets"]];
        [_searchTableView reloadData];
    }
}

#pragma mark -

#pragma mark UITableView delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_contentArr && [_contentArr count]>0) {
        if (_content) {
            NSInteger totalPages = [[_content objectForKey:@"total_pages"] intValue];
            NSInteger page = [[_content objectForKey:@"page"] intValue];
            if (page<totalPages) {
                return [_contentArr count]+1;
            }else{
                return [_contentArr count];
            }
        }else{
            return [_contentArr count];
        }
        
        
    }else{
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"CellId";
    static NSString *lastCellID = @"LastCellId";
    UITableViewCell *cell;
    if (indexPath.row < [_contentArr count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:lastCellID];
    }
    
    
    if (!cell) {
        if (indexPath.row < [_contentArr count]) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        }else{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:lastCellID] autorelease];
            cell.userInteractionEnabled = NO;
        }
        
        if ([Util isPhone]) {
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
            bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
            
            UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
            bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
            
            cell.backgroundView = bgImageView;
            cell.selectedBackgroundView = bgImageViewHighligthed;
            
            [bgImageView release];
            [bgImageViewHighligthed release];
        }
        
        if (indexPath.row < [_contentArr count]) {
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            UIImageView *locked = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"LockIndicator.png"]];
            if (_searchType == QISearchTypeSets) {
                locked.center = CGPointMake(tableView.frame.size.width-locked.frame.size.width/2.0-35.0, cell.contentView.frame.size.height/2.0);
            }else{
                locked.center = CGPointMake(tableView.frame.size.width-locked.frame.size.width/2.0-5.0, cell.contentView.frame.size.height/2.0);
            }
            locked.tag = 100;
            [cell.contentView addSubview:locked];
            [locked release];
            
            if (_searchType == QISearchTypeSets) {
                UIImageView *pickView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"pic.png"]];
                pickView.center = CGPointMake(tableView.frame.size.width-pickView.frame.size.width/2.0-5.0, cell.contentView.frame.size.height/2.0);
                pickView.tag = 101;
                [cell.contentView addSubview:pickView];
                [pickView release];
            }
        }else{
            UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, tableView.frame.size.width, cell.contentView.frame.size.height)];
            lastLabel.backgroundColor = [UIColor clearColor];
            lastLabel.tag = 100;
            lastLabel.numberOfLines = 2;
            lastLabel.textColor = [UIColor blackColor];
            if ([Util isPhone]) {
                lastLabel.font = [UIFont boldSystemFontOfSize:14];
            }else{
                lastLabel.font = [UIFont boldSystemFontOfSize:18];
            }
            lastLabel.textAlignment = NSTextAlignmentCenter;
            if (_searchType == QISearchTypeSets) {
                lastLabel.text = @"Pull up to get more sets...";
            }else{
                lastLabel.text = @"Pull up to get more groups...";
            }
            [cell.contentView addSubview:lastLabel];
            [lastLabel release];
            
        }
    }
    
    if (indexPath.row < [_contentArr count]) {
        if (_searchType == QISearchTypeGroup) {
            NSDictionary *dic = [_contentArr objectAtIndex:indexPath.row];
            NSString *name = [dic objectForKey:@"name"];
            NSNumber *setCount = [dic objectForKey:@"set_count"];
            if (name) {
                cell.textLabel.text = name;
            }
            if (setCount) {
                NSInteger c = [setCount intValue];
                if (c>1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sets",c];
                }else if(c == 1){
                    cell.detailTextLabel.text = @"1 set";
                }else if(c == 0){
                    cell.detailTextLabel.text = @"No sets";
                }
            }
            
            NSNumber *has_access = [dic objectForKey:@"has_access"];
            UIImageView *locked = (UIImageView*)[cell.contentView viewWithTag:100];
            if (![has_access boolValue]) {
                locked.hidden = NO;
            }else{
                locked.hidden = YES;
            }
            
            
            
        }else{
            NSDictionary *dic = [_contentArr objectAtIndex:indexPath.row];
            NSString *name = [dic objectForKey:@"title"];
            NSNumber *cardCount = [dic objectForKey:@"term_count"];
            if (name) {
                cell.textLabel.text = name;
            }
            if (cardCount) {
                NSInteger c = [cardCount intValue];
                if (c>1) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d cards",c];
                }else if(c == 1){
                    cell.detailTextLabel.text = @"1 card";
                }else if(c == 0){
                    cell.detailTextLabel.text = @"No cards";
                }
                
            }
            
            NSNumber *has_access = [dic objectForKey:@"has_access"];
            NSNumber *has_images = [dic objectForKey:@"has_images"];
            UIImageView *locked = (UIImageView*)[cell.contentView viewWithTag:100];
            UIImageView *pic = (UIImageView*)[cell.contentView viewWithTag:101];
            if (![has_access boolValue]) {
                locked.hidden = NO;
            }else{
                locked.hidden = YES;
            }
            if ([has_images boolValue]) {
                pic.hidden = NO;
            }else{
                pic.hidden = YES;
            }
            
        }
    }else{
        UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:100];
        if ([_content objectForKey:@"total_results"] && _contentArr) {
            NSInteger totalResults = [[_content objectForKey:@"total_results"] intValue];
            if (_searchType == QISearchTypeGroup) {
                titleLabel.text = [NSString stringWithFormat:@"%d of %d\nPull up to get more groups...",[_contentArr count],totalResults];
            }else{
                titleLabel.text = [NSString stringWithFormat:@"%d of %d\nPull up to get more sets...",[_contentArr count],totalResults];
            }
            
        }else{
            if (_searchType == QISearchTypeGroup) {
                titleLabel.text = [NSString stringWithFormat:@"Pull up to get more groups..."];
            }else{
                titleLabel.text = [NSString stringWithFormat:@"Pull up to get more sets..."];
            }
        }
        
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([Util isPhone]) {
        if (indexPath.row == [_contentArr count]) {
            return 60;
        }
        return 39;
    }else{
        if (indexPath.row == [_contentArr count]) {
            return 65;
        }
        return 44;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_searchType == QISearchTypeGroup) {
        NSDictionary *group = [_contentArr objectAtIndex:indexPath.row];
        NSString *gid = [NSString stringWithFormat:@"%@",[group objectForKey:@"id"]];
        if ([Util isPhone]) {
            FIQuizletAvailableSetsController *sets = [[FIQuizletAvailableSetsController alloc] init];
            sets.category = gid;
            sets.title = [group objectForKey:@"name"];
            [self.navigationController pushViewController:sets animated:YES];
            [sets release];
        }else{
            FImportApiMainController *sets = [[FImportApiMainController alloc] init];
            [sets setDelegateAndCategory:self forCategory:gid];
            sets.title = [group objectForKey:@"name"];
            [self.navigationController pushViewController:sets animated:YES];
            [sets release];
        }
        
    }else{
        if ([Util isPhone]) {
            FIQuizletDetailController *detailController = [[FIQuizletDetailController alloc] init];
            detailController.setInfoDictionary = [self generateInfoDic:indexPath.row];
            [self.navigationController pushViewController:detailController animated:YES];
            [detailController release];
        }else{
            FSetDetailsController *detailController = [[FSetDetailsController alloc] init];
            [detailController setInformation:[self generateInfoDic:indexPath.row]];
            [self.navigationController pushViewController:detailController animated:YES];
            [detailController release];
        }
        
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_searchTableView.contentOffset.y+_searchTableView.frame.size.height>=_searchTableView.contentSize.height+75) {
        _shouldReloadTable = YES;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (_shouldReloadTable) {
        _shouldReloadTable = NO;
        NSNumber *total_pages = [_content objectForKey:@"total_pages"];
        NSNumber *page = [_content objectForKey:@"page"];
        if(total_pages && page){
            if ([page intValue]<[total_pages intValue]) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                if (_searchType == QISearchTypeGroup) {
                    [[QIRequest sharedRequest] fetchGroupFind:_searchBar.text delegate:self page:[page intValue]+1];
                }else{
                    [[QIRequest sharedRequest] fetchSetFind:_searchBar.text delegate:self options:_setType page:[page intValue]+1];
                }
            }
        }
    }
    
    
}

#pragma mark -

#pragma mark -
#pragma mark UISearchBarDelegate

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    if (![Util connectedToNetwork]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [Util showMessage:@"Connection error"
               forMessage:@"Please, check internet connection and try again." forButtonTitle:@"Close"];
        return;
    }
    
    if (searchBar.text && ![searchBar.text isEqualToString:@""]) {
        if (_contentArr) {
            [_contentArr removeAllObjects];
        }
        [_searchTableView reloadData];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        if (_searchType == QISearchTypeGroup) {
            
            [[QIRequest sharedRequest] fetchGroupFind:searchBar.text delegate:self page:1];
        }else{
            [[QIRequest sharedRequest] fetchSetFind:searchBar.text delegate:self options:_setType page:1];
        }
        [searchBar resignFirstResponder];
    }
    
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
	
}

#pragma mark init
-(void)initView{
    FINavigationBar* _topBar;
    if ([Util isPhone]) {
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
        UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@""];
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
        
        _searchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(customBackButtonImage.size.width+10,
                                                                   ((IS_IPHONE_5)?0:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?0:-4)),
                                                                   ((IS_IPHONE_5)?558:470)-customBackButtonImage.size.width,
                                                                   35)];
        [_topBar addSubview:_searchBar];
    }else{
        _searchBar = [[FISearchBar alloc] initWithFrame:CGRectMake(70,
                                                                   5,
                                                                   460,
                                                                   35)];
        //[self.navigationController.navigationBar addSubview:_searchBar];
    }
    _searchBar.bgImage = nil;
    _searchBar.delegate = self;
    if ([Util isPhone]) {
        [_searchBar release];
    }
    
    
    if (_searchType == QISearchTypeSets) {
        _setType = QISetTypeSubject;
        _searchBar.placeholder = @"Search by sets";
        if ([Util isPhone]) {
            NSArray *subjectArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_subject1.png"],
                                   [UIImage imageNamed:@"i_set3_subject2.png"],
                                   [UIImage imageNamed:@"i_set3_subject3.png"],nil];
            
            NSArray *creatorArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_creator1.png"],
                                   [UIImage imageNamed:@"i_set3_creator2.png"],
                                   [UIImage imageNamed:@"i_set3_creator3.png"],nil];
            
            NSArray *termArr = [NSArray arrayWithObjects:[UIImage imageNamed:@"i_set3_term1.png"],
                                [UIImage imageNamed:@"i_set3_term2.png"],
                                [UIImage imageNamed:@"i_set3_term3.png"],nil];
            
            FCustomSegmentedController* segment = [[FCustomSegmentedController alloc] initWithItems:[NSArray arrayWithObjects:subjectArr,
                                                                                                     creatorArr,
                                                                                                     termArr,nil]];
            segment.center = CGPointMake(((IS_IPHONE_5)?284:240),60);
            segment.selectedSegmentIndex = 0;
            [segment addTarget:self action:@selector(changeSearchMode:) forControlEvents:UIControlEventValueChanged];
            [self.view addSubview:segment];
            [segment release];
            
            _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, ((IS_IPHONE_5)?568:480), ((IS_IPHONE_5)?264:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?240:220)))
                                                            style:UITableViewStylePlain];
        }else{
            UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Subject",@"Creator",@"Term",nil]];
            segment.center = CGPointMake(290, 30);
            segment.segmentedControlStyle = UISegmentedControlStyleBar;
            segment.selectedSegmentIndex = 0;
            [segment addTarget:self action:@selector(changeSearchMode:) forControlEvents:UIControlEventValueChanged];
            [self.view addSubview:segment];
            [segment release];
            
            _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 540, 530)
                                                            style:UITableViewStylePlain];
            
        }
    }else{
        _searchBar.placeholder = @"Search by groups";
        
        if ([Util isPhone]) {
            _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, ((IS_IPHONE_5)?568:480), ((IS_IPHONE_5)?285:(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?285:265)))
                                                            style:UITableViewStylePlain];
        }else{
            _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 540, 580)
                                                            style:UITableViewStylePlain];
        }
    }
    
    _searchTableView.delegate = self;
    _searchTableView.dataSource = self;
    _searchTableView.backgroundColor = [UIColor whiteColor];
    if ([Util isPhone]) {
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    [self.view addSubview:_searchTableView];
    [_searchTableView release];
    
    if ([Util isPhone]) {
        [self.view bringSubviewToFront:_topBar];
    }
    
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -

#pragma mark private

-(NSArray*)convertToSetPreview:(NSInteger)index{
    if (_contentArr && index<[_contentArr count]) {
        NSDictionary *set = [_contentArr objectAtIndex:index];
        NSArray *cards = [set objectForKey:@"cards"];
        NSMutableArray *previewSet = [NSMutableArray array];
        for (NSDictionary *card in cards) {
            NSMutableArray *pcard = [NSMutableArray array];
            NSString *q = [card objectForKey:@"term"];
            NSString *a = [card objectForKey:@"definition"];
            NSString *image = [card objectForKey:@"image"];
            if (q) {
                [pcard addObject:q];
            }else{
                [pcard addObject:@""];
            }
            if (a) {
                [pcard addObject:a];
            }else{
                [pcard addObject:@""];
            }
            if (image) {
                [pcard addObject:image];
            }
            [previewSet addObject:pcard];
        }
        return previewSet;
    }else{
        return nil;
    }
}

-(NSDictionary*)generateInfoDic:(NSInteger)index{
    if (_contentArr && index<[_contentArr count]) {
        NSDictionary *set = [_contentArr objectAtIndex:index];
        return [NSDictionary dictionaryWithObjectsAndKeys:[set objectForKey:@"id"],@"id",
                [set objectForKey:@"title"],@"title",
                [set objectForKey:@"has_images"],@"has_images",
                [set objectForKey:@"created_by"],@"creator",
                [set objectForKey:@"created_date"],@"created",
                [set objectForKey:@"term_count"],@"term_count",nil];
    }else{
        return nil;
    }
}

#pragma mark -

#pragma mark targets
-(void)backButtonPressed:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)changeSearchMode:(id)sender{
    NSInteger index;
    
    if ([Util isPhone]) {
        index = ((FCustomSegmentedController*)sender).selectedSegmentIndex;
    }else{
        index = ((UISegmentedControl*)sender).selectedSegmentIndex;
    }
    
    switch (index) {
        case 0:
            _setType = QISetTypeSubject;
            break;
        case 1:
            _setType = QISetTypeCreator;
            break;
        case 2:
            _setType = QISetTypeTerm;
            break;
        default:
            break;
    }
    [_searchBar becomeFirstResponder];
}

#pragma mark -

@end
