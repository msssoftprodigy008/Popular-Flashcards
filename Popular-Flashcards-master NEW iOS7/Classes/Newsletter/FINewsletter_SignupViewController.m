//
//  FINewsletter_SignupViewController.m
//  flashCards
//
//  Created by Ruslan on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FINewsletter_SignupViewController.h"
#import "Util.h"
#import "FINavigationBar.h"
#import "FRootConstants.h"
#import "Constant.h"
@interface FINewsletter_SignupViewController(Private)

//init methods
-(void)initContent;

//targets
-(void)doneButtonPressed:(id)sender;
-(void)submitButtonPressed:(id)sender;


@end


@implementation FINewsletter_SignupViewController
@synthesize delegate;

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
	CGRect viewFrame = [delegate FINewsletterViewFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:viewFrame];
	self.view = contentView;
	[contentView release];
	
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterCustomizeMainView:)])
		[delegate FINewsletterCustomizeMainView:self.view];
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[Util imageFromBundle:@"ip_add_category_bg.png"]];
    [self initContent];
	
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
	
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterInterfaceOrientation:)]){
		return [delegate FINewsletterInterfaceOrientation:interfaceOrientation];
	}else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
    
	
}

#pragma mark-
#pragma mark targets

-(void)submitButtonPressed:(id)sender
{
	NSString *submitUrl = @"http://ads-sg.us1.list-manage.com/subscribe/post?u=72d5b8a4afc99727c015af51a&id=09282d5bd1";
	NSString *submitType = @"POST";
	NSString *fieldEmail = @"EMAIL";
	NSString *fieldFirst = @"FNAME";
	NSString *fieldLast =  @"LNAME";
	NSString *fieldExtra = @"";
    
	if(indicatorLabel){
		[indicatorLabel startWithText:@"Sending request..."];
	}
	else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
    
	submitButton.enabled = NO;
	
	// Setup our requestReady Boolean
	BOOL requestReady = YES;
	NSString *validMessage = @"" ;
	
	// Check for Field Completion
	if([firstNameField.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your first name!\r\n"];
		requestReady = NO;
	}
	
	if([lastNameField.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your last name!\r\n"];
		requestReady = NO;
	}
	
	if([emailField.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your email address!"];
		requestReady = NO;
	} else {
		
		// Email Address specified. Lets check for validation now.
		NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
		NSPredicate *emailValid = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegEx];
		if([emailValid evaluateWithObject:emailField.text] == NO) {
			validMessage = [validMessage stringByAppendingString:@"Please enter a valid email address!"];
			requestReady = NO;
		}
		
	}
	
	// *************************************************************
	// Asynchronous HTTP POST Request to Submit our Signup Form Data
	// *************************************************************
	
	// Parameters for our Request Object
	NSString* requestParams = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@",fieldEmail,emailField.text,
							   fieldFirst,firstNameField.text,
							   fieldLast,emailField.text,fieldExtra];
	
	// If requestReady is YES then we can go ahead and process out our request
	if(requestReady == YES) {
		
		// Clear lblMessage Output Again for Good Measure
        
		// Setup our full Request Object
		NSMutableURLRequest *submitRequest = [[[NSMutableURLRequest alloc] init] autorelease];
		[submitRequest setURL:[NSURL URLWithString:submitUrl]];
		[submitRequest setHTTPMethod:submitType];
		[submitRequest setHTTPBody:[requestParams dataUsingEncoding:NSUTF8StringEncoding]];
		
		// Setup & Execute our Connection for the Request Object
		
		if(newsletterConn)
			[newsletterConn release];
		
		newsletterConn = [[NSURLConnection alloc] initWithRequest:submitRequest delegate:self];
		
		if(receivedData)
		{
			[receivedData release];
			receivedData = nil;
		}
		
		// Check for Connection Success or Failure
		if(newsletterConn) {
			
			// Connection Success - Setup our Received Data Variable for Use Later
			receivedData = [[NSMutableData alloc] init];
			
		} else {
			
			// Connection Failed - Relay Message to User and Re-Enable Submit Button and Hide loadIndicator
			
			if(indicatorLabel){
				[indicatorLabel completeWithText:@"Ooops! We were not able to transmit your information at this time!"];
			}else {
				[Util showMessage:@"Newsletter"
					   forMessage:@"Ooops! We were not able to transmit your information at this time!"
				   forButtonTitle:@"OK"];
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			}
            
			submitButton.enabled = YES;
			
		}
		
	} else {
		
		// Request was not ready due to validation errors. Let's output the results and re-enable the submit button now and Hide loadIndicator.
		if(indicatorLabel){
			[indicatorLabel completeWithText:validMessage];
		}else {
			[Util showMessage:@"Newsletter"
				   forMessage:validMessage
			   forButtonTitle:@"OK"];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		submitButton.enabled = YES;
	}
	
	
	
}


-(void)doneButtonPressed:(id)sender
{
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterDoneButtonPressed:)])
		[delegate FINewsletterDoneButtonPressed:self];
}

