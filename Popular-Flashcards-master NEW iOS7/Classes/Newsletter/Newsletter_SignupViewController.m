//
//  Newsletter_SignupViewController.m
//  Newsletter Signup
//

#import "Newsletter_SignupViewController.h"

@implementation Newsletter_SignupViewController

// Snythesize the Three Text Field Objects & Submit Button
@synthesize userFirst, userLast, userEmail, lblMessage, buttonSignup, loadIndicator;

// IBAction Function Attached to Slider ValueChanged Event
- (IBAction)signupSubmit {
	
	// *************************************************************
	// Submit Newsletter Signup Information
	// *************************************************************
	//
	// The core functionality of the Newsletter Signup application relies on the NSMutableURLRequest object,
	// and the ability to use it to commit both POST and GET transactions to a specified URL. This flexibility
	// grants us the capabilities to incorporate what would commonly be used as a web form (HTML) into our application.
	// This specific application has been setup to use MailChimp as the example, though can be incorporated with any
	// popular newsletter / email marketing company out there such as Constant Contact or AWeber. The only requirement
	// is that the email marketing provider have the HTML forms you need to retrieve to information this application needs.
	// In short, the application only needs the URL to which it will submit the POST or GET transaction, and the fields that
	// are ultimately required by the HTML form to simulate a web-based submission of the user data. Some companies such
	// as Constant Contact may use a HTML "hidden" field to represent certain information such as the user's unique
	// identifier on their system, or the specific identifier of the list the signup will be sent to. This can be handled
	// easily by appending this information to the request parameters field below.
	//
	// Currently, this line can be found in the code below:
	// 
	// requestParams = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@",fieldEmail,userEmail.text,fieldFirst,userFirst.text,fieldLast,userLast.text];
	// 
	// In the event where your HTML form requires the use of <input type='hidden' ....> style fields simply expand the end of
	// the WithFormatString to include however many extra key=pair combinations you need. If this information is specific to
	// your form and does not need to be dynamic based on a response from your user or the application, then the information
	// can be placed directly in the WithFormat string like so:
	// 
	// stringWithFormat:@"%@=%@&%@=%@&%@=%@   &listid=323223   &userid=323245144353"
	// 
	// Please note I have added spaces for the sake of better illustrating the key=value pair relationship. These spaces should be
	// removed prior to running the application. You will notice that an ampersand is placed between each key=value pair combination
	// after the first pair. This is the delimiting character which separates each key=value pair, and is required. The key value
	// in this instance comes from the "NAME" value of the input i.e. <input type='hidden' name='listid' ....> for the example above.
	// the value is then the respective value that the form element is set to.
	// 
	
	// Create Extra Fields String Object
	fieldExtra = @"";
	
	// Disable Registration Button to Prevent Multiple Clicks
	buttonSignup.enabled = NO;
	
	// Clear lblMessage Output
	lblMessage.text = @"";
	
	// Display Load Indicator
	[self.loadIndicator startAnimating];
	
	// *************************************************************
	// MailChimp Settings
	// http://eepurl.com/cEvtc
	// *************************************************************
	//
	// The information below specifies the information required by the application to properly submit the request to your MailChimp
	// account. The submitURL field below is found by accessing the Lists section of your MailChimp account online. Click the "Forms"
	// link in the context area for the list that you wish to use in the application. This will bring up the "Build It" editor section
	// of MailChimp for that specific list. Click the "Create Embed Code for Small Form" link just above the form preview box. In order
	// to use the First and Last Name fields with the default signup form as assumed here, click the "Include All Fields" radio button
	// in the "Define Form Structure" section to the right of the form preview. Now scroll down to the "Copy/Paste Into Your Site"
	// section just below the form preview box. Scroll through the code until you come across a line similar to the following:
	// 
	// <form action="http://somecompany.us2.list-manage1.com/subscribe/post?u=youruseridentifier&amp;id=yourlistid" method="post"....
	//
	// The "http://......" section enclosed in the quotation marks is what you will then copy and paste into the submitURL information below.
	//
	// Please note however that the URL you retrieve from MailChimp will initially cause the application to fail unless you correct the
	// URL encoding that MailChimp has used on the URL. If you look between the "u=" and the "id=" key/value pairs you will see "&amp;" in
	// the URL. Again, for good measure, this will cause the application to fail as it is not a properly formed URL to separate the key/value
	// pairs that MailChimp relies on the know which user and list this submission applies to. As such you *MUST* change the "&amp;" part of
	// the URL to just an ampersand "&" without the "amp;" portion. Please take a moment to compare the URL above with the URL below to
	// notice the difference and what is expected for the application to post correctly to your MailChimp URL.
	//
	// Using the standard MailChimp form with the First and Last Name fields, and the required Email field, you do not need to change anything else.
	
	// IMPORTANT!!!
	// ================================================================================================
	// REMOVE COMMENTING "/* ... */" TO USE THESE SETTINGS FOR SUBMISSION TO MAILCHIMP.
	// YOU MUST COMMENT OUT THE SETTINGS FOR ANY OTHER SYSTEMS INCLUDED HERE OR ELSE ERRORS WILL RESULT
	// ================================================================================================
	
	/*
	submitUrl =  @"http://neezio.us2.list-manage1.com/subscribe/post?u=07475a8f893fbff0293608743&id=0a74ddc4be";
	submitType = @"POST";
	fieldEmail = @"EMAIL";
	fieldFirst = @"FNAME";
	fieldLast =  @"LNAME";
	fieldExtra = @"";
	*/
	
	// *************************************************************
	// AWeber Communications Settings
	// http://neezio.aweber.com
	// *************************************************************
	//
	// The information below specifies the information required by the application to properly submit the request to your AWeber
	// account. The submitURL field below is found by accessing the Web Forms section of your Aweber account online. Click the " Web Forms"
	// link in the main navigation area. If you have not yet created a web form, you will need to do so by clicking the "Create Web Form"
	// button. Once you have decided which form you are going to use, click on the hyperlinked name of the form in the list. This will take
	// you to the form editor. By default AWeber creates a form with the "Full Name", and "Email" fields. To parallel the currect setup of the
	// Newsletter Signup project, you will need to move your mouse over the "Full Name" field in the form display and click the resulting "Edit"
	// button that appears to the left of the field. In the resulting window select the "First & Last Name" option which will then split the name
	// field into the two form fields the current setup requires. Click "Save Web Form". Once you have finalized the other settings you would like
	// for your form, go to the "Publish (Step 3)" tab of the form editor. Click on the "I Will Install My Form" button, and select "Raw HTML Version"
	// from the resulting list. Scroll through the code until you come across a line similar to the following:
	//
	// <form method="post" class="af-form-wrapper" action="http://www.aweber.com/scripts/addlead.pl">
	//
	// The "http://......" section enclosed in the quotation marks is what you will then copy and paste into the submitURL information below. This
	// link is common to all AWeber forms because they use hidden fields in the form to represent the account information, however it is always a
	// wise decision to check your HTML form code to make sure they have not changed the link after any upgrades to their systems.
	//
	// Using the new/edited AWeber form with the First and Last Name fields, and the required Email field, we still need to add a few extra pieces
	// of information to make everything work. We are going to use the fieldExtra string object for this. In the form code that we retrieved our form
	// post URL from, we are also going to look for the following information just below the line where we found that information. Starting just
	// two or three lines below our "<form method..." line you will see something that resembles the following:
	//
	// <input type="hidden" name="meta_web_form_id" value="yourwebformID" />
	// ...
	// <input type="hidden" name="listname" value="youraccountlistname" />
	//
	// What we want to use from this here is the "meta_web_form_id" and the "listname" hidden fields and place these in our fieldExtra object as seen below.
	// This is the information that tells AWeber which account form the request is being processed from, and which list that form is attributed to.
	//
	// fieldExtra = @"  meta_web_form_id = yourwebformID  &  listname = youraccountlistname";
	//
	// I have used extra spaces here to show the "name = value" combination for each of the fields from above. You will also notice the ampersand "&"
	// between the two fields, this is what separates the two elements from eachother in the post information and needs to be there. You will notice
	// the actual fieldExtra object below does NOT have any spaces in it, and that is how it should be or else you will run into a series of errors.
	
	// IMPORTANT!!!
	// ================================================================================================
	// REMOVE COMMENTING "/* ... */" TO USE THESE SETTINGS FOR SUBMISSION TO AWEBER.
	// YOU MUST COMMENT OUT THE SETTINGS FOR ANY OTHER SYSTEMS INCLUDED HERE OR ELSE ERRORS WILL RESULT
	// ================================================================================================
	
	submitUrl =  @"http://ads-sg.us1.list-manage.com/subscribe/post?u=72d5b8a4afc99727c015af51a&id=09282d5bd1";
	submitType = @"POST";
	fieldEmail = @"EMAIL";
	fieldFirst = @"FNAME";
	fieldLast =  @"LNAME";
	fieldExtra = @"";
	
	
	// *************************************************************
	// Custom PHP Script Settings
	// http://www.neezio.com
	// *************************************************************
	//
	// Using the included PHP script, this application can notify you via email when an application users submits their information to be added to
	// your mailing list. While this script is functional out of the box, it can also be modified to do a number of other things to better fit your
	// needs. For example, instead of emailing you, this script could be modified to record their information in a database of users, or automatically
	// create an account for them on your WordPress/Joomla/Drupal/etc... site. If you have any question regarding custom script integrations, or
	// would like to have a custom solution created for you, please contact us at The Neezio Group (newsletter.signup@neezio.com).
	//
	// Upload the "register.php" script to your web hosting provider. Take note of the FULL url to where you uploaded the script as you will need this
	// as the "submitUrl" value. The out-of-the-box script has the following expected POST variables: first, last, email, owner. "Owner" must be specified
	// in the "fieldExtra" object, and is used to specify which email address the signup notifications will be mailed to, i.e. your email address.
	
	// IMPORTANT!!!
	// ================================================================================================
	// REMOVE COMMENTING "/* ... */" TO USE THESE SETTINGS FOR SUBMISSION TO MAILCHIMP.
	// YOU MUST COMMENT OUT THE SETTINGS FOR ANY OTHER SYSTEMS INCLUDED HERE OR ELSE ERRORS WILL RESULT
	// ================================================================================================
	
	/*
	 submitUrl =  @"http://www.gkauten.net/projects/newslettersignup/register.php";
	 submitType = @"POST";
	 fieldEmail = @"email";
	 fieldFirst = @"first";
	 fieldLast =  @"last";
	 fieldExtra = @"owner=newsletter.signup@neezio.com";
	*/
	
	
	// *************************************************************
	// Field Validation for our Signup Form
	// *************************************************************
	
	// Setup our requestReady Boolean
	BOOL requestReady = YES;
	NSString *validMessage = @"" ;
	
	// Check for Field Completion
	if([userFirst.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your first name!\r\n"];
		requestReady = NO;
	}
	
	if([userLast.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your last name!\r\n"];
		requestReady = NO;
	}
	
	if([userEmail.text isEqualToString:@""]) {
		validMessage = [validMessage stringByAppendingString:@"Please enter your email address!"];
		requestReady = NO;
	} else {
		
		// Email Address specified. Lets check for validation now.
		NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
		NSPredicate *emailValid = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailRegEx];
		if([emailValid evaluateWithObject:userEmail.text] == NO) {
			validMessage = [validMessage stringByAppendingString:@"Please enter a valid email address!"];
			requestReady = NO;
		}
		
	}

	// *************************************************************
	// Asynchronous HTTP POST Request to Submit our Signup Form Data
	// *************************************************************
	
	// Parameters for our Request Object
	requestParams = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@",fieldEmail,userEmail.text,fieldFirst,userFirst.text,fieldLast,userLast.text,fieldExtra];
	
	// If requestReady is YES then we can go ahead and process out our request
	if(requestReady == YES) {
		
		// Clear lblMessage Output Again for Good Measure
		lblMessage.text = @"";

		// Setup our full Request Object
		NSMutableURLRequest *submitRequest = [[[NSMutableURLRequest alloc] init] autorelease];
		[submitRequest setURL:[NSURL URLWithString:submitUrl]];
		[submitRequest setHTTPMethod:submitType];
		[submitRequest setHTTPBody:[requestParams dataUsingEncoding:NSUTF8StringEncoding]];
	
		// Setup & Execute our Connection for the Request Object
		requestConn = [[NSURLConnection alloc] initWithRequest:submitRequest delegate:self];
		
		// Check for Connection Success or Failure	
		if(requestConn) {
		
			// Connection Success - Setup our Received Data Variable for Use Later
			receivedData = [[NSMutableData data] retain];
		
		} else {
	
			// Connection Failed - Relay Message to User and Re-Enable Submit Button and Hide loadIndicator
			lblMessage.text = @"Ooops! We were not able to transmit your information at this time!";
			buttonSignup.enabled = YES;
			[loadIndicator stopAnimating];
		
		}
		
	} else {
	
		// Request was not ready due to validation errors. Let's output the results and re-enable the submit button now and Hide loadIndicator.
		lblMessage.text = validMessage;
		buttonSignup.enabled = YES;
		[loadIndicator stopAnimating];
		
	}
	
}

-(IBAction)donePressed{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)keyboardDone {
	// Releases the keyboard when the done button is pressed after user enters their information
}

// Function to Handle the didReceiveResponse Data Generated by the NSURLConnection Action
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	// As data is received after each connection, we clear it at the start of each connection.
	// This prevents any data from being added to our receivedData object should the request
	// be redirected to another URL prior to reaching the final destination.
	
	[receivedData setLength:0];

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
	
	// Hide loadIndicator
	[loadIndicator stopAnimating];
	
	// Notify User
	lblMessage.text = @"Ooops! Something went wrong and we were unable to confirm your information was sent!";
	
	// Release objects
	[receivedData release];
	[requestConn release];
	receivedData = nil;
	requestConn  = nil;
	
	// Re-enable our Signup button
	buttonSignup.enabled = YES;
	
}

