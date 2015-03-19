    //
//  FISceneViewController.m
//  flashCards
//
//  Created by Ruslan on 7/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FISceneViewController.h"
#import "FAdMobController.h"
#import "FRootConstants.h"
#import "FICardEditController.h"
#import "Util.h"
#import "FDBController.h"
#import "Constant.h"
@interface FISceneViewController(Private)

-(void)initTopBar;
-(void)initBottomBar;
-(void)initButtons;
-(void)initAxilPanel;
-(void)backPressed;

-(void)bothPressed;
-(void)reversePressed;
-(void)shufflePressed;
-(void)moveAxilPanel:(UIButton*)sender;
-(void)addCardButtonPressed:(id)sender;
-(void)editCardButtonPressed:(id)sender;
-(void)trashButtonPressed:(id)sender;
-(void)handleTap:(UITapGestureRecognizer*)sender;
-(void)hidePanels:(NSTimer*)timer;
-(void)seePanels;
-(void)setVersion;
-(void)upgraded;
-(void)hideTrash;

-(NSDictionary*)createContentForEditController;

-(void)restoreController;
-(void)prepareToExit;
-(void)exit;

#pragma mark Notifications
-(void)restorePopover:(NSNotification*)sender;
-(void)showMe:(NSNotification *)sender;
-(void)dissmisPopover:(NSNotification*)sender;
#pragma mark -

@end


@implementation FISceneViewController

@synthesize category;
@synthesize categoryName;
@synthesize initedId;
@synthesize r_isTopPanelExist;
@synthesize delegate;
@synthesize withoutAnimation;

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
	
	CGRect frame;
	
	if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                frame = CGRectMake(0,0,568,320);
            }
            else{
                frame = CGRectMake(0,0,568,300);
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                frame = CGRectMake(0,0,480,320);
            }
            else{
                frame = CGRectMake(0,0,480,300);
            }
        }
	}else {
		frame = CGRectMake(0,0,1024,1024);
	}
	
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	self.view = contentView;
	[contentView release];
	
    if (![Util isPhone]) {
		r_bgLandView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Landscape.png"]];
        r_bgLandView.frame =CGRectMake(0, 0, 1024, 1024);
        [self.view addSubview:r_bgLandView];
        [r_bgLandView release];
        
        r_bgPortView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Portrait.png"]];
        [self.view addSubview:r_bgPortView];
        [r_bgPortView release];
        
        if ([Util isPortrait:self]) {
            r_bgLandView.alpha = 0.0;
        }else{
            r_bgPortView.alpha = 0.0;
        }
	}
    
	container = [[FICardsContainerController alloc] init];
	container.category = category;
    container.withoutAnimations = withoutAnimation;
	container.delegate = self;
	[container initCardsArray:cards];
	container.currentId = initedId;
	[container initIgnoredCards:ignoredCards];
	[self.view addSubview: container.view];
	
	
	isStateChanged = NO;
	
	[self setVersion];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(showMe:)
												 name:@"showMe"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(dissmisPopover:)
												 name:@"dissmisPopover"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(restorePopover:)
												 name:@"restorePopover"
											   object:nil];
	
	/*[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(upgraded)
												 name:@"upgraded"
											   object:nil];*/
	
		
}

-(void)initByArray:(NSArray*)Acards
{
	if (cards) {
		[cards release];
		cards = nil;
	}
	
	
	
	if (Acards) 
	{
		cards = [[NSMutableArray alloc] initWithArray:Acards];
		
	}
}

