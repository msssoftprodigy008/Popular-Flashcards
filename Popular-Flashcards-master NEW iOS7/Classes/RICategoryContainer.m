//
//  RICategoryContainer.m
//  FC 1.4
//
//  Created by Ruslan on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RICategoryContainer.h"
#import "FIAnimationController.h"
#import "Util.h"
#import "FIRoundedProgress.h"
#import "Constant.h"

@interface RICategoryContainer(Private)

#pragma mark init
-(void)createCards;
-(void)createPageControl;
-(void)bindRecognizers;

#pragma mark targets
-(void)handleDragged:(UIPanGestureRecognizer*)sender;
-(void)handleTapped:(UITapGestureRecognizer*)sender;
-(void)handleLongPressed:(UILongPressGestureRecognizer*)sender;
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)removeButtonPressed:(UIButton*)sender;
-(void)addCardPressed:(UITapGestureRecognizer*)sender;
-(void)settingsPressed:(UITapGestureRecognizer*)sender;

#pragma mark private
-(NSDictionary*)createContent:(NSInteger)index;
-(NSDictionary*)infoForSet:(NSInteger)index;
-(void)completeDragging;
-(void)completeDraggingAnimation:(NSInteger)which;
-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP;
-(void)updateCard:(NSInteger)tag;
-(void)updatePageControl;
-(void)renameCurrentCategory:(NSString*)newName;
-(void)removeCategory;
-(void)startEditing;
-(void)stopEditing;
-(void)hideItemsForViewTag:(BOOL)isHidden forTag:(NSInteger)tag animated:(BOOL)isAnimated;
-(void)animateRemoving:(UIView*)card;





@end

@implementation RICategoryContainer
@synthesize r_delegate;

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

-(id)initWithCategories:(NSArray*)categories
{
	if (self = [super init]) {
		r_categories = [[NSMutableArray alloc] initWithArray:categories];
	}
	
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	CGRect frame;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            frame = CGRectMake(0,0,568,300);
		}else{
            frame = CGRectMake(0,0,480,300);
        }
		
	}else {
		
		frame = CGRectMake(0,0,768,1024);
	}
    
	UIView* contentView = [[UIView alloc] initWithFrame:frame];
	contentView.backgroundColor = [UIColor clearColor];
	self.view = contentView;
	[contentView release];
    
	r_isNoButtonsMode = NO;
	r_animationId = 0;
	
	[self createCards];
	[self bindRecognizers];
	[self createPageControl];
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ServiceButton" ofType:@"wav"]], &addSoundID);
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"EnterSet" ofType:@"wav"]], &tapSetSoundID);
}

#pragma mark -
#pragma mark public methods

-(void)removeCurrentSetFromList{
	[r_categories removeObjectAtIndex:r_currentId];
	
	if (r_categories && [r_categories count]>0) {
		r_currentId = r_currentId%[r_categories count];
		
		if (r_currentId == 0) {
			r_isFirstCard = YES;
		}else {
			r_isFirstCard = NO;
		}
        
		if (r_currentId == [r_categories count]-1) {
			r_isLastCard = YES;
		}else {
			r_isLastCard = NO;
		}
        
	}
	
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	
	if ([r_categories count] == 0) {
		r_currentId = 0;
        
		if (r_delegate && [r_delegate respondsToSelector:@selector(didEditEnd)]) {
			[r_delegate didEditEnd];
		}
        
		r_isEdit = NO;
		[self stopEditing];
		[self edit:NO];
		
		r_centerCard.hidden = YES;
		[self updatePageControl];
		return;
	}else {
		[self updateCard:100];
		[self updateCard:102];
		
	}
	
	[self performSelector:@selector(animateRemoving:)
			   withObject:r_centerCard
			   afterDelay:0.5f];
	[self updatePageControl];
}

-(void)changeCategories:(NSArray*)newCategories
{
	if (newCategories) {
		
		if (r_categories) {
			[r_categories removeAllObjects];
		}else {
			r_categories = [[NSMutableArray alloc] init];
		}
		
		
		[r_categories addObjectsFromArray:newCategories];
		
		r_isFirstCard = YES;
		
		r_currentId = 0;
		
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		r_centerCard.hidden = NO;
        
		if (r_categories && [r_categories count]<=1) {
			r_isLastCard = YES;
            
			if ([r_categories count] == 0) {
				r_centerCard.hidden = YES;
			}
            
		}else {
			r_isLastCard = NO;
		}
        
		[self updateCard:101];
		[self updateCard:102];
		[self updatePageControl];
	}
}

-(void)changeCategoriesWithFeedBack:(NSArray*)newCategories{
    [self changeCategories:newCategories];
    if (r_delegate && [r_delegate respondsToSelector:@selector(groupIsLoaded)]) {
        [r_delegate groupIsLoaded];
    }
}

-(void)createNewCategory:(NSDictionary*)category animated:(BOOL)isAnimated withEditing:(BOOL)isEditingField
{
	if (category && r_categories) {
		[r_categories addObject:category];
		r_currentId = [r_categories count]-1;
		
		[self updateCard:100];
		[self updateCard:101];
		[self updateCard:102];
		
		r_isLastCard = YES;
		
		if (r_currentId==0) {
			r_isFirstCard = YES;
		}else {
			r_isFirstCard = NO;
		}
        
		
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		r_centerCard.hidden = NO;
        
		if (isAnimated) {
			
			if (isEditingField)
			{
				r_animationId = -1;
				[[FIAnimationController sharedAnimation:self] pushView:r_centerCard dir:kCATransitionFromRight];
			}
			else {
				[[FIAnimationController sharedAnimation:nil] pushView:r_centerCard dir:kCATransitionFromRight];
			}
            
		}
		
		[self updatePageControl];
	}
}

-(void)edit:(BOOL)isEdit
{
	if (!r_categories || [r_categories count]<=0) {
		
		if (r_delegate && [r_delegate respondsToSelector:@selector(didEditEnd)]) {
			[r_delegate didEditEnd];
		}
		
		return;
	}
	
	if (isEdit) {
		if (!r_isEdit) {
			r_isEdit = YES;
            
			if (r_categories && r_currentId == [r_categories count]-1) {
				r_isLastCard = YES;
			}
			[self startEditing];
		}
	}else {
		if (r_isEdit) {
			r_isEdit = NO;
			
			[self stopEditing];
		}
	}
}



-(NSString*)currentCategoryId
{
	if (r_categories && r_currentId>=0 && [r_categories count]>r_currentId) {
		NSDictionary *category = [r_categories objectAtIndex:r_currentId];
		return [category objectForKey:@"c"];
	}
	
	return nil;
}

-(void)updateCurrentCategory:(NSDictionary*)category
{
	if (category) {
		if (r_categories && r_currentId>=0 && [r_categories count]>r_currentId) {
			[r_categories replaceObjectAtIndex:r_currentId withObject:category];
			[self updateCard:101];
			
		}
	}
}

-(void)updateTestInfoLabel:(FICardPosition)position
{
	UIView *card;
	NSInteger updateId;
	
	if (!r_categories || [r_categories count]==0) {
		return;
	}
	
	NSInteger categoryCount = [r_categories count];
	
	switch (position) {
		case FICardPositionLeft:
			card = (UIView*)[self.view viewWithTag:100];
			updateId = (r_currentId-1+categoryCount)%categoryCount;
			break;
		case FICardPositionCenter:
			card = (UIView*)[self.view viewWithTag:101];
			updateId = r_currentId;
			break;
		case FICardPositionRight:
			card = (UIView*)[self.view viewWithTag:102];
			updateId = (r_currentId+1)%categoryCount;
			break;
		default:
			break;
	}
	
	if (card) {
		UILabel *infoLabel = (UILabel*)[card viewWithTag:112];
		
		NSDictionary *infoDic = [self infoForSet:updateId];
		NSInteger testCount = [[infoDic objectForKey:@"test"] intValue];
		BOOL isSO = [[infoDic objectForKey:@"isSO"] boolValue];
        BOOL isAL = [[infoDic objectForKey:@"isAL"] boolValue];
        NSInteger count = [[infoDic objectForKey:@"count"] intValue];
        
        NSString *labelStr = @"";
        
        if (count==0) {
            labelStr = @"Tap to add new cards";
        }else{
            
            if(isAL){
                labelStr = @"All cards studied";
            }else{
                if (!isSO) {
                    labelStr = @"Tap to start new session";
                }else{
                    if (testCount>0) {
                        if (testCount == 1) {
                            labelStr = [labelStr stringByAppendingFormat:@"1 card to test"];
                        }else {
                            labelStr = [labelStr stringByAppendingFormat:@"%d cards to test",testCount];
                        }
                    }
                }
            }
        }
        infoLabel.text = labelStr;
	}
}

-(void)setTitleHidden:(BOOL)isHidden animated:(BOOL)isAnimated
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FICardView *card = (FICardView*)[r_centerCard viewWithTag:105];
	r_centerTitle = (UITextField*)[r_centerCard viewWithTag:107];
	UILabel *fieldLabel = (UILabel*)[r_centerCard viewWithTag:114];
	CGPoint c;
	CGPoint cLabel;
	
	
	if (isHidden) {
		[r_centerCard bringSubviewToFront:card];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c = CGPointMake(card.center.x,card.frame.origin.y+r_centerTitle.frame.size.height/2.0);
			cLabel = CGPointMake(card.center.x,card.frame.origin.y+r_centerTitle.frame.size.height/2.0);
		}else {
			c = CGPointMake(kFCardLargeWidth/2+52,95);
			cLabel = CGPointMake(kFCardLargeWidth/2+52,90);
		}
        
		
	}else {
        
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c = CGPointMake(card.center.x,r_centerTitle.frame.size.height/2.0);
			cLabel = CGPointMake(card.center.x,r_centerTitle.frame.size.height/2.0);
		}else {
			c = CGPointMake((kFCardLargeWidth-20)/2+52,30);
			cLabel = CGPointMake((kFCardLargeWidth-20)/2+52,25);
		}
        
	}
    
	if (isAnimated) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_centerTitle toPoint:c];
		[[FIAnimationController sharedAnimation:nil] moveCenter:fieldLabel toPoint:cLabel];
	}else {
		r_centerTitle.center = c;
		fieldLabel.center = cLabel;
	}
	
	
	
}

-(void)makeCenter:(BOOL)isCenter animated:(BOOL)isAnimated
{
    r_centerCard = (UIView*)[self.view viewWithTag:101];
    FICardView *card = (FICardView*)[r_centerCard viewWithTag:105];
    CGPoint c;
	
    if (isCenter) {
        
        if ([Util isPhone]) {
            CGPoint aP = [r_centerCard convertPoint:CGPointMake(((IS_IPHONE_5)?284:240),((IS_IPHONE_5)?184:140)) fromView:self.view];
            CGFloat tx = card.center.x-aP.x;
            CGFloat ty = card.center.y-aP.y;
            c = CGPointMake(((IS_IPHONE_5)?284:240)-tx,160-ty);
        }else {
            if ([Util isPortrait:(UIViewController*)r_delegate]) {
                c = CGPointMake(384,351);
            }else {
                c = CGPointMake(512,307);
            }
            
        }
        
    }else {
        if ([Util isPhone]) {
            c = CGPointMake(((IS_IPHONE_5)?284:240),160.0);
        }else {
            if ([Util isPortrait:(UIViewController*)r_delegate]) {
                c = CGPointMake(384,512);
            }else {
                c = CGPointMake(512,384);
            }
        }
        
    }
	
	
    if (isAnimated) {
        [[FIAnimationController sharedAnimation:nil] moveCenter:r_centerCard toPoint:c];
        
        [UIView beginAnimations:@"fadeShadow" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDuration:0.5f];
        
        if (isCenter) {
            [card setShadowOffset:CGPointMake(0.0,0.0)];
        }else {
            [card setShadowOffset:CGPointMake(0.0,5.0)];
        }
        
        
        [UIView commitAnimations];
        
    }else {
        r_centerCard.center = c;
        if (isCenter) {
            [card setShadowOffset:CGPointMake(0.0,0.0)];
        }else {
            [card setShadowOffset:CGPointMake(0.0,5.0)];
        }
    }
	
    
}

