//
//  RIMainViewCotroller.m
//  FC 1.4
//
//  Created by Ruslan on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIMainViewCotroller.h"
#import "FDBController.h"
#import "FRootConstants.h"
#import "FIBoxSceneViewController.h"
#import "FIAnimationController.h"
#import "FIITunesViewController.h"
#import "FIQuizletController.h"
#import "QIViewController.h"
#import "FICardEditController.h"
#import "FIAboutController.h"
#import "RIPRotatingController.h"
#import "FIAddViewController.h"
#import "FDrawController.h"
#import "JSON.h"
#import "FRootConstants.h"
#import "DBTime.h"
#import "Util.h"
#import "Constant.h"


#import "Orientation.h"
@interface RIMainViewCotroller(Private)

#pragma mark init
-(void)initTopBar;
-(void)initGroupView:(CGRect)frame tag:(RITableListViewType)viewType;
-(void)initOtherViews;
#pragma mark group methods
-(void)updateGroupStr;
-(void)updateGroupArray;
-(void)sortGroupArray;
NSInteger groupCompareFunctions(id left, id right, void *context);


#pragma mark targets
-(void)addCategoryPressed:(id)sender;
-(void)editCategoryPressed:(id)sender;
-(void)upgradeButtonPressed:(id)sender;
-(void)aboutButtonPressed:(id)sender;
-(void)changeMode:(UITapGestureRecognizer*)sender;
-(void)showGroupNavBar;
-(void)upgrade:(NSNotification*)sender;

-(void)loadSceneController:(NSString*)setId;

-(void)cellAccessoryButtonPressed:(id)sender;

-(void)addCategorySelected:(id)sender;
-(void)itunesSelected:(id)sender;
-(void)quizletSelected:(id)sender;

#pragma mark notifications
-(void)quizletSetPop:(NSNotification*)sender; //name=quizletAdded
-(void)quizletSetAdded:(NSNotification*)sender; //name=SetAdded
-(void)itunesSetPop:(NSNotification*)sender; //name=itunesAdded

#pragma mark IPAD notifications
-(void)showMe:(NSNotification*)sender;
-(void)restorePopover:(NSNotification*)sender;
-(void)dissmisPopover:(NSNotification*)sender;

#pragma mark private
-(NSArray*)createCategoryContent;
-(NSDictionary*)createContentForCategory:(NSString*)categoryId;
-(NSDictionary*)getCurrentPreference:(NSString*)category;
-(NSDictionary*)getCurrentFont:(NSString*)category;
-(void)createEmptySet:(NSString*)setName template:(NSInteger)template;
-(NSArray*)supportedTemplates;

-(CGPoint)calculateCenterPointForShape:(NSString*)s;
-(void)reshapeTriangleShape;

-(void)enableAddButton:(BOOL)enabled;
-(void)enableEditButton:(BOOL)enabled;

-(void)addCategoryAnimated:(NSDictionary*)dic;
-(void)addCategoryNotAnimated:(NSDictionary*)dic;
-(void)addCategoryFeatTest:(NSDictionary*)dic;

-(void)upgradeControlToFullVersion;
-(BOOL)isOperationLimited;

-(void)prepareToChanges:(BOOL)isCheckTest;
-(void)loadController;
-(void)loadBoxController;
-(void)restoreController;
-(void)restoreIPadAfterScene;
-(void)restoreControllerAnimated;

-(CGRect)popoverFrame:(UIInterfaceOrientation)orientation forState:(RIPopoverState)state;
-(void)presentIPadImport;
-(void)presentIPadTemplates;
-(void)presentIPhoneTemplate;

-(void)showAxButtons:(BOOL)animated;
-(void)hideAxButtons:(BOOL)animated;

-(void)hideAdv:(BOOL)hidden;

-(void)showContent;

-(void)startActivity;
-(void)stopActivity;

-(NSInteger)findIndexForId:(NSInteger)cid inArr:(NSArray*)cards;


@end



@implementation RIMainViewCotroller

#pragma mark -
#pragma mark main methods

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	

    CGRect frame;
    
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                frame = CGRectMake(0,0,568,320);
            }
            else{
                frame = CGRectMake(0,0,568,300);
            }
        }
		else{
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
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
	contentView.backgroundColor = [UIColor clearColor];
	self.view = contentView;
	[contentView release];
	
	self.view.multipleTouchEnabled = NO;
	
	if (![Util isPhone]) {
		r_bgLandView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"Default-Landscape@2x.png"]];
        
        //CGRect framebg;
        r_bgLandView.frame =CGRectMake(0, 20, 1024, 1024);  /////change by Sanjeev Reddy
        
        
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
	
    isButtonHidden = NO;
    
	r_popoverState = RIPopoverStateNone;
	r_mode = RIMainModeCategories;
	r_currentSelectedRow = nil;
	[self updateGroupArray];
	[self updateGroupStr];
    
	r_categoryContainer = [[RICategoryContainer alloc] initWithCategories:[self createCategoryContent]];
	r_categoryContainer.r_delegate = self;
	r_categoryContainer.view.alpha = 0.0;
	[self.view addSubview:r_categoryContainer.view];
	
	[self initOtherViews];
	[self hideAxButtons:NO];
	
	if ([r_groupIDArray count]==0) {
		r_categoryContainer.view.hidden = YES;
	}
	
	[self initTopBar];
	r_navigationBar.alpha = 0.0;
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(quizletSetPop:) name:@"quizletAdded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(quizletSetAdded:) name:@"SetAdded" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(itunesSetPop:) name:@"itunesAdded" object:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(upgrade:)
												 name:@"upgrade"
											   object:nil];
    
   	r_isEdit = FALSE;
    r_editWithCurId  = NO;
	[UIApplication sharedApplication].statusBarHidden = NO;
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AddSet21" ofType:@"wav"]], &addSetID);
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    NSLog(@"present screen dimensions %f%f",screenWidth,screenHeight);
    
    if (![Util isFullVersion]) {
        _advTimer = 0;
		if ([Util isPhone]) {
            [[FAdMobController sharedAdMobController:self] loadAdMob:1];
		}else {
            [[FAdMobController sharedAdMobController:self] loadAdMob:1];
		}
        
		
	}
    
    
	[super viewDidLoad];
	
	[self performSelector:@selector(showContent) withObject:nil afterDelay:0.5f];
	
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(shouldAutorotate)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];

	
}

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    return UIInterfaceOrientationMaskLandscape ;
//}
-(BOOL)shouldAutorotate
{
    if (UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation])) return YES;
    else return NO;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskLandscape ;
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return UIInterfaceOrientationMaskLandscape ;


}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	
//	if ([Util isPhone]) {
//		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//	}else {
//		return YES;
//	}
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
-(void)viewWillAppear:(BOOL)animated{
    
    [self supportedInterfaceOrientations];
    
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cardUpdateTextPosition" object:nil];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
	if (![Util isPhone]) {
		[r_categoryContainer rotateView:interfaceOrientation];
        
		if (r_upgradeButton) {
            UIImage *upgradeImage = [UIImage imageNamed:@"upgrade_1.png"];
            if (isButtonHidden) {
                if ([Util isPortraitWithOrientation:interfaceOrientation]) {
                    r_upgradeButton.center = CGPointMake(-upgradeImage.size.width,1004-upgradeImage.size.height/2.0-10);
                }else {
                    r_upgradeButton.center = CGPointMake(-upgradeImage.size.width,748-upgradeImage.size.height/2.0-10);
                }
            }else{
                if ([Util isPortraitWithOrientation:interfaceOrientation]) {
                    r_upgradeButton.center = CGPointMake(10+upgradeImage.size.width/2.0,1004-upgradeImage.size.height/2.0-10);
                }else {
                    r_upgradeButton.center = CGPointMake(10+upgradeImage.size.width/2.0,748-upgradeImage.size.height/2.0-10);
                }
            }
			
		}
        
		if (r_aboutButton) {
			UIImage *infoImage = [UIImage imageNamed:@"info1.png"];
            if (isButtonHidden) {
                if ([Util isPortraitWithOrientation:interfaceOrientation]) {
                    r_aboutButton.center = CGPointMake(768+infoImage.size.width,1004-infoImage.size.height/2.0-10);
                }else {
                    r_aboutButton.center = CGPointMake(1024+infoImage.size.width,748-infoImage.size.height/2.0-10);
                }
            }else{
                if ([Util isPortraitWithOrientation:interfaceOrientation]) {
                    r_aboutButton.center = CGPointMake(768-infoImage.size.width/2.0-10,1004-infoImage.size.height/2.0-10);
                }else {
                    r_aboutButton.center = CGPointMake(1024-infoImage.size.width/2.0-10,748-infoImage.size.height/2.0-10);
                }
            }
		}
		
//		UIView *aboutView = [self.view.window viewWithTag:-888];
//		
//		if (aboutView) {
//			if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//				aboutView.transform = CGAffineTransformMakeRotation(-M_PI_2);
//            }
//			} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//				aboutView.transform = CGAffineTransformMakeRotation(M_PI_2);
//			} else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
//				aboutView.transform = CGAffineTransformMakeRotation(0);
//			} else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
//				aboutView.transform = CGAffineTransformMakeRotation(M_PI);
//			}
		//}
		
        
        if ([Util isPortraitWithOrientation:interfaceOrientation]) {
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelport_bg.png"];
            r_bgPortView.alpha = 1.0;
            r_bgLandView.alpha = 0.0;
        }else{
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
            r_bgPortView.alpha = 0.0;
            r_bgLandView.alpha = 1.0;
        }
		
		if (![Util isFullVersion]) {
            [self hideAdv:NO];
		}
		
		[self reshapeTriangleShape];
		
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (![Util isPhone]) {
		if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
			UIPopoverArrowDirection arrowDirection = r_popoverContoller.popoverArrowDirection;
			[r_popoverContoller dismissPopoverAnimated:NO];
			CGRect frame = [self popoverFrame:self.interfaceOrientation forState:r_popoverState];
			
			if (r_popoverState != RIPopoverStateAddCategory) {
				
				if (r_popoverState == RIPopoverStateAddCard) {
					UINavigationController *contentNavigation = (UINavigationController*)r_popoverContoller.contentViewController;
					
					if (contentNavigation.topViewController) {
						if ([contentNavigation.topViewController isKindOfClass:[FIFlickerViewController class]]) {
							[r_popoverContoller setPopoverContentSize:CGSizeMake(540.0,615.0)];
							FIFlickerViewController *flick = (FIFlickerViewController*)contentNavigation.topViewController;
							[flick dismissPopover:NO];
						}
						
						if ([contentNavigation.topViewController isKindOfClass:[FDrawController class]]) {
							[r_popoverContoller setPopoverContentSize:CGSizeMake(500.0,635.0)];
						}
					}
				}
				
                switch (r_popoverState) {
                    case RIPopoverStateGroup:
                        arrowDirection = UIPopoverArrowDirectionUp;
                        break;
                    case RIPopoverStateSettings:
                        arrowDirection = UIPopoverArrowDirectionLeft;
                        break;
                    case RIPopoverStateAddCard:
                        arrowDirection = UIPopoverArrowDirectionRight;
                        break;
                    default:
                        break;
                }
                
				[r_popoverContoller presentPopoverFromRect:frame
													inView:self.view
								  permittedArrowDirections:arrowDirection
												  animated:NO];
			}else {
				[r_popoverContoller presentPopoverFromBarButtonItem:r_addButton
										   permittedArrowDirections:UIPopoverArrowDirectionUp
														   animated:NO];
			}
			
			if (self.presentedViewController) {
				id cont = self.presentedViewController;
				[cont dismissViewControllerAnimated:NO completion:nil];
				[self presentViewController:cont animated:NO completion:nil];
			}
			
		}
		
		
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[r_categoryContainer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AudioServicesDisposeSystemSoundID(addSetID);
	if (r_currentSelectedRow) {
        [r_currentSelectedRow release];
    }
	
	if (r_category) {
		[r_category release];
	}
	
	if (r_groupIDArray) {
		[r_groupIDArray release];
	}
	
	if (r_popoverContoller) {
		[r_popoverContoller release];
	}
	
	if (r_term) {
		[r_term release];
	}
	
	if (r_popoverBgView) {
		[r_popoverBgView release];
	}
	
	[r_addButton release];
	[r_editButton release];
	
    [super dealloc];
}

-(void)importTerm:(NSString*)term{
	
	if ([r_categoryContainer currentCategoryId] && ![self.navigationController.topViewController isKindOfClass:[FIBoxSceneViewController class]]) {
		
        
        if ([self.navigationController.topViewController isKindOfClass:[FISceneViewController class]]) {
            
            if (r_term) {
                [r_term release];
            }
            
            r_term = [[NSString alloc] initWithString:term];
            
            FISceneViewController *sceneController = (FISceneViewController*)self.navigationController.topViewController;
            [sceneController addCardWithText:r_term];
        }else if([self.navigationController.topViewController isKindOfClass:[FIExportViewController class]] || [self.navigationController.topViewController isKindOfClass:[FIAboutController class]] || [self.navigationController.topViewController isKindOfClass:[RIMainViewCotroller class]]){
            
            if (r_term) {
                [r_term release];
            }
            
            r_term = [[NSString alloc] initWithString:term];
            
            if (![self.navigationController isKindOfClass:[RIMainViewCotroller class]]) {
                [self.navigationController popViewControllerAnimated:NO];
            }
            FICardEditController *editController = [[FICardEditController alloc] initWithType:FIEditCardTypeUpdate
                                                                                  forCategory:[r_categoryContainer currentCategoryId]
                                                                                       forArg:[NSDictionary dictionaryWithObject:r_term forKey:@"question"]];
            editController.delegate = self;
            [r_categoryContainer hideCard:FICardPositionRight hidden:YES];
            if ([Util isPhone]) {
                editController.orientation = FIOrientationLandscape;
                [self.navigationController pushViewController:editController animated:YES];
            }else{
                //TODO IPAD
            }
            [editController release];
        }
	}
}

-(void)enterToBackground
{
	if ([self.navigationController.topViewController isKindOfClass:[FIBoxSceneViewController class]]) {
		FIBoxSceneViewController *scene = (FIBoxSceneViewController*)self.navigationController.topViewController;
		[scene pauseTest];
	}else if ([self.navigationController.topViewController isKindOfClass:[FBoxSceneController class]]) {
		FBoxSceneController *scene = (FBoxSceneController*)self.navigationController.topViewController;
		[scene pauseTest];
	}
}

-(NSDictionary*)infoForCurrentCategory{
    NSString *setId = [r_categoryContainer currentCategoryId];
    
    if (setId) {
        NSString *setName = [[FDBController sharedDatabase] nameForCategory:setId];
        NSInteger testNum = [[FDBController sharedDatabase] getTestNumForCategory:setId];
        NSInteger studyNum = 0;
        BOOL isSessionOpened = [[FDBController sharedDatabase] isSessionOpened:setId];
        BOOL allLearned = [[FDBController sharedDatabase] isAllLearned:setId];
        NSDictionary *learnDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:setName,[NSNumber numberWithInt:testNum+studyNum],[NSNumber numberWithBool:isSessionOpened],[NSNumber numberWithBool:allLearned], nil]
                                                             forKeys:[NSArray arrayWithObjects:@"name",@"learnCount",@"isSO",@"isAL", nil]];
        return learnDic;
    }
    
    return  nil;
}