// Function to Handle the Response Generated by the NSURLConnection Action
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	// Hide loadIndicator
	[loadIndicator stopAnimating];
	
	// The finalResponse is the ASCII encoded version of the receivedData we collected earlier.
	// Now in string format, we are free to work with that data as needed to detect any errors,
	// or success messages that we need to look for.
	
	finalResponse = [[NSString alloc] initWithData:receivedData encoding:NSASCIIStringEncoding];
	
	// *************************************************************
	// Verify Final Response Output
	// *************************************************************
	//
	// This is where we need to process the information returned from the request we made.
	// Because this request is made over an HTTP POST method, the information returned will
	// be in the form of website HTML data rather than just a simple response code for us to
	// evaluate. Because of this, we need to look for unique strings on the success page for
	// our Signup Success result from the newsletter provider. Once we find that unique string
	// in the response, we know we either made it through or failed somewhere along the way.
	
	
	// ================================================================================================
	// IMPORTANT!!! REMOVE COMMENTING "//" TO USE THESE SETTINGS FOR SUBMISSION TO YOUR RESPECTIVE HOST.
	// YOU MUST COMMENT OUT THE SETTINGS FOR ANY OTHER SYSTEMS INCLUDED HERE OR ELSE ERRORS WILL RESULT
	// ================================================================================================
	
	
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
	// AWeber: Success Message - "submission was successful"
	// *************************************************************
	//
	// This is the data from the AWeber newsletter system. Once a signup
	// reaches the success stage, AWeber uses the "submission was successful" message on that page
	// to normally notify the web used to check their email for the confirmation message that
	// AWeber will send to them if you have Double Opt-In in place for your form. This message
	// also results when you do not have Double Opt-In and have also not specified a redirect URL
	// which we have not done here in this application because we want to control the amount of
	// web transfer to only what we need to complete our transaction. Since we are going to handle
	// the message ourself, we just check for the response for that string, and notify the user accordingly.
	
	//NSString *successMessage = @"submission was successful";
	
	
	// *************************************************************
	// Custom Script: Success Message - "Success!"
	// *************************************************************
	//
	// This is the success message that the out-of-the-box script included with this project
	// will output to be read again by the application.
	
	/*
 	 NSString *successMessage = @"Success!";
	*/
	
	
	// *************************************************************
	// Response Message Processing - Finally!
	// *************************************************************
		
	NSRange range = [finalResponse rangeOfString:successMessage];
	if(range.location != NSNotFound) {

		// Success Message was located in the final response! Notify our user and we are all done here!
		lblMessage.text = @"Thank you for signing up for our newsletter!";

	} else {
		
		// Re-enable our Signup button
		buttonSignup.enabled = YES;
		
		// ******************************************
		// Common Error Message for Signup Failure
		// ******************************************

		// We did not find a success message in the final response. Notify our user and hope they try again!
		lblMessage.text = @"Ooops! Something went wrong and we were unable to confirm your information was sent!";
		
		
		// ******************************************
		// AWeber - User Already Signed Up Error
		// Will override common error msg output
		// ******************************************
		
		range = [finalResponse rangeOfString:@"already subscribed"];
		if(range.location != NSNotFound) {
			// User already submitted request to AWeber
			lblMessage.text = @"Ooops! Our records indicate you have already signed up for our newsletter!";
		}

	}
	
	// Release our Connection & Response Objects
	[requestConn release];
	requestConn = nil;
	[receivedData release];
	[finalResponse release];
	receivedData = nil;

}

