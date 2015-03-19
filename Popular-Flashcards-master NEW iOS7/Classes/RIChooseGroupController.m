//
//  RIChooseGroupController.m
//  flashCards
//
//  Created by Ruslan on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIChooseGroupController.h"
#import "FDBController.h"
#import "Util.h"
#import "FINavigationBar.h"

@interface RIChooseGroupController(Private)
#pragma mark init
-(void)initGroupArray;
-(void)initTableView;
-(void)initTopBar;

#pragma mark target
-(void)backButtonPressed:(id)sender;


@end

@implementation RIChooseGroupController
@synthesize group;
@synthesize delegate;

#pragma mark main

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


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    UIView *contentView;
    if ([Util isPhone]) {
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 300)];
    }else{
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, 500)];
    }
    
    self.view = contentView;
    [contentView release];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initGroupArray];
    [self initTableView];
    [self initTopBar];
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
    self.group = nil;
    if (_groups) {
        [_groups release];
    }
    [super dealloc];
}

#pragma mark -

#pragma mark tableview delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_groups) {
        return [_groups count];
    }
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellGR";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if ([Util isPhone]) {
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
            bgImageView.image = [Util imageFromBundle:@"i_list_bg.png"];
            
            UIImageView *bgImageViewHighligthed = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ((IS_IPHONE_5)?568:480), 39)];
            bgImageViewHighligthed.image = [Util imageFromBundle:@"i_list_bg_active.png"];
            
            cell.backgroundView = bgImageView;
            cell.selectedBackgroundView = bgImageViewHighligthed;
            
            [bgImageView release];
            [bgImageViewHighligthed release];     
        }else{
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }

    }
    
    NSString *gid = [_groups objectAtIndex:indexPath.row];
    NSString *name = [[FDBController sharedDatabase] nameForGroup:gid];
    NSInteger setnum = [[FDBController sharedDatabase] numOfItemsInGroup:gid];
    cell.textLabel.text = name;
    if (setnum <= 1) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d set",setnum];
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sets",setnum];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _index = indexPath.row;
    NSString *gid = [_groups objectAtIndex:_index];
    NSString *message = [NSString stringWithFormat:@"Are you sure you want to move your set to %@ category?",[[FDBController sharedDatabase] nameForGroup:gid]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"NO"
                                          otherButtonTitles:@"YES", nil];
    [alert show];
    [alert release];
}

#pragma mark -

#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=[alertView cancelButtonIndex]) {
        if (delegate && [delegate respondsToSelector:@selector(movedTo:)]) {
            [delegate movedTo:[_groups objectAtIndex:_index]];
        }
    }
}

#pragma mark -

#pragma mark init

-(void)initTopBar{
    FINavigationBar* navigationBar;
    
    if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];;
            }
            else{
                navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];;
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
                navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];;
            }
            else{
                navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];;
            }
            
            
        }
        navigationBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
        navigationBar.titleLabel.text = @"Move to";
    }else{
        navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        navigationBar.tintColor = [UIColor lightGrayColor];
    }
    

    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UINavigationItem *topItem;
    if ([Util isPhone]) {
        topItem = [[UINavigationItem alloc] init]; 
    }else{
        topItem = [[UINavigationItem alloc] initWithTitle:@"Move to"];
    }
     
    [navigationBar pushNavigationItem:topItem animated:NO];
    [topItem release];
    
    if ([Util isPhone]) {
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
    }else{
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self 
                                                                      action:@selector(backButtonPressed:)];
        topItem.leftBarButtonItem = backButton;
        [backButton release];     
    }

}

-(void)initTableView{
    if ([Util isPhone]) {
       _groupView = [[UITableView alloc] initWithFrame:CGRectMake(0, 35, ((IS_IPHONE_5)?568:480), 265) style:UITableViewStylePlain];
    }else{
       _groupView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 500, 460) style:UITableViewStylePlain];  
    }
    _groupView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;    
    _groupView.delegate = self;
    _groupView.dataSource = self;
    _groupView.backgroundColor = [UIColor whiteColor];
    if ([Util isPhone]) {
      _groupView.separatorStyle = UITableViewCellSeparatorStyleNone;  
    }
    
    [self.view addSubview:_groupView];
    [_groupView release];
}

-(void)initGroupArray{
    NSArray *gids = [[FDBController sharedDatabase] groupsid];
    if (gids ) {
        _groups = [[NSMutableArray alloc] initWithArray:gids];
        if (group) {
            for (int i =0 ; i<[_groups count]; i++) {
                if ([group isEqualToString:[_groups objectAtIndex:i]]) {
                    [_groups removeObjectAtIndex:i];
                    break;
                    
                }
            } 
        }
        
    }
    
}


#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -

#pragma mark -
-(void)backButtonPressed:(id)sender{
    if ([Util isPhone]) {
       [self.navigationController popViewControllerAnimated:YES]; 
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

@end