#pragma mark -

#pragma mark -
#pragma mark NSURLConnectionDelegate

// Function to Handle the didReceiveResponse Data Generated by the NSURLConnection Action
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

// Function to Handle the didReceiveData Data Generated by the NSURLConnection Action
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	// Once the NSURLConnection has collected enough data to formulate a response output
	// that data is now appended to our receivedData object to ultimately be used in the
	// didFinishLoading delegate below.
	
	[receivedData appendData:data];
}

// Function to Handle the didFailWithError Data Generated by the NSURLConnection Action
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	// The connection failed or was not able to complete. As no other delegate messages
	// are sent we need to close the receivedData and requestConn objects. We might also
	// want to let the user know as well while we are at it.
	
	// Notify User
	if(indicatorLabel){
		[indicatorLabel completeWithText:@"Ooops! Something went wrong and we were unable to confirm your information was sent!"];
	}else {
		[Util showMessage:@"Newsletter"
			   forMessage:@"Ooops! Something went wrong and we were unable to confirm your information was sent!"
		   forButtonTitle:@"OK"];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
    
	
	
	// Release objects
	if(receivedData)
	{
		[receivedData release];
		receivedData = nil;
	}
	
	if(newsletterConn)
	{
		[newsletterConn release];
		newsletterConn = nil;
	}
	
	// Re-enable our Signup button
	submitButton.enabled = YES;
	
}

// Function to Handle the Response Generated by the NSURLConnection Action
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// The finalResponse is the ASCII encoded version of the receivedData we collected earlier.
	// Now in string format, we are free to work with that data as needed to detect any errors,
	// or success messages that we need to look for.
	
	NSString *finalResponse = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
	
    
	// *************************************************************
	// Mail Chimp: Success Message - "Almost finished..."
	// *************************************************************
	//
	// This is the data from the MailChimp newsletter system. Once a signup
	// reaches the success stage, MailChimp uses the "Almost finished..." message on that page
	// to normally notify the web used to check their email for the confirmation message that
	// MailChimp will send to them. Since we are going to handle the message ourself, we just
	// check for the response for that string, and notify the user accordingly.
	
    
	NSString *successMessage = @"Almost finished...";
	
	
	
    
	// *************************************************************
	// Response Message Processing - Finally!
	// *************************************************************
	
	NSRange range = [finalResponse rangeOfString:successMessage];
	if(range.location != NSNotFound) {
		
		// Success Message was located in the final response! Notify our user and we are all done here!
		if(indicatorLabel){
			[indicatorLabel completeWithText:@"Thank you for signing up for our newsletter!"];
		}else {
			[Util showMessage:@"Newsletter"
				   forMessage:@"Thank you for signing up for our newsletter!"
			   forButtonTitle:@"OK"];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		
	} else {
		
		// Re-enable our Signup button
		submitButton.enabled = YES;
		
		// ******************************************
		// Common Error Message for Signup Failure
		// ******************************************
		
		// We did not find a success message in the final response. Notify our user and hope they try again!
		if(indicatorLabel){
			[indicatorLabel completeWithText:@"Ooops! Something went wrong and we were unable to confirm your information was sent!"];
		}else {
			[Util showMessage:@"Newsletter"
				   forMessage:@"Ooops! Something went wrong and we were unable to confirm your information was sent!"
			   forButtonTitle:@"OK"];
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		}
		
		// ******************************************
		// AWeber - User Already Signed Up Error
		// Will override common error msg output
		// ******************************************
		
		range = [finalResponse rangeOfString:@"already subscribed"];
		if(range.location != NSNotFound) {
			// User already submitted request to AWeber
			if(indicatorLabel){
				[indicatorLabel completeWithText:@"Ooops! Our records indicate you have already signed up for our newsletter!"];
			}else {
				[Util showMessage:@"Newsletter"
					   forMessage:@"Ooops! Our records indicate you have already signed up for our newsletter!"
				   forButtonTitle:@"OK"];
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			}
		}
		
	}
	
	// Release our Connection & Response Objects
	
	if(newsletterConn)
	{
		[newsletterConn release];
		newsletterConn = nil;
	}
	
	if(receivedData)
	{
		[receivedData release];
		receivedData = nil;
	}
	
	[finalResponse release];
	
	
}