// Standard function to execute processes after the view has loaded
- (void)viewDidLoad {
    [super viewDidLoad];
}

// Function Used to Prevent Interface Orientation Switching as Device is Rotated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationPortrait;
}

// Standard Memory Warning Function
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// Standard Unload Function
- (void)viewDidUnload {
	
	// *************************************************************
	// Release Any Retained Objects
	// *************************************************************
	
	self.userFirst = nil;
	self.userLast = nil;
	self.userEmail = nil;
	self.buttonSignup = nil;
	submitUrl = nil;
	submitType = nil;
	fieldEmail = nil;
	fieldFirst = nil;
	fieldLast = nil;
	requestParams = nil;
	submitResponse = nil;
	requestConn = nil;
	finalResponse = nil;
	loadIndicator = nil;
}

// Standard Deallocation Function
- (void)dealloc {
	
	// *************************************************************
	// Deallocate Hold On View Objects
	// *************************************************************
	
	[self.userFirst release];
	[self.userLast release];
	[self.userEmail release];
	[self.buttonSignup release];
	[self.loadIndicator release];
	
	if(requestConn)
	{
		[requestConn cancel];
		[requestConn release];
	}
	
	if(receivedData)
	{
		[receivedData release];
	}
	
    [super dealloc];
}

@end