-(void)initIgnoredCards:(NSMutableSet*)AignoredCards
{
	if (ignoredCards) {
		[ignoredCards release];
		ignoredCards = nil;
	}
	
	if (AignoredCards) {
		ignoredCards = [[NSMutableSet alloc] initWithSet:AignoredCards];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
   [super viewDidLoad];
	
	if (![Util isPhone]) {
		[self initBottomBar];
	}
	
	if (r_isTopPanelExist && ![Util isPhone]) {
		[self initTopBar];
	}
	
	if (!cards || [cards count]<=0) {
		[self editing:NO];
		[self deleteCard:NO];
		
	}
	
	[self initButtons];
	
	if ([Util isPhone]) {
		[self initAxilPanel];
	}
	
    if (!withoutAnimation) {
        isAxilPanelHidden = YES;
    }else{
        isAxilPanelHidden = YES;
    }
	
	if ([Util isPhone]) {
        if (!withoutAnimation) {
            [self performSelector:@selector(restoreController)
                       withObject:nil
                       afterDelay:0.5f];
        }
	}else {
		[self performSelector:@selector(seePanels)
				   withObject:nil
				   afterDelay:0.5f];
	}

	
	
}

-(void)viewWillAppear:(BOOL)animated{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"cardUpdateTextPosition" object:nil];
    if([Util isPhone])
    {
        
       [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
	if ([Util isPhone]) {
		[UIApplication sharedApplication].statusBarHidden = YES;
	}
}

-(void)viewWillDisappear:(BOOL)animated
{
	if ([Util isPhone]) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}
}

-(void)addCardWithText:(NSString*)term{
    FICardEditController *editController = [[FICardEditController alloc] initWithType:FIEditCardTypeUpdate
                                                                          forCategory:category
                                                                               forArg:[NSDictionary dictionaryWithObject:term forKey:@"question"]];
    editController.delegate = self;
    [container hideCard:FICardPositionRight hidden:YES];
    if ([Util isPhone]) {
        editController.orientation = FIOrientationLandscape;
        [self.navigationController pushViewController:editController animated:YES];
    }else{
        
    }
    [editController release];
}

#pragma mark -
#pragma mark FIEditCardControllerDelegate

-(void)createdCard:(NSArray*)newCard
{
	isStateChanged = YES;
	
	if (container && newCard) {
		[container addCard:newCard];
	}
}

-(void)updatedCard:(NSArray*)card
{
	isStateChanged = YES;
	
	if (container && card) {
		[container updateCurrentCard:card];
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
#pragma mark FICardsContainerControllerDelegate

-(void)editing:(BOOL)enable
{
	if (editCardButton) {
		editCardButton.enabled = enable;
	}
	
	if (reverse) {
		reverse.enabled = enable;	
	}

	if (bothSide) {
		bothSide.enabled = enable;
	}

	if (shuffle) {
		shuffle.enabled = enable;
	}
	
}

-(void)deleteCard:(BOOL)enable
{
	if (deleteCardButton) {
		deleteCardButton.enabled = enable;
	}
}

-(void)removeCardWithId:(NSInteger)cardId
{
	if (cardId>=0) {
		[Util removeImageWithName:category withId:cardId forWhat:YES];
		[Util removeImageWithName:category withId:cardId forWhat:NO];
		[Util removeSoundForCard:category forId:cardId forWhat:YES];
		[Util removeSoundForCard:category forId:cardId forWhat:NO];
		[[FDBController sharedDatabase] removeQuestion:category forIndex:cardId];
	}
}

-(void)catchRemovedCard
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	if ([Util isPhone]) {
		trashButton.center = CGPointMake(((IS_IPHONE_5)?284:240),296);
	}else {
		if ([Util isPortrait:self]) {
			trashButton.center = CGPointMake(384,939);
		}else {
			trashButton.center = CGPointMake(512,684);
		}
	}

	
	[UIView commitAnimations];
	
	[self performSelector:@selector(hideTrash) withObject:nil afterDelay:1.2f];
}

-(void)cardsWantToQuit
{
	[self backPressed];
}

-(void)fullScreen:(BOOL)enabled
{
	if ([Util isPhone]) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
	
		if (enabled) {
			quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
										  quitButton.frame.origin.y,
										  quitButton.frame.size.width,
										  quitButton.frame.size.height);
		
			if (addCardButton) {
				addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
												 addCardButton.frame.origin.y,
												 addCardButton.frame.size.width,
												 addCardButton.frame.size.height);
			}
		
			if (axilPanel) {
				axilPanel.frame = CGRectMake(-axilPanel.frame.size.width,
											 axilPanel.frame.origin.y,
											 axilPanel.frame.size.width,
											 axilPanel.frame.size.height);
				if (!isAxilPanelHidden) {
					isAxilPanelHidden = YES;
					[showButton setImage:[UIImage imageNamed:@"i_card_show1.png"] forState:UIControlStateNormal];
					[showButton setImage:[UIImage imageNamed:@"i_card_show2.png"] forState:UIControlStateHighlighted];
				}
			}	
		}else {
			if (quitButton) {
				quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-quitButton.frame.size.width,
											  quitButton.frame.origin.y,
											  quitButton.frame.size.width,
											  quitButton.frame.size.height);
			}
		
			if (addCardButton) 
				addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-addCardButton.frame.size.width,
												 addCardButton.frame.origin.y,
												 addCardButton.frame.size.width,
												 addCardButton.frame.size.height);
			if (axilPanel) {
				axilPanel.frame = CGRectMake(40-axilPanel.frame.size.width,
											 axilPanel.frame.origin.y,
											 axilPanel.frame.size.width,
											 axilPanel.frame.size.height);
			}
		}
	
		[UIView commitAnimations];
	}
}

#pragma mark -

#pragma mark -
#pragma mark UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	
}


#pragma mark -
#pragma mark Notifications

-(void)dissmisPopover:(NSNotification*)sender
{
	if (r_popoverController) {
		
		if ([r_popoverController isPopoverVisible]) {
			[r_popoverController dismissPopoverAnimated:YES];
		}
		
		[r_popoverController release];
		r_popoverController = nil;
	}
	
	topBar.userInteractionEnabled = YES;
	container.view.userInteractionEnabled = YES;
	bottomBar.userInteractionEnabled = YES;
}

-(void)showMe:(NSNotification*)sender
{
	UINavigationController *navController = (UINavigationController*)[sender object];
	
	if (navController) {
		navController.modalPresentationStyle = UIModalPresentationFormSheet;
		navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentModalViewController:navController animated:YES];
	}
}