#pragma mark -


#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	if([Util isPhone])
	{
		[UIView beginAnimations:@"active editing" context:nil];
		
		if([textField isEqual:firstNameField])
		{
			lastNameLabel.alpha = 0.0;
			lastNameField.alpha = 0.0;
			emailLabel.alpha = 0.0;
			emailField.alpha = 0.0;
		}
		
		if([textField isEqual:lastNameField])
		{
			lastNameLabel.center = [[[centers objectAtIndex:0] objectAtIndex:0] CGPointValue];
			lastNameField.center = [[[centers objectAtIndex:0] objectAtIndex:1] CGPointValue];
			firstNameField.alpha = 0.0;
			firstNameLabel.alpha = 0.0;
			emailLabel.alpha = 0.0;
			emailField.alpha = 0.0;
		}
		
		if([textField isEqual:emailField])
		{
			emailLabel.center = [[[centers objectAtIndex:0] objectAtIndex:0] CGPointValue];
			emailField.center = [[[centers objectAtIndex:0] objectAtIndex:1] CGPointValue];
			firstNameField.alpha = 0.0;
			firstNameLabel.alpha = 0.0;
			lastNameField.alpha = 0.0;
			lastNameLabel.alpha = 0.0;
		}
		
		[UIView commitAnimations];
		
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if([Util isPhone])
	{
		[UIView beginAnimations:@"nonactive editing" context:nil];
		lastNameLabel.center = [[[centers objectAtIndex:1] objectAtIndex:0] CGPointValue];
		lastNameField.center = [[[centers objectAtIndex:1] objectAtIndex:1] CGPointValue];
		emailLabel.center = [[[centers objectAtIndex:2] objectAtIndex:0] CGPointValue];
		emailField.center = [[[centers objectAtIndex:2] objectAtIndex:1] CGPointValue];
		firstNameField.alpha = 1.0;
		firstNameLabel.alpha = 1.0;
		lastNameLabel.alpha = 1.0;
		lastNameField.alpha = 1.0;
		emailLabel.alpha = 1.0;
		emailField.alpha = 1.0;
		[UIView commitAnimations];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}


#pragma mark UITextFieldDelegate ends

#pragma mark -
#pragma mark private

-(void)initContent
{
	//init navigation bar
	NSInteger topBarOffset = 0;
	
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterNavigationBarExist)]
	   && [delegate FINewsletterNavigationBarExist])
	{
		
		if(self.navigationController && self.navigationController.navigationBar)
		{
			UINavigationBar *navBar;
			navBar = self.navigationController.navigationBar;
			navBar.topItem.title = @"Newsletter";
			
			if(delegate && [delegate respondsToSelector:@selector(FINewsletterDoneButtonExist)] &&
			   [delegate FINewsletterDoneButtonExist])
			{
				UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																							target:self
																							action:@selector(doneButtonPressed:)];
				navBar.topItem.rightBarButtonItem = doneButton;
				[doneButton release];
			}
			
			if(delegate && [delegate respondsToSelector:@selector(FINewsletterCustomizeNavBar:)])
				[delegate FINewsletterCustomizeNavBar:navBar];
			
		}else {
			if([Util isPhone]){
				FINavigationBar *navBar;
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                            [self prefersStatusBarHidden];
                            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                        } else {
                            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                        }
                        navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
                    }
                    else{
                        navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,568,40)];
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
                        navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,37)];
                    }
                    else{
                        navBar = [[FINavigationBar alloc] initWithFrame:CGRectMake(0,0,480,37)];
                    }
                    
                    
                }
                
				
				navBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
				UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Newsletter"];
				[navBar pushNavigationItem:item animated:NO];
				[item release];
				[self.view addSubview:navBar];
				[navBar release];
				topBarOffset = 37;
				
				if(delegate && [delegate respondsToSelector:@selector(FINewsletterDoneButtonExist)] &&
				   [delegate FINewsletterDoneButtonExist])
				{
					UIButton *customDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
					UIImage *customDoneImage = [UIImage imageNamed:@"i_panel_done1.png"];
					customDoneButton.frame = CGRectMake(0,0,customDoneImage.size.width,customDoneImage.size.height);
					[customDoneButton setImage:customDoneImage forState:UIControlStateNormal];
					[customDoneButton setImage:customDoneImage forState:UIControlStateHighlighted];
					[customDoneButton addTarget:self
										 action:@selector(doneButtonPressed:)
							   forControlEvents:UIControlEventTouchUpInside];
					UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithCustomView:customDoneButton];
					navBar.topItem.rightBarButtonItem = doneButton;
					[doneButton release];
				}
				
				if(delegate && [delegate respondsToSelector:@selector(FINewsletterCustomizeNavBar:)])
					[delegate FINewsletterCustomizeNavBar:navBar];
			}
		}
		
		
	}
	
    
	CGRect viewFrame = self.view.frame;
	
	CGFloat fieldsHeight;
	
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterTextFieldHeight)]){
		fieldsHeight = [delegate FINewsletterTextFieldHeight];
	}else {
		fieldsHeight = viewFrame.size.height/12.0;
	}
	
	centers = [[NSMutableArray alloc] init];
	
    
    if (IS_IPHONE_5) {
        //first name field
        firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0,topBarOffset,viewFrame.size.width-10.0,fieldsHeight)];
        firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(80.0,topBarOffset+fieldsHeight,3*viewFrame.size.width/4.0,fieldsHeight)];
        //last name field
        lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0,topBarOffset+fieldsHeight*2,viewFrame.size.width-10.0,fieldsHeight)];
        lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(80.0,topBarOffset+fieldsHeight*3,3.0*viewFrame.size.width/4.0,fieldsHeight)];
        //email field
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80.0,topBarOffset+fieldsHeight*4,viewFrame.size.width-10.0,fieldsHeight)];
        emailField = [[UITextField alloc] initWithFrame:CGRectMake(80.0,topBarOffset+fieldsHeight*5,3.0*viewFrame.size.width/4.0,fieldsHeight)];
        
    }
    else{
        //first name field
        firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,topBarOffset,viewFrame.size.width-10.0,fieldsHeight)];
        firstNameField = [[UITextField alloc] initWithFrame:CGRectMake(10.0,topBarOffset+fieldsHeight,3*viewFrame.size.width/4.0,fieldsHeight)];
        //last name field
        lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,topBarOffset+fieldsHeight*2,viewFrame.size.width-10.0,fieldsHeight)];
        lastNameField = [[UITextField alloc] initWithFrame:CGRectMake(10.0,topBarOffset+fieldsHeight*3,3.0*viewFrame.size.width/4.0,fieldsHeight)];
        //email field
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,topBarOffset+fieldsHeight*4,viewFrame.size.width-10.0,fieldsHeight)];
        emailField = [[UITextField alloc] initWithFrame:CGRectMake(10.0,topBarOffset+fieldsHeight*5,3.0*viewFrame.size.width/4.0,fieldsHeight)];
    }
	
	//first name field
	firstNameLabel.backgroundColor = [UIColor clearColor];
	firstNameLabel.adjustsFontSizeToFitWidth = YES;
	firstNameLabel.textAlignment = UITextAlignmentLeft;
	firstNameLabel.text = @"First Name";
	[self.view addSubview:firstNameLabel];
	[firstNameLabel release];
	
	
	firstNameField.borderStyle = UITextBorderStyleRoundedRect;
	firstNameField.delegate = self;
	firstNameField.returnKeyType = UIReturnKeyDone;
	firstNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	firstNameField.autocorrectionType = UITextAutocorrectionTypeNo;
	firstNameField.backgroundColor = [UIColor clearColor];
	firstNameField.text = @"";
	[self.view addSubview:firstNameField];
	[firstNameField release];
	
	[centers addObject:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:firstNameLabel.center],
						[NSValue valueWithCGPoint:firstNameField.center],nil]];
	
	
	lastNameLabel.backgroundColor = [UIColor clearColor];
	lastNameLabel.adjustsFontSizeToFitWidth = YES;
	lastNameLabel.textAlignment = UITextAlignmentLeft;
	lastNameLabel.text = @"Last Name";
	[self.view addSubview:lastNameLabel];
	[lastNameLabel release];
	
	
	lastNameField.borderStyle = UITextBorderStyleRoundedRect;
	lastNameField.backgroundColor = [UIColor clearColor];
	lastNameField.returnKeyType = UIReturnKeyDone;
	lastNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	lastNameField.autocorrectionType = UITextAutocorrectionTypeNo;
	lastNameField.delegate = self;
	lastNameField.text = @"";
	[self.view addSubview:lastNameField];
	[lastNameField release];
	
	[centers addObject:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:lastNameLabel.center],
						[NSValue valueWithCGPoint:lastNameField.center],nil]];
	
	
	emailLabel.backgroundColor = [UIColor clearColor];
	emailLabel.adjustsFontSizeToFitWidth = YES;
	emailLabel.textAlignment = UITextAlignmentLeft;
	emailLabel.text = @"Email";
	[self.view addSubview:emailLabel];
	[emailLabel release];
	
	
	emailField.borderStyle = UITextBorderStyleRoundedRect;
	emailField.backgroundColor = [UIColor clearColor];
	emailField.returnKeyType = UIReturnKeyDone;
	emailField.keyboardType = UIKeyboardTypeEmailAddress;
	emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	emailField.delegate = self;
	emailField.text = @"";
	[self.view addSubview:emailField];
	[emailField release];
	
	[centers addObject:[NSArray arrayWithObjects:[NSValue valueWithCGPoint:emailLabel.center],
						[NSValue valueWithCGPoint:emailField.center],nil]];
	
	CGFloat submitButtonOffset;
	
	if(delegate && [delegate respondsToSelector:@selector(FINewsletterDistanceToSignButton)]){
		submitButtonOffset = [delegate FINewsletterDistanceToSignButton];
	}else {
		submitButtonOffset = topBarOffset+viewFrame.size.height-5.0-fieldsHeight*2;
	}
    
	
	
	submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[submitButton setTitle:@"Join Our Newsletter!" forState:UIControlStateNormal];
	[submitButton setTitle:@"Join Our Newsletter!" forState:UIControlStateHighlighted];
	submitButton.frame = CGRectMake(10.0,submitButtonOffset,viewFrame.size.width-20.0,fieldsHeight*2);
	[submitButton addTarget:self action:@selector(submitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	if(![Util isPhone])
	{
		indicatorLabel = [[SSIndicatorLabel alloc] initWithFrame:CGRectMake(10.0,topBarOffset+5*fieldsHeight+50.0,viewFrame.size.width-20.0,3*fieldsHeight-5.0)];
		indicatorLabel.backgroundColor = [UIColor clearColor];
		indicatorLabel.textLabel.numberOfLines = 3;
		indicatorLabel.textLabel.lineBreakMode = UILineBreakModeCharacterWrap;
		indicatorLabel.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
		indicatorLabel.activityIndicatorView.hidden = YES;
		indicatorLabel.textLabel.text = @"";
		[self.view addSubview:indicatorLabel];
		[indicatorLabel release];
	}
    
	
}
#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark -

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
	delegate = nil;
	
	if(newsletterConn)
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[newsletterConn cancel];
		[newsletterConn release];
		newsletterConn = nil;
	}
	
	if(centers)
		[centers release];
	
	if(receivedData)
	{
		[receivedData release];
		receivedData = nil;
	}
	
    [super dealloc];
}


@end