-(void)makeActive
{
	[r_categoryContainer updateTestInfoLabel:FICardPositionLeft];
	[r_categoryContainer updateTestInfoLabel:FICardPositionCenter];
	[r_categoryContainer updateTestInfoLabel:FICardPositionRight];
}

-(void)termination
{
	if (r_group) {
		[[NSUserDefaults standardUserDefaults] setObject:r_group forKey:@"DefaultGroup"];
	}
}

-(NSString*)getCurrentGroup{
    return r_group;
}

-(void)reloadCurrentGroup:(NSString*)gId category:(NSString*)categoryName{
    if ([r_groupIDArray count]==0) {
        if (r_group) {
            [r_group release];
        }
        
        r_group = [[NSString alloc] initWithString:gId];
        r_categoryContainer.view.hidden = NO;
        r_navigationBar.titleLabel.text = [NSString stringWithString:categoryName];
        [r_groupIDArray addObject:[NSArray arrayWithObjects:gId,categoryName,nil]];
        [self sortGroupArray];
        [self reshapeTriangleShape];
    }
    [r_categoryContainer changeCategories:[self createCategoryContent]];
    [self enableAddButton:YES];
    [self enableEditButton:YES];
    
}

#pragma mark main methods

#pragma mark -
#pragma mark FISceneViewControllerDelegate

-(void)stateChanged
{
	NSString *categoryId = [r_categoryContainer currentCategoryId];
	
	if (categoryId) {
		NSDictionary *category = [self createContentForCategory:categoryId];
		[r_categoryContainer updateCurrentCategory:category];
	}
	
}

-(NSDictionary*)viewingDidEnd:(BOOL)isEmpty forCategory:(NSString*)categoryId
{
	if (!isEmpty) {
		NSDictionary *dic = [self createContentForCategory:categoryId];
		[r_categoryContainer updateCurrentCategory:dic];
		if ([Util isPhone]) {
            self.view.userInteractionEnabled = NO;
			[self performSelector:@selector(restoreController)
					   withObject:nil
					   afterDelay:1.1f];
		}else {
            self.view.userInteractionEnabled = YES;
			[self performSelector:@selector(restoreIPadAfterScene)
					   withObject:nil
					   afterDelay:1.1f];
		}
        
		return dic;
	}else {
		[r_categoryContainer setCenterCardHidden:YES];
		[r_categoryContainer setTitleHidden:NO animated:NO];
		[r_categoryContainer makeCenter:NO animated:NO];
		[r_categoryContainer hideButtons:NO animated:NO];
		[r_categoryContainer hideInfoLabel:NO animated:NO];
		[r_categoryContainer wrapBgDeckView:NO animated:NO];
		self.view.userInteractionEnabled = NO;
		[self performSelector:@selector(restoreControllerAnimated)
				   withObject:nil
				   afterDelay:1.1f];
	}
    
	
	return nil;
}

-(void)sceneViewWasRotated:(UIInterfaceOrientation)orientation
{
	if (![Util isFullVersion]) {
		[self hideAdv:YES];
	}
    
    if ([Util isPortrait:self]) {
        r_bgLandView.alpha = 0.0;
        r_bgPortView.alpha = 1.0;
    }else{
        r_bgPortView.alpha = 0.0;
        r_bgLandView.alpha = 1.0;
    }
    
	[self hideAxButtons:NO];
	[r_categoryContainer rotateView:orientation];
	[r_categoryContainer makeIpadSceneCenter:YES animated:NO];
	[self reshapeTriangleShape];
}

#pragma mark FISceneViewControllerDelegate ends

#pragma mark -
#pragma mark FIBoxSceneViewController delegate

-(void)learningWillEnd:(NSString*)categoryId animated:(BOOL)isAnimate
{
    if (isAnimate) {
        [[FDBController sharedDatabase] changeSessionState:0 forSet:categoryId];
    }
    
	if (categoryId) {
		NSDictionary *dic = [self createContentForCategory:categoryId];
		[r_categoryContainer updateCurrentCategory:dic];
	}
	
	if (isAnimate) {
        [r_categoryContainer setCenterCardHidden:YES];
		[r_categoryContainer hideButtons:NO animated:NO];
		[r_categoryContainer makeCenter:NO animated:NO];
		[r_categoryContainer setTitleHidden:NO animated:NO];
		[r_categoryContainer hideInfoLabel:NO animated:NO];
		[r_categoryContainer wrapBgDeckView:NO animated:NO];
		self.view.userInteractionEnabled = NO;
		[self performSelector:@selector(restoreControllerAnimated)
				   withObject:nil
				   afterDelay:1.0f];
	}else {
		self.view.userInteractionEnabled = NO;
		[self performSelector:@selector(restoreController)
				   withObject:nil
				   afterDelay:1.0f];
	}
    
    if (![Util isFullVersion]) {
        if (_advTimer==2) {
            [[FAdMobController sharedAdMobController:self] requestForFullScreen:0];
        }
        _advTimer = (_advTimer+1)%3;
    }
	
	
}

-(void)rotated:(UIInterfaceOrientation)orientation
{
	if (![Util isFullVersion]) {
		[self hideAdv:YES];
	}
    
    if ([Util isPortrait:self]) {
        r_bgLandView.alpha = 0.0;
        r_bgPortView.alpha = 1.0;
    }else{
        r_bgPortView.alpha = 0.0;
        r_bgLandView.alpha = 1.0;
    }
    
	[self hideAxButtons:NO];
	[r_categoryContainer rotateView:orientation];
	[r_categoryContainer makeCenter:YES animated:NO];
	[self reshapeTriangleShape];
}

#pragma mark FIBoxSceneViewController delegate ends




#pragma mark -
#pragma mark RICategoryContainerDelegate

-(void)selectedCategory:(NSString*)category
{
	if (category) {
		
		if (r_category) {
			[r_category release];
		}
		
		r_category = [[NSString alloc] initWithString:category];
		
		NSInteger numOfCards = [[FDBController sharedDatabase] getNumberOfItems:r_category];
		
		if (numOfCards>0) {
			
			[self prepareToChanges:YES];
			[self performSelector:@selector(loadController)
					   withObject:nil
					   afterDelay:0.25f];
		}else {
            [self addCardSelected:r_category];
		}
        
	}
	
	
}

-(void)addCardSelected:(NSString*)category
{
	if (category) {
		FICardEditController *addController = [[FICardEditController alloc] initWithType:FIEditCardTypeAdd
																			 forCategory:category
																				  forArg:nil];
		addController.delegate = self;
		[r_categoryContainer hideCard:FICardPositionRight hidden:YES];
		if ([Util isPhone]) {
			
			addController.orientation = FIOrientationLandscape;
			[self.navigationController pushViewController:addController animated:YES];
            
		}else {
			UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:addController];
			navController.navigationBar.topItem.title = @"Add card";
			
			if (r_popoverContoller) {
				[r_popoverContoller release];
				r_popoverContoller = nil;
			}
			
			r_popoverContoller = [[UIPopoverController alloc] initWithContentViewController:navController];
			r_popoverContoller.passthroughViews = [NSArray arrayWithObject:self.view];
			r_categoryContainer.view.userInteractionEnabled = NO;
			r_navigationBar.userInteractionEnabled = NO;
			addController.contentSizeForViewInPopover = CGSizeMake(500,256);
            [r_popoverContoller setPopoverContentSize:CGSizeMake(500, 290)];
			[r_popoverContoller presentPopoverFromRect:[self popoverFrame:self.interfaceOrientation forState:RIPopoverStateAddCard]
												inView:self.view
							  permittedArrowDirections:UIPopoverArrowDirectionRight
											  animated:YES];
			[navController release];
			r_popoverState = RIPopoverStateAddCard;
		}
		
		[addController release];
        
	}
}

-(void)settingsSelected:(NSString*)category
{
	if (category) {
		[r_categoryContainer hideCard:FICardPositionRight hidden:YES];
		if ([Util isPhone]) {
			FIExportViewController *exportController = [[FIExportViewController alloc] init];
			exportController.categoryToExport = category;
            exportController.group = r_group;
			exportController.delegate = self;
			[self.navigationController pushViewController:exportController
												 animated:YES];
			[exportController release];
		}else {
			FExportBaseController *exportController = [[FExportBaseController alloc] init];
			[exportController exportCategory:category group:r_group];
			exportController.delegate = self;
			
			if (r_popoverContoller) {
				if([r_popoverContoller isPopoverVisible])
					[r_popoverContoller dismissPopoverAnimated:NO];
				[r_popoverContoller release];
			}
            
			r_popoverContentID = kPContentNone;
			r_popoverContoller = [[UIPopoverController alloc] initWithContentViewController:exportController];
			r_popoverContoller.popoverContentSize = CGSizeMake(400,450);
            r_popoverContoller.delegate = self;
			[r_popoverContoller presentPopoverFromRect:[self popoverFrame:self.interfaceOrientation forState:RIPopoverStateSettings]
												inView:self.view
							  permittedArrowDirections:UIPopoverArrowDirectionLeft
											  animated:YES];
			[exportController release];
			r_popoverState = RIPopoverStateSettings;
			
		}
        
	}
}

-(void)renameCategory:(NSString*)categoryId forName:(NSString*)categoryName
{
	if (categoryId && categoryName) {
		[[FDBController sharedDatabase] renameCategory:categoryId forNewName:categoryName];
	}
	
    
}

-(void)removeCategory:(NSString*)categoryId
{
	if (categoryId) {
		[[FDBController sharedDatabase] removeCategory:categoryId fromGroup:r_group];
		[Util removeAllImages:categoryId];
		[Util removeAllSounds:categoryId];
		
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@Font",categoryId]];
        
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastTest%@",categoryId]];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastStudy%@",categoryId]];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_ignored",categoryId]];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Setings",categoryId]];
		
	}
	
    [self enableAddButton:YES];
    
}

-(void)didEditStart
{
	if (!r_isEdit) {
		r_isEdit = YES;
		if (![Util isPhone]) {
			r_editButton.style = UIBarButtonItemStyleDone;
			r_editButton.title = @"Done";
		}else {
			UIButton *editButton = (UIButton*)r_editButton.customView;
			[editButton setImage:[UIImage imageNamed:@"i_panel_done1.png"] forState:UIControlStateNormal];
			[editButton setImage:[UIImage imageNamed:@"i_panel_done2.png"] forState:UIControlStateHighlighted];
		}
        
		[self enableAddButton:NO];
	}
    
}

