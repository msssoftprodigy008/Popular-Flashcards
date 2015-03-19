//
//  RICategoryContainer.h
//  FC 1.4
//
//  Created by Ruslan on 4/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FICardView.h"
#import "FIRoundedButton.h"

@protocol RICategoryContainerDelegate <NSObject>

-(void)selectedCategory:(NSString*)category;
-(void)addCardSelected:(NSString*)category;
-(void)settingsSelected:(NSString*)category;
-(void)renameCategory:(NSString*)categoryId forName:(NSString*)categoryName;
-(void)removeCategory:(NSString*)categoryId;
-(void)didEditStart;
-(void)didEditEnd;
-(NSDictionary*)infoForSetId:(NSString*)setId;
-(void)groupIsLoaded;

@end


@interface RICategoryContainer : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate> {
	
	UIView *r_leftCard;
	UIView *r_rightCard;
	UIView *r_centerCard;
	
	UIPageControl* r_pageControlView;
	
	UITextField *r_centerTitle;
	UITextField *r_leftTitle;
	UITextField *r_rightTitle;
	
	NSMutableArray *r_categories;
	NSInteger r_currentId;
	NSInteger r_animationId;
	
	BOOL r_isFirstCard;
	BOOL r_isLastCard;
	BOOL r_isEdit;
	BOOL r_isNoButtonsMode;
	
    SystemSoundID addSoundID;
    SystemSoundID tapSetSoundID;
    
    NSString *setName;
    UITextField *setnameField;
    
	id<RICategoryContainerDelegate> r_delegate;
}

@property(nonatomic,assign)id<RICategoryContainerDelegate> r_delegate;

-(id)initWithCategories:(NSArray*)categories;
-(void)changeCategories:(NSArray*)newCategories;
-(void)changeCategoriesWithFeedBack:(NSArray*)newCategories;
-(void)createNewCategory:(NSDictionary*)category animated:(BOOL)isAnimated withEditing:(BOOL)isEditingField;
-(void)edit:(BOOL)isEdit;
-(NSString*)currentCategoryId;
-(void)updateCurrentCategory:(NSDictionary*)category;
-(void)updateTestInfoLabel:(FICardPosition)position;
-(void)setTitleHidden:(BOOL)isHidden animated:(BOOL)isAnimated;
-(void)setCenterCardHidden:(BOOL)isHidden;
-(void)jumpCenterCard;
-(void)makeCenter:(BOOL)isCenter animated:(BOOL)isAnimated;
-(void)moveCardToRight:(BOOL)isAnimated;
-(void)hideCardShadow:(BOOL)isHidden animated:(BOOL)isAnimate;
-(void)hideButtons:(BOOL)isHidden animated:(BOOL)isAnimated;
-(void)rotateView:(UIInterfaceOrientation)orientation;
-(void)makeIpadSceneCenter:(BOOL)isCenter animated:(BOOL)animated;
-(void)hideInfoLabel:(BOOL)hidden animated:(BOOL)animated;
-(void)hideCard:(FICardPosition)position hidden:(BOOL)hidden;
-(void)hideCardButtons:(FICardPosition)position hidden:(BOOL)hidden animated:(BOOL)animated;
-(void)wrapBgDeckView:(BOOL)hidden animated:(BOOL)animated;
-(void)animateCard:(NSString*)animationType subType:(NSString*)subType duration:(CGFloat)duration speed:(CGFloat)speed;
-(void)removeCurrentSetFromList;

@end
