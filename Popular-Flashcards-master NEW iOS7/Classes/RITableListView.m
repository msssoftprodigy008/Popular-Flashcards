//
//  RITableListView.m
//  flashCards
//
//  Created by Ruslan on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RITableListView.h"
#import "FRootConstants.h"
#import "Util.h"

@interface RITableListView(Private)

#pragma mark private
-(void)initTopBar;
-(CGPoint)calculateCenterPointForShape:(NSString*)s;
#pragma mark private ends

#pragma mark targets
-(void)leftButtonPressed:(id)sender;
-(void)rightButtonPressed:(id)sender;
-(void)topBarTouched:(id)sender;
#pragma mark targets ends

@end


@implementation RITableListView
@synthesize r_tableView;
@synthesize r_topBar;
@synthesize r_leftButton;
@synthesize r_rightButton;

#pragma mark -
#pragma mark main methods

-(id)initWithFrame:(CGRect)frame forDelegate:(id)delegate forBTitles:(NSArray*)btitles forTag:(NSInteger)viewTag{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		r_delegate = delegate;
		
		if (btitles) {
			r_btitles = [[NSArray alloc] initWithArray:btitles];
		}
        [self initTopBar];
		r_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
																	34.0,
																	frame.size.width,
																	frame.size.height-34.0)
												   style:UITableViewStylePlain];
		r_tableView.backgroundColor = [UIColor whiteColor];
        r_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        r_tableView.tag = viewTag;
		self.tag = viewTag;
		r_tableView.delegate = delegate;
		r_tableView.dataSource = delegate;
		[self addSubview:r_tableView];
		//[r_tableView release];
        [self bringSubviewToFront:r_topBar];
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
	
	if (r_btitles) {
		[r_btitles release];
	}
	//[super dealloc];
}

#pragma mark main methods ends

#pragma mark -
#pragma mark init

-(void)initTopBar
{
    UIImage *panelImage = [Util imageFromBundle:@"i_panel_bg.png"];
    
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            r_topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
        }
        else{
            r_topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
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
            r_topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
        }
        else{
            r_topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
        }
        
        
    }
	//r_topBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,self.frame.size.width,40)];
	r_topBar.bgImage = panelImage;
	r_topBar.tintColor = kDefaultNavColor;
    UINavigationItem *topItem = [[UINavigationItem alloc] init ];
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; // change this color
    topItem.titleView = label;
    label.text = NSLocalizedString(@"Categories", @"");
    [label sizeToFit];

    [r_topBar pushNavigationItem:topItem animated:NO];
	
    UIImage *addCustomItemImage = [UIImage imageNamed:@"i_panel_plus1.png"];
    UIButton *addCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
    addCustomItem.frame = CGRectMake(0,0,addCustomItemImage.size.width,addCustomItemImage.size.height);
    [addCustomItem setImage:addCustomItemImage forState:UIControlStateNormal];
    [addCustomItem setImage:[UIImage imageNamed:@"i_panel_plus2.png"] forState:UIControlStateHighlighted];
    [addCustomItem addTarget:self
                      action:@selector(leftButtonPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    if (IS_IPHONE_5) {
        [addCustomItem setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    }
    else{
        
    }
    r_leftButton = [[UIBarButtonItem alloc] initWithCustomView:addCustomItem];
    topItem.leftBarButtonItem = r_leftButton;
    
    [r_leftButton release];
    
	UIImage *editCustomItemImage = [UIImage imageNamed:@"i_panel_edit1.png"];
	UIButton *editCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
	editCustomItem.frame = CGRectMake(0,0,editCustomItemImage.size.width,editCustomItemImage.size.height);
	[editCustomItem setImage:editCustomItemImage forState:UIControlStateNormal];
	[editCustomItem setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
	[editCustomItem addTarget:self
					   action:@selector(rightButtonPressed:)
			 forControlEvents:UIControlEventTouchUpInside];
	r_rightButton = [[UIBarButtonItem alloc] initWithCustomView:editCustomItem];
    
	topItem.rightBarButtonItem = r_rightButton;
	[r_rightButton release];
    
	
	[self addSubview:r_topBar];
	
	UIButton *touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
	touchButton.frame = CGRectMake(self.frame.size.width/2-self.frame.size.width/4,0,self.frame.size.width/2,40);
	[touchButton addTarget:self
					action:@selector(topBarTouched:)
		  forControlEvents:UIControlEventTouchUpInside];
	[r_topBar addSubview:touchButton];
	
    if ([Util isPhone]) {
        
        UIImageView* shape = [[UIImageView alloc] initWithImage:[Util rotateImage:[UIImage imageNamed:@"i_panel_arrow1.png"] forAngle:180]];
        CGPoint c = [self calculateCenterPointForShape:@"Categories"];
        if(IS_IPHONE_5) {
            shape.center = CGPointMake(c.x+50,c.y+6);
        }
        else{
            shape.center = CGPointMake(c.x+10,c.y+6);
        }
        
        [r_topBar addSubview:shape];
        [shape release];
    }
    
	[topItem release];
	[r_topBar release];
	
    [self bringSubviewToFront:r_topBar];
}

-(CGPoint)calculateCenterPointForShape:(NSString*)s
{
	CGSize sz = [s sizeWithFont:[UIFont boldSystemFontOfSize:20]];
	return CGPointMake(240+sz.width/2,16);
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

#pragma mark -
#pragma mark targets
-(void)leftButtonPressed:(id)sender;
{
	if (r_delegate && [r_delegate respondsToSelector:@selector(leftButtonPressed:)]) {
		[r_delegate leftButtonPressed:self];
	}
}

-(void)rightButtonPressed:(id)sender
{
	if (r_delegate && [r_delegate respondsToSelector:@selector(rightButtonPressed:)]) {
		[r_delegate rightButtonPressed:self];
	}
	
}

-(void)topBarTouched:(id)sender
{
	if (r_delegate && [r_delegate respondsToSelector:@selector(topBarPressed:)]) {
		[r_delegate topBarPressed:self];
	}
}


#pragma mark targets ends


@end