-(void)didEditEnd
{
	if (r_isEdit) {
		r_isEdit = NO;
		if (![Util isPhone]) {
			r_editButton.style = UIBarButtonItemStyleBordered;
			r_editButton.title = @"Edit";
		}else {
			UIButton *editButton = (UIButton*)r_editButton.customView;
			[editButton setImage:[UIImage imageNamed:@"i_panel_edit1.png"] forState:UIControlStateNormal];
			[editButton setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
		}
        
		[self enableAddButton:YES];
	}
}

-(NSDictionary*)infoForSetId:(NSString*)setId
{
	if (!setId) {
		return nil;
	}
	
	NSInteger tC = [[FDBController sharedDatabase] getTestNumForCategory:setId];
	NSInteger sC = 0;
    BOOL isSessionOpened = [[FDBController sharedDatabase] isSessionOpened:setId];
    BOOL allLearned = [[FDBController sharedDatabase] isAllLearned:setId];
	NSInteger count = [[FDBController sharedDatabase] getNumberOfItems:setId];
	NSInteger diff = [[FDBController sharedDatabase] learnedCards:setId];
	
	NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
	[infoDic setObject:[NSNumber numberWithInt:tC] forKey:@"test"];
	[infoDic setObject:[NSNumber numberWithInt:sC] forKey:@"study"];
	[infoDic setObject:[NSNumber numberWithInt:count] forKey:@"count"];
	[infoDic setObject:[NSNumber numberWithInt:diff] forKey:@"diff"];
    [infoDic setObject:[NSNumber numberWithBool:isSessionOpened] forKey:@"isSO"];
    [infoDic setObject:[NSNumber numberWithBool:allLearned] forKey:@"isAL"];
	
	return infoDic;
}

-(void)groupIsLoaded{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    [self performSelector:@selector(changeMode:) withObject:nil afterDelay:0.0f];
    [self reshapeTriangleShape];
}

#pragma mark RICategoryContainerDelegate ends

#pragma mark -
#pragma mark RITableListView delegate

-(void)leftButtonPressed:(RITableListView*)list
{
	if (list.tag == RITableListViewTypeGroup) {
		FTextAlertView *addAlert = [[FTextAlertView alloc] init];
    
        
		addAlert.delegate = self;
		addAlert.tag = kAlertAdd;
		[addAlert show];
		[addAlert release];
        
	}else {
		
		if ([Util isPhone]) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_groupView
															toPoint:CGPointMake(240,
																				478.0)];
			[r_groupView performSelector:@selector(removeFromSuperview)
							  withObject:nil
							  afterDelay:0.25f];
		}else {
			[self dismissViewControllerAnimated:YES completion:nil];
		}
        
	}
    
}

-(void)rightButtonPressed:(RITableListView*)list
{
	if ([r_groupView.r_tableView isEditing]) {
		[r_groupView.r_tableView setEditing:NO animated:YES];
        UIButton *editButton = (UIButton*)r_groupView.r_rightButton.customView;
		if (editButton) {
			[editButton setImage:[UIImage imageNamed:@"i_panel_edit1.png"] forState:UIControlStateNormal];
			[editButton setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
		}
	}else {
		[r_groupView.r_tableView setEditing:YES animated:YES];
		UIButton *editButton = (UIButton*)r_groupView.r_rightButton.customView;
		if (editButton) {
			[editButton setImage:[UIImage imageNamed:@"i_panel_done1.png"] forState:UIControlStateNormal];
			[editButton setImage:[UIImage imageNamed:@"i_panel_done2.png"] forState:UIControlStateHighlighted];
		}
	}
	
	if (![r_groupView.r_tableView isEditing]) {
		if (r_currentSelectedRow) {
			[r_groupView.r_tableView selectRowAtIndexPath:r_currentSelectedRow
												 animated:YES
										   scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

-(void)topBarPressed:(RITableListView*)list
{
	if (list.tag == RITableListViewTypeGroup) {
		[self changeMode:nil];
	}
}

#pragma mark RITableListView delegate ends

#pragma mark -
#pragma mark FIExportViewController delegate

-(void)reloadCurrentCategory:(NSString*)categoryId
{
	if (categoryId) {
		NSDictionary *category = [self createContentForCategory:categoryId];
		[r_categoryContainer updateCurrentCategory:category];
	}
}

#pragma mark FIExportViewController delegate ends

#pragma mark -
#pragma mark RIChooseGroup delegate

-(void)movedTo:(NSString*)gid{
    [[FDBController sharedDatabase] transmitCategory:[r_categoryContainer currentCategoryId]
                                           fromGroup:r_group
                                             toGroup:gid];
    [r_categoryContainer performSelector:@selector(removeCurrentSetFromList) withObject:nil afterDelay:0.25f];
    if ([Util isPhone]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self dismissModalViewControllerAnimated:YES];
    }
    
    [self enableAddButton:YES];
}

#pragma mark -

#pragma mark -
#pragma mark IPadAboutControllerDelegate delegate

-(void)aboutClosed:(AboutViewController*)about
{
	UIView *blackView = [self.view.window viewWithTag:-777];
	
	[UIView beginAnimations:nil context:about];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.3f];
	
	
	if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationPortrait) {
		[about.view setOrigin:CGPointMake((768 - about.view.frame.size.width)/2, 1024.0f)];
	} else if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
		[about.view setOrigin:CGPointMake((768 - about.view.frame.size.width)/2, -about.view.frame.size.height)];
	} else if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
		[about.view setOrigin:CGPointMake(768.0f, (1024 - about.view.frame.size.height)/2)];
	} else if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
		[about.view setOrigin:CGPointMake(-about.view.frame.size.width, (1024 - about.view.frame.size.height)/2)];
	}
	
	blackView.alpha = 0.0f;
	
	[UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	AboutViewController *about = (AboutViewController*)(context);
	UIView *blackView = [self.view.window viewWithTag:-777];
	[about.view removeFromSuperview];
	[about release];
    
	[blackView removeFromSuperview];
	[blackView release];
	
}

#pragma mark IPadAboutControllerDelegate delegate ends

#pragma mark -
#pragma mark FIEditCardController delegate

-(void)cardAdded:(NSInteger)cardId
{
	NSString *categoryId = [r_categoryContainer currentCategoryId];
	
	if (categoryId) {
		NSDictionary *category = [self createContentForCategory:categoryId];
		[r_categoryContainer updateCurrentCategory:category];
	}
}

#pragma mark FIEditCardController delegate ends

#pragma mark -
#pragma mark myAdView delegate

-(void)iAdRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [self hideAdv:NO];
    }
}

-(void)adMobRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [self hideAdv:NO];
    }
}

-(void)gAdRecievedSuccessfully{
    if (adView && adView.hidden) {
        adView.hidden = NO;
        [self hideAdv:NO];
    }
}


-(void)iAdFailed{
    [adView tryGAD:GAD_SIZE_320x50];
    
}

-(void)adMobFailed{
    
}

-(void)gAdFailed{
}

#pragma mark -
#pragma mark FUpgradeManagerDelegate

-(void)upgradeFinished:(BOOL)result
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([Util isFullVersion]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"upgraded" object:nil];
	}
	
	
	if ([Util isFullVersion]) {
		[self upgradeControlToFullVersion];
	}else {
		r_upgradeButton.enabled = YES;
	}
    
	
	
}

#pragma mark FUpgradeManager delegate ends

#pragma mark -
#pragma mark FIAnimationController delegate

-(void)didEndAnimation
{
	if (r_animationID == 11) {
		[self loadController];
	}
}

#pragma mark FIAnimationController delegate ends

#pragma mark -
#pragma mark RITableListView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView.tag == RITableListViewTypeGroup) {
		if (r_groupIDArray) {
			return [r_groupIDArray count];
		}
	}else {
		return [[self supportedTemplates] count];
	}
    
	
	return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"TableListCell";
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (!cell) {
		if (tableView.tag == RITableListViewTypeGroup) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:CellIdentifier] autorelease];
            
            UIImageView *bgView = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"i_list_bg.png"]];
            UIImageView *bgViewHighlighted = [[UIImageView alloc] initWithImage:[Util imageFromBundle:@"i_list_bg_active.png"]];
            cell.selectedBackgroundView = bgViewHighlighted;
            cell.backgroundView = bgView;
            [bgView release];
            [bgViewHighlighted release];
            
            UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *accessoryImage = [Util imageFromBundle:@"i_list_edit1.png"];
            accessoryButton.frame = CGRectMake(0, 0, accessoryImage.size.width, accessoryImage.size.height);
            [accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
            [accessoryButton setImage:[Util imageFromBundle:@"i_list_edit2.png"] forState:UIControlStateHighlighted];
            [accessoryButton addTarget:self
                                action:@selector(cellAccessoryButtonPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = accessoryButton;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
            
            
            
		}else {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
										   reuseIdentifier:CellIdentifier] autorelease];
		}
    }
    
	if (tableView.tag == RITableListViewTypeGroup) {
        UIButton *accessoryButton = (UIButton*)cell.accessoryView;
        accessoryButton.tag = indexPath.row;
		NSArray *infoForSet = [r_groupIDArray objectAtIndex:indexPath.row];
		NSString *name = [NSString stringWithString:[infoForSet objectAtIndex:1]];
		NSString *groupId = [NSString stringWithString:[infoForSet objectAtIndex:0]];
        
		NSInteger numOfSets = [[FDBController sharedDatabase] numOfItemsInGroup:groupId];
        
		cell.textLabel.text = name;
        NSLog(@"category name %@",name);
        
		if (numOfSets>1) {
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sets",numOfSets];
		}else if (numOfSets==1) {
			cell.detailTextLabel.text = @"1 set";
		}else {
			cell.detailTextLabel.text = @"No set";
		}
        
		if (r_group && [r_group isEqualToString:groupId]) {
            if ([Util isPhone]) {
                UIButton *accessoryButton = (UIButton*)cell.accessoryView;
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit3.png"] forState:UIControlStateNormal];
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit3.png"] forState:UIControlStateHighlighted];
            }
			[tableView selectRowAtIndexPath:indexPath
								   animated:NO
							 scrollPosition:UITableViewScrollPositionNone];
            
            if (r_currentSelectedRow) {
                [r_currentSelectedRow release];
            }
            
			r_currentSelectedRow = [[NSIndexPath indexPathForRow:indexPath
                                                       inSection:indexPath.section] retain];
            
            
		}else{
            if ([Util isPhone]) {
                UIButton *accessoryButton = (UIButton*)cell.accessoryView;
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit1.png"] forState:UIControlStateNormal];
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit2.png"] forState:UIControlStateHighlighted];
            }
        }
	}else {
		cell.textLabel.text = [[self supportedTemplates] objectAtIndex:indexPath.row];
	}
    
    
	
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView.tag == RITableListViewTypeGroup) {
		if (r_currentSelectedRow && r_currentSelectedRow.row == indexPath.row) {
            if ([Util isPhone]) {
                [self performSelector:@selector(changeMode:)
                           withObject:nil
                           afterDelay:0.25];
            }else{
                [self changeMode:nil];
            }
			
			return;
		}
        
		NSArray *infoForSet = [r_groupIDArray objectAtIndex:indexPath.row];
		NSString *groupId = [NSString stringWithString:[infoForSet objectAtIndex:0]];
        
		if (r_group) {
			[r_group release];
		}
        
		r_group = [[NSString alloc] initWithString:groupId];
        r_navigationBar.titleLabel.text = [NSString stringWithString:[infoForSet objectAtIndex:1]];
		if (r_currentSelectedRow) {
			[tableView deselectRowAtIndexPath:r_currentSelectedRow animated:YES];
            if ([Util isPhone]) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:r_currentSelectedRow];
                UIButton *accessoryButton = (UIButton*)cell.accessoryView;
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit1.png"] forState:UIControlStateNormal];
                [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit2.png"] forState:UIControlStateHighlighted];
            }
		}
        
        if ([Util isPhone]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIButton *accessoryButton = (UIButton*)cell.accessoryView;
            [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit3.png"] forState:UIControlStateNormal];
            [accessoryButton setImage:[UIImage imageNamed:@"i_list_edit3.png"] forState:UIControlStateHighlighted];
        }
        
        if (r_currentSelectedRow) {
            [r_currentSelectedRow release];
        }
        
		r_currentSelectedRow = [[NSIndexPath indexPathForRow:indexPath.row
                                                   inSection:indexPath.section] retain];
        [UIApplication sharedApplication].keyWindow.userInteractionEnabled = NO;
        [r_categoryContainer performSelector:@selector(changeCategoriesWithFeedBack:)
                                  withObject:[self createCategoryContent]
                                  afterDelay:0.0];
        
    }else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		
		if ([Util isPhone]) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_groupView
															toPoint:CGPointMake(240,
																				458.0)];
			[r_groupView performSelector:@selector(removeFromSuperview)
							  withObject:nil
							  afterDelay:0.25f];
		}else {
			[self dismissModalViewControllerAnimated:YES];
		}
		
		NSInteger template = 0;
		
		switch (indexPath.row) {
			case 0:
				template = kBackTextTemplate | kFrontAudioTemplate | kAudioTemplate;
				break;
			case 1:
				template = kCustomTemplate;
				break;
			case 2:
				template = kFrontTextTemplate | kBackTextTemplate | kDefinitionTemplate | kWebTemplate;
				break;
			case 3:
				template = kFrontTextTemplate | kBackTextTemplate | kTranslateTemplate;
				break;
			case 4:
				template = kBackTextTemplate | kFrontPicTemplate | kImageTemplate | kWebTemplate;
				break;
                
			default:
				break;
		}
		
		[self createEmptySet:@"" template:template];
	}
    
	
}
- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *infoForSet = [r_groupIDArray objectAtIndex:indexPath.row];
    NSString *groupId = [NSString stringWithString:[infoForSet objectAtIndex:0]];
    
    [r_groupIDArray removeObjectAtIndex:indexPath.row];
    
    NSMutableArray *sets = [[FDBController sharedDatabase] getCategoriesForGroup:groupId];
    
    for (NSString *set in sets) {
        [[FDBController sharedDatabase] removeCategory:set];
        [Util removeAllImages:set];
        [Util removeAllSounds:set];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastTest%@",set]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastStudy%@",set]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_ignored",set]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Setings",set]];
    }
    
    [[FDBController sharedDatabase] removeGroup:groupId];
    NSString *defaultGroup = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultGroup"];
    if (defaultGroup && [defaultGroup isEqualToString:groupId]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DefaultGroup"];
    }
    
    [tableView beginUpdates];
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView endUpdates];
    
    
    if (r_group && [r_group isEqualToString:groupId]) {
        [r_group release];
        r_group = nil;
        if (r_currentSelectedRow) {
            [r_currentSelectedRow release];
            r_currentSelectedRow = nil;
        }
        
        
        if (r_groupIDArray && [r_groupIDArray count]>0) {
            infoForSet = [r_groupIDArray objectAtIndex:0];
            r_group = [[NSString alloc] initWithString:[infoForSet objectAtIndex:0]];
            [r_categoryContainer changeCategories:[self createCategoryContent]];
            r_navigationBar.titleLabel.text = [NSString stringWithString:[infoForSet objectAtIndex:1]];
            
            r_currentSelectedRow = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
        }else {
            [r_categoryContainer changeCategories:[NSMutableArray array]];
            r_categoryContainer.view.hidden = YES;
            r_navigationBar.titleLabel.text = @"Create category";
            r_groupView.r_rightButton.enabled = NO;
            [r_groupView.r_tableView setEditing:NO animated:NO];
        }
        [self reshapeTriangleShape];
        
    }
    
    
    if(sets)
        [sets release];