-(void)wrapBgDeckView:(BOOL)hidden animated:(BOOL)animated
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	UIImageView* bgDeckView = (UIImageView*)[r_centerCard viewWithTag:113];
	
	if (animated) {
		[UIView beginAnimations:@"wrap" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.25f];
		
		if (hidden) {
			bgDeckView.transform = CGAffineTransformMakeScale(1.0,0.001);
		}else {
			bgDeckView.transform = CGAffineTransformIdentity;
		}
		
		[UIView commitAnimations];
	}else {
		if (hidden) {
			bgDeckView.transform = CGAffineTransformMakeScale(1.0,0.001);
		}else {
			bgDeckView.transform = CGAffineTransformIdentity;
		}
	}
    
}

-(void)makeIpadSceneCenter:(BOOL)isCenter animated:(BOOL)animated
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FICardView *card = (FICardView*)[r_centerCard viewWithTag:105];
	
	CGPoint c;
	
	if (isCenter) {
		
		if ([Util isPortrait:(UIViewController*)r_delegate]) {
			c = CGPointMake(384,482);
		}else {
			c = CGPointMake(512,354);
		}
        
	}else {
		if ([Util isPortrait:(UIViewController*)r_delegate]) {
			c = CGPointMake(384,512);
		}else {
			c = CGPointMake(512,384);
		}
	}
	
	
	if (animated) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_centerCard toPoint:c];
		[UIView beginAnimations:@"fadeShadow" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:0.5f];
		
		if (isCenter) {
			[card setShadowOffset:CGPointMake(0.0,0.0)];
		}else {
			[card setShadowOffset:CGPointMake(0.0,5.0)];
		}
		[UIView commitAnimations];
	}else {
		r_centerCard.center = c;
		if (isCenter) {
			[card setShadowOffset:CGPointMake(0.0,0.0)];
		}else {
			[card setShadowOffset:CGPointMake(0.0,5.0)];
		}
	}
}

-(void)setCenterCardHidden:(BOOL)isHidden
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	r_centerCard.hidden = isHidden;
}

-(void)animateCard:(NSString*)animationType subType:(NSString*)subType duration:(CGFloat)duration speed:(CGFloat)speed{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FICardView *card = (FICardView*)[r_centerCard viewWithTag:105];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:card
														  type:animationType
													   subType:subType
													  duration:duration
														 speed:speed];
}

-(void)moveCardToRight:(BOOL)isAnimated
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	
	CGPoint c;
	
	if (UIUserInterfaceIdiomPhone) {
		c = CGPointMake(700,160.0);
	}else {
		
		if ([Util isPortrait:self]) {
			c = CGPointMake(868+kFCardLargeWidth/2,512);
		}else {
			c = CGPointMake(1080+kFCardLargeWidth/2,384);
		}
        
		
		
	}
    
	
	if (isAnimated) {
		[[FIAnimationController sharedAnimation:nil] moveCenter:r_centerCard toPoint:c];
	}else {
		r_centerCard.center = c;
	}
}

-(void)jumpCenterCard
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	[[FIAnimationController sharedAnimation:nil] fallAndTrembell:r_centerCard];
}

-(void)hideCardShadow:(BOOL)isHidden animated:(BOOL)isAnimate
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FICardView *card = (FICardView*)[r_centerCard viewWithTag:105];
	
	if (isAnimate) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDuration:1.0f];
		
		if (isHidden) {
			[card hideShadow];
		}else {
			[card seeShadow];
		}
        
		[UIView commitAnimations];
	}else {
		if (isHidden) {
			[card hideShadow];
		}else {
			[card seeShadow];
		}
	}
    
	
}

-(void)hideCard:(FICardPosition)position hidden:(BOOL)hidden
{
	UIView *card;
	
	switch (position) {
		case FICardPositionLeft:
			card = (UIView*)[self.view viewWithTag:100];
			break;
		case FICardPositionCenter:
			card = (UIView*)[self.view viewWithTag:101];
			break;
		case FICardPositionRight:
			card = (UIView*)[self.view viewWithTag:102];
			break;
		default:
			break;
	}
	
	if (card) {
		card.hidden = hidden;
	}
	
	return;
	
}

-(void)hideButtons:(BOOL)isHidden animated:(BOOL)isAnimated
{
	CGPoint c1;
	CGPoint c2;
	
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FICardView *centerCard = (FICardView*)[r_centerCard viewWithTag:105];
	FIRoundedButton *addButton = (FIRoundedButton*)[r_centerCard viewWithTag:108];
	FIRoundedButton *settingsButton = (FIRoundedButton*)[r_centerCard viewWithTag:109];
	UILabel *infoLabel = (UILabel*)[r_centerCard viewWithTag:112];
	
	if (isHidden) {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c1 = CGPointMake(settingsButton.frame.size.width+0.65*((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)-addButton.frame.size.width/2.0,addButton.center.y);
			c2 = CGPointMake(5+settingsButton.frame.size.width*1.5,settingsButton.center.y);
		}else {
			c1 = CGPointMake(kFCardLargeWidth+21,156);
			c2 = CGPointMake(63,156);
			
		}
		addButton.userInteractionEnabled = NO;
		settingsButton.userInteractionEnabled = NO;
		[r_centerCard bringSubviewToFront:centerCard];
		[r_centerCard bringSubviewToFront:infoLabel];
	}else {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c1 = CGPointMake(settingsButton.frame.size.width+10+0.65*((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)+addButton.frame.size.width/2.0,addButton.center.y);
			c2 = CGPointMake(settingsButton.frame.size.width/2.0,settingsButton.center.y);
		}else {
			c1 = CGPointMake(kFCardLargeWidth+63,156);
			c2 = CGPointMake(21,156);
		}
		addButton.userInteractionEnabled = YES;
		settingsButton.userInteractionEnabled = YES;
		if (!isAnimated) {
			[r_centerCard bringSubviewToFront:addButton];
			[r_centerCard bringSubviewToFront:settingsButton];
		}
	}
	
	if (isAnimated) {
		r_animationId = -2;
		[[FIAnimationController sharedAnimation:nil] moveCenter:addButton toPoint:c1];
		[[FIAnimationController sharedAnimation:self] moveCenter:settingsButton toPoint:c2];
	}else {
		addButton.center = c1;
		settingsButton.center = c2;
	}
	
	
	
}

-(void)hideCardButtons:(FICardPosition)position hidden:(BOOL)hidden animated:(BOOL)animated
{
	UIView *card;
	
	switch (position) {
		case FICardPositionLeft:
			card = (UIView*)[self.view viewWithTag:100];
			break;
		case FICardPositionCenter:
			card = (UIView*)[self.view viewWithTag:101];
			break;
		case FICardPositionRight:
			card = (UIView*)[self.view viewWithTag:102];
			break;
		default:
			break;
	}
	
	CGPoint c1;
	CGPoint c2;
	
	FICardView *content = (FICardView*)[card viewWithTag:105];
	FIRoundedButton *addButton = (FIRoundedButton*)[card viewWithTag:108];
	FIRoundedButton *settingsButton = (FIRoundedButton*)[card viewWithTag:109];
	UILabel *infoLabel = (UILabel*)[card viewWithTag:112];
	
	
	if (hidden) {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c1 = CGPointMake(settingsButton.frame.size.width+0.65*kFCardWidth-addButton.frame.size.width/2.0,addButton.center.y);
			c2 = CGPointMake(5+settingsButton.frame.size.width*1.5,settingsButton.center.y);
		}else {
			c1 = CGPointMake(kFCardLargeWidth+21,151);
			c2 = CGPointMake(63,151);
			
		}
		addButton.userInteractionEnabled = NO;
		settingsButton.userInteractionEnabled = NO;
		[card bringSubviewToFront:content];
		[card bringSubviewToFront:infoLabel];
	}else {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			c1 = CGPointMake(settingsButton.frame.size.width+10+0.65*kFCardWidth+addButton.frame.size.width/2.0,addButton.center.y);
			c2 = CGPointMake(settingsButton.frame.size.width/2.0,settingsButton.center.y);
		}else {
			c1 = CGPointMake(kFCardLargeWidth+63,156);
			c2 = CGPointMake(21,156);
		}
		addButton.userInteractionEnabled = YES;
		settingsButton.userInteractionEnabled = YES;
		if (!animated) {
			[card bringSubviewToFront:addButton];
			[card bringSubviewToFront:settingsButton];
		}
	}
	
	if (animated) {
		r_animationId = -2;
		[[FIAnimationController sharedAnimation:nil] moveCenter:addButton toPoint:c1];
		[[FIAnimationController sharedAnimation:self] moveCenter:settingsButton toPoint:c2];
	}else {
		addButton.center = c1;
		settingsButton.center = c2;
	}
	
}

-(void)hideInfoLabel:(BOOL)hidden animated:(BOOL)animated
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	UILabel *infoLabel = (UILabel*)[r_centerCard viewWithTag:112];
	FIRoundedProgress *progress = (FIRoundedProgress*)[r_centerCard viewWithTag:115];
	[r_centerCard bringSubviewToFront:infoLabel];
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	}
	
	if(hidden){
		infoLabel.alpha = 0.0;
		progress.alpha = 0.0;
	}else {
		infoLabel.alpha = 1.0;
		progress.alpha = 1.0;
	}
    
	
	if (animated) {
		[UIView commitAnimations];
	}
	
	
}

-(void)rotateView:(UIInterfaceOrientation)orientation
{
	if (![Util isPhone]) {
		r_leftCard = (UIView*)[self.view viewWithTag:100];
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		r_rightCard = (UIView*)[self.view viewWithTag:102];
        
		//if ([Util isPortraitWithOrientation:orientation]) {
//			self.view.frame = CGRectMake(0,0,768,1024);
//			r_leftCard.center = CGPointMake(-r_leftCard.frame.size.width/2,512);
//			r_centerCard.center = CGPointMake(384,512);
//			r_rightCard.center = CGPointMake(768+r_rightCard.frame.size.width/2,512);
//			r_pageControlView.center = CGPointMake(384,984);
		//}else {
			self.view.frame = CGRectMake(0,0,1024,768);
			r_leftCard.center = CGPointMake(-r_leftCard.frame.size.width/2,384);
			r_centerCard.center = CGPointMake(512,384);
			r_rightCard.center = CGPointMake(1024+r_rightCard.frame.size.width/2,384);
			r_pageControlView.center = CGPointMake(512,728);
		//}
	}
    
}

#pragma mark public ends



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	r_isFirstCard = YES;
	
	
	r_currentId = 0;
	
	if (r_categories && [r_categories count]<=1) {
		r_isLastCard = YES;
	}else {
		r_isLastCard = NO;
	}
    
	[self rotateView:self.interfaceOrientation];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	
	if ([Util isPhone]) {
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}else {
		return YES;
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
    AudioServicesDisposeSystemSoundID(tapSetSoundID);
    AudioServicesDisposeSystemSoundID(addSoundID);
	if (r_categories) {
		[r_categories release];
	}
	
    [super dealloc];
}

#pragma mark main methods ends

#pragma mark -
#pragma mark UIPageControl delegate

-(void)pageChanged:(UIPageControl*)sender
{
	NSInteger oldId = r_currentId;
	NSInteger newId = r_pageControlView.currentPage;
	
	if (oldId != newId) {
		if (oldId>newId) {
			[self completeDraggingAnimation:2];
		}else {
			[self completeDraggingAnimation:0];
		}
        
	}
	
}

#pragma mark UIPageControl delegate ends

#pragma mark -
#pragma mark FIAnimationController delegate

-(void)didEndAnimation
{
	if (r_animationId == -1) {
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		r_centerTitle = (UITextField*)[r_centerCard viewWithTag:107];
        
		if (r_centerTitle) {
			[r_centerTitle performSelector:@selector(becomeFirstResponder)
								withObject:nil afterDelay:0.25f];
		}
	}
	
	if (r_animationId == -2) {
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		FIRoundedButton *addButton = (FIRoundedButton*)[r_centerCard viewWithTag:108];
		FIRoundedButton *settingsButton = (FIRoundedButton*)[r_centerCard viewWithTag:109];
		[r_centerCard bringSubviewToFront:addButton];
		[r_centerCard bringSubviewToFront:settingsButton];
	}
	
	r_animationId = 0;
	
}