-(void)restorePopover:(NSNotification*)sender
{
	if (r_popoverController) {
		[r_popoverController setPopoverContentSize:CGSizeMake(500.0,256.0)];
	}
}

#pragma mark Notifications ends

#pragma mark -
#pragma mark myAdView delegate

-(void)iAdRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        
        adView.center = CGPointMake(adView.frame.size.width/2.0, adView.center.y);
        
        [UIView commitAnimations];
    }
}

-(void)adMobRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        
        adView.center = CGPointMake(adView.frame.size.width/2.0, adView.center.y);
        
        [UIView commitAnimations];
    }
}

-(void)gAdRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5f];
        
        adView.center = CGPointMake(adView.frame.size.width/2.0, adView.center.y);
        
        [UIView commitAnimations];
    }
}


-(void)iAdFailed{
   /* CGRect frame = adView.frame;
    frame.size.height = 90;
    
    if (![Util isPortrait:self]) {
        frame.origin.y = 943-frame.size.height;
    }else{
        frame.origin.y = 682-frame.size.height;
    }
    
    adView.frame = frame;
    [adView tryGAD:GAD_SIZE_728x90];*/

}

-(void)adMobFailed{
    
}

-(void)gAdFailed{

}

#pragma mark -
#pragma mark axilPanel tap

-(void)moveAxilPanel:(UIButton*)sender;
{
    isAxilPanelHidden = !isAxilPanelHidden;
	NSInteger move;
	[UIView beginAnimations:@"move_axil_panel" context:nil];
	
	if (isAxilPanelHidden) {
		move = 40-axilPanel.frame.size.width;
		[showButton setImage:[UIImage imageNamed:@"i_card_show1.png"] forState:UIControlStateNormal];
		[showButton setImage:[UIImage imageNamed:@"i_card_show2.png"] forState:UIControlStateHighlighted];
	}else {
		move = -25;
		[showButton setImage:[UIImage imageNamed:@"i_card_hide1.png"] forState:UIControlStateNormal];
		[showButton setImage:[UIImage imageNamed:@"i_card_hide2.png"] forState:UIControlStateHighlighted];
	}
	
	axilPanel.frame = CGRectMake(move,axilPanel.frame.origin.y,axilPanel.frame.size.width,axilPanel.frame.size.height);
	
	[UIView commitAnimations];

}

#pragma mark axilPanel tap ends

#pragma mark -
#pragma mark private

-(void)upgraded
{
	

	
}

-(void)setVersion
{
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
		isFullVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"version"] boolValue];
	}else {
		isFullVersion = NO;
	}
	
	
	
}