//    if (editingStyle==UITableViewCellEditingStyleDelete) {
//            categoryIndexPath =indexPath.row;
//        myTableView=[r_groupView.r_tableView retain];
//        NSLog(@"categoryIndexPath %d",categoryIndexPath);
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                            message:@"Are you sure you want to delete?"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"No"
//                                                  otherButtonTitles:@"Yes",nil];
//            alert.tag = KAlerTDeleteCategory;
//            [alert show];
//            [alert release];
//    }

   // NSLog(@"%@roupid array %@",r_groupIDArray);
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
	return index;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	NSArray *group = [r_groupIDArray objectAtIndex:indexPath.row];
	NSString *name = [NSString stringWithString:[group objectAtIndex:1]];
	r_changedIndex = indexPath.row;
	
	FTextAlertView *addAlert = [[FTextAlertView alloc] init];
	addAlert.delegate = self;
   
    
	addAlert.nameField.text = name;
    
	addAlert.tag = kAlertEdit;
	[addAlert show];
	[addAlert release];
	
}

-(void)cellAccessoryButtonPressed:(id)sender{
    UIButton *accessoryButton = (UIButton*)sender;
    [self tableView:nil accessoryButtonTappedForRowWithIndexPath:[NSIndexPath indexPathForRow:accessoryButton.tag inSection:0]];
}

#pragma mark RITableListView delegate ends

#pragma mark -
#pragma mark FTextAlertViewDelegate

- (void)alertView:(FTextAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag) {
		case kAlertQuizlet:
		{
			if (buttonIndex!=0) {
				[self dismissModalViewControllerAnimated:YES];
			}
			
			break;
		}
		case kAlertAdd:
		{
            NSString *newCategory ;
			if (buttonIndex != 0) {
   		     
                newCategory = [alertView name];
   
				if (newCategory != nil) {
                    
					NSString *groupId =	[[FDBController sharedDatabase] addGroup:newCategory];
                    
					if (groupId) {
                        
                        
						if ([r_groupIDArray count]==0) {
							if (r_group) {
								[r_group release];
							}
                            
							r_group = [[NSString alloc] initWithString:groupId];
							[r_categoryContainer changeCategories:[self createCategoryContent]];
							r_categoryContainer.view.hidden = NO;
                            r_navigationBar.titleLabel.text = [NSString stringWithString:newCategory];
							r_groupView.r_rightButton.enabled = YES;
                            [self enableAddButton:YES];
                            [self enableEditButton:YES];
						}
						[r_groupIDArray addObject:[NSArray arrayWithObjects:groupId,newCategory,nil]];
						[self sortGroupArray];
						[r_groupView.r_tableView reloadData];
						[self reshapeTriangleShape];
					}
                
                }else
                {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"Can't Create Set with Empty Name"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    
                    [alert show];
                    [alert release];
                    
                }
            }
        
			break;
        
		}
		case kAlertEdit:
		{
			if (buttonIndex != 0) {
				NSString *newCategory = [alertView name];
				if (newCategory) {
					if (r_groupIDArray && r_changedIndex>=0 && r_changedIndex<[r_groupIDArray count]) {
						NSArray *group = [r_groupIDArray objectAtIndex:r_changedIndex];
						NSString *oldName = [NSString stringWithString:[group objectAtIndex:1]];
						NSString *groupId = [NSString stringWithString:[group objectAtIndex:0]];
                        
						if (![newCategory isEqualToString:oldName]) {
							[[FDBController sharedDatabase] renameGroup:groupId forNewName:newCategory];
                            r_navigationBar.titleLabel.text = newCategory;
                            
							if (r_currentSelectedRow) {
								[r_groupView.r_tableView deselectRowAtIndexPath:r_currentSelectedRow animated:YES];
							}
                            
							[r_groupIDArray removeObjectAtIndex:r_changedIndex];
							[r_groupIDArray addObject:[NSArray arrayWithObjects:groupId,newCategory,nil]];
							[self sortGroupArray];
							[r_groupView.r_tableView reloadData];
							[self reshapeTriangleShape];
						}
					}
				}
			}
			break;
		}
		case kAlertImportTerm:{
			if (buttonIndex != [alertView cancelButtonIndex]) {
				NSString *categoryId = [r_categoryContainer currentCategoryId];
				if (categoryId && r_term) {
					NSInteger cardId = [[FDBController sharedDatabase] addQuestionToCategory:categoryId question:r_term answer:@""];
					if (cardId>=0) {
						[r_categoryContainer updateCurrentCategory:[self createContentForCategory:categoryId]];
						NSArray *card = [NSArray arrayWithObjects:[NSNumber numberWithInt:cardId],r_term,@"",nil];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"importTerm" object:card];
					}else {
						[Util showMessage:@"Create card"
							   forMessage:@"Can't create card with this term"
						   forButtonTitle:@"OK"];
					}
                    
				}
			}
			break;
        }
        
        
        
        
        case KAlerTDeleteCategory:{
            NSArray *infoForSet = [r_groupIDArray objectAtIndex:categoryIndexPath];
            NSString *groupId = [NSString stringWithString:[infoForSet objectAtIndex:0]];
            
            [r_groupIDArray removeObjectAtIndex:categoryIndexPath];
            
            NSMutableArray *sets = [[FDBController sharedDatabase] getCategoriesForGroup:groupId];
            
            for (NSString *set in sets) {
                [[FDBController sharedDatabase] removeCategory:set];
                [Util removeAllImages:set];
                [Util removeAllSounds:set];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastTest%@",set]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"lastStudy%@",set]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_ignored",set]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_Setings",set]];
            }
            
            [[FDBController sharedDatabase] removeGroup:groupId];
            NSString *defaultGroup = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultGroup"];
            if (defaultGroup && [defaultGroup isEqualToString:groupId]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DefaultGroup"];
            }
            
            [myTableView beginUpdates];
            NSLog(@"categoryIndexPath %d",categoryIndexPath);
            [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:categoryIndexPath]
                                           withRowAnimation:UITableViewRowAnimationFade];
            
            [myTableView endUpdates];
           
            
            if (r_group && [r_group isEqualToString:groupId]) {
                [r_group release];
                r_group = nil;
                if (r_currentSelectedRow) {
                    [r_currentSelectedRow release];
                    r_currentSelectedRow = nil;
                }
                
                
                if (r_groupIDArray && [r_groupIDArray count]>0) {
                    infoForSet = [r_groupIDArray objectAtIndex:0];
                    r_group = [[NSString alloc] initWithString:[infoForSet objectAtIndex:0]];
                    [r_categoryContainer changeCategories:[self createCategoryContent]];
                    r_navigationBar.titleLabel.text = [NSString stringWithString:[infoForSet objectAtIndex:1]];
                    
                    r_currentSelectedRow = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
                }else {
                    [r_categoryContainer changeCategories:[NSMutableArray array]];
                    r_categoryContainer.view.hidden = YES;
                    r_navigationBar.titleLabel.text = @"Create category";
                    r_groupView.r_rightButton.enabled = NO;
                    [r_groupView.r_tableView setEditing:NO animated:NO];
                }
                [self reshapeTriangleShape];
                
            }
            
            
            if(sets)
                [sets release];
            

        
        
        break;
        }

            
		default:
			break;
	}
	
	
}

#pragma mark FTextAlertViewDelegate ends

#pragma mark -
#pragma mark init

-(void)initTopBar
{
	if ([Util isPhone]) {
		if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                r_navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
            }
            else{
                r_navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,568.0,40.0)];
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
                r_navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
            }
            else{
                r_navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,480.0,40.0)];
            }
            
            
        }
		r_navigationBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
	}else {
		r_navigationBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0.0,0.0,1024.0,50.0)];
        if ([Util isPortrait:self]) {
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelport_bg.png"];
        }else{
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
        }
        
    }
    
    CGRect titleFrame = r_navigationBar.titleLabel.frame;
    titleFrame.origin.y -= 3;
    
    r_navigationBar.titleLabel.frame = titleFrame;
	
	r_navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	NSString *titleStr = @"Create category";
    
	if (r_group) {
		titleStr = [[FDBController sharedDatabase] nameForGroup:r_group];
	}
	
	
	r_navigationBar.titleLabel.text = titleStr;
	r_navigationItem = [[UINavigationItem alloc] init];
	[r_navigationBar pushNavigationItem:r_navigationItem animated:NO];
	[r_navigationItem release];
	
	[self.view addSubview:r_navigationBar];
	[r_navigationBar release];
	
	//adding add button
	UIImage *addCustomItemImage;
    if ([Util isPhone]) {
        addCustomItemImage = [UIImage imageNamed:@"i_panel_plus1.png"];
    }else{
        addCustomItemImage = [UIImage imageNamed:@"ip_panel_plus1.png"];
    }
    
    
    UIButton *addCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
	addCustomItem.frame = CGRectMake(0,0,addCustomItemImage.size.width,addCustomItemImage.size.height);
    addCustomItem.exclusiveTouch = YES;
    
    if (![Util isPhone]) {
        [addCustomItem setImageEdgeInsets:UIEdgeInsetsMake(-6, 0, 6, 0)];
    }
    else{
        if (IS_IPHONE_5) {
            [addCustomItem setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
        }
        else{
            
        }
    }
    
	[addCustomItem setImage:addCustomItemImage forState:UIControlStateNormal];
    if ([Util isPhone]) {
        [addCustomItem setImage:[UIImage imageNamed:@"i_panel_plus2.png"] forState:UIControlStateHighlighted];
    }else{
        [addCustomItem setImage:[UIImage imageNamed:@"ip_panel_plus2.png"] forState:UIControlStateHighlighted];
    }
    [addCustomItem addTarget:self
					  action:@selector(addCategoryPressed:)
			forControlEvents:UIControlEventTouchUpInside];
	r_addButton = [[UIBarButtonItem alloc] initWithCustomView:addCustomItem];
    
	//adding edit button
	UIImage *editCustomItemImage;
    
    editCustomItemImage = [UIImage imageNamed:@"i_panel_edit1.png"];
	UIButton *editCustomItem = [UIButton buttonWithType:UIButtonTypeCustom];
    editCustomItem.exclusiveTouch = YES;
	editCustomItem.frame = CGRectMake(0,0,editCustomItemImage.size.width,editCustomItemImage.size.height);
	[editCustomItem setImage:editCustomItemImage forState:UIControlStateNormal];
	[editCustomItem setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
    
    if (![Util isPhone]) {
        [editCustomItem setImageEdgeInsets:UIEdgeInsetsMake(-6, 0, 6, 0)];
    }
    
	[editCustomItem addTarget:self
					   action:@selector(editCategoryPressed:)
			 forControlEvents:UIControlEventTouchUpInside];
	r_editButton = [[UIBarButtonItem alloc] initWithCustomView:editCustomItem];
    
	r_navigationItem.rightBarButtonItem = r_editButton;
	r_navigationItem.leftBarButtonItem = r_addButton;
	
	if (!r_group) {
		[self enableAddButton:NO];
		[self enableEditButton:NO];
	}
	
    UIView * tmpView;
	
	if ([Util isPhone]) {
		tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,200,40.0)];
		tmpView.center = CGPointMake(240.0,20.0);
	}else {
		tmpView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,400,44.0)];
		tmpView.center = CGPointMake(512.0,22.0);
	}
    
	tmpView.backgroundColor = [UIColor clearColor];
	
	UITapGestureRecognizer *changeModeTap = [[UITapGestureRecognizer alloc] initWithTarget:self
																					action:@selector(changeMode:)];
	[tmpView addGestureRecognizer:changeModeTap];
	
	[changeModeTap release];
	
	shape = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_panel_arrow1.png"]];
    
	[r_navigationBar addSubview:shape];
	[shape release];
	
	[self reshapeTriangleShape];
	
	[r_navigationBar addSubview:tmpView];
	[tmpView release];
	
}