#pragma mark FIAnimationController delegate ends

#pragma mark -
#pragma mark TextField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    

	[self renameCurrentCategory:textField.text];

    UIView *card = (UIView*)[self.view viewWithTag:101];
	UILabel *fieldLabel = (UILabel*)[card viewWithTag:114];
    fieldLabel.alpha = 1.0;
	textField.textColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:textField
														  type:kCATransitionFade
														   dir:kCATransitionFromTop];
    [[FIAnimationController sharedAnimation:nil] makeAnimation:fieldLabel
														  type:kCATransitionFade
														   dir:kCATransitionFromTop];
	
	r_centerTitle.borderStyle = UITextBorderStyleNone;
	
	if (r_delegate) {
		((UIViewController*)r_delegate).view.userInteractionEnabled = YES;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (r_delegate) {
		((UIViewController*)r_delegate).view.userInteractionEnabled = YES;
	}
	
    UIView *card = (UIView*)[self.view viewWithTag:101];
	UILabel *fieldLabel = (UILabel*)[card viewWithTag:114];
	   if ([r_centerTitle.text isEqualToString:@""]) {
           setName=textField.text;

           UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Message" message:@"Please name your set" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
           alert.tag=1212;
           [alert show];
           alert.delegate=self;
           [alert release];
       }else
       {
            setName=textField.text;
	    [self renameCurrentCategory:textField.text];
       }
    fieldLabel.alpha = 1.0;
	textField.textColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:textField
														  type:kCATransitionFade
														   dir:kCATransitionFromTop];
    [[FIAnimationController sharedAnimation:nil] makeAnimation:fieldLabel
														  type:kCATransitionFade
														   dir:kCATransitionFromTop];
    
	textField.borderStyle = UITextBorderStyleNone;
    if (![Util isPhone]) {
        textField.backgroundColor = [UIColor clearColor];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (r_isEdit) {
		return NO;
	}
    
    UIView *card = (UIView*)[self.view viewWithTag:101];
	UILabel *fieldLabel = (UILabel*)[card viewWithTag:114];
	
	textField.textColor = [UIColor colorWithWhite:0.0 alpha:1.0];
    fieldLabel.alpha = 0.0;
	[[FIAnimationController sharedAnimation:nil] makeAnimation:textField
														  type:kCATransitionFade
														   dir:kCATransitionFromBottom];
    [[FIAnimationController sharedAnimation:nil] makeAnimation:fieldLabel
														  type:kCATransitionFade
														   dir:kCATransitionFromBottom];
	textField.borderStyle = UITextBorderStyleRoundedRect;
    if (![Util isPhone]) {
        textField.backgroundColor = [UIColor whiteColor];
    }
	
    
	if (r_delegate) {
		((UIViewController*)r_delegate).view.userInteractionEnabled = NO;
	}
    
       
    
	return YES;
    
}

#pragma mark TextField delegate ends

#pragma mark -
#pragma mark UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 1313) {
		[self removeCategory];
	}
    if (alertView.tag==1212) {

        
       // [r_centerTitle resignFirstResponder];
        [self renameCurrentCategory:setName];
       
    }
}
#pragma mark UIAlertView delegate ends


#pragma mark -
#pragma mark init

-(void)createCards
{
	if (!r_categories) {
		return;
	}
	
	CGRect addButtonFrame;
	CGRect prefButtonFrame;
	CGRect deleteButtonFrame;
	CGRect titleFrame;
	CGRect labelFrame;
	CGRect cardFrame;
	CGRect cardBgFrame;
	CGPoint cardCenterPoint;
	
	UIImage *addButtonImage;
	UIImage *addButtonImageH;
	UIImage *settingsButtonImage;
	UIImage *settingsButtonImageH;
	UIImage *deleteButtonImage;
	UIImage *deleteButtonImageH;
	
	if ([Util isPhone]) {
		addButtonImage = [UIImage imageNamed:@"i_set_plus1.png"];
		addButtonImageH = [UIImage imageNamed:@"i_set_plus2.png"];
		settingsButtonImage = [UIImage imageNamed:@"i_set_settings1.png"];
		settingsButtonImageH = [UIImage imageNamed:@"i_set_settings2.png"];
		deleteButtonImage = [UIImage imageNamed:@"i_set_delete_1.png"];
		deleteButtonImageH = [UIImage imageNamed:@"i_set_delete_2.png"];
		UIImage *cardBgImage = [UIImage imageNamed:@"i_set_screen2.png"];
        
        if (IS_IPHONE_5) {
            cardFrame = CGRectMake(0,0,settingsButtonImage.size.width+kFCardWidthIPhone5*0.65+addButtonImage.size.width+5,46+kFCardHieght*0.65);
            titleFrame = CGRectMake(cardFrame.size.width/2.0-0.65*kFCardWidthIPhone5/2.0,0,kFCardWidthIPhone5*0.65,36.0);
            labelFrame = CGRectMake(cardFrame.size.width/2.0-0.65*kFCardWidthIPhone5/2.0,0,kFCardWidthIPhone5*0.65,36.0);
            prefButtonFrame = CGRectMake(0,cardFrame.size.height-5-settingsButtonImage.size.height,settingsButtonImage.size.width,settingsButtonImage.size.height);
            addButtonFrame = CGRectMake(kFCardWidthIPhone5*0.65+settingsButtonImage.size.width+10,cardFrame.size.height-5-addButtonImage.size.height,addButtonImage.size.width,
                                        addButtonImage.size.height);
            deleteButtonFrame = CGRectMake(kFCardWidthIPhone5*0.65+settingsButtonImage.size.width+5-deleteButtonImage.size.width/2.0,
                                           titleFrame.size.height-deleteButtonImage.size.height/2.0,
                                           deleteButtonImage.size.width,
                                           deleteButtonImage.size.height);
            cardCenterPoint = CGPointMake(0.65*kFCardWidthIPhone5/2.0+prefButtonFrame.size.width+5,titleFrame.size.height+6+0.65*kFCardHieght/2.0);
            if (IS_IPHONE_5) {
                cardBgFrame = CGRectMake(settingsButtonImage.size.width+5,titleFrame.size.height,355,cardBgImage.size.height);
            }
            else{
                cardBgFrame = CGRectMake(settingsButtonImage.size.width+5,titleFrame.size.height,cardBgImage.size.width,cardBgImage.size.height);
            }
            
        }
        else{
            cardFrame = CGRectMake(0,0,settingsButtonImage.size.width+kFCardWidth*0.65+addButtonImage.size.width+5,46+kFCardHieght*0.65);
            titleFrame = CGRectMake(cardFrame.size.width/2.0-0.65*kFCardWidth/2.0,0,kFCardWidth*0.65,36.0);
            labelFrame = CGRectMake(cardFrame.size.width/2.0-0.65*kFCardWidth/2.0,0,kFCardWidth*0.65,36.0);
            prefButtonFrame = CGRectMake(0,cardFrame.size.height-5-settingsButtonImage.size.height,settingsButtonImage.size.width,settingsButtonImage.size.height);
            addButtonFrame = CGRectMake(kFCardWidth*0.65+settingsButtonImage.size.width+10,cardFrame.size.height-5-addButtonImage.size.height,addButtonImage.size.width,
                                        addButtonImage.size.height);
            deleteButtonFrame = CGRectMake(kFCardWidth*0.65+settingsButtonImage.size.width+5-deleteButtonImage.size.width/2.0,
                                           titleFrame.size.height-deleteButtonImage.size.height/2.0,
                                           deleteButtonImage.size.width,
                                           deleteButtonImage.size.height);
            cardCenterPoint = CGPointMake(0.65*kFCardWidth/2.0+prefButtonFrame.size.width+5,titleFrame.size.height+6+0.65*kFCardHieght/2.0);
            cardBgFrame = CGRectMake(settingsButtonImage.size.width+5,titleFrame.size.height,cardBgImage.size.width,cardBgImage.size.height);
        }
        
		
	}else {
        deleteButtonImage = [UIImage imageNamed:@"set_delete_1.png"];
		deleteButtonImageH = [UIImage imageNamed:@"set_delete_2.png"];
		addButtonFrame = CGRectMake(kFCardLargeWidth+42,85,42,142);
		prefButtonFrame = CGRectMake(0,85,42,142);
		deleteButtonFrame = CGRectMake(kFCardLargeWidth,20,deleteButtonImage.size.width,deleteButtonImage.size.height);
		titleFrame = CGRectMake(52.0,15.0,kFCardLargeWidth-20,50.0);
		labelFrame = CGRectMake(52.0,0.0,kFCardLargeWidth-20,50.0);
		cardCenterPoint = CGPointMake(kFCardLargeWidth/2.0+42.0,60+kFCardLargeHeight/2.0);
		addButtonImage = [UIImage imageNamed:@"add_card_1.png"];
		addButtonImageH = [UIImage imageNamed:@"add_card_2.png"];
		settingsButtonImage = [UIImage imageNamed:@"set_settings_1.png"];
		settingsButtonImageH = [UIImage imageNamed:@"set_settings_2.png"];
	}
    
	
	NSInteger all = [r_categories count];
	
	NSDictionary *categoryDelegate;
	BOOL isBothSide;
	BOOL isReversed;
	NSString *font;
	NSInteger fontsize;
	NSInteger cardsCount;
	NSString *categoryName;
	
	if (all>0) {
		categoryDelegate = [r_categories objectAtIndex:r_currentId];
		isBothSide = [[categoryDelegate objectForKey:@"isBoth"] boolValue];
		isReversed = [[categoryDelegate objectForKey:@"isRev"] boolValue];
		font = [categoryDelegate objectForKey:@"font"];
		fontsize = [[categoryDelegate objectForKey:@"fontsize"] intValue];
		categoryName = [categoryDelegate objectForKey:@"cname"];
		cardsCount = [[categoryDelegate objectForKey:@"cardsCount"] intValue];
	}else {
		font = nil;
		categoryName = nil;
		cardsCount = 0;
	}
    
	
	//create center card
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSLog(@"Card Frame :--> %f,%f,%f,%f",cardFrame.origin.x,cardFrame.origin.y,cardFrame.size.width,cardFrame.size.height);
		r_centerCard = [[UIView alloc] initWithFrame:cardFrame];
        if (IS_IPHONE_5) {
            r_centerCard.center = CGPointMake(280,160.0);
        }
        else{
            r_centerCard.center = CGPointMake(240,160.0);
        }
        
	}else {
		r_centerCard = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,kFCardLargeWidth+84,kFCardLargeHeight+60)];
		r_centerCard.center = CGPointMake(512,384);
	}
    
	
	r_centerCard.backgroundColor = [UIColor clearColor];
	r_centerCard.tag = 101;
	FICardView* centerCard;
	
	
	if ([r_categories count]>0) {
		centerCard = [[FICardView alloc] initWithContent:[self createContent:r_currentId] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	}else {
		centerCard = [[FICardView alloc] initWithContent:nil forSide:NO forRev:NO forCheckBox:NO];
	}
    
	centerCard.currentFont = [UIFont fontWithName:font size:fontsize];
	centerCard.userInteractionEnabled = NO;
	//[centerCard hideShadow];
	[centerCard setShadowOffset:CGPointMake(0.0,5.0)];
	centerCard.delegate = self;
	
	centerCard.center = cardCenterPoint;
	centerCard.tag = 105;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		centerCard.transform = CGAffineTransformMakeScale(0.65,0.65);
	}else {
		
	}
	UIColor *titleColor = [UIColor colorWithRed:104.0/255.0 green:56.0/255.0 blue:12.0/255.0 alpha:1.0];
	UILabel *r_centerTextLabel = [[UILabel alloc] initWithFrame:labelFrame];
	r_centerTextLabel.tag = 114;
	r_centerTextLabel.backgroundColor = [UIColor clearColor];
	r_centerTextLabel.textColor = titleColor;
	r_centerTextLabel.shadowOffset = CGSizeMake(0.0,1.0);
	r_centerTextLabel.shadowColor = [UIColor whiteColor];
	r_centerTextLabel.textAlignment = NSTextAlignmentCenter;
	
	r_centerTextLabel.font = [UIFont fontWithName:@"Helvetica" size:21];
	
	if (categoryName) {
//                    if ([categoryName isEqualToString:@""]) {
//        
//                        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please name your set" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"", nil];
//                        [alert show];
//                       [alert release];
//        
//                    }else
//                    {
		[r_centerTextLabel setText:categoryName];
                    //}
	}
	
	[r_centerCard addSubview:r_centerTextLabel];
	[r_centerTextLabel release];
	
	
	r_centerTitle = [[UITextField alloc] initWithFrame:titleFrame];
	r_centerTitle.backgroundColor = [UIColor clearColor];
	r_centerTitle.textColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
	r_centerTitle.returnKeyType = UIReturnKeyDone;
	r_centerTitle.tag = 107;
	r_centerTitle.delegate = self;
	r_centerTitle.borderStyle = UITextBorderStyleNone;
	r_centerTitle.adjustsFontSizeToFitWidth = YES;
    r_centerTitle.delegate=self;
    //r_centerTitle.placeholder=@"Please enter set name";
	r_centerTitle.textAlignment = NSTextAlignmentCenter;
	r_centerTitle.font = [UIFont boldSystemFontOfSize:21];
    