-(void)initTopBar
{
    if (![Util isFullVersion]) {
        
        if ([Util isPhone]) {
            adView = [[myAdView alloc] initWithFrame:CGRectMake(-768, 0, 768, 32)
                                            delegate:self];
        }else
        {
            adView = [[myAdView alloc] initWithFrame:CGRectMake(-768, 0, 1024, 32)
                                            delegate:self];
        
        }
        
        adView.hidden = YES;
    }
    
	if ([Util isPortrait:self]) {
        topBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,-50,768,50)];
        if (![Util isFullVersion] && adView) {
            adView.center = CGPointMake(adView.center.x, 943-adView.frame.size.height/2.0);
        }
    }else {
		topBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,-50,1024,50)];
        if (![Util isFullVersion] && adView) {
            adView.center = CGPointMake(adView.center.x, 682-adView.frame.size.height/2.0);
        }
	}
    
    if (![Util isFullVersion] && adView) {
        adView.ViewController = [[self.navigationController viewControllers] objectAtIndex:0];
        [adView showInView:self.view animated:YES];
        adView.hidden = YES;
        [adView tryiAd:ADBannerContentSizeIdentifierLandscape];
        [adView release];
    }
    
    topBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(topBar.frame.size.width/2.0-250, 0, 500, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(1, 1);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    if (category) {
        titleLabel.text = [[FDBController sharedDatabase] nameForCategory:category];
    }
    
    [topBar addSubview:titleLabel];
    [titleLabel release];
    
    UIImage* editCustomItemImage = [UIImage imageNamed:@"i_panel_edit1.png"];
	UIButton *editCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
	editCustomItem.frame = CGRectMake(0,0,editCustomItemImage.size.width,editCustomItemImage.size.height);
	[editCustomItem setImage:editCustomItemImage forState:UIControlStateNormal];
	[editCustomItem setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
    [editCustomItem setImageEdgeInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
        
	[editCustomItem addTarget:self
					   action:@selector(editCardButtonPressed:)
			 forControlEvents:UIControlEventTouchUpInside];
        
	editCardButton = [[UIBarButtonItem alloc] initWithCustomView:editCustomItem];
    
	UIImage* addCustomItemImage = [UIImage imageNamed:@"ip_panel_plus1.png"]; 
	UIButton *addCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
	addCustomItem.frame = CGRectMake(0,0,addCustomItemImage.size.width,addCustomItemImage.size.height);
    [addCustomItem setImageEdgeInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
        
	[addCustomItem setImage:addCustomItemImage forState:UIControlStateNormal];
    [addCustomItem setImage:[UIImage imageNamed:@"ip_panel_plus2.png"] forState:UIControlStateHighlighted];        
    [addCustomItem addTarget:self
					  action:@selector(addCardButtonPressed:)
			forControlEvents:UIControlEventTouchUpInside];
	addCardIPadButton = [[UIBarButtonItem alloc] initWithCustomView:addCustomItem];
	
    UIButton *backButtonCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *customButtonImage = [UIImage imageNamed:@"i_panel_back1.png"];
    backButtonCustom.frame = CGRectMake(0,0,customButtonImage.size.width,customButtonImage.size.height);
    [backButtonCustom setImageEdgeInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    [backButtonCustom setImage:customButtonImage forState:UIControlStateNormal];
    [backButtonCustom setImage:[UIImage imageNamed:@"i_panel_back2.png"] forState:UIControlStateHighlighted];
    [backButtonCustom addTarget:self
                         action:@selector(backPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonCustom];
    
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                           target:nil
                                                                           action:nil];
	[topBar setItems:[NSArray arrayWithObjects:backButton,addCardIPadButton,space,editCardButton,nil]];
    [editCardButton release];
    [addCardIPadButton release];
    [backButton release];
    
	[self.view addSubview:topBar];
	[topBar release];
    

}

-(void)initBottomBar
{
	if ([Util isPhone]) {
		bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,320,((IS_IPHONE_5)?568:480),44)];
	}else {
		if ([Util isPortrait:self]) {
			bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,1004,768,50)];
		}else {
			bottomBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,748,1024,50)];
		}
        bottomBar.bgImage = [Util imageFromBundle:@"ip_panelbottom_bg.png"];
	}

	[self.view addSubview:bottomBar];
	[bottomBar release];
	
    UIButton *customSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *customSideImage = [Util imageFromBundle:@"i_card_both_sides1.png"];
    customSideButton.frame = CGRectMake(0, 0, customSideImage.size.width, customSideImage.size.height);
    [customSideButton setImage:customSideImage forState:UIControlStateNormal];
    [customSideButton setImage:[Util imageFromBundle:@"i_card_both_sides2.png"] forState:UIControlStateHighlighted];
    [customSideButton addTarget:self
                         action:@selector(bothPressed)
               forControlEvents:UIControlEventTouchUpInside];
    
	bothSide = [[UIBarButtonItem alloc] initWithCustomView:customSideButton];
	
	if (container.isBothSide) {
		bothSide.style = UIBarButtonItemStyleDone;
	}
    
    UIButton *customShuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *customShuffleImage = [Util imageFromBundle:@"i_card_shuffle1.png"];
    customShuffleButton.frame = CGRectMake(0, 0, customShuffleImage.size.width, customShuffleImage.size.height);
    [customShuffleButton setImage:customShuffleImage forState:UIControlStateNormal];
    [customShuffleButton setImage:[Util imageFromBundle:@"i_card_shuffle2.png"] forState:UIControlStateHighlighted];
    [customShuffleButton addTarget:self
                         action:@selector(shufflePressed)
               forControlEvents:UIControlEventTouchUpInside];
    
	shuffle = [[UIBarButtonItem alloc] initWithCustomView:customShuffleButton];
	
	UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		   target:nil
																		   action:nil];
	
    UIButton *customDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *customDeleteImage = [Util imageFromBundle:@"i_card_delete1.png"];
    customDeleteButton.frame = CGRectMake(0, 0, customDeleteImage.size.width, customDeleteImage.size.height);
    [customDeleteButton setImage:customDeleteImage forState:UIControlStateNormal];
    [customDeleteButton setImage:[Util imageFromBundle:@"i_card_delete2.png"] forState:UIControlStateHighlighted];
    [customDeleteButton addTarget:self
                            action:@selector(trashButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
	deleteCardButton = [[UIBarButtonItem alloc] initWithCustomView:customDeleteButton];
	bottomBar.items = [NSArray arrayWithObjects:flex,bothSide,flex,shuffle,flex,deleteCardButton,flex,nil];
	[deleteCardButton release];
	[bothSide release];
	[shuffle release];
	[flex release];

}

-(void)initButtons
{
	if ([Util isPhone]) {
		UIImage *quitButtonImage = [UIImage imageNamed:@"i_card_quit1.png"];
		if (quitButtonImage) {
			quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
            quitButton.exclusiveTouch = YES;
            if (!withoutAnimation) {
                quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),15,quitButtonImage.size.width,quitButtonImage.size.height);
            }else{
                quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-quitButtonImage.size.width,15,quitButtonImage.size.width,quitButtonImage.size.height);
            }
			[quitButton setImage:[UIImage imageNamed:@"i_card_quit1.png"] forState:UIControlStateNormal];
			[quitButton setImage:[UIImage imageNamed:@"i_card_quit2.png"] forState:UIControlStateHighlighted];
			[quitButton addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:quitButton];
		}
	}

	
	trashButton = [UIButton buttonWithType:UIButtonTypeCustom];
	
	if ([Util isPhone]) {
        trashButton.frame = CGRectMake(226,322,28,32);
	}else {
		if ([Util isPortrait:self]) {
			//trashButton.frame = CGRectMake(370,1026,28,32);
		}else {
			//trashButton.frame = CGRectMake(498,1026,28,32);
		}
		
	}
	
	[trashButton setImage:[UIImage imageNamed:@"i_trash.png"] forState:UIControlStateNormal];
	[trashButton setImage:[UIImage imageNamed:@"i_trash.png"] forState:UIControlStateHighlighted];
	
	
	[trashButton addTarget:self
					action:@selector(trashButtonPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:trashButton];
	
	if ([Util isPhone]) {
		UIImage *addCardImage = [UIImage imageNamed:@"i_card_new1.png"];
		if (addCardImage) {
			addCardButton = [UIButton buttonWithType:UIButtonTypeCustom];
            if (!withoutAnimation) {
                addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)+addCardImage.size.width,305-addCardImage.size.height,addCardImage.size.width,addCardImage.size.height);
            }else{
                addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-addCardImage.size.width,305-addCardImage.size.height,addCardImage.size.width,addCardImage.size.height);
            }
		
			[addCardButton setImage:[UIImage imageNamed:@"i_card_new1.png"] forState:UIControlStateNormal];
			[addCardButton setImage:[UIImage imageNamed:@"i_card_new2.png"] forState:UIControlStateHighlighted];
			[addCardButton addTarget:self
							  action:@selector(addCardButtonPressed:)
					forControlEvents:UIControlEventTouchUpInside];
			[self.view addSubview:addCardButton];
		}
	}
}