-(void)initGroupView:(CGRect)frame tag:(RITableListViewType)viewType
{
	NSArray *titles = nil;
	if (viewType == RITableListViewTypeGroup) {
		titles = [NSArray arrayWithObjects:@"Add",@"Edit",nil];
	}else {
		titles = [NSArray arrayWithObjects:@"Cancel",nil];
	}
    
	
	r_groupView = [[RITableListView alloc] initWithFrame:frame
											 forDelegate:self
											  forBTitles:titles
				   								  forTag:viewType];
    
	if (viewType == RITableListViewTypeGroup && !r_group) {
		r_groupView.r_rightButton.enabled = NO;
	}
	
}

-(void)initOtherViews
{
	if (![Util isFullVersion]) {
		r_upgradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        r_upgradeButton.exclusiveTouch = YES;
		if ([Util isPhone]) {
			UIImage *upgradeImage = [UIImage imageNamed:@"i_upgrade1.png"];
			r_upgradeButton.frame = CGRectMake(5,47,upgradeImage.size.width,upgradeImage.size.height);
			[r_upgradeButton setImage:upgradeImage forState:UIControlStateNormal];
			[r_upgradeButton setImage:[UIImage imageNamed:@"i_upgrade2.png"] forState:UIControlStateHighlighted];
		}else {
            UIImage *upgradeImage = [UIImage imageNamed:@"upgrade_1.png"];
			if ([Util isPortrait:self]) {
				r_upgradeButton.frame = CGRectMake(10,
                                                   1004-upgradeImage.size.height-10,
                                                   upgradeImage.size.width,
                                                   upgradeImage.size.height);
			}else {
				r_upgradeButton.frame = CGRectMake(10,748-upgradeImage.size.height-10,
                                                   upgradeImage.size.width,
                                                   upgradeImage.size.height);
			}
			[r_upgradeButton setImage:[UIImage imageNamed:@"upgrade_1.png"] forState:UIControlStateNormal];
			[r_upgradeButton setImage:[UIImage imageNamed:@"upgrade_2.png"] forState:UIControlStateHighlighted];
		}
        
		[r_upgradeButton addTarget:self
                            action:@selector(upgradeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
		if ([Util isPhone]) {
			[r_categoryContainer.view insertSubview:r_upgradeButton atIndex:0];
		}else {
			[self.view addSubview:r_upgradeButton];
		}
        
        if (![Util isPhone]) {
            
            adView = [[myAdView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                320,
                                                                50)
                                            delegate:self];
            
            adView.hidden = YES;
            adView.ViewController = self;
            [self.view addSubview:adView];
            [adView tryGAD:GAD_SIZE_320x50];
            [self hideAdv:YES];
            [adView release];
            
        }
        
	}
	
	r_aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    r_aboutButton.exclusiveTouch = YES;
	if ([Util isPhone]) {
		UIImage *infoImage = [UIImage imageNamed:@"i_info1.png"];
        if (IS_IPHONE_5) {
            r_aboutButton.frame = CGRectMake(563-infoImage.size.width,47,infoImage.size.width,infoImage.size.height);
        }
        else{
            r_aboutButton.frame = CGRectMake(475-infoImage.size.width,47,infoImage.size.width,infoImage.size.height);
        }
		
        NSLog(@"button :-->%@",r_aboutButton);
		[r_aboutButton setImage:infoImage
					   forState:UIControlStateNormal];
		[r_aboutButton setImage:[UIImage imageNamed:@"i_info2.png"]
					   forState:UIControlStateHighlighted];
	}else {
   		UIImage *infoImage = [UIImage imageNamed:@"info1.png"];
		if ([Util isPortrait:self]) {
			r_aboutButton.frame = CGRectMake(768-infoImage.size.width-10,
                                             1004-infoImage.size.height-10,
                                             infoImage.size.width,
                                             infoImage.size.height);
		}else {
			r_aboutButton.frame = CGRectMake(1024-infoImage.size.width-10,
                                             748-infoImage.size.height-10,
                                             infoImage.size.width,
                                             infoImage.size.height);
		}
		[r_aboutButton setImage:[UIImage imageNamed:@"info1.png"]
					   forState:UIControlStateNormal];
		[r_aboutButton setImage:[UIImage imageNamed:@"info2.png"]
					   forState:UIControlStateHighlighted];
	}
	
	[r_aboutButton addTarget:self
					  action:@selector(aboutButtonPressed:)
			forControlEvents:UIControlEventTouchUpInside];
	if ([Util isPhone]) {
		[r_categoryContainer.view insertSubview:r_aboutButton atIndex:0];
	}else {
		[self.view addSubview:r_aboutButton];
	}
    
}

#pragma mark init ends

#pragma mark -
#pragma mark IPAD import delegate

-(void)importFinished:(BOOL)result newCat:(NSString*)cat
{
	if (result) {
		
		NSString *message = @"NOT VALID";
		
		if (cat) {
			
			if (r_category) {
				[r_category release];
			}
			
			r_category = [[NSString alloc] initWithString:cat];
			
			[[FDBController sharedDatabase] insertCategory:cat toGroup:r_group];
			NSDictionary *categoryContent = [self createContentForCategory:cat];
			[self performSelector:@selector(addCategoryFeatTest:)
					   withObject:categoryContent
					   afterDelay:0.5f];
			
			message = [NSString stringWithFormat:@"Set %@ imported.\n Would you like to go to this set?",[[FDBController sharedDatabase] nameForCategory:cat]];
		}
		
        
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import"
														message:message
													   delegate:self
											  cancelButtonTitle:@"NO"
											  otherButtonTitles:@"YES",nil];
		alert.tag = kAlertQuizlet;
		[alert show];
		[alert release];
		
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Import"
														message:@"Connection failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark IPAD import delegate ends

#pragma mark -
#pragma mark IPAD notifications
-(void)showMe:(NSNotification*)sender
{
	if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
		UINavigationController *navController = (UINavigationController*)[sender object];
        
		if (navController) {
			navController.modalPresentationStyle = UIModalPresentationFormSheet;
			navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
			[self presentModalViewController:navController animated:YES];
		}
	}
}

-(void)restorePopover:(NSNotification*)sender
{
	if (r_popoverContoller) {
        if (r_popoverState == RIPopoverStateAddCategory) {
            [r_popoverContoller setPopoverContentSize:CGSizeMake(300.0,200.0)];
        }else{
            [r_popoverContoller setPopoverContentSize:CGSizeMake(500.0,256.0)];
        }
	}
}

#pragma mark IPAD notifications ends



#pragma mark -
#pragma mark IPAD Export controller delegate

-(void)setWasReseted:(NSString*)categoryId;
{
	[self reloadCurrentCategory:categoryId];
}

-(void)dissmisMe
{
	if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
		[r_popoverContoller dismissPopoverAnimated:NO];
		[r_popoverContoller release];
		r_popoverContoller = nil;
	}
}

-(void)loadCardEditing:(NSString*)setId{
    
    if (r_category) {
        [r_category release];
    }
    
    r_category = [[NSString alloc] initWithString:setId];
    
    NSInteger numOfCards = [[FDBController sharedDatabase] getNumberOfItems:setId];
    
    if (numOfCards>0) {
        [self dissmisMe];
        [self prepareToChanges:NO];
        r_editWithCurId = YES;
        [self performSelector:@selector(loadSceneController:)
                   withObject:setId
                   afterDelay:0.25f];
    }else{
        [Util showMessage:@"Edit" forMessage:@"No cards to edit" forButtonTitle:@"OK"];
    }
    
}

#pragma mark IPAD Export controller delegate ends

#pragma mark -
#pragma mark UIPopoverController delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
	if (![Util isPhone]) {
		if (r_popoverContoller) {
			[r_popoverContoller release];
			r_popoverContoller = nil;
		}
		r_popoverState = RIPopoverStateNone;
		if (r_popoverContentID == kPContentMode) {
			[self changeMode:nil];
		}
	}else {
		if (iphone_popover) {
			[iphone_popover release];
			iphone_popover = nil;
			[r_popoverBgView removeFromSuperview];
		}
	}
	
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
	return YES;
}

#pragma mark UIPopoverController delegate ends

#pragma mark -
#pragma mark AdMob delegate

-(void)advRecieveFailed:(FAdMobController*)sender
{
	
}

-(void)advRecieveSuccess:(FAdMobController*)sender
{
    if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
        [r_popoverContoller dismissPopoverAnimated:NO];
        [r_popoverContoller release];
        r_popoverContoller = nil;
    }else
    {
    
    [self hideAdv:NO];
        
        
    }
}

-(void)hideAdv:(BOOL)hidden
{
    if (![Util isPhone]) {
        
        if (adView && hidden && adView.hidden) {
            return;
        }
        
        [UIView beginAnimations:@"AdMobAnimation" context:nil];
        CGRect frame = adView.frame;
        UIImage *infoImage = [UIImage imageNamed:@"info1.png"];
        if (hidden) {
			
            if ([Util isPortrait:self]) {
                frame.origin.y = 1004+frame.size.height;
                frame.origin.x = 748-adView.frame.size.width;
            }else{
               
                frame.origin.y = 748+frame.size.height;
                frame.origin.x = 1004-infoImage.size.width-adView.frame.size.width;
                
              
            }
            
        }else {
            
            if ([[self.navigationController topViewController] isEqual:self]) {
                if ([Util isPortrait:self]) {
                    frame.origin.y = 990-frame.size.height-infoImage.size.height;
                    frame.origin.x = 768-adView.frame.size.width;
                }else{
                    
                   
                    frame.origin.y = 738-frame.size.height;
                    frame.origin.x = 1004-infoImage.size.width-adView.frame.size.width;
                    
                }
            }
            
        }
        
       
        adView.frame = frame;
        
        
        [UIView commitAnimations];
    }
    
}


#pragma mark AdMob delegate ends


#pragma mark -
#pragma mark ITunes import delegate
-(void)itunesSetImported:(NSString*)setId
{
	if (setId) {
		
		if (r_category) {
			[r_category release];
		}
		
		r_category = [[NSString alloc] initWithString:setId];
		
		[[FDBController sharedDatabase] insertCategory:setId toGroup:r_group];
		NSDictionary *categoryContent = [self createContentForCategory:setId];
		[r_categoryContainer createNewCategory:categoryContent animated:NO withEditing:NO];
	}
}

#pragma mark ITunes import delegate ends

#pragma mark -
#pragma mark targets
-(void)addCategoryPressed:(id)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(addSetID);
    }
    
	if (!r_isEdit) {
		if ([Util isPhone]) {
			FIAddViewController *addController = [[FIAddViewController alloc] init];
			addController.contentSizeForViewInPopover = CGSizeMake(242,195);
			addController.delegate = self;
			
			if (iphone_popover) {
				[iphone_popover dismissPopoverAnimated:NO];
				[iphone_popover release];
				iphone_popover = nil;
			}
			
			if (!r_popoverBgView) {
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        r_popoverBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,320)];
                    }
                    else{
                        r_popoverBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,568,300)];
                    }
                }
                else{
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        r_popoverBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,320)];
                    }
                    else{
                        r_popoverBgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,480,300)];
                    }
                }
				r_popoverBgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
			}
			
			[self.view addSubview:r_popoverBgView];
			
			iphone_popover = [[WEPopoverController alloc] initWithContentViewController:addController];
			iphone_popover.delegate = self;
			[iphone_popover presentPopoverFromRect:CGRectMake(105,0,40,25)
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionUp
                                          animated:YES];
			[addController release];
		}else {
			if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
				return;
			}
            
			FIAddViewController *addController = [[FIAddViewController alloc] init];
			addController.delegate = self;
			
            UINavigationController *navcont = [[UINavigationController alloc] initWithRootViewController:addController];
            navcont.navigationBarHidden = YES;
            
			if (r_popoverContoller) {
				[r_popoverContoller release];
			}
            r_popoverContentID = kPContentAdd;
			r_popoverContoller = [[UIPopoverController alloc] initWithContentViewController:navcont];
			r_popoverContoller.delegate = self;
            [addController setContentSizeForViewInPopover:CGSizeMake(300, 200)];
			r_popoverContoller.popoverContentSize = CGSizeMake(300,200);
			[r_popoverContoller presentPopoverFromBarButtonItem:r_addButton
									   permittedArrowDirections:UIPopoverArrowDirectionUp
													   animated:YES];
			[addController release];
            [navcont release];
			r_popoverState = RIPopoverStateAddCategory;
		}
	}
	
}