//                if ([r_centerTitle.text  isEqualToString:@""]) {
//    
//                    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please name your set" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"", nil];
//                    [alert show];
//                   [alert release];
//    
//                }else
//                {
//                }
    
	if (categoryName) {
		

           r_centerTitle.text = categoryName;
     
	}
                
	[r_centerCard addSubview:r_centerTitle];
	[r_centerTitle release];
	
	[r_centerCard addSubview:centerCard];
	[centerCard release];
    
	UIImageView* centerBgView;
	
	if ([Util isPhone]) {
		centerBgView = [[UIImageView alloc] initWithFrame:cardBgFrame];
		if (cardsCount>0) {
			
			if (cardsCount==1) {
				centerBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				centerBgView.image = [UIImage imageNamed:@"i_set_screen2.png"];
			}else {
				centerBgView.image = [UIImage imageNamed:@"i_set_screen3.png"];
			}
            
		}
        
	}else {
		centerBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardLargeWidth,kFCardLargeHeight)];
		if (cardsCount>0) {
			
			if (cardsCount==1) {
				centerBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				centerBgView.image = [UIImage imageNamed:@"sets2.png"];
			}else {
				centerBgView.image = [UIImage imageNamed:@"sets3.png"];
			}
			
		}
        
	}
    
	if ([Util isPhone]) {
        
	}else {
		centerBgView.center = CGPointMake(centerCard.center.x,centerCard.center.y-15);
	}
    
	centerBgView.tag = 113;
	[r_centerCard addSubview:centerBgView];
	[centerBgView release];
	[r_centerCard bringSubviewToFront:r_centerTitle];
	
	//buttons for center view
	CGRect infoLabelFrame;
	UIFont *infoLabelFont;
	
	if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            infoLabelFrame = CGRectMake(prefButtonFrame.size.width+5+0.65*kFCardWidthIPhone5-125,titleFrame.size.height+5,120,25);
        }
        else{
            infoLabelFrame = CGRectMake(prefButtonFrame.size.width+5+0.65*kFCardWidth-125,titleFrame.size.height+5,120,25);
        }
		
		infoLabelFont = [UIFont fontWithName:@"Helvetica" size:10];
	}else {
		infoLabelFrame = CGRectMake(kFCardLargeWidth-220,60,250,70);
        infoLabelFont = [UIFont fontWithName:@"Helvetica" size:22];
	}
	
	UILabel *infoCenterLabel = [[UILabel alloc] initWithFrame:infoLabelFrame];
	infoCenterLabel.font = infoLabelFont;
	infoCenterLabel.tag = 112;
	infoCenterLabel.numberOfLines = 1;
	infoCenterLabel.textAlignment = UITextAlignmentRight;
	infoCenterLabel.backgroundColor = [UIColor clearColor];
    infoCenterLabel.adjustsFontSizeToFitWidth = YES;
	infoCenterLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
	[r_centerCard addSubview:infoCenterLabel];
	[infoCenterLabel release];
	
	NSDictionary *infoDic = [self infoForSet:r_currentId];
	NSInteger testCount = [[infoDic objectForKey:@"test"] intValue];
    BOOL isSO = [[infoDic objectForKey:@"isSO"] boolValue];
    BOOL isAL = [[infoDic objectForKey:@"isAL"] boolValue];
    NSInteger count = [[infoDic objectForKey:@"count"] intValue];
	NSInteger diff = [[infoDic objectForKey:@"diff"] intValue];
    
	NSString *labelStr = @"";
    
    if (count==0) {
        labelStr = @"Tap to add new cards";
    }else{
        
        if(isAL){
            labelStr = @"All cards studied";
        }else{
            if (!isSO) {
                labelStr = @"Tap to start new session";
            }else{
                if (testCount>0) {
                    if (testCount == 1) {
                        labelStr = [labelStr stringByAppendingFormat:@"1 card to test"];
                    }else {
                        labelStr = [labelStr stringByAppendingFormat:@"%d cards to test",testCount];
                    }
                }
            }
        }
    }
    
	infoCenterLabel.text = labelStr;
    
	NSMutableArray *progressColorArr = [NSMutableArray array];
	NSDictionary *progressDic;
	if (cardsCount>0) {
		CGFloat knowPer = 100.0*((CGFloat)diff/(CGFloat)cardsCount);
        
        
		for (int i=0;i<4;i++) {
			
			if ((NSInteger)knowPer>i*30) {
				[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
			}else {
				[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
			}
			
		}
		
		if ((NSInteger)knowPer == 100) {
			[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
		}else {
			[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
		}
		
		if ([Util isPhone]) {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
                                                               [NSNumber numberWithInt:6],
                                                               [NSNumber numberWithInt:5],nil]
                                                      forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}else {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:10],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}
        
		
	}else {
		progressDic = nil;
	}
	
	CGRect progressFrame;
	
	if ([Util isPhone]) {
		progressFrame = CGRectMake(prefButtonFrame.size.width+5+30,r_centerTitle.frame.size.height+12,80,10);
	}else {
		progressFrame = CGRectMake(125,r_centerTitle.frame.size.height+45,80,14);
	}
    
	
	
	FIRoundedProgress *centerProgress = [[FIRoundedProgress alloc] initWithColors:progressFrame
																	   attributes:progressDic];
	centerProgress.tag = 115;
	[r_centerCard addSubview:centerProgress];
	[centerProgress release];
	
	if (cardsCount==0) {
		centerProgress.hidden = YES;
	}
	
	UIButton *addCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addCenterButton.frame = addButtonFrame;
    addCenterButton.exclusiveTouch = YES;
	addCenterButton.tag = 108;
	[addCenterButton setImage:addButtonImage forState:UIControlStateNormal];
	[addCenterButton setImage:addButtonImageH forState:UIControlStateHighlighted];
	[addCenterButton addTarget:self
						action:@selector(addCardPressed:)
			  forControlEvents:UIControlEventTouchUpInside];
	[r_centerCard addSubview:addCenterButton];
    
	UIButton *prefCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prefCenterButton.frame = prefButtonFrame;
    prefCenterButton.exclusiveTouch = YES;
	[prefCenterButton setImage:settingsButtonImage forState:UIControlStateNormal];
	[prefCenterButton setImage:settingsButtonImageH forState:UIControlStateHighlighted];
	prefCenterButton.tag = 109;
	[prefCenterButton addTarget:self
						 action:@selector(settingsPressed:)
			   forControlEvents:UIControlEventTouchUpInside];
	[r_centerCard addSubview:prefCenterButton];
    
	[r_centerCard bringSubviewToFront:centerCard];
	[r_centerCard bringSubviewToFront:infoCenterLabel];
	[r_centerCard bringSubviewToFront:addCenterButton];
	[r_centerCard bringSubviewToFront:prefCenterButton];
	
	UIButton *deleteCenterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteCenterButton.frame = deleteButtonFrame;
    deleteCenterButton.exclusiveTouch = YES;
	[deleteCenterButton setImage:deleteButtonImage forState:UIControlStateNormal];
	[deleteCenterButton setImage:deleteButtonImageH forState:UIControlStateHighlighted];
    
	[deleteCenterButton addTarget:self
						   action:@selector(removeButtonPressed:)
				 forControlEvents:UIControlEventTouchUpInside];
	
	deleteCenterButton.hidden = YES;
	deleteCenterButton.tag = 111;
	[r_centerCard addSubview:deleteCenterButton];
	
	
	if (all==0) {
		r_centerCard.hidden = YES;
	}
	
	[self.view addSubview:r_centerCard];
	[r_centerCard bringSubviewToFront:centerProgress];
	
	[r_centerCard release];
	
	
	
	//create left card
	
	
	if (all>0) {
		categoryDelegate = [r_categories objectAtIndex:(r_currentId-1+all)%all];
		isBothSide = [[categoryDelegate objectForKey:@"isBoth"] boolValue];
		isReversed = [[categoryDelegate objectForKey:@"isRev"] boolValue];
		font = [categoryDelegate objectForKey:@"font"];
		fontsize = [[categoryDelegate objectForKey:@"fontsize"] intValue];
		categoryName = [categoryDelegate objectForKey:@"cname"];
		cardsCount = [[categoryDelegate objectForKey:@"cardsCount"] intValue];
	}else {
		cardsCount = 0;
	}
    
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		r_leftCard = [[UIView alloc] initWithFrame:cardFrame];
		r_leftCard.center = CGPointMake(-kFCardWidth/2,160);
	}else {
		r_leftCard = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,kFCardLargeWidth+84,kFCardLargeHeight+60)];
		r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-42,384);
	}
    
	r_leftCard.backgroundColor = [UIColor clearColor];
	r_leftCard.tag = 100;
	
	FICardView* leftCard;
	
	if (all>0) {
		leftCard = [[FICardView alloc] initWithContent:[self createContent:(r_currentId-1+all)%all] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	}else {
		leftCard = [[FICardView alloc] initWithContent:nil forSide:NO forRev:NO forCheckBox:NO];
	}
    
	leftCard.currentFont = [UIFont fontWithName:font size:fontsize];
	leftCard.userInteractionEnabled = NO;
	//[leftCard hideShadow];
	[leftCard setShadowOffset:CGPointMake(0.0,5.0)];
	leftCard.delegate = self;
	
	leftCard.center = cardCenterPoint;
	leftCard.tag = 105;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		leftCard.transform = CGAffineTransformMakeScale(0.65,0.65);
	}
	
	[r_leftCard	addSubview:leftCard];
	[leftCard release];
	
	UILabel *r_leftTextLabel = [[UILabel alloc] initWithFrame:labelFrame];
	r_leftTextLabel.tag = 114;
	r_leftTextLabel.backgroundColor = [UIColor clearColor];
	r_leftTextLabel.textColor = titleColor;
	r_leftTextLabel.shadowOffset = CGSizeMake(0.0,1.0);
	r_leftTextLabel.shadowColor = [UIColor whiteColor];
	r_leftTextLabel.textAlignment = UITextAlignmentCenter;
	
	r_leftTextLabel.font = [UIFont fontWithName:@"Helvetica" size:21];
	
	if (categoryName) {
		[r_leftTextLabel setText:categoryName];
	}
	
	[r_leftCard addSubview:r_leftTextLabel];
	[r_leftTextLabel release];
	
	r_leftTitle = [[UITextField alloc] initWithFrame:titleFrame];
	r_leftTitle.backgroundColor = [UIColor clearColor];
	r_leftTitle.textColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
	r_leftTitle.borderStyle = UITextBorderStyleNone;
	r_leftTitle.tag = 107;
	r_leftTitle.delegate = self;
	r_leftTitle.returnKeyType = UIReturnKeyDone;
	r_leftTitle.adjustsFontSizeToFitWidth = YES;
	r_leftTitle.textAlignment = UITextAlignmentCenter;
	r_leftTitle.font = [UIFont boldSystemFontOfSize:21];
	
	
	if (categoryName) {
		r_leftTitle.text = categoryName;
	}
	
	[r_leftCard addSubview:r_leftTitle];
	[r_leftTitle release];
	
	UIImageView* leftBgView;
	
	if ([Util isPhone]) {
		leftBgView = [[UIImageView alloc] initWithFrame:cardBgFrame];
		if (cardsCount>0) {
			if (cardsCount==1) {
				leftBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				leftBgView.image = [UIImage imageNamed:@"i_set_screen2.png"];
			}else {
				leftBgView.image = [UIImage imageNamed:@"i_set_screen3.png"];
			}
			
		}else {
			leftBgView.hidden = YES;
		}
        
	}else {
		leftBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardLargeWidth,kFCardLargeHeight)];
		if (cardsCount>0) {
			if (cardsCount==1) {
				leftBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				leftBgView.image = [UIImage imageNamed:@"sets2.png"];
			}else {
				leftBgView.image = [UIImage imageNamed:@"sets3.png"];
			}
			
		}else {
			leftBgView.hidden = YES;
		}
        
	}
    
	if ([Util isPhone]) {
        
	}else {
		leftBgView.center = CGPointMake(leftCard.center.x,leftCard.center.y-15);
	}
    
	leftBgView.tag = 113;
	[r_leftCard addSubview:leftBgView];
	[leftBgView release];
	[r_leftCard bringSubviewToFront:r_leftTitle];
	
	//buttons for left view
	
	UILabel *infoLeftLabel = [[UILabel alloc] initWithFrame:infoLabelFrame];
	infoLeftLabel.font = infoLabelFont;
	infoLeftLabel.tag = 112;
	infoLeftLabel.numberOfLines = 1;
	infoLeftLabel.textAlignment = UITextAlignmentRight;
    infoLeftLabel.adjustsFontSizeToFitWidth = YES;
	infoLeftLabel.backgroundColor = [UIColor clearColor];
	infoLeftLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
	[r_leftCard addSubview:infoLeftLabel];
	[infoLeftLabel release];
	
	if (r_currentId != 0) {
		infoDic = [self infoForSet:r_currentId-1];
		testCount = [[infoDic objectForKey:@"test"] intValue];
		isSO = [[infoDic objectForKey:@"isSO"] boolValue];
        isAL = [[infoDic objectForKey:@"isAL"] boolValue];
        count = [[infoDic objectForKey:@"count"] intValue];
		diff = [[infoDic objectForKey:@"diff"] intValue];
		
		labelStr = @"";
        if (count==0) {
            labelStr =@"Tap to add new cards";
        }else{
            
            if(isAL){
                labelStr = @"All cards studied";
            }else{
                if (!isSO) {
                    labelStr =@"Tap to start new session";
                }else{
                    if (testCount>0) {
                        if (testCount == 1) {
                            labelStr = [labelStr stringByAppendingFormat:@"1 card to test"];
                        }else {
                            labelStr = [labelStr stringByAppendingFormat:@"%d cards to test",testCount];
                        }
                    }
                }
            }
        }
        
		infoLeftLabel.text = labelStr;
	}
	
	progressColorArr = [NSMutableArray array];
	
	if (cardsCount>0) {
		CGFloat knowPer = 100.0*((CGFloat)diff/(CGFloat)cardsCount);
        
		for (int i=0;i<4;i++) {
			
			if ((NSInteger)knowPer>i*30) {
				[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
			}else {
				[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
			}
			
		}
		
		if ((NSInteger)knowPer == 100) {
			[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
		}else {
			[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
		}
		
		if ([Util isPhone]) {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:6],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}else {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:10],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}
	}else {
		progressDic = nil;
	}
    
	FIRoundedProgress *leftProgress = [[FIRoundedProgress alloc] initWithColors:progressFrame
                                                                     attributes:progressDic];
	leftProgress.tag = 115;
	[r_leftCard addSubview:leftProgress];
	[leftProgress release];
	
	if (cardsCount==0) {
		leftProgress.hidden = YES;
	}
	
	UIButton *addLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addLeftButton.frame = addButtonFrame;
    addLeftButton.exclusiveTouch = YES;
	addLeftButton.tag = 108;
	[addLeftButton setImage:addButtonImage forState:UIControlStateNormal];
	[addLeftButton setImage:addButtonImageH forState:UIControlStateHighlighted];
	[addLeftButton addTarget:self
                      action:@selector(addCardPressed:)
            forControlEvents:UIControlEventTouchUpInside];
	[r_leftCard addSubview:addLeftButton];
	
	UIButton *prefLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prefLeftButton.frame = prefButtonFrame;
    prefLeftButton.exclusiveTouch = YES;
	[prefLeftButton setImage:settingsButtonImage forState:UIControlStateNormal];
	[prefLeftButton setImage:settingsButtonImageH forState:UIControlStateHighlighted];
	prefLeftButton.tag = 109;
	[prefLeftButton addTarget:self
                       action:@selector(settingsPressed:)
             forControlEvents:UIControlEventTouchUpInside];
	[r_leftCard addSubview:prefLeftButton];
	
	
	[r_leftCard bringSubviewToFront:leftCard];
	[r_leftCard bringSubviewToFront:infoLeftLabel];
	[r_leftCard bringSubviewToFront:addLeftButton];
	[r_leftCard bringSubviewToFront:prefLeftButton];
	
	UIButton *deleteLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteLeftButton.frame = deleteButtonFrame;
    deleteLeftButton.exclusiveTouch = YES;
	[deleteLeftButton setImage:deleteButtonImage forState:UIControlStateNormal];
	[deleteLeftButton setImage:deleteButtonImageH forState:UIControlStateHighlighted];
    
	[deleteLeftButton addTarget:self
                         action:@selector(removeButtonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
	
	deleteLeftButton.hidden = YES;
	deleteLeftButton.tag = 111;
	[r_leftCard addSubview:deleteLeftButton];
	
	[self.view addSubview:r_leftCard];
	[r_leftCard bringSubviewToFront:leftProgress];
	[r_leftCard release];
	
	if (all>0) {
		categoryDelegate = [r_categories objectAtIndex:(r_currentId+1)%all];
		isBothSide = [[categoryDelegate objectForKey:@"isBoth"] boolValue];
		isReversed = [[categoryDelegate objectForKey:@"isRev"] boolValue];
		font = [categoryDelegate objectForKey:@"font"];
		fontsize = [[categoryDelegate objectForKey:@"fontsize"] intValue];
		categoryName = [categoryDelegate objectForKey:@"cname"];
		cardsCount = [[categoryDelegate objectForKey:@"cardsCount"] intValue];
	}else {
		cardsCount = 0;
	}
    
	
	//create right card
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		r_rightCard = [[UIView alloc] initWithFrame:cardFrame];
        if (IS_IPHONE_5) {
            r_rightCard.center = CGPointMake(568+kFCardWidth/2,160);
		}else{
            r_rightCard.center = CGPointMake(480+kFCardWidth/2,160);
        }
		
	}else {
		r_rightCard = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,kFCardLargeWidth+84,kFCardLargeHeight+60)];
		r_rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+42,384);
	}
    
	r_rightCard.backgroundColor = [UIColor clearColor];
	
	r_rightCard.tag = 102;
	
	FICardView* rightCard;
	
	if (all>0) {
		rightCard = [[FICardView alloc] initWithContent:[self createContent:(r_currentId+1)%all] forSide:isBothSide forRev:isReversed forCheckBox:NO];
	}else {
		rightCard = [[FICardView alloc] initWithContent:nil forSide:NO forRev:NO forCheckBox:NO];
	}
    
	rightCard.currentFont = [UIFont fontWithName:font size:fontsize];
	rightCard.userInteractionEnabled = NO;
	//[rightCard hideShadow];
	[rightCard setShadowOffset:CGPointMake(0.0,5.0)];
	rightCard.delegate = self;
	
	rightCard.center = cardCenterPoint;
	rightCard.tag = 105;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		rightCard.transform = CGAffineTransformMakeScale(0.65,0.65);
	}
	
	[r_rightCard addSubview:rightCard];
	[rightCard release];
	
	UILabel *r_rightTextLabel = [[UILabel alloc] initWithFrame:labelFrame];
	r_rightTextLabel.tag = 114;
	r_rightTextLabel.backgroundColor = [UIColor clearColor];
	r_rightTextLabel.textColor = titleColor;
	r_rightTextLabel.shadowOffset = CGSizeMake(0.0,1.0);
	r_rightTextLabel.shadowColor = [UIColor whiteColor];
	r_rightTextLabel.textAlignment = UITextAlignmentCenter;
	
	r_rightTextLabel.font = [UIFont fontWithName:@"Helvetica" size:21];
	
	if (categoryName) {
		[r_rightTextLabel setText:categoryName];
	}
	
	[r_rightCard addSubview:r_rightTextLabel];
	[r_rightTextLabel release];
	
	r_rightTitle = [[UITextField alloc] initWithFrame:titleFrame];
	r_rightTitle.backgroundColor = [UIColor clearColor];
	r_rightTitle.textColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	r_rightTitle.returnKeyType = UIReturnKeyDone;
	r_rightTitle.delegate = self;
	r_rightTitle.tag = 107;
	r_rightTitle.adjustsFontSizeToFitWidth = YES;
	r_rightTitle.borderStyle = UITextBorderStyleNone;
	r_rightTitle.textAlignment = UITextAlignmentCenter;
	r_rightTitle.font = [UIFont boldSystemFontOfSize:21];
    
	
	if (categoryName) {
		r_rightTitle.text = categoryName;
	}
	
	[r_rightCard addSubview:r_rightTitle];
	[r_rightTitle release];
	
	UIImageView* rightBgView;
	
	if ([Util isPhone]) {
		rightBgView = [[UIImageView alloc] initWithFrame:cardBgFrame];
		if (cardsCount>0) {
			if (cardsCount==1) {
				rightBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				rightBgView.image = [UIImage imageNamed:@"i_set_screen2.png"];
			}else {
				rightBgView.image = [UIImage imageNamed:@"i_set_screen3.png"];
			}
			
		}
        
	}else {
		rightBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,kFCardLargeWidth,kFCardLargeHeight)];
		if (cardsCount>0) {
			if (cardsCount==1) {
				rightBgView.image = nil;
			}else if (cardsCount>=2 && cardsCount<=5) {
				rightBgView.image = [UIImage imageNamed:@"sets2.png"];
			}else {
				rightBgView.image = [UIImage imageNamed:@"sets3.png"];
			}
			
		}
        
	}
    
	if ([Util isPhone]) {
        
	}else {
		rightBgView.center = CGPointMake(rightCard.center.x,rightCard.center.y-15);
	}
    
	rightBgView.tag = 113;
	[r_rightCard addSubview:rightBgView];
	[rightBgView release];
	[r_rightCard bringSubviewToFront:r_rightTitle];
	
	//buttons for right view
	UILabel *infoRightLabel = [[UILabel alloc] initWithFrame:infoLabelFrame];
	infoRightLabel.font = infoLabelFont;
	infoRightLabel.tag = 112;
	infoRightLabel.numberOfLines = 1;
	infoRightLabel.textAlignment = UITextAlignmentRight;
    infoRightLabel.adjustsFontSizeToFitWidth = YES;
	infoRightLabel.backgroundColor = [UIColor clearColor];
	infoRightLabel.textColor = [UIColor colorWithWhite:0.5 alpha:0.5];
	[r_rightCard addSubview:infoRightLabel];
	[infoRightLabel release];
	
	if (r_currentId<[r_categories count]-1) {
		infoDic = [self infoForSet:r_currentId+1];
		testCount = [[infoDic objectForKey:@"test"] intValue];
		isSO = [[infoDic objectForKey:@"isSO"] boolValue];
        isAL = [[infoDic objectForKey:@"isAL"] boolValue];
        count = [[infoDic objectForKey:@"count"] intValue];
		diff = [[infoDic objectForKey:@"diff"] intValue];
        
		labelStr = @"";
		
        if (count==0) {
            labelStr = @"Tap to add new cards";
        }else{
            
            if(isAL){
                labelStr = @"All cards studied";
            }else{
                if (!isSO) {
                    labelStr = @"Tap to start new session";
                }else{
                    if (testCount>0) {
                        if (testCount == 1) {
                            labelStr = [labelStr stringByAppendingFormat:@"1 card to test"];
                        }else {
                            labelStr = [labelStr stringByAppendingFormat:@"%d cards to test",testCount];
                        }
                    }
                }
            }
        }
        
		infoRightLabel.text = labelStr;
	}
	
	progressColorArr = [NSMutableArray array];
	
	if (cardsCount>0) {
		CGFloat knowPer = 100.0*((CGFloat)diff/(CGFloat)cardsCount);
        
		for (int i=0;i<4;i++) {
			
			if ((NSInteger)knowPer>i*30) {
				[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
			}else {
				[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
			}
			
		}
		
		if ((NSInteger)knowPer == 100) {
			[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
		}else {
			[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
		}
		
		if ([Util isPhone]) {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:6],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}else {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:10],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}
	}else {
		progressDic = nil;
	}
	
	FIRoundedProgress *rightProgress = [[FIRoundedProgress alloc] initWithColors:progressFrame
                                                                      attributes:progressDic];
	rightProgress.tag = 115;
	[r_rightCard addSubview:rightProgress];
	[rightProgress release];
	
	if (cardsCount==0) {
		rightProgress.hidden = YES;
	}
	
	UIButton *addRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addRightButton.frame = addButtonFrame;
    addRightButton.exclusiveTouch = YES;
	addRightButton.tag = 108;
	[addRightButton setImage:addButtonImage forState:UIControlStateNormal];
	[addRightButton setImage:addButtonImageH forState:UIControlStateHighlighted];
	[addRightButton addTarget:self
                       action:@selector(addCardPressed:)
             forControlEvents:UIControlEventTouchUpInside];
	[r_rightCard addSubview:addRightButton];
	
	UIButton *prefRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	prefRightButton.frame = prefButtonFrame;
    prefRightButton.exclusiveTouch = YES;
	[prefRightButton setImage:settingsButtonImage forState:UIControlStateNormal];
	[prefRightButton setImage:settingsButtonImageH forState:UIControlStateHighlighted];
	prefRightButton.tag = 109;
	[prefRightButton addTarget:self
                        action:@selector(settingsPressed:)
              forControlEvents:UIControlEventTouchUpInside];
	[r_rightCard addSubview:prefRightButton];
	
	[r_rightCard bringSubviewToFront:rightCard];
	[r_rightCard bringSubviewToFront:infoRightLabel];
	[r_rightCard bringSubviewToFront:addRightButton];
	[r_rightCard bringSubviewToFront:prefRightButton];
	
	UIButton *deleteRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
	deleteRightButton.frame = deleteButtonFrame;
    deleteRightButton.exclusiveTouch = YES;
	[deleteRightButton setImage:deleteButtonImage forState:UIControlStateNormal];
	[deleteRightButton setImage:deleteButtonImageH forState:UIControlStateHighlighted];
	[r_rightCard addSubview:deleteRightButton];
	
	[deleteRightButton addTarget:self
                          action:@selector(removeButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
	
	deleteRightButton.hidden = YES;
	deleteRightButton.tag = 111;
	
	if (all==1) {
		r_rightCard.hidden = YES;
	}
	
	[self.view addSubview:r_rightCard];
	[r_rightCard bringSubviewToFront:rightProgress];
	[r_rightCard release];
	
}

-(void)bindRecognizers
{
	UIGestureRecognizer* panRecog = [[UIPanGestureRecognizer alloc] initWithTarget:self
																			action:@selector(handleDragged:)];
	panRecog.delegate = self;
	[self.view addGestureRecognizer:panRecog];
	
	[panRecog release];
	
	
	UITapGestureRecognizer* tapRecogLeftCard = [[UITapGestureRecognizer alloc] initWithTarget:self
																					   action:@selector(handleTapped:)];
	tapRecogLeftCard.delegate = self;
	UITapGestureRecognizer* tapRecogCenterCard = [[UITapGestureRecognizer alloc] initWithTarget:self
																						 action:@selector(handleTapped:)];
	tapRecogCenterCard.delegate = self;
	
	UITapGestureRecognizer* tapRecogRightCard = [[UITapGestureRecognizer alloc] initWithTarget:self
																						action:@selector(handleTapped:)];
	tapRecogRightCard.delegate = self;
	[r_centerCard addGestureRecognizer:tapRecogCenterCard];
	[r_leftCard addGestureRecognizer:tapRecogLeftCard];
	[r_rightCard addGestureRecognizer:tapRecogRightCard];
	
	[tapRecogLeftCard release];
	[tapRecogCenterCard release];
	[tapRecogRightCard release];
	
	UILongPressGestureRecognizer* longpressRecog = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																								 action:@selector(handleLongPressed:)];
	[self.view addGestureRecognizer:longpressRecog];
	
	longpressRecog.delegate = self;
	
	[longpressRecog release];
}

-(void)createPageControl
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        if (IS_IPHONE_5) {
            r_pageControlView = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0,280,568.0,20.0)];
		}else{
            r_pageControlView = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0,280,480.0,20.0)];
        }
	}else {
		r_pageControlView = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0,708,1024.0,40.0)];
	}
    
	r_pageControlView.userInteractionEnabled = NO;
	
	[self updatePageControl];
	r_pageControlView.hidesForSinglePage = YES;
	
	[self.view addSubview:r_pageControlView];
	[r_pageControlView release];
}

