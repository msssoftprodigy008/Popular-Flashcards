//
//  Newsletter_SignupViewController.h
//  Newsletter Signup
//

#import <UIKit/UIKit.h>

@interface Newsletter_SignupViewController : UIViewController {
	
	// ****************************
	// Specify the IBOutlet Objects
	// ****************************
	
	IBOutlet UITextField *userFirst;
	IBOutlet UITextField *userLast;
	IBOutlet UITextField *userEmail;
	IBOutlet UILabel *lblMessage;
	IBOutlet UIButton *buttonSignup;
	IBOutlet UIActivityIndicatorView *loadIndicator;
	
	// ****************************
	// Specify the Request Objects
	// ****************************
	
	NSString *submitUrl;
	NSString *submitType;
	NSString *fieldEmail;
	NSString *fieldFirst;
	NSString *fieldLast;
	NSString *fieldExtra;
	
	// ****************************
	// Specify the NSURL Objects
	// ****************************
	
	NSString *requestParams;
	NSMutableData *submitResponse;
	NSURLConnection *requestConn;
	NSString *finalResponse;
	NSMutableData *receivedData;
	
}

// **********************************************
// Property Declarations for the IBOutlet Objects
// **********************************************

@property (retain) IBOutlet UITextField *userFirst;
@property (retain) IBOutlet UITextField *userLast;
@property (retain) IBOutlet UITextField *userEmail;
@property (retain) IBOutlet UILabel *lblMessage;
@property (retain) IBOutlet UIButton *buttonSignup;
@property (retain) IBOutlet UIActivityIndicatorView *loadIndicator;


// ***************************
// Specify the IBAction Events
// ***************************

// IBAction Function Attached to Submit Signup button
-(IBAction)signupSubmit;

// IBAction Function Attached to Hide Keyboard when Done
-(IBAction)keyboardDone;

//IBAction dissmis controller
-(IBAction)donePressed;

@end