-(void)editCategoryPressed:(id)sender
{
	if (!r_isEdit) {
		r_isEdit = YES;
		UIButton *editButton = (UIButton*)r_editButton.customView;
		[editButton setImage:[UIImage imageNamed:@"i_panel_done1.png"] forState:UIControlStateNormal];
		[editButton setImage:[UIImage imageNamed:@"i_panel_done2.png"] forState:UIControlStateHighlighted];
		
		[self enableAddButton:NO];
		[r_categoryContainer edit:YES];
	}else {
		r_isEdit = FALSE;
		UIButton *editButton = (UIButton*)r_editButton.customView;
		[editButton setImage:[UIImage imageNamed:@"i_panel_edit1.png"] forState:UIControlStateNormal];
		[editButton setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
		
		[self enableAddButton:YES];
		[r_categoryContainer edit:FALSE];
	}
    
	
    
}

-(void)upgradeButtonPressed:(id)sender
{
    if ([Util connectedToNetwork]) {
       	r_upgradeButton.enabled = NO;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [[FUpgradeManager initWithDelegate:self] updateToDeluxe];
    }else{
        [Util showMessage:@"" forMessage:@"Check internet connection and try again" forButtonTitle:@"OK"];
    }
    
	
}

-(void)aboutButtonPressed:(id)sender{
    
	if ([Util isPhone]) {
		[r_categoryContainer hideCard:FICardPositionRight hidden:YES];
        
        FIAboutController *aboutController = [[FIAboutController alloc] init];
        [self.navigationController pushViewController:aboutController animated:YES];
        [aboutController release];
        
        //vc = [[MyViewController alloc]init];
        //Orientation *myNavigationController = [[Orientation alloc] initWithRootViewController:aboutController];
        //[self myNavigationController ];
        
		
        
        
	}else {
		AboutViewController* aboutController = [[AboutViewController alloc]init];
		aboutController.delegate = self;
		UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0,0,768,1024)];
		blackView.backgroundColor = [UIColor blackColor];
		blackView.alpha = 0.0f;
		blackView.tag = -777;
		aboutController.view.tag = -888;
		[self.view.window addSubview:blackView];
		[self.view.window addSubview:aboutController.view];
//		if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationPortrait) {
//			[aboutController.view setOrigin:CGPointMake((768 - aboutController.view.frame.size.width)/2, 1024.0f)];
//		} else if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
//			[aboutController.view setOrigin:CGPointMake((768 - aboutController.view.frame.size.width)/2, -aboutController.view.frame.size.height)];
//		} else
//        if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {//ipad mini ,ipad2
//			[aboutController.view setOrigin:CGPointMake(768.0f, (1024 - aboutController.view.frame.size.height)/2)];
//		}
//        else if ([[UIApplication sharedApplication]statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
//			[aboutController.view setOrigin:CGPointMake(-aboutController.view.frame.size.width, (1024 - aboutController.view.frame.size.height)/2)];
//		}
//		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		blackView.alpha = 0.5f;
//		[aboutController.view setOrigin:CGPointMake((768.0f - aboutController.view.frame.size.width)/2, (1024.0f - aboutController.view.frame.size.height)/2)];
		[UIView commitAnimations];
	}
	
}

-(void)changeMode:(UITapGestureRecognizer*)sender
{
    
	if (r_mode == RIMainModeCategories) {
		r_mode = RIMainModeGroups;
		
		if (r_isEdit) {
			r_isEdit = FALSE;
			if (![Util isPhone]) {
				r_editButton.style = UIBarButtonItemStyleBordered;
				r_editButton.title = @"Edit";
                [self enableAddButton:YES];
			}else {
				UIButton *editButton = (UIButton*)r_editButton.customView;
				[editButton setImage:[UIImage imageNamed:@"i_panel_edit1.png"] forState:UIControlStateNormal];
				[editButton setImage:[UIImage imageNamed:@"i_panel_edit2.png"] forState:UIControlStateHighlighted];
                [self enableAddButton:YES];
			}
            
			[r_categoryContainer edit:FALSE];
		}
        
		if ([Util isPhone]) {
            
            CGRect frame;
            if (IS_IPHONE_5) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    frame = CGRectMake(0,0,568,320);
                }
                else{
                    frame = CGRectMake(0,0,568,300);
                }
            }
            else{
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    frame = CGRectMake(0,0,480,320);
                }
                else{
                    frame = CGRectMake(0,0,480,300);
                }
            }
            
            
			[self initGroupView:frame tag:RITableListViewTypeGroup];
            r_groupView.r_topBar.hidden = YES;
			[self.view addSubview:r_groupView];
			//[r_groupView release];
			[self.view bringSubviewToFront:r_navigationBar];
			[[FIAnimationController sharedAnimation:nil] makeAnimation:r_groupView
                                                                  type:kCATransitionMoveIn
                                                                   dir:kCATransitionFromBottom];
            self.view.userInteractionEnabled = NO;
            [self performSelector:@selector(showGroupNavBar)
                       withObject:nil afterDelay:0.5f];
		}else {
			UIViewController *groupController = [[UIViewController alloc] init];
			[self initGroupView:CGRectMake(0,0,300,500) tag:RITableListViewTypeGroup];
			groupController.view = r_groupView;
			//[r_groupView release];
			
			r_popoverContentID = kPContentMode;
			
			if (r_popoverContoller) {
				
				if ([r_popoverContoller isPopoverVisible]) {
					[r_popoverContoller dismissPopoverAnimated:NO];
				}
				
				[r_popoverContoller release];
			}
			
			r_popoverContoller = [[UIPopoverController alloc] initWithContentViewController:groupController];
			r_popoverContoller.delegate = self;
			r_popoverContoller.popoverContentSize = CGSizeMake(300,500);
			[r_popoverContoller presentPopoverFromRect:[self popoverFrame:self.interfaceOrientation forState:RIPopoverStateGroup]
												inView:self.view
							  permittedArrowDirections:UIPopoverArrowDirectionUp
											  animated:YES];
			[groupController release];
			r_popoverState = RIPopoverStateGroup;
		}
        
		
		
	}else {
		
		r_mode = RIMainModeCategories;
		
		if (!r_group) {
			[self enableAddButton:NO];
			[self enableEditButton:NO];
		}
		
		if ([Util isPhone]) {
            [self.view bringSubviewToFront:r_navigationBar];
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_groupView
															toPoint:CGPointMake(((IS_IPHONE_5)?284:240),
																				-r_groupView.frame.size.height)];
			[r_groupView performSelector:@selector(removeFromSuperview)
							  withObject:nil
							  afterDelay:0.25f];
		}else {
			if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
				[r_popoverContoller dismissPopoverAnimated:YES];
				[r_popoverContoller release];
				r_popoverContoller = nil;
			}
		}
        
	}
	
    
    
}

-(void)showGroupNavBar{
    self.view.userInteractionEnabled = YES;
    [self.view bringSubviewToFront:r_groupView];
    r_groupView.r_topBar.hidden = NO;
}

-(void)loadSceneController:(NSString*)setId{
    NSArray *cards = [[FDBController sharedDatabase] infoForCategory:setId];
    
    if (cards) {
        
        NSArray *tmpSet = nil;
        NSMutableSet *ignCards = nil;
        
        if (r_category)
            tmpSet =  [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ignored",setId]];
        
        if (!tmpSet) {
            ignCards = [[NSMutableSet alloc] init];
        }
        else {
            ignCards = [[NSMutableSet alloc] initWithArray:tmpSet];
        }
        
        FISceneViewController *scene = [[FISceneViewController alloc] init];
        scene.withoutAnimation = NO;
        scene.delegate = self;
        NSString *categoryName = [[FDBController sharedDatabase] nameForCategory:setId];
        scene.category = setId;
        scene.categoryName = categoryName;
        NSInteger initId = 0;
        
        if (r_editWithCurId) {
            r_editWithCurId = NO;
            NSDictionary *currentSet = [self createContentForCategory:setId];
            NSInteger curId = [[currentSet objectForKey:@"id"] intValue];
            initId = [self findIndexForId:curId inArr:cards];
        }
        
        scene.initedId = initId;
        scene.r_isTopPanelExist = YES;
        [scene initByArray:cards];
        
        [scene initIgnoredCards:ignCards];
        [self.navigationController pushViewController:scene
                                             animated:NO];
        [ignCards release];
        [scene release];
        
        [r_categoryContainer setTitleHidden:YES animated:NO];
    }
    
    if (cards) {
        [cards release];
    }
}

-(void)upgrade:(NSNotification*)sender{
    if (r_upgradeButton.enabled) {
        [self upgradeButtonPressed:nil];
    }
    
}

#pragma mark targets ends

#pragma mark -
#pragma mark FIAddViewController delegate

-(void)addCategorySelected:(id)sender
{
	if ([Util isPhone]) {
        
		if (iphone_popover) {
			[iphone_popover dismissPopoverAnimated:YES];
			[iphone_popover release];
			iphone_popover = nil;
			[r_popoverBgView removeFromSuperview];
		}
		
        [self performSelector:@selector(presentIPhoneTemplate)
                   withObject:nil
                   afterDelay:0.25f];
        
	}else {
		
		if (r_popoverContoller) {
			[r_popoverContoller dismissPopoverAnimated:YES];
			[r_popoverContoller release];
			r_popoverContoller = nil;
		}
		
        [self performSelector:@selector(presentIPadTemplates)
                   withObject:nil
                   afterDelay:0.25f];
  	}
}

-(void)itunesSelected:(id)sender
{
    
	if (iphone_popover) {
		[iphone_popover dismissPopoverAnimated:YES];
		[iphone_popover release];
		iphone_popover = nil;
		[r_popoverBgView removeFromSuperview];
	}
    
	FIITunesViewController *itunes = [[FIITunesViewController alloc] init];
	[r_categoryContainer hideCard:FICardPositionRight hidden:YES];
	[self.navigationController pushViewController:itunes animated:YES];
	[itunes release];
    
}

-(void)quizletSelected:(id)sender{
    
	if ([Util isPhone]) {
		if (iphone_popover) {
			[iphone_popover dismissPopoverAnimated:YES];
			[iphone_popover release];
			iphone_popover = nil;
			[r_popoverBgView removeFromSuperview];
		}
		
		QIViewController *quizlet = [[QIViewController alloc] init];
		[r_categoryContainer hideCard:FICardPositionRight hidden:YES];
		[self.navigationController pushViewController:quizlet animated:YES];
		[quizlet release];
	}else {
		if (r_popoverContoller) {
			[r_popoverContoller dismissPopoverAnimated:YES];
			[r_popoverContoller release];
			r_popoverContoller = nil;
		}
		[self presentIPadImport];
	}
    
}

#pragma mark FIAddViewController delegate ends

#pragma mark -
#pragma mark FITemplateViewController delegate
-(void)createCategory:(NSInteger)templateType
{
    if (![Util isPhone]) {
        if (r_popoverContoller) {
			[r_popoverContoller dismissPopoverAnimated:YES];
			[r_popoverContoller release];
			r_popoverContoller = nil;
		}
    }
    
	[self createEmptySet:@"" template:templateType];
}

#pragma mark FITemplateViewController delegate ends

#pragma mark -
#pragma mark notifications

//name=quizletAdded
-(void)quizletSetPop:(NSNotification*)sender
{
	if (sender) {
		NSString *category = (NSString*)sender.object;
		
		if (category) {
			[[FDBController sharedDatabase] insertCategory:category toGroup:r_group];
			[[FDBController sharedDatabase] insertTemplate:category withTemplate:kCustomTemplate];
			NSDictionary *categoryContent = [self createContentForCategory:category];
			
			if ([Util isPhone]) {
				[self.navigationController popToRootViewControllerAnimated:YES];
			}else {
				[self dismissModalViewControllerAnimated:YES];
			}
            
			[self performSelector:@selector(addCategoryFeatTest:)
                       withObject:categoryContent
                       afterDelay:0.05f];
			
			[self performSelector:@selector(selectedCategory:)
					   withObject:category
					   afterDelay:1.0f];
		}
		
	}
	
}

//name=SetAdded
-(void)quizletSetAdded:(NSNotification*)sender
{
	if (sender) {
		NSString *category = (NSString*)sender.object;
		
		if (category) {
			[[FDBController sharedDatabase] insertCategory:category toGroup:r_group];
			[[FDBController sharedDatabase] insertTemplate:category withTemplate:kCustomTemplate];
			NSDictionary *categoryContent = [self createContentForCategory:category];
			[r_categoryContainer createNewCategory:categoryContent animated:NO withEditing:NO];
		}
		
	}
	
    
}

//name=itunesAdded
-(void)itunesSetPop:(NSNotification*)sender
{
	if (sender) {
		NSString *category = (NSString*)sender.object;
		
		if (category) {
			[[FDBController sharedDatabase] insertCategory:category toGroup:r_group];
			//[[FDBController sharedDatabase] insertTemplate:category withTemplate:RITemplateMixed];
			NSDictionary *categoryContent = [self createContentForCategory:category];
			[r_categoryContainer createNewCategory:categoryContent animated:NO withEditing:NO];
		}
		
	}
	
}

-(void)dissmisPopover:(NSNotification*)sender
{
	r_categoryContainer.view.userInteractionEnabled = YES;
	r_navigationBar.userInteractionEnabled = YES;
	
	if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
		[r_popoverContoller dismissPopoverAnimated:YES];
		[r_popoverContoller release];
		r_popoverContoller = nil;
	}
}