-(void)initAxilPanel
{
	axilPanel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_card_menu.png"]];
    isAxilPanelHidden = NO;
    if (!withoutAnimation) {
        axilPanel.frame = CGRectMake(-axilPanel.frame.size.width,
								 305-axilPanel.frame.size.height,
								 axilPanel.frame.size.width,
								 axilPanel.frame.size.height);
    }else{
        axilPanel.frame = CGRectMake(40.0-axilPanel.frame.size.width,
									 305-axilPanel.frame.size.height,
									 axilPanel.frame.size.width,
									 axilPanel.frame.size.height);
    }
	axilPanel.userInteractionEnabled = YES;
	[self.view addSubview:axilPanel];
	[axilPanel release];
	
	CGFloat _offset = 25.0;
	CGFloat _buttonDis = 0.0;
	
	//showButton
	showButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *_showImage = [UIImage imageNamed:@"i_card_show1.png"];
	showButton.frame = CGRectMake(axilPanel.frame.size.width-_showImage.size.width,
								  axilPanel.frame.size.height/2-_showImage.size.height/2,
								  _showImage.size.width,
								  _showImage.size.height);
	[showButton setImage:_showImage forState:UIControlStateNormal];
    showButton.exclusiveTouch = YES;
	[showButton setImage:[UIImage imageNamed:@"i_card_show2.png"] forState:UIControlStateHighlighted];
	[showButton addTarget:self
				   action:@selector(moveAxilPanel:)
		 forControlEvents:UIControlEventTouchUpInside];
	[axilPanel addSubview:showButton];
	
	//create edit button
	editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *_editImage = [UIImage imageNamed:@"i_card_edit1.png"];
	editButton.frame = CGRectMake(_offset,
							 axilPanel.frame.size.height/2-_editImage.size.height/2,
							 _editImage.size.width,
							 _editImage.size.height);
	[editButton setImage:_editImage forState:UIControlStateNormal];
    editButton.exclusiveTouch = YES;
	[editButton setImage:[UIImage imageNamed:@"i_card_edit2.png"] forState:UIControlStateHighlighted];
	[editButton addTarget:self
					action:@selector(editCardButtonPressed:)
		  forControlEvents:UIControlEventTouchUpInside];
	[axilPanel addSubview:editButton];
	
	//create delete button
	deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *_deleteImage = [UIImage imageNamed:@"i_card_delete1.png"];
	deleteButton.frame = CGRectMake(editButton.frame.origin.x+editButton.frame.size.width+_buttonDis,
							 axilPanel.frame.size.height/2-_deleteImage.size.height/2,
							 _deleteImage.size.width,
							 _deleteImage.size.height);
	[deleteButton setImage:_deleteImage forState:UIControlStateNormal];
    deleteButton.exclusiveTouch = YES;
	[deleteButton setImage:[UIImage imageNamed:@"i_card_delete2.png"] forState:UIControlStateHighlighted];
	[deleteButton addTarget:self
					  action:@selector(trashButtonPressed:)
			forControlEvents:UIControlEventTouchUpInside];
	[axilPanel addSubview:deleteButton];
	
	//shuffle button 
	shuffleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *_shuffleImage = [UIImage imageNamed:@"i_card_shuffle1.png"];
	shuffleButton.frame = CGRectMake(deleteButton.frame.origin.x+deleteButton.frame.size.width+_buttonDis,
							   axilPanel.frame.size.height/2-_shuffleImage.size.height/2,
							   _shuffleImage.size.width,
							   _shuffleImage.size.height);
	[shuffleButton setImage:_shuffleImage forState:UIControlStateNormal];
    shuffleButton.exclusiveTouch = YES;
	[shuffleButton setImage:[UIImage imageNamed:@"i_card_shuffle2.png"] forState:UIControlStateHighlighted];
	[shuffleButton addTarget:self
					  action:@selector(shufflePressed)
			forControlEvents:UIControlEventTouchUpInside];
	[axilPanel addSubview:shuffleButton];
	
	//both side button
	bothSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bothSideButton.exclusiveTouch = YES;
	UIImage *_bothSideImage = [UIImage imageNamed:@"i_card_both_sides1.png"];
	bothSideButton.frame = CGRectMake(shuffleButton.frame.origin.x+shuffleButton.frame.size.width+_buttonDis,
									  axilPanel.frame.size.height/2-_bothSideImage.size.height/2,
									  _bothSideImage.size.width,
									  _bothSideImage.size.height);
	if (!container.isBothSide) {
		[bothSideButton setImage:_bothSideImage
						forState:UIControlStateNormal];
		[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides2.png"]
						forState:UIControlStateHighlighted];
	}else {
		[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides3.png"]
						forState:UIControlStateNormal];
		[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides4.png"]
						forState:UIControlStateHighlighted];
	}

	[bothSideButton addTarget:self
					   action:@selector(bothPressed)
			 forControlEvents:UIControlEventTouchUpInside];
	[axilPanel addSubview:bothSideButton];

}

