//
//  FINewsletter_SignupViewController.h
//  flashCards
//
//  Created by Ruslan on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SSToolkit/SSIndicatorLabel.h>

@class FINewsletter_SignupViewController;

@protocol FINewsletterDelegate

-(CGRect)FINewsletterViewFrame;
-(BOOL)FINewsletterNavigationBarExist;
-(BOOL)FINewsletterDoneButtonExist;


@optional
-(void)FINewsletterDoneButtonPressed:(FINewsletter_SignupViewController*)sender;
-(void)FINewsletterCustomizeNavBar:(UINavigationBar*)navigationBar;
-(BOOL)FINewsletterInterfaceOrientation:(UIInterfaceOrientation)orientation;
-(void)FINewsletterCustomizeMainView:(UIView*)view;
-(CGFloat)FINewsletterTextFieldHeight;
-(CGFloat)FINewsletterDistanceToSignButton;

@end


@interface FINewsletter_SignupViewController : UIViewController<UITextFieldDelegate> {
	BOOL isNavigationBarExist;
	BOOL isDoneButtonExist;
	UITextField* firstNameField;
	UITextField* lastNameField;
	UITextField* emailField;
	UILabel *firstNameLabel;
	UILabel *lastNameLabel;
	UILabel *emailLabel;
	UIButton *submitButton;
	SSIndicatorLabel *indicatorLabel;
	
	NSURLConnection *newsletterConn;
	NSMutableData *receivedData;
	
	NSMutableArray *centers;
	
	id delegate;
}

@property(nonatomic,assign)id delegate;

@end