#pragma mark init ends

#pragma mark -
#pragma mark targets

-(void)handleDragged:(UIPanGestureRecognizer*)sender
{
	
	if (!r_categories || [r_categories count]==0) {
		return;
	}
	
	CGPoint translate = [sender translationInView:self.view];
	
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	r_leftCard = (UIView*)[self.view viewWithTag:100];
	r_rightCard = (UIView*)[self.view viewWithTag:102];
	
	FICardView *leftCard = (FICardView*)[r_leftCard viewWithTag:105];
	FICardView *rightCard = (FICardView*)[r_rightCard viewWithTag:105];
	
	if (r_isFirstCard) {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            
            if (IS_IPHONE_5) {
                r_centerCard.center = CGPointMake(284+translate.x,160);
                r_rightCard.center = CGPointMake(568+kFCardWidth/2+translate.x,160);
            }else{
                r_centerCard.center = CGPointMake(240+translate.x,160);
                r_rightCard.center = CGPointMake(480+kFCardWidth/2+translate.x,160);
            }
		}else {
			
			if ([Util isPortrait:(UIViewController*)r_delegate]) {
				r_centerCard.center = CGPointMake(384+translate.x,512);
				r_rightCard.center = CGPointMake(768+kFCardLargeWidth/2+70+translate.x,512);
			}else {
				r_centerCard.center = CGPointMake(512+translate.x,384);
				r_rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+70+translate.x,384);
			}
            
		}
        
		[rightCard updateCardTextView];
	}
	else {
		if (r_isLastCard) {
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                if (IS_IPHONE_5) {
                    r_centerCard.center = CGPointMake(284+translate.x,160);
                    r_leftCard.center = CGPointMake(-kFCardWidth/2+translate.x,160);
                }else{
                    r_centerCard.center = CGPointMake(240+translate.x,160);
                    r_leftCard.center = CGPointMake(-kFCardWidth/2+translate.x,160);
                }
				
			}else {
				
				if ([Util isPortrait:(UIViewController*)r_delegate]) {
					r_centerCard.center = CGPointMake(384+translate.x,512);
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70+translate.x,512);
				}else {
					r_centerCard.center = CGPointMake(512+translate.x,384);
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70+translate.x,384);
				}
                
				
                
			}
            
			
			[leftCard updateCardTextView];
		}
		else {
			
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                if (IS_IPHONE_5) {
                    r_centerCard.center = CGPointMake(280+translate.x,160);
                    r_leftCard.center = CGPointMake(-kFCardWidth/2+translate.x,160);
                    r_rightCard.center = CGPointMake(568+kFCardWidth/2+translate.x,160);
                }else{
                    r_centerCard.center = CGPointMake(240+translate.x,160);
                    r_leftCard.center = CGPointMake(-kFCardWidth/2+translate.x,160);
                    r_rightCard.center = CGPointMake(480+kFCardWidth/2+translate.x,160);
                }
                
			}else {
				if ([Util isPortrait:(UIViewController*)r_delegate]) {
					r_centerCard.center = CGPointMake(384+translate.x,512);
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70+translate.x,512);
					r_rightCard.center = CGPointMake(768+kFCardLargeWidth/2+70+translate.x,512);
				}else {
					r_centerCard.center = CGPointMake(512+translate.x,384);
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70+translate.x,384);
					r_rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+70+translate.x,384);
				}
                
			}
            
			[rightCard updateCardTextView];
			[leftCard updateCardTextView];
		}
		
	}
	
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		
		if (r_leftCard.center.x<=-kFCardWidth/2 || r_isFirstCard) {
			r_leftCard.hidden = YES;
		}
		else {
			r_leftCard.hidden = NO;
		}
		
		if (r_rightCard.center.x>=480+kFCardWidth/2 || r_isLastCard) {
			r_rightCard.hidden = YES;
		}
		else {
			r_rightCard.hidden = NO;
		}
		
	}else {
		
		if (r_leftCard.center.x<=-kFCardLargeWidth/2-70 || r_isFirstCard) {
			r_leftCard.hidden = YES;
		}
		else {
			r_leftCard.hidden = NO;
		}
		
		NSInteger p;
		
		if ([Util isPortrait:(UIViewController*)r_delegate]) {
			p = 768;
		}else {
			p = 1024;
		}
        
		
		if (r_rightCard.center.x>=p+kFCardLargeWidth/2+70 || r_isLastCard) {
			r_rightCard.hidden = YES;
		}
		else {
			r_rightCard.hidden = NO;
		}
		
	}
    
	
	
	
	if (sender.state == UIGestureRecognizerStateEnded)
	{
		[self completeDragging];
	}
	
}