#pragma mark notifications ended

#pragma mark -
#pragma mark private
-(NSArray*)createCategoryContent
{
	if (!r_group) {
		return [NSMutableArray array];
	}
	
	NSMutableArray *categoryList = [[FDBController sharedDatabase] getCategoriesForGroup:r_group];
	
	NSMutableArray *categoryContent = [NSMutableArray array];
	
	for (NSString *categoryId in categoryList) {
		
		NSMutableDictionary *dic = [NSMutableDictionary dictionary];
		
		[dic setObject:categoryId forKey:@"c"];
		NSString *categoryName = [[FDBController sharedDatabase] nameForCategory:categoryId];
		[dic setObject:categoryName forKey:@"cname"];
		
        NSArray *visCard = [[FDBController sharedDatabase] cardWithMinIdForTest:categoryId];
        
		if (!visCard) {
			visCard = [[FDBController sharedDatabase] cardWithMinId:categoryId];
		}
		
		if (visCard) {
			NSString *q = [visCard objectAtIndex:1];
			NSString *a = [visCard objectAtIndex:2];
			
			[dic setObject:[visCard objectAtIndex:0] forKey:@"id"];
			[dic setObject:q forKey:@"q"];
			[dic setObject:a forKey:@"a"];
		}
		
		NSInteger cardsCount = [[FDBController sharedDatabase] getNumberOfItems:categoryId];
		
		[dic setObject:[NSNumber numberWithInt:1] forKey:@"cardNumber"];
		[dic setObject:[NSNumber numberWithInt:cardsCount] forKey:@"cardsCount"];
		
		
		NSDictionary *prefDic = [self getCurrentPreference:categoryId];
		[dic setObject:[prefDic objectForKey:@"isBoth"] forKey:@"isBoth"];
		[dic setObject:[prefDic objectForKey:@"isRev"] forKey:@"isRev"];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			NSDictionary *fontDic = [self getCurrentFont:categoryId];
			[dic setObject:[fontDic objectForKey:@"font"] forKey:@"font"];
			[dic setObject:[fontDic objectForKey:@"fontsize"] forKey:@"fontsize"];
		}else {
			NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",categoryId]];
			
			if (currentSettings) {
				[dic setObject:[currentSettings objectAtIndex:0] forKey:@"font"];
				[dic setObject:[currentSettings objectAtIndex:1] forKey:@"fontsize"];
			}else {
				[dic setObject:@"Helvetica" forKey:@"font"];
				[dic setObject:[NSNumber numberWithInt:30] forKey:@"fontsize"];
			}
            
		}
        
		
		[categoryContent addObject:dic];
		
	}
	
	[categoryList release];
	
	return categoryContent;
}

-(NSDictionary*)createContentForCategory:(NSString*)categoryId
{
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:categoryId forKey:@"c"];
	
	NSString *categoryName = [[FDBController sharedDatabase] nameForCategory:categoryId];
	[dic setObject:categoryName forKey:@"cname"];
	
	NSArray *visCard = [[FDBController sharedDatabase] cardWithMinIdForTest:categoryId];
    
    if (!visCard) {
        visCard = [[FDBController sharedDatabase] cardWithMinId:categoryId];
    }
    
    if (visCard) {
        NSString *q = [visCard objectAtIndex:1];
        NSString *a = [visCard objectAtIndex:2];
        
        [dic setObject:[visCard objectAtIndex:0] forKey:@"id"];
        [dic setObject:q forKey:@"q"];
        [dic setObject:a forKey:@"a"];
    }
    
    NSInteger cardsCount = [[FDBController sharedDatabase] getNumberOfItems:categoryId];
	
	[dic setObject:[NSNumber numberWithInt:1] forKey:@"cardNumber"];
	[dic setObject:[NSNumber numberWithInt:cardsCount] forKey:@"cardsCount"];
	
	NSDictionary *prefDic = [self getCurrentPreference:categoryId];
	[dic setObject:[prefDic objectForKey:@"isBoth"] forKey:@"isBoth"];
	[dic setObject:[prefDic objectForKey:@"isRev"] forKey:@"isRev"];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		NSDictionary *fontDic = [self getCurrentFont:categoryId];
		[dic setObject:[fontDic objectForKey:@"font"] forKey:@"font"];
		[dic setObject:[fontDic objectForKey:@"fontsize"] forKey:@"fontsize"];
	}else {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",categoryId]];
		
		if (currentSettings) {
			[dic setObject:[currentSettings objectAtIndex:0] forKey:@"font"];
			[dic setObject:[currentSettings objectAtIndex:1] forKey:@"fontsize"];
		}else {
			[dic setObject:@"Helvetica" forKey:@"font"];
			[dic setObject:[NSNumber numberWithInt:30] forKey:@"fontsize"];
		}
	}
	
	return dic;
}

-(void)createEmptySet:(NSString*)setName template:(NSInteger)template
{
    NSString *setId ;
    
//    if ([setName isEqualToString:@""]) {
    
//        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Can't Create empty set" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"", nil];
//        [alert show];
//        [alert release];
    
   
    
	setId = [[FDBController sharedDatabase] addCategory:setName
														  toGroup:r_group
													 withTemplate:template];
  
    
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	[dic setObject:setId forKey:@"c"];
	[dic setObject:setName forKey:@"cname"];
	
	[r_categoryContainer createNewCategory:dic animated:YES withEditing:YES];
}

-(NSDictionary*)getCurrentPreference:(NSString*)category
{
	BOOL isBothSide;
	BOOL isReversed;
	
	if (category) {
		NSArray *cardSettings = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_Setings",category]];
		
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
	
	
	NSDictionary *prefDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithBool:isBothSide],
																 [NSNumber numberWithBool:isReversed],nil]
														forKeys:[NSArray arrayWithObjects:@"isBoth",@"isRev",nil]];
	
	return prefDic;
	
}

-(NSDictionary*)getCurrentFont:(NSString*)category
{
	NSString *currentFont;
	NSInteger cSize;
	
	if (category) {
		NSArray *currentSettings = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@Font",category]];
		
		if (currentSettings) {
			currentFont = [NSString stringWithString:[currentSettings objectAtIndex:0]];
			cSize = [[currentSettings objectAtIndex:1] intValue];
		}else {
			currentFont = [NSString stringWithString:@"Helvetica"];
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				cSize = 21;
			}else {
				cSize = 30;
			}
            
		}
        
	}else {
		currentFont = [NSString stringWithString:@"Helvetica"];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			cSize = 21;
		}else {
			cSize = 30;
		}
	}
	
	NSDictionary *fontDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:currentFont,[NSNumber numberWithInt:cSize],nil]
														forKeys:[NSArray arrayWithObjects:@"font",@"fontsize",nil]];
	
	return fontDic;
	
    
}

-(NSArray*)supportedTemplates
{
	return [NSArray arrayWithObjects:@"Audio",@"Custom",@"Definition",@"Translate",@"Picture",nil];
}

-(void)addCategoryAnimated:(NSDictionary*)dic
{
	if (dic) {
		[r_categoryContainer createNewCategory:dic animated:YES withEditing:YES];
	}
}

-(void)addCategoryNotAnimated:(NSDictionary*)dic
{
	if (dic) {
		[r_categoryContainer createNewCategory:dic animated:NO withEditing:YES];
	}
}

-(void)addCategoryFeatTest:(NSDictionary*)dic
{
	if (dic) {
		if ([Util isPhone]) {
			[r_categoryContainer createNewCategory:dic animated:NO withEditing:NO];
		}else {
			[r_categoryContainer createNewCategory:dic animated:YES withEditing:NO];
		}
        
	}
}

-(void)prepareToChanges:(BOOL)isCheckTest
{
	NSInteger cardsNum = [[FDBController sharedDatabase] getNumberOfItems:r_category];
	NSInteger tC = [[FDBController sharedDatabase] getTestNumForCategory:r_category];
	if ([Util isPhone]) {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(((IS_IPHONE_5)?284.0:240.0),-45)];
	}else {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(r_navigationBar.frame.size.width/2,-r_navigationBar.frame.size.height/2)];
	}
	[r_categoryContainer hideButtons:YES animated:YES];
	[r_categoryContainer wrapBgDeckView:YES animated:YES];
	
	if (cardsNum>0) {
		
		if ([Util isPhone]) {
			[r_categoryContainer makeCenter:YES animated:YES];
		}else {
			if (tC>0 && isCheckTest) {
				[r_categoryContainer makeCenter:YES animated:YES];
			}else {
				[r_categoryContainer makeIpadSceneCenter:YES animated:YES];
				
			}
		}
		[r_categoryContainer setTitleHidden:YES animated:YES];
	}else {
		[r_categoryContainer moveCardToRight:YES];
	}
	
	[self hideAxButtons:YES];
	
	if (![Util isFullVersion]) {
        [self hideAdv:YES];
        
	}
	
	
	[r_categoryContainer hideInfoLabel:YES animated:YES];
    
}

-(void)restoreController
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	
	if ([Util isPhone]) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(((IS_IPHONE_5)?284.0:240.0),r_navigationBar.frame.size.height/2.0)];
        [r_navigationBar setNeedsDisplay];
	}else {
        [[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(r_navigationBar.frame.size.width/2,r_navigationBar.frame.size.height/2)];
        if ([Util isPortrait:self]) {
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelport_bg.png"];
        }else{
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
        }
	}
	
	[self showAxButtons:YES];
	if (![Util isFullVersion]) {
		[self hideAdv:NO];
	}
	[r_categoryContainer setTitleHidden:NO animated:YES];
	[r_categoryContainer makeCenter:NO animated:YES];
	[r_categoryContainer hideButtons:NO animated:YES];
	[r_categoryContainer hideInfoLabel:NO animated:YES];
	[r_categoryContainer wrapBgDeckView:NO animated:YES];
    self.view.userInteractionEnabled = YES;
    
}

-(void)restoreIPadAfterScene
{
	[UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
	[self showAxButtons:YES];
	if (![Util isFullVersion]) {
		[self hideAdv:NO];
	}
	[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(r_navigationBar.frame.size.width/2,r_navigationBar.frame.size.height/2)];
    if ([Util isPortrait:self]) {
        r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelport_bg.png"];
    }else{
        r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
    }
    [r_navigationBar setNeedsDisplay];
	[r_categoryContainer makeIpadSceneCenter:NO animated:YES];
	[r_categoryContainer wrapBgDeckView:NO animated:YES];
	[r_categoryContainer setTitleHidden:NO animated:YES];
	[r_categoryContainer hideButtons:NO animated:YES];
	[r_categoryContainer hideInfoLabel:NO animated:YES];
    self.view.userInteractionEnabled = YES;
}

-(void)presentIPadImport
{
	FImportApiBaseController *fileImport = [[FImportApiBaseController alloc] init];
	[fileImport setDelegate:self];
	UINavigationController* navCont = [[UINavigationController alloc] initWithRootViewController:fileImport];
	navCont.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:navCont animated:YES];
	[fileImport release];
	[navCont release];
}

-(void)presentIPadTemplates
{
	FITemplateViewController *templateController = [[FITemplateViewController alloc] init];
	templateController.delegate = self;
	[self presentModalViewController:templateController animated:YES];
	[templateController release];
}

-(void)presentIPhoneTemplate{
	FITemplateViewController *templateController = [[FITemplateViewController alloc] init];
	templateController.delegate = self;
	templateController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:templateController animated:YES];
	[templateController release];
}