-(void)backPressed
{
   	[container saveCurrentSession];
    if (isStateChanged && delegate && [delegate respondsToSelector:@selector(stateChanged)]) {
        [delegate stateChanged];
    }
    
    [container stopSounds];
    
    if (![Util isFullVersion] && adView) {
        adView._delegate = nil;
    }
    
    if (withoutAnimation) {
        axilPanel.hidden = YES;
        [container hideCard:FICardPositionLeft hidden:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
    
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;

        BOOL isEmpty;
	
        NSInteger cardsCount = [[FDBController sharedDatabase] getNumberOfItems:category];
	
        if (cardsCount>0) {
            isEmpty = NO;
        }else {
            isEmpty = YES;
        }

	
	
        NSDictionary *dic = nil;
	
        if (delegate && [delegate respondsToSelector:@selector(viewingDidEnd:forCategory:)]) {
            dic = [delegate viewingDidEnd:isEmpty forCategory:category];
        }
	
        if(!isEmpty)
            [container scaleCenterCard:dic];
	
        [self performSelector:@selector(hidePanels:) withObject:nil
                   afterDelay:0.25f];
	
        if ([Util isPhone]) {
            [self performSelector:@selector(prepareToExit)
                       withObject:nil
                       afterDelay:0.5f];
        }
	
        [self performSelector:@selector(exit)
                   withObject:nil
                   afterDelay:1.0f];
    }
	
}

-(void)bothPressed
{
	isStateChanged = YES;
	
	[container stopSounds];
	[container makeBothSide];
	
	if ([Util isPhone]) {
		if (!container.isBothSide) {
			[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides1.png"]
							forState:UIControlStateNormal];
			[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides2.png"]
							forState:UIControlStateHighlighted];
		}else {
			[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides3.png"]
							forState:UIControlStateNormal];
			[bothSideButton setImage:[UIImage imageNamed:@"i_card_both_sides4.png"]
							forState:UIControlStateHighlighted];
		}
	}else {
        UIButton *customBothButton = (UIButton*)bothSide.customView;
        if (container.isBothSide) {
			[customBothButton setImage:[UIImage imageNamed:@"i_card_both_sides1.png"]
							forState:UIControlStateNormal];
			[customBothButton setImage:[UIImage imageNamed:@"i_card_both_sides2.png"]
							forState:UIControlStateHighlighted];
		}else {
			[customBothButton setImage:[UIImage imageNamed:@"i_card_both_sides3.png"]
							forState:UIControlStateNormal];
			[customBothButton setImage:[UIImage imageNamed:@"i_card_both_sides4.png"]
							forState:UIControlStateHighlighted];
		}
	}
}

-(void)reversePressed
{
	isStateChanged = YES;
	[container makeReversed];
	
	if (container.isReversed) {
		reverse.style = UIBarButtonItemStyleDone;
	}else {
		reverse.style = UIBarButtonItemStyleBordered;
	}
	
}

-(void)shufflePressed
{
	isStateChanged = YES;
	[container stopSounds];
	[container makeShuffle];
}

-(void)addCardButtonPressed:(id)sender
{
	FICardEditController *addController = [[FICardEditController alloc] initWithType:FIEditCardTypeAdd
																		 forCategory:category
																			  forArg:nil];
	addController.delegate = self;
	[container hideCard:FICardPositionRight hidden:YES];
	if ([Util isPhone]) {
		addController.orientation = FIOrientationLandscape;
		[self.navigationController pushViewController:addController animated:YES];
	}else {
		if (r_popoverController) {
			if ([r_popoverController isPopoverVisible]) {
				[r_popoverController dismissPopoverAnimated:NO];
			}
			[r_popoverController release];
		}
		
		UINavigationController *navCont = [[UINavigationController alloc] initWithRootViewController:addController];
		r_popoverController = [[UIPopoverController alloc] initWithContentViewController:navCont];
		r_popoverController.passthroughViews = [NSArray arrayWithObject:self.view];
		container.view.userInteractionEnabled = NO;
		topBar.userInteractionEnabled = NO;
		bottomBar.userInteractionEnabled = NO;
		addController.contentSizeForViewInPopover = CGSizeMake(500,256);
        [r_popoverController setPopoverContentSize:CGSizeMake(500, 290)];
		[r_popoverController presentPopoverFromBarButtonItem:addCardIPadButton
									permittedArrowDirections:UIPopoverArrowDirectionUp
													animated:YES];
		[navCont release];
	}

	
	[addController release];
	
}

-(void)editCardButtonPressed:(id)sender
{
	NSArray *card = [container currentCardId];
	
	if (card) {
		NSString *q = [card objectAtIndex:1];
		NSString *a = [card objectAtIndex:2];
		NSInteger cardId = [[card objectAtIndex:0] intValue];
		UIImage *qIm = [Util imageWithId:category forId:cardId forWhat:YES];
		UIImage *aIm = [Util imageWithId:category forId:cardId forWhat:NO];
	
		NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
	
		if (q) {
			[dic setObject:q forKey:@"question"];
		}
	
		if(a)
			[dic setObject:a forKey:@"answer"];
	
		if (qIm) {
			[dic setObject:UIImagePNGRepresentation(qIm) forKey:@"qImage"];
		}
	
		if (aIm) {
			[dic setObject:UIImagePNGRepresentation(aIm) forKey:@"aImage"];
		}
	
		[dic setObject:[NSNumber numberWithInt:cardId] forKey:@"cardId"];
		
		FICardEditController *editController = [[FICardEditController alloc] initWithType:FIEditCardTypeUpdate
																			 forCategory:category
																				  forArg:dic];
		editController.delegate = self;
		[container hideCard:FICardPositionRight hidden:YES];
		if ([Util isPhone]) {
			editController.orientation = FIOrientationLandscape;
			[self.navigationController pushViewController:editController animated:YES];
		}else {
			if (r_popoverController) {
				if ([r_popoverController isPopoverVisible]) {
					[r_popoverController dismissPopoverAnimated:NO];
				}
				[r_popoverController release];
			}
			
			UINavigationController *navCont = [[UINavigationController alloc] initWithRootViewController:editController];
			r_popoverController = [[UIPopoverController alloc] initWithContentViewController:navCont];
			r_popoverController.passthroughViews = [NSArray arrayWithObject:self.view];
			container.view.userInteractionEnabled = NO;
			topBar.userInteractionEnabled = NO;
			bottomBar.userInteractionEnabled = NO;
			editController.contentSizeForViewInPopover = CGSizeMake(500,256);
            [r_popoverController setPopoverContentSize:CGSizeMake(500, 290)];
			[r_popoverController presentPopoverFromBarButtonItem:editCardButton
										permittedArrowDirections:UIPopoverArrowDirectionUp
														animated:YES];
			[navCont release];
		}

		
		[editController release];
		[dic release];
	}
}

-(void)trashButtonPressed:(id)sender
{
	isStateChanged = YES;
	
	[container removeCurrentCard];
}

-(void)handleTap:(UITapGestureRecognizer*)sender
{
	NSLog(@"taped");
	[self seePanels];
}

-(void)hidePanels:(NSTimer*)timer
{
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];

	if (r_isTopPanelExist) {
		
		if ([Util isPhone]) {
			topBar.frame = CGRectMake(0.0,-44.0,((IS_IPHONE_5)?568.0:480.0),44.0);
		}else {
			if ([Util isPortrait:self]) {
				topBar.frame = CGRectMake(0.0,-50.0,768.0,50.0);
			}else {
				topBar.frame = CGRectMake(0.0,-50.0,1024.0,50.0);
			}

		}

	}
	
	if ([Util isPhone]) {
		bottomBar.frame = CGRectMake(0,364,((IS_IPHONE_5)?568:480),44);
	}else {
		if ([Util isPortrait:self]) {
			bottomBar.frame = CGRectMake(0,1024,768,50);
		}else {
			bottomBar.frame = CGRectMake(0,768,1024,50);
		}

	}
    
    if (![Util isFullVersion] && adView) {
        adView.center = CGPointMake(-adView.frame.size.width/2.0, adView.center.y);
    }

	
	
	[UIView commitAnimations];

}