-(void)handleTapped:(UITapGestureRecognizer*)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(tapSetSoundID);
    }
	if (!r_categories || [r_categories count]==0 || r_currentId == [r_categories count] || r_isNoButtonsMode) {
		return;
	}
	
	if (!r_isEdit) {
		NSDictionary *categoryDelegate = [r_categories objectAtIndex:r_currentId];
		NSString *categoryId = [categoryDelegate objectForKey:@"c"];
		
		if (r_delegate && [r_delegate respondsToSelector:@selector(selectedCategory:)]) {
			[r_delegate selectedCategory:categoryId];
		}
	}else {
		r_isEdit = NO;
		[self stopEditing];
		
		if (r_delegate && [r_delegate respondsToSelector:@selector(didEditEnd)]) {
			[r_delegate didEditEnd];
		}
	}
    
}

-(void)handleLongPressed:(UILongPressGestureRecognizer*)sender
{
	if (!r_categories || [r_categories count]==0 || r_currentId<0 || r_currentId >= [r_categories count]) {
		return;
	}
	
	if (!r_isNoButtonsMode) {
		if (!r_isEdit && r_currentId != [r_categories count]) {
			[self edit:YES];
			if (r_delegate && [r_delegate respondsToSelector:@selector(didEditStart)]) {
				[r_delegate didEditStart];
			}
		}
	}else {
		
	}
    
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	
	
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	FIRoundedButton *centerDelete = (FIRoundedButton*)[r_centerCard viewWithTag:111];
	FIRoundedButton *addCenter = (FIRoundedButton*)[r_centerCard viewWithTag:108];
	FIRoundedButton *centerSettings = (FIRoundedButton*)[r_centerCard viewWithTag:109];
	
	if ([touch.view isDescendantOfView:centerDelete] ||
		[touch.view isDescendantOfView:addCenter] ||
		[touch.view isDescendantOfView:centerSettings]) {
		return NO;
	}
	
	return YES;
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	r_pageControlView.currentPage = r_currentId;
	[self updateCard:100];
	[self updateCard:102];
}