-(void)showAxButtons:(BOOL)animated
{
	CGPoint c1;
	CGPoint c2;
	
	if (r_upgradeButton) {
		if ([Util isPhone]) {
			UIImage *upgradeImage = [UIImage imageNamed:@"i_upgrade1.png"];
			c1 = CGPointMake(5+upgradeImage.size.width/2.0,47+upgradeImage.size.height/2.0);
		}else {
            UIImage *upgradeImage = [UIImage imageNamed:@"upgrade_1.png"];
			if ([Util isPortrait:self]) {
				c1 = CGPointMake(10+upgradeImage.size.width/2.0,1004-upgradeImage.size.height/2.0-10);
			}else {
				c1 = CGPointMake(10+upgradeImage.size.width/2.0,748-upgradeImage.size.height/2.0-10);
			}
			
		}
		
		if (animated) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_upgradeButton toPoint:c1];
		}else {
			r_upgradeButton.center = c1;
		}
        
		
	}
	
	if (r_aboutButton) {
		if ([Util isPhone]) {
			
            UIImage *infoImage = [UIImage imageNamed:@"i_info1.png"];
            if (IS_IPHONE_5) {
                c2 = CGPointMake(563-infoImage.size.width/2.0,47+infoImage.size.height/2.0);
            }
            else{
                c2 = CGPointMake(475-infoImage.size.width/2.0,47+infoImage.size.height/2.0);
            }
			
		}else {
            UIImage *infoImage = [UIImage imageNamed:@"info1.png"];
			if ([Util isPortrait:self]) {
				c2 = CGPointMake(768-infoImage.size.width/2.0-10,1004-infoImage.size.height/2.0-10);
			}else {
				c2 = CGPointMake(1024-infoImage.size.width/2.0-10,748-infoImage.size.height/2.0-10);
			}
			
		}
		
		if (animated) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_aboutButton toPoint:c2];
		}else {
			r_aboutButton.center = c2;
		}
	}
    
    isButtonHidden = NO;
}


-(void)hideAxButtons:(BOOL)animated
{
	CGPoint c1;
	CGPoint c2;
	
	if (r_upgradeButton) {
		if ([Util isPhone]) {
			UIImage *upgradeImage = [UIImage imageNamed:@"i_upgrade1.png"];
			c1 = CGPointMake(-5-upgradeImage.size.width/2.0,47+upgradeImage.size.height/2.0);
		}else {
            UIImage *upgradeImage = [UIImage imageNamed:@"upgrade_1.png"];
			if ([Util isPortrait:self]) {
				c1 = CGPointMake(-upgradeImage.size.width,1004-upgradeImage.size.height/2.0-10);
			}else {
				c1 = CGPointMake(-upgradeImage.size.width,748-upgradeImage.size.height/2.0-10);
			}
			
		}
		
		if (animated) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_upgradeButton toPoint:c1];
		}else {
			r_upgradeButton.center = c1;
		}
		
	}
	
	if (r_aboutButton) {
		if ([Util isPhone]) {
			UIImage *infoImage = [UIImage imageNamed:@"i_info1.png"];
			c2 = CGPointMake(485+infoImage.size.width/2.0,47+infoImage.size.height/2.0);
		}else {
            UIImage *infoImage = [UIImage imageNamed:@"info1.png"];
			if ([Util isPortrait:self]) {
				c2 = CGPointMake(768+infoImage.size.width,1004-infoImage.size.height/2.0-10);
			}else {
				c2 = CGPointMake(1024+infoImage.size.width,748-infoImage.size.height/2.0-10);
			}
			
		}
		
		if (animated) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:r_aboutButton toPoint:c2];
		}else {
			r_aboutButton.center = c2;
		}
		
	}
    
    isButtonHidden = YES;
}

-(void)showContent{
	[UIView beginAnimations:@"showContent" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	
	r_navigationBar.alpha = 1.0;
	r_categoryContainer.view.alpha = 1.0;
	[UIView commitAnimations];
	
	[self showAxButtons:YES];
    
    
}

-(void)restoreControllerAnimated
{
	if ([Util isPhone]) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(((IS_IPHONE_5)?284:240),r_navigationBar.frame.size.height/2.0)];
	}else {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_navigationBar toPoint:CGPointMake(r_navigationBar.frame.size.width/2,r_navigationBar.frame.size.height/2)];
        if ([Util isPortrait:self]) {
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelport_bg.png"];
        }else{
            r_navigationBar.bgImage = [Util imageFromBundle:@"ip_panelland_bg.png"];
        }
	}
	[self showAxButtons:YES];
   
    
    //[[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"advertisement"];
    
	  if (![Util isFullVersion]) {
          if (r_popoverContoller && [r_popoverContoller isPopoverVisible]) {
             [self hideAdv:YES];
              NSLog(@"ad hidden");
          }else
           {
		    [self hideAdv:NO];
           }
	    }
    
	[r_categoryContainer setCenterCardHidden:NO];
	[r_categoryContainer jumpCenterCard];
    self.view.userInteractionEnabled = YES;
}

-(void)loadController
{
	if (r_category) {
		
        BOOL isAL = [[FDBController sharedDatabase] isAllLearned:r_category];
        BOOL isSO = [[FDBController sharedDatabase] isSessionOpened:r_category];
        
        if (!isAL && !isSO) {
            NSInteger minSession = [[FDBController sharedDatabase] minSession:r_category];
            [[FDBController sharedDatabase] changeSessionState:1 forSet:r_category];
            [[FDBController sharedDatabase] updateSessionForSet:r_category session:minSession];
        }
        
        if (!isAL) {
            [self loadBoxController];
		}else {
			NSArray *cards = [[FDBController sharedDatabase] infoForCategory:r_category];
			
			if (cards) {
				
				NSArray *tmpSet = nil;
				NSMutableSet *ignCards = nil;
				
				if (r_category)
					tmpSet =  [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_ignored",r_category]];
				
				if (!tmpSet) {
					ignCards = [[NSMutableSet alloc] init];
				}
				else {
					ignCards = [[NSMutableSet alloc] initWithArray:tmpSet];
				}
				
				FISceneViewController *scene = [[FISceneViewController alloc] init];
                scene.withoutAnimation = NO;
				scene.delegate = self;
				NSString *categoryName = [[FDBController sharedDatabase] nameForCategory:r_category];
				scene.category = r_category;
				scene.categoryName = categoryName;
				scene.initedId = 0;
				scene.r_isTopPanelExist = YES;
				[scene initByArray:cards];
				[scene initIgnoredCards:ignCards];
				[self.navigationController pushViewController:scene
													 animated:NO];
				[ignCards release];
				[scene release];
				
				[r_categoryContainer setTitleHidden:YES animated:NO];
			}
			
			if (cards) {
				[cards release];
			}
			
			
		}
		
	}
}

-(void)loadBoxController{
	NSInteger tC;
	
	tC = [[FDBController sharedDatabase] getTestNumForCategory:r_category];
	
	if (tC>0) {
		
		FILearningProccesType type;
		
		if (tC>0) {
			type = FILearningProccesTypeTest;
		}else {
			type = FILearningProccesTypeStudy;
		}
		
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			FIBoxSceneViewController *scene = [[FIBoxSceneViewController alloc] createLearningProcces:type
																						  forCategory:r_category];
			scene.delegate = self;
			[self.navigationController pushViewController:scene animated:NO];
			[scene release];
		}else {
			
			NSArray *learnArray;
			
			if (type == FILearningProccesTypeTest){
				learnArray = [[FDBController sharedDatabase] getTestListForCategory:r_category];
            }
            
			FBoxSceneController *scene = [[FBoxSceneController alloc] initWithCards:learnArray
																		forCategory:r_category
																			forMode:type
																		forDelegate:self];
			[self.navigationController pushViewController:scene animated:NO];
			[scene release];
			[learnArray release];
		}
		
		
	}
}

-(CGRect)popoverFrame:(UIInterfaceOrientation)orientation forState:(RIPopoverState)state
{
	CGRect frame = CGRectNull;
    
	switch (state) {
		case RIPopoverStateGroup:
		{
			if ([Util isPortraitWithOrientation:orientation]) {
				frame = CGRectMake(380,20,10,10);
			}else {
				frame = CGRectMake(512,20,10,10);
			}
			break;
		}
		case RIPopoverStateSettings:
		{
			if ([Util isPortraitWithOrientation:orientation]) {
				frame = CGRectMake(45,370,10,50);
			}else {
				frame = CGRectMake(172,250,10,50);
			}
			
			break;
		}
		case RIPopoverStateAddCard:
		{
			if ([Util isPortraitWithOrientation:orientation]) {
				frame = CGRectMake(720,375,10,10);
			}else {
				frame = CGRectMake(850,245,10,10);
			}
			
			break;
		}
		default:
			break;
	}
	
	return frame;
}

-(void)upgradeControlToFullVersion
{
	if (r_upgradeButton) {
		[r_upgradeButton removeFromSuperview];
		r_upgradeButton = nil;
	}
	
    
	[[FAdMobController sharedAdMobController:nil] clearFullscreen];
}

-(void)enableAddButton:(BOOL)enabled{
	if (enabled) {
		if (r_group && !r_isEdit) {
			r_navigationBar.topItem.leftBarButtonItem = r_addButton;
		}
	}else {
        r_navigationBar.topItem.leftBarButtonItem = nil;
	}
	
	return;
}

-(void)enableEditButton:(BOOL)enabled{
	if (enabled) {
		if (r_group) {
			r_navigationBar.topItem.rightBarButtonItem = r_editButton;
		}
	}else {
		r_navigationBar.topItem.rightBarButtonItem = nil;
	}
    
}

-(BOOL)isOperationLimited;
{
	return ![Util isFullVersion];
}

-(CGPoint)calculateCenterPointForShape:(NSString*)s
{
	if ([Util isPhone]) {
		CGSize sz = [s sizeWithFont:[UIFont boldSystemFontOfSize:20]];
		return CGPointMake(240+sz.width/2,16);
	}else {
		CGSize sz = [s sizeWithFont:[UIFont boldSystemFontOfSize:30]];
		if ([Util isPortrait:self]) {
			return CGPointMake(384+sz.width/2,20);
		}else {
			return CGPointMake(512+sz.width/2,20);
		}
        
	}
    
}

-(void)reshapeTriangleShape
{
	shape.hidden = NO;
    NSString *title = r_navigationBar.titleLabel.text;
    
    CGPoint shapeCenter = [self calculateCenterPointForShape:title];
    if (IS_IPHONE_5) {
        shape.center = CGPointMake(shapeCenter.x+IPHONE_5_NAV_PADDING,shapeCenter.y);
        
    } else {
        shape.center = CGPointMake(shapeCenter.x+IPHONE_4_NAV_PADDING,shapeCenter.y);
    }
	
	
	if ([Util isPhone]) {
		if (shape.center.x>420) {
			shape.hidden = YES;
		}
	}else {
		if ([Util isPortrait:self]) {
			if (shape.center.x>710) {
				shape.hidden = YES;
			}
		}else {
			if (shape.center.x>980) {
				shape.hidden = YES;
			}
		}
        
	}
    
	
}

-(NSInteger)findIndexForId:(NSInteger)cid inArr:(NSArray*)cards{
    NSInteger count = [cards count];
    NSInteger result = 0;
    for (int i=0; i<count; i++) {
        NSArray *card = [cards objectAtIndex:i];
        
        if ([[card objectAtIndex:0] intValue] == cid) {
            result = i;
            break;
        }
    }
    
    return result;
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -
#pragma mark activities

-(void)startActivity{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)stopActivity{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark private ends

#pragma mark -


#pragma mark -
#pragma mark group methods

-(void)updateGroupArray
{
	if (r_groupIDArray) {
		[r_groupIDArray removeAllObjects];
	}else {
		r_groupIDArray = [[NSMutableArray alloc] init];
	}
	
	NSArray *groupsArr = [[FDBController sharedDatabase] groupsid];
	
	if (groupsArr) {
		for (NSString *groupId in groupsArr) {
			NSString *name = [[FDBController sharedDatabase] nameForGroup:groupId];
			
			if (name) {
				NSArray *groupInfo = [NSArray arrayWithObjects:groupId,name,nil];
				[r_groupIDArray addObject:groupInfo];
			}
		}
	}
	
	[self sortGroupArray];
	
    
}

-(void)updateGroupStr
{
	if (r_group) {
		[r_group release];
		r_group = nil;
	}
	
	NSString *group = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultGroup"];
	
	if (group) {
		r_group = [[NSString alloc] initWithString:group];
	}else {
		
		if (r_groupIDArray && [r_groupIDArray count]>0) {
			NSArray *groupInfo = [r_groupIDArray objectAtIndex:0];
			r_group = [[NSString alloc] initWithString:[groupInfo objectAtIndex:0]];
		}
	}
	
}

-(void)sortGroupArray
{
	if (!r_groupIDArray || ![r_groupIDArray count]) {
		return;
	}
	
	[r_groupIDArray sortUsingFunction:groupCompareFunctions context:nil];
}

NSInteger groupCompareFunctions(id left, id right, void *context)
{
	NSString *name1 = [left objectAtIndex:1];
	NSString *name2 = [right objectAtIndex:1];
	
	return [name1 localizedCompare:name2];
}

#pragma mark group methods ends


@end