-(void)seePanels
{
	//tapRecog.enabled = NO;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	if (r_isTopPanelExist) {
		if ([Util isPhone]) {
			topBar.frame = CGRectMake(0.0,0.0,((IS_IPHONE_5)?568.0:480.0),44.0);
		}else {
			if ([Util isPortrait:self]) {
				topBar.frame = CGRectMake(0.0,0.0,768,50.0);
			}else {
				topBar.frame = CGRectMake(0.0,0.0,1024,50.0);
			}

		}

		
	}
	
	if ([Util isPhone]) {
		bottomBar.frame = CGRectMake(0.0,320.0-44.0,((IS_IPHONE_5)?568.0:480.0),44.0);
	}else {
		if ([Util isPortrait:self]) {
			bottomBar.frame = CGRectMake(0.0,960.0,768.0,50.0);
		}else {
			bottomBar.frame = CGRectMake(0.0,704.0,1024.0,50.0);
		}

	}


	
	[UIView commitAnimations];
}

-(void)hideTrash
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	if ([Util isPhone]) {
		trashButton.center = CGPointMake(((IS_IPHONE_5)?284:240),340);
	}else {
		if ([Util isPortrait:self]) {
			trashButton.center = CGPointMake(384,1030);
		}else {
			trashButton.center = CGPointMake(512,764);
		}

	}

	

	
	[UIView commitAnimations];
	
}