-(void)removeButtonPressed:(UIButton*)sender
{
	NSString *msg = @"Are you sure you want to remove this category?";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Category"
													message:msg
												   delegate:self
										  cancelButtonTitle:@"YES"
										  otherButtonTitles:@"NO",nil];
	
    alert.tag=1313;
    [alert show];
	[alert release];
}

-(void)addCardPressed:(UITapGestureRecognizer*)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(addSoundID);
    }
	NSDictionary *category = [r_categories objectAtIndex:r_currentId];
	NSString* categoryId = [category objectForKey:@"c"];
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(addCardSelected:)]) {
		[r_delegate addCardSelected:categoryId];
	}
	
}

-(void)settingsPressed:(UITapGestureRecognizer*)sender
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"] boolValue]) {
        AudioServicesPlaySystemSound(addSoundID);
    }
	NSDictionary *category = [r_categories objectAtIndex:r_currentId];
	NSString* categoryId = [category objectForKey:@"c"];
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(settingsSelected:)]) {
		[r_delegate settingsSelected:categoryId];
	}
    
}


#pragma mark targets ends

#pragma mark -
#pragma mark private

-(void)renameCurrentCategory:(NSString*)newName
{
	if (newName) {
		NSMutableDictionary *category = [NSMutableDictionary dictionaryWithDictionary:[r_categories objectAtIndex:r_currentId]];
		NSString *categoryName = [category objectForKey:@"cname"];
		
		if (![newName isEqualToString:categoryName]) {
			if (r_delegate && [r_delegate respondsToSelector:@selector(renameCategory:forName:)]) {
				NSString *categoryId = [category objectForKey:@"c"];
				[r_delegate renameCategory:categoryId forName:newName];
			}
			[category setObject:newName forKey:@"cname"];
			[r_categories replaceObjectAtIndex:r_currentId withObject:category];
		}
		
		r_centerCard = (UIView*)[self.view viewWithTag:101];
		UILabel *fieldLabel = (UILabel*)[r_centerCard viewWithTag:114];
		fieldLabel.text = newName;
	}
	
	
	
}

-(void)removeCategory
{
	NSDictionary *category = [r_categories objectAtIndex:r_currentId];
	NSString* categoryId = [category objectForKey:@"c"];
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(removeCategory:)]) {
		[r_delegate removeCategory:categoryId];
	}
	
	[r_categories removeObjectAtIndex:r_currentId];
	
	if (r_categories && [r_categories count]>0) {
		r_currentId = r_currentId%[r_categories count];
		
		if (r_currentId == 0) {
			r_isFirstCard = YES;
		}else {
			r_isFirstCard = NO;
		}
        
		if (r_currentId == [r_categories count]-1) {
			r_isLastCard = YES;
		}else {
			r_isLastCard = NO;
		}
        
	}
	
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	
	if ([r_categories count] == 0) {
		r_currentId = 0;
        
		if (r_delegate && [r_delegate respondsToSelector:@selector(didEditEnd)]) {
			[r_delegate didEditEnd];
		}
        
		r_isEdit = NO;
		[self stopEditing];
		[self edit:NO];
		
		r_centerCard.hidden = YES;
		[self updatePageControl];
		return;
	}else {
		[self updateCard:100];
		[self updateCard:102];
		
	}
	
	[self performSelector:@selector(animateRemoving:)
			   withObject:r_centerCard
			   afterDelay:0.5f];
	[self updatePageControl];
	
	
	
	
}

-(NSDictionary*)createContent:(NSInteger)index
{
	if (!r_categories || [r_categories count]<=index || index<0) {
		return nil;
	}
	
	NSDictionary *categoryDelegate = [r_categories objectAtIndex:index];
	NSNumber *cardN = [categoryDelegate objectForKey:@"id"];
	
	NSString *question = nil;
	NSString *answer = nil;
	NSString *category = nil;
	UIImage *qImage = nil;
	UIImage *aImage = nil;
	NSData *qSound = nil;
	NSData *aSound = nil;
	
	if (cardN) {
		NSInteger cardId = [cardN intValue];
		question = [categoryDelegate objectForKey:@"q"];
		answer = [categoryDelegate objectForKey:@"a"];
		category = [categoryDelegate objectForKey:@"c"];
		
		if (category) {
			qImage = [Util imageWithId:category forId:cardId forWhat:YES];
			aImage = [Util imageWithId:category forId:cardId forWhat:NO];
			qSound = [Util getSoundForCard:category forId:cardId forWhat:YES];
			aSound = [Util getSoundForCard:category forId:cardId forWhat:NO];
		}
	}
	
	NSNumber* cardNumber = [categoryDelegate objectForKey:@"cardNumber"];
	NSNumber *allCard = [categoryDelegate objectForKey:@"cardsCount"];
	
	
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	
	if(question)
		[dic setObject:question forKey:@"question"];
	
	if (answer)
	{
		[dic setObject:answer forKey:@"answer"];
		
	}
	
	if (qImage) {
		[dic setObject:qImage forKey:@"qImage"];
	}
	
	if (aImage) {
		[dic setObject:aImage forKey:@"aImage"];
	}
	
	if (qSound) {
		[dic setObject:qSound forKey:@"qSound"];
	}
	
	if (aSound) {
		[dic setObject:aSound forKey:@"aSound"];
	}
	
	if (cardNumber) {
		[dic setObject:cardNumber forKey:@"number"];
	}else {
		[dic setObject:[NSNumber numberWithInt:0] forKey:@"number"];
	}
    
	if (allCard) {
		[dic setObject:allCard forKey:@"allNumber"];
	}else {
		[dic setObject:[NSNumber numberWithInt:0] forKey:@"allNumber"];
	}
    
    
	
	
	return dic;
	
	
}

-(NSDictionary*)infoForSet:(NSInteger)index
{
	if (!r_categories || [r_categories count]<=index || index<0) {
		return nil;
	}
	
	NSDictionary *category = [r_categories objectAtIndex:index];
	NSString* categoryId = [category objectForKey:@"c"];
	
	if (r_delegate && [r_delegate respondsToSelector:@selector(infoForSetId:)]) {
		return [r_delegate infoForSetId:categoryId];
	}
	
	return nil;
}

-(void)updatePageControl
{
	if (r_categories) {
		r_pageControlView.currentPage = r_currentId;
		r_pageControlView.numberOfPages = [r_categories count];
	}
    
}

-(void)completeDragging
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	
	CGFloat min1;
	CGFloat min2;
	CGFloat min3;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		min1 = [self calculateDis:r_centerCard.center forSec:CGPointMake(0,160)];
		min2 = [self calculateDis:r_centerCard.center forSec:CGPointMake(((IS_IPHONE_5)?284:240),160)];
		min3 = [self calculateDis:r_centerCard.center forSec:CGPointMake(((IS_IPHONE_5)?568:480),160)];
	}else {
		
		if ([Util isPortrait:(UIViewController*)r_delegate]) {
			min1 = [self calculateDis:r_centerCard.center forSec:CGPointMake(0,512)];
			min2 = [self calculateDis:r_centerCard.center forSec:CGPointMake(384,512)];
			min3 = [self calculateDis:r_centerCard.center forSec:CGPointMake(768,512)];
		}else {
			min1 = [self calculateDis:r_centerCard.center forSec:CGPointMake(0,384)];
			min2 = [self calculateDis:r_centerCard.center forSec:CGPointMake(512,384)];
			min3 = [self calculateDis:r_centerCard.center forSec:CGPointMake(1024,384)];
		}
        
		
        
	}
    
	
	NSInteger which;
	
	if (min1<=min2 && min1<=min3) {
		which = 0;
	}
	else {
		if (min2<=min1 && min2<=min3) {
			which = 1;
		}
		else {
			if (min3<=min2 && min3<=min1) {
				which = 2;
			}
		}
		
	}
    
	[self completeDraggingAnimation:which];
	
}

-(void)completeDraggingAnimation:(NSInteger)which
{
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	r_leftCard = (UIView*)[self.view viewWithTag:100];
	r_rightCard = (UIView*)[self.view viewWithTag:102];
	
	if (which == 0 && r_isLastCard) {
		which = 1;
	}else {
		if (which == 2 && r_isFirstCard) {
			which = 1;
		}
	}
    
	NSInteger all = [r_categories count];
    
	switch (which) {
		case 0:
		{
			r_leftCard.tag = 102;
			r_centerCard.tag = 100;
			r_rightCard.tag = 101;
			r_currentId = (r_currentId+1)%all;
			break;
		}
		case 2:
		{
			r_leftCard.tag = 101;
			r_centerCard.tag = 102;
			r_rightCard.tag = 100;
			r_currentId = (r_currentId-1+all)%all;
			break;
		}
		default:
			break;
	}
	
	if (r_currentId == 0) {
		r_isFirstCard = YES;
	}
	else {
		r_isFirstCard = NO;
	}
	
	
	if (r_currentId == all-1) {
		r_isLastCard = YES;
	}
	else {
		r_isLastCard = NO;
	}
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDelegate:self];
	
	
	switch (which) {
		case 0:
		{
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				r_leftCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
				r_centerCard.center = CGPointMake(-((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
				r_rightCard.center = CGPointMake(((IS_IPHONE_5)?284.5:240.5),160);
			}else {
				if ([Util isPortrait:(UIViewController*)r_delegate]) {
					r_leftCard.center = CGPointMake(768+kFCardLargeWidth/2+70,512);
					r_centerCard.center = CGPointMake(-kFCardLargeWidth/2-70,512);
					r_rightCard.center = CGPointMake(384,512);
				}else {
					r_leftCard.center = CGPointMake(1024+kFCardLargeWidth/2+70,384);
					r_centerCard.center = CGPointMake(-kFCardLargeWidth/2-70,384);
					r_rightCard.center = CGPointMake(512,384);
				}
                
				
			}
            
			break;
		}
		case 1:
		{
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				r_leftCard.center = CGPointMake(-((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
				r_centerCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
				r_rightCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
			}else {
				if ([Util isPortrait:(UIViewController*)r_delegate]) {
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70,512);
					r_centerCard.center = CGPointMake(384,512);
					r_rightCard.center = CGPointMake(768+kFCardLargeWidth/2+70,512);
				}else {
					r_leftCard.center = CGPointMake(-kFCardLargeWidth/2-70,384);
					r_centerCard.center = CGPointMake(512,384);
					r_rightCard.center = CGPointMake(1024+kFCardLargeWidth/2+70,384);
				}
                
				
			}
            
			break;
		}
		case 2:
		{
			if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
				r_leftCard.center = CGPointMake(((IS_IPHONE_5)?284:240),160);
				r_centerCard.center = CGPointMake(((IS_IPHONE_5)?568:480)+((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
				r_rightCard.center = CGPointMake(-((IS_IPHONE_5)?kFCardWidthIPhone5:kFCardWidth)/2,160);
			}else {
				
				if ([Util isPortrait:(UIViewController*)r_delegate]) {
					r_leftCard.center = CGPointMake(384,512);
					r_centerCard.center = CGPointMake(768+kFCardLargeWidth/2+70,512);
					r_rightCard.center = CGPointMake(-kFCardLargeWidth/2-70,512);
				}else {
					r_leftCard.center = CGPointMake(512,384);
					r_centerCard.center = CGPointMake(1024+kFCardLargeWidth/2+70,384);
					r_rightCard.center = CGPointMake(-kFCardLargeWidth/2-70,384);
				}
                
				
				
			}
            
			break;
		}
		default:
			break;
	}
	
	if (which!=1) {
		SEL	 stopSel = @selector(animationDidStop:finished:context:);
		[UIView setAnimationDidStopSelector:stopSel];
	}
	
	
	[UIView commitAnimations];
}

-(CGFloat)calculateDis:(CGPoint)fP forSec:(CGPoint)sP
{
	return sqrt((fP.x-sP.x)*(fP.x-sP.x)+(fP.y-sP.y)*(fP.y-sP.y));
}

-(void)updateCard:(NSInteger)tag
{
	if (!r_categories) {
		return;
	}
	
	NSInteger curId = 101-tag;
	NSInteger all = [r_categories count];
	
	if ((r_currentId-curId)>=all || (r_currentId-curId)<0) {
		return;
	}
	
	
	UIView *card = (UIView*)[self.view viewWithTag:tag];
	FICardView *content = (FICardView*)[card viewWithTag:105];
	UIImageView *bgDeckView = (UIImageView*)[card viewWithTag:113];
	UITextField *field = (UITextField*)[card viewWithTag:107];
	UILabel *fieldLabel = (UILabel*)[card viewWithTag:114];
	UILabel *infoLabel = (UILabel*)[card viewWithTag:112];
	FIRoundedProgress *progressView = (FIRoundedProgress*)[card viewWithTag:115];
	FIRoundedButton *addButton = (FIRoundedButton*)[card viewWithTag:108];
	FIRoundedButton *settingsButton = (FIRoundedButton*)[card viewWithTag:109];
    
	curId = (r_currentId-curId+all)%all;
	
	card.hidden = NO;
	
	if (!r_isEdit) {
		addButton.hidden = NO;
		settingsButton.hidden = NO;
	}
	
	NSDictionary *dic = [self createContent:curId];
	
	NSDictionary *category = [r_categories objectAtIndex:curId];
	NSString *categoryName = [category objectForKey:@"cname"];
	
	NSNumber *isB = [category objectForKey:@"isBoth"];
	NSNumber *isRev = [category objectForKey:@"isRev"];
    
	NSString* font = [category objectForKey:@"font"];
	NSInteger fontsize;
    
	if (font) {
		fontsize = [[category objectForKey:@"fontsize"] intValue];
	}
    
	if (font) {
		content.currentFont = [UIFont fontWithName:font size:fontsize];
	}else {
		content.currentFont = [UIFont fontWithName:@"Helvetica" size:21];
	}
    
	if (isB) {
		content.isBothSide = [isB boolValue];
	}else {
		content.isBothSide = NO;
	}
	
	if (isRev) {
		content.isReversed = [isRev boolValue];
	}else {
		content.isReversed = NO;
	}
	
	[content changeContent:dic];
	
	if (field) {
		field.text = categoryName;
	}
    
	if (fieldLabel) {
		fieldLabel.text = categoryName;
	}
    
	NSDictionary *infoDic = [self infoForSet:curId];
	NSInteger testCount = [[infoDic objectForKey:@"test"] intValue];
	BOOL isSO = [[infoDic objectForKey:@"isSO"] boolValue];
    BOOL isAL = [[infoDic objectForKey:@"isAL"] boolValue];
	NSInteger cardsCount = [[infoDic objectForKey:@"count"] intValue];
	NSInteger diff = [[infoDic objectForKey:@"diff"] intValue];
    
	NSString *labelStr = @"";
	
    if (cardsCount==0) {
        labelStr = @"Tap to add new cards";
    }else{
        
        if(isAL){
            labelStr = @"All cards studied";
        }else{
            if (!isSO) {
                labelStr = @"Tap to start new session";
            }else{
                if (testCount>0) {
                    if (testCount == 1) {
                        labelStr = [labelStr stringByAppendingFormat:@"1 card to test"];
                    }else {
                        labelStr = [labelStr stringByAppendingFormat:@"%d cards to test",testCount];
                    }
                }
            }
        }
    }
	infoLabel.text = labelStr;
    
	NSMutableArray* progressColorArr = [NSMutableArray array];
	NSDictionary *progressDic;
	if (cardsCount>0) {
        
        if (progressView.hidden) {
            progressView.hidden = NO;
        }
        
		CGFloat knowPer = 100.0*((CGFloat)diff/(CGFloat)cardsCount);
        
		for (int i=0;i<4;i++) {
			if ((NSInteger)knowPer>i*30) {
				[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
			}else {
				[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
			}
		}
        
		if ((NSInteger)knowPer == 100) {
			[progressColorArr addObject:[UIColor colorWithWhite:0.0 alpha:0.7]];
		}else {
			[progressColorArr addObject:[UIColor colorWithWhite:0.5 alpha:0.3]];
		}
        
		if ([Util isPhone]) {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
                                                               [NSNumber numberWithInt:6],
                                                               [NSNumber numberWithInt:5],nil]
                                                      forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}else {
			progressDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:progressColorArr,
															   [NSNumber numberWithInt:10],
															   [NSNumber numberWithInt:5],nil]
													  forKeys:[NSArray arrayWithObjects:@"colors",@"radius",@"tx",nil]];
		}
        
	}else {
		progressDic = nil;
		progressView.hidden = YES;
	}
    
	[progressView changeValue:progressDic];
	[card bringSubviewToFront:progressView];
    
	bgDeckView.image = nil;
    bgDeckView.hidden = NO;
	if (cardsCount>0) {
		if (cardsCount==1) {
			bgDeckView.image = nil;
		}else if (cardsCount>=2 && cardsCount<=5) {
			if ([Util isPhone]) {
				bgDeckView.image = [UIImage imageNamed:@"i_set_screen2.png"];
			}else {
				bgDeckView.image = [UIImage imageNamed:@"sets2.png"];
			}
            
		}else {
			if ([Util isPhone]) {
				bgDeckView.image = [UIImage imageNamed:@"i_set_screen3.png"];
			}else {
				bgDeckView.image = [UIImage imageNamed:@"sets3.png"];
			}
		}
	}
}

-(void)startEditing
{
	r_leftCard = (UIView*)[self.view viewWithTag:100];
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	r_rightCard = (UIView*)[self.view viewWithTag:102];
	
	FIRoundedButton *centerDelete = (FIRoundedButton*)[r_centerCard viewWithTag:111];
	FIRoundedButton *leftDelete = (FIRoundedButton*)[r_leftCard viewWithTag:111];
	FIRoundedButton *rightDelete = (FIRoundedButton*)[r_rightCard viewWithTag:111];
	
	[r_centerCard bringSubviewToFront:centerDelete];
	[r_leftCard bringSubviewToFront:leftDelete];
	[r_rightCard bringSubviewToFront:rightDelete];
	
	FIRoundedButton *addCenter = (FIRoundedButton*)[r_centerCard viewWithTag:108];
	FIRoundedButton *addLeft = (FIRoundedButton*)[r_leftCard viewWithTag:108];
	FIRoundedButton *addRight = (FIRoundedButton*)[r_rightCard viewWithTag:108];
	
	FIRoundedButton *centerSettings = (FIRoundedButton*)[r_centerCard viewWithTag:109];
	FIRoundedButton *leftSettings = (FIRoundedButton*)[r_leftCard viewWithTag:109];
	FIRoundedButton *rightSettings = (FIRoundedButton*)[r_rightCard viewWithTag:109];
	
	
	[[FIAnimationController sharedAnimation:nil] makeAnimation:centerDelete
														  type:kCATransitionFade
														   dir:kCATransitionFromBottom];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:centerSettings
														  type:kCATransitionFade
														   dir:kCATransitionFromRight];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:addCenter
														  type:kCATransitionFade
														   dir:kCATransitionFromLeft];
	
	centerDelete.hidden = NO;
	leftDelete.hidden = NO;
	rightDelete.hidden = NO;
	
	addCenter.hidden = YES;
	addLeft.hidden = YES;
	addRight.hidden = YES;
	
	centerSettings.hidden = YES;
	leftSettings.hidden = YES;
	rightSettings.hidden = YES;
	
}

-(void)stopEditing
{
	r_leftCard = (UIView*)[self.view viewWithTag:100];
	r_centerCard = (UIView*)[self.view viewWithTag:101];
	r_rightCard = (UIView*)[self.view viewWithTag:102];
	
	FIRoundedButton *centerDelete = (FIRoundedButton*)[r_centerCard viewWithTag:111];
	FIRoundedButton *leftDelete = (FIRoundedButton*)[r_leftCard viewWithTag:111];
	FIRoundedButton *rightDelete = (FIRoundedButton*)[r_rightCard viewWithTag:111];
	
	FIRoundedButton *addCenter = (FIRoundedButton*)[r_centerCard viewWithTag:108];
	FIRoundedButton *addLeft = (FIRoundedButton*)[r_leftCard viewWithTag:108];
	FIRoundedButton *addRight = (FIRoundedButton*)[r_rightCard viewWithTag:108];
	
	FIRoundedButton *centerSettings = (FIRoundedButton*)[r_centerCard viewWithTag:109];
	FIRoundedButton *leftSettings = (FIRoundedButton*)[r_leftCard viewWithTag:109];
	FIRoundedButton *rightSettings = (FIRoundedButton*)[r_rightCard viewWithTag:109];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	r_leftCard.layer.transform = CATransform3DIdentity;
	r_centerCard.layer.transform = CATransform3DIdentity;
	r_rightCard.layer.transform = CATransform3DIdentity;
	
	[UIView commitAnimations];
	
	[[FIAnimationController sharedAnimation:nil] makeAnimation:centerDelete
														  type:kCATransitionFade
														   dir:kCATransitionFromBottom];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:centerSettings
														  type:kCATransitionFade
														   dir:kCATransitionFromRight];
	[[FIAnimationController sharedAnimation:nil] makeAnimation:addCenter
														  type:kCATransitionFade
														   dir:kCATransitionFromLeft];
	
	centerDelete.hidden = YES;
	leftDelete.hidden = YES;
	rightDelete.hidden = YES;
	
	addCenter.hidden = NO;
	addLeft.hidden = NO;
	addRight.hidden = NO;
	
	centerSettings.hidden = NO;
	leftSettings.hidden = NO;
	rightSettings.hidden = NO;
	
}

-(void)hideItemsForViewTag:(BOOL)isHidden forTag:(NSInteger)tag animated:(BOOL)isAnimated
{
	UIView *itemView = [self.view viewWithTag:tag];
	
	if (itemView) {
		FICardView *card = (FICardView*)[itemView viewWithTag:105];
		
		if (card) {
			[itemView bringSubviewToFront:card];
		}
		
		
		UITextField *titleField = (UITextField*)[itemView viewWithTag:107];
		FIRoundedButton *addButton = (FIRoundedButton*)[itemView viewWithTag:108];
		FIRoundedButton *prefButton = (FIRoundedButton*)[itemView viewWithTag:109];
		
		
		CGPoint tCP; 
		CGPoint aCP; 
		CGPoint pCP; 
		
		if (isHidden) {
			tCP = CGPointMake(kFCardWidth*0.65/2.0+20.0,80);
			aCP = CGPointMake(kFCardWidth*0.65-30.0,80.0);
			pCP = CGPointMake(85,130.0);
			addButton.userInteractionEnabled = NO;
			prefButton.userInteractionEnabled = NO;
		}else {
			tCP = CGPointMake(kFCardWidth*0.65/2.0+20.0,43);
			aCP = CGPointMake(kFCardWidth*0.65+35.0,80.0);
			pCP = CGPointMake(10,130.0);
			addButton.userInteractionEnabled = YES;
			prefButton.userInteractionEnabled = YES;
		}
        
		
		if (isAnimated) {
			[[FIAnimationController sharedAnimation:nil] moveCenter:titleField toPoint:tCP];
			[[FIAnimationController sharedAnimation:nil] moveCenter:addButton toPoint:aCP];
			[[FIAnimationController sharedAnimation:nil] moveCenter:prefButton toPoint:pCP];
		}else {
			titleField.center = tCP;
			addButton.center = aCP;
			prefButton.center = pCP;
		}
        
		
	}
}

-(void)animateRemoving:(UIView*)card{
	[self updateCard:101];
	[[FIAnimationController sharedAnimation:nil] fallAndTrembell:card dir:kCATransitionFromRight];
}

#pragma mark private ends


@end