-(NSDictionary*)createContentForEditController
{
	return nil;
}

-(void)restoreController
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	if (quitButton) {
		quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-quitButton.frame.size.width,
									  quitButton.frame.origin.y,
									  quitButton.frame.size.width,
									  quitButton.frame.size.height);
	}
	
	if (addCardButton) 
		addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480)-addCardButton.frame.size.width,
										 addCardButton.frame.origin.y,
										 addCardButton.frame.size.width,
										 addCardButton.frame.size.height);
	if (axilPanel) {
		axilPanel.frame = CGRectMake(40.0-axilPanel.frame.size.width,
									 axilPanel.frame.origin.y,
									 axilPanel.frame.size.width,
									 axilPanel.frame.size.height);
	}
	
	
	[UIView commitAnimations];
	
	
}

-(void)prepareToExit
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25f];
	
	quitButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
								  quitButton.frame.origin.y,
								  quitButton.frame.size.width,
								  quitButton.frame.size.height);
	
	if (addCardButton) {
		addCardButton.frame = CGRectMake(((IS_IPHONE_5)?568:480),
										 addCardButton.frame.origin.y,
										 addCardButton.frame.size.width,
										 addCardButton.frame.size.height);
	}
	
	if (axilPanel) {
		axilPanel.frame = CGRectMake(-axilPanel.frame.size.width,
									 axilPanel.frame.origin.y,
									 axilPanel.frame.size.width,
									 axilPanel.frame.size.height);
	}
    
    
	
	[UIView commitAnimations];
}

-(void)exit
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
  	if (![Util isPhone]) {
        if (delegate && [delegate respondsToSelector:@selector(sceneViewWasRotated:)]) {
            [delegate sceneViewWasRotated:interfaceOrientation];
        }
        
        [container rotateView:interfaceOrientation];
        
        if ([Util isPortraitWithOrientation:interfaceOrientation]) {
            topBar.frame = CGRectMake(0,0,768,50);
            bottomBar.frame = CGRectMake(0,960,768,50);
            trashButton.frame = CGRectMake(370,1026,28,32);
        }else {
            topBar.frame = CGRectMake(0,0,1024,50);
            bottomBar.frame = CGRectMake(0,704,1024,50);
            trashButton.frame = CGRectMake(498,1026,28,32);
        }
        
		if ([Util isPortrait:self]) {
			quitButton.frame = CGRectMake(700,150,60,40);
		}else {
			quitButton.frame = CGRectMake(950,150,60,40);
		}
        
        if ([Util isPortraitWithOrientation:interfaceOrientation]) {
            r_bgPortView.alpha = 1.0;
            r_bgLandView.alpha = 0.0;
            
            if (![Util isFullVersion] && adView) {
                adView.center = CGPointMake(adView.center.x, 943-adView.frame.size.height/2.0);
            }
            
        }else{
            r_bgPortView.alpha = 0.0;
            r_bgLandView.alpha = 1.0;
            
            if (![Util isFullVersion] && adView) {
                adView.center = CGPointMake(adView.center.x, 682-adView.frame.size.height/2.0);
            }
        }
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if ([Util isPhone]) {
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}else {
		return YES;
	}

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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"showMe" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"dissmisPopover" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"restorePopover" object:nil];
	
	[container release];
	[cards release];
	
	if (ignoredCards) {
		[ignoredCards release];
		ignoredCards = nil;
	}
    
    self.category = nil;
    self.categoryName = nil;
		
    [super dealloc];
}


@end
