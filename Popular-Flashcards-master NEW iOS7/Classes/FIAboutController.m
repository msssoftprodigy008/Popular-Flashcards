//
//  FIAboutController.m
//  flashCards
//
//  Created by Ruslan on 8/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIAboutController.h"
#import "FIWebViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FRootConstants.h"
#import "FINewsletter_SignupViewController.h"
#import "Util.h"
#import "FINavigationBar.h"
#import "Constant.h"
@interface FIAboutController(Private)

-(void)initTopBar;
-(void)backPressed;
-(void)sendEmail:(NSInteger)typeOfEmail;
-(void)rateOniTunes;
-(void)moreApps;
-(void)newsletter;
-(void)initWebView;
-(void)loadHTML;

@end


@implementation FIAboutController

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
	UIView *contentView = [[UIView alloc] init];
    if (IS_IPHONE_5) {
        contentView.frame = CGRectMake(0,0,568,300);
        aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,50,279,260) style:UITableViewStyleGrouped];
    }
    else{
        contentView.frame = CGRectMake(0,0,480,300);
        aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(5,50,235,260) style:UITableViewStyleGrouped];
    }
	self.view = contentView;
	self.view.backgroundColor = [UIColor clearColor];
	[contentView release];
	
	[self initTopBar];
	[self initWebView];
	
	
	aboutTableView.delegate = self;
	aboutTableView.dataSource = self;
	aboutTableView.backgroundColor = [UIColor clearColor];
	aboutTableView.scrollEnabled = NO;
	[self.view addSubview:aboutTableView];
	[aboutTableView release];
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self performSelector:@selector(loadHTML)
			   withObject:nil
			   afterDelay:0.0f];
//    [self performSelector:@selector(moreApps)
//			   withObject:nil
//			   afterDelay:0.25f];
    UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
    NSLog( @" ORIENTATION: %@", UIInterfaceOrientationIsLandscape( orientation ) ? @"LANDSCAPE" : @"PORTRAIT");

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(preferredInterfaceOrientationForPresentation)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
}

//- (BOOL)deviceRotated: (id) sender{
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    if (orientation == UIDeviceOrientationFaceUp ||
//        orientation == UIDeviceOrientationFaceDown)
//    {
//        //Device rotated up/down
//        return NO;
//        
//    }
//    
//    if (orientation == UIDeviceOrientationPortraitUpsideDown)
//    {
//        return NO;
//    }
//    else if (orientation == UIDeviceOrientationLandscapeLeft)
//    {
//        return YES;
//        
//    }
//    else if (orientation == UIDeviceOrientationLandscapeRight)
//    {
//        return YES;
//    }
//}
- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
// Returns interface orientation masks.
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskLandscape;

}
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    
//    if ([Util isPortraitWithOrientation:UIInterfaceOrientationMaskPortrait]) {
//        return NO;
//    }else
//    {
//        return YES;
//        
//    }
//    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//    
//    if (orientation == UIDeviceOrientationPortraitUpsideDown)
//    {
//                return NO;
//    }
//    else if (orientation == UIDeviceOrientationFaceUp ||
//                     orientation == UIDeviceOrientationFaceDown)
//    {
//        //Device rotated up/down
//        return NO;
//        
//    }else if(orientation == UIDeviceOrientationPortrait)
//    {
//        return NO;
//    }else
//        return YES;
//
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
 
}


#pragma mark -
#pragma mark AlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex]) {
		[self rateOniTunes];
	}
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{
	if (result == MFMailComposeResultSent) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
														message:@"Your letter has been send"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	if (result == MFMailComposeResultFailed) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Sorry,can't sent your letter"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 3;
	
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForCategory";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
	}
	
	/*switch (indexPath.row) {
        case 0:
			cell.textLabel.text = @"More Apps";
          	cell.imageView.image = [Util imageFromBundle:@"i_icon_moreapps.png"];
			break;
		case 1:
			cell.textLabel.text = @"Send to friend";
          	cell.imageView.image = [Util imageFromBundle:@"i_icon_send2friend.png"];
			break;
		case 2:
			cell.textLabel.text = @"Send feedback";
          	cell.imageView.image = [Util imageFromBundle:@"i_icon_sendfeedback.png"];
			break;
		case 3:
			cell.textLabel.text = @"Rate on Itunes";
           	cell.imageView.image = [Util imageFromBundle:@"i_icon_rate.png"];
			break;
		case 4:
			cell.textLabel.text = @"Newsletter";
           	cell.imageView.image = [Util imageFromBundle:@"i_icon_newsletter.png"];
			break;
		default:
			break;
	}*/
    
    switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Send to friend";
          	cell.imageView.image = [Util imageFromBundle:@"i_icon_send2friend.png"];
			break;
		case 1:
			cell.textLabel.text = @"Send feedback";
          	cell.imageView.image = [Util imageFromBundle:@"i_icon_sendfeedback.png"];
			break;
		case 2:
			cell.textLabel.text = @"Rate on Itunes";
           	cell.imageView.image = [Util imageFromBundle:@"i_icon_rate.png"];
			break;
		default:
			break;
	}
	
	/*UIImageView *bg = (UIImageView*)cell.backgroundView;
     UIImageView *selbg = (UIImageView*)cell.selectedBackgroundView;
     
     if (indexPath.row == 5) {
     bg.image = [UIImage imageNamed:@"i_list_bottom_1.png"];
     selbg.image = [UIImage imageNamed:@"i_list_bottom_2.png"];
     }else {
     bg.image = [UIImage imageNamed:@"i_list_bg_menu_1.png"];;
     selbg.image = [UIImage imageNamed:@"i_list_middle_2.png"];
     }
     
     cell.backgroundView = bg;
     cell.selectedBackgroundView = selbg;*/
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 43;
}

/*- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
 {
 return 50.0;
 }*/

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
 {
 UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0,0,320.0,36.0)] autorelease];
 
 
 UIImageView *imageView = [[UIImageView alloc] init];
 imageView.frame = CGRectMake(7,-28,306.0,32.0);
 imageView.image = [UIImage imageNamed:@"i_list_bottom_shadow.png"];
 [customView addSubview:imageView];
 [imageView release];
 
 return customView;
 }*/

/*- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
 {
 // create the parent view that will hold header Label
 
 UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0,0,320.0,50.0)] autorelease];
 
 UIImageView *imageView = [[UIImageView alloc] init];
 
 imageView.frame = CGRectMake(9.0,50-32,302.0,32.0);
 imageView.image = [UIImage imageNamed:@"i_sets_menu.png"];
 [customView addSubview:imageView];
 [imageView release];
 
 UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5,16-12,24,24)];
 iconView.image = [UIImage imageNamed:@"i_info.png"];
 
 [imageView addSubview:iconView];
 [iconView release];
 
 UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24+5+5,0,50,32)];
 
 titleLabel.text = @"Info";
 
 
 titleLabel.textColor = [UIColor colorWithRed:0.224 green:0.224 blue:0.224 alpha:1.0];
 titleLabel.backgroundColor = [UIColor clearColor];
 titleLabel.font = [UIFont boldSystemFontOfSize:16];
 titleLabel.shadowOffset = CGSizeMake(1,1);
 titleLabel.shadowColor = [UIColor whiteColor];
 [imageView addSubview:titleLabel];
 [titleLabel release];
 
 
 return customView;
 
 }*/


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch (indexPath.row) {
        case 0:
			[self moreApps];
			break;
		case 1:
			[self sendEmail:0];
			break;
		case 2:
//			[self sendEmail:1];
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=352320289"]];
        }
			break;
		case 3:
        {
            NSString *msg = @"Would you like to rate the app on iTunes? 5-star rates keep free updates coming!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Itunes"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"YES"
                                                  otherButtonTitles:@"Cancel",nil];
            [alert show];
            [alert release];
            break;
        }
		case 4:
			[self newsletter];
			break;
		default:
			break;
	}
	
}

#pragma mark -
#pragma mark FINewsletterDelegate

-(CGRect)FINewsletterViewFrame
{
    if (IS_IPHONE_5) {
        return CGRectMake(0,0,568,300);
    }
    else{
        return CGRectMake(0,0,480,300);
    }
	 return CGRectMake(0,0,480,300);
}

-(BOOL)FINewsletterNavigationBarExist
{
	return YES;
}

-(BOOL)FINewsletterDoneButtonExist
{
	return YES;
}


-(void)FINewsletterDoneButtonPressed:(FINewsletter_SignupViewController*)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

-(void)FINewsletterCustomizeNavBar:(UINavigationBar*)navigationBar
{
	navigationBar.tintColor = kDefaultNavColor;
}

-(BOOL)FINewsletterInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	return orientation == UIInterfaceOrientationLandscapeLeft;
}

-(void)FINewsletterCustomizeMainView:(UIView*)view
{
    UIImageView *bgView = [[UIImageView alloc] init];
    if (IS_IPHONE_5) {
        bgView.frame = CGRectMake(0,0,568,300);
    }
    else{
        bgView.frame = CGRectMake(0,0,480,300);
    }
	
	bgView.image = [Util rotateImage:[UIImage imageNamed:@"i_bg.png"] forAngle:90];
	bgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[view addSubview:bgView];
	[bgView release];
}

-(CGFloat)FINewsletterTextFieldHeight
{
	return 30;
}

-(CGFloat)FINewsletterDistanceToSignButton
{
	return 230;
}

#pragma mark FINewsletterDelegate ends

#pragma mark -
#pragma mark private

-(void)backPressed
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)initTopBar
{
    FINavigationBar *navBar = [[FINavigationBar alloc] init];
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                [self prefersStatusBarHidden];
                [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
            } else {
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }
            navBar.frame = CGRectMake(0,0,568,40);
        }
        else{
            navBar.frame = CGRectMake(0,0,568,40);
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
            navBar.frame = CGRectMake(0,0,480,40);
        }
        else{
            navBar.frame = CGRectMake(0,0,480,40);
        }
        
        
    }
	navBar.tintColor = [UIColor blackColor];
	navBar.bgImage = [UIImage imageNamed:@"i_panel_bg.png"];
	UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"A+ FlashCards"];
	[navBar pushNavigationItem:navItem animated:NO];
	[navItem release];
    
	UIButton *backCustomButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *backButtonImage = [UIImage imageNamed:@"i_panel_main1.png"];
	backCustomButton.frame = CGRectMake(0,0,backButtonImage.size.width,backButtonImage.size.height);
	[backCustomButton setImage:backButtonImage forState:UIControlStateNormal];
	[backCustomButton setImage:[UIImage imageNamed:@"i_panel_main2.png"] forState:UIControlStateHighlighted];
	[backCustomButton addTarget:self
						 action:@selector(backPressed)
			   forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backCustomButton];
	navItem.leftBarButtonItem = backButton;
	[backButton release];
	[self.view addSubview:navBar];
	[navBar release];
	
}

-(void)initWebView
{
    if (IS_IPHONE_5) {
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(284,60,274,215)];
    }
    else{
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(240,60,230,215)];
    }
	[[webView layer] setContentsScale:[UIScreen mainScreen].scale];
	[[webView layer] setCornerRadius:10];
	[[webView layer] setBorderWidth:1.0f];
	[[webView layer] setBorderColor:[UIColor lightGrayColor].CGColor];
	webView.clipsToBounds = YES;
	webView.backgroundColor = [UIColor whiteColor];
	webView.scalesPageToFit = YES;
	webView.userInteractionEnabled = NO;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:webView];
	[webView release];
    
}

- (void) sendEmail:(NSInteger)typeOfEmail {
	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil) {
		if ([mailClass canSendMail]) {
			MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
			picker.navigationBar.tintColor = kDefaultNavColor;
			picker.mailComposeDelegate = self;
			
			if (typeOfEmail) {
				[picker setToRecipients:[NSArray arrayWithObject:@"support@ads-sg.com"]];
				[picker setSubject:@"Feedback from A+ FlashCards"];
				[picker setMessageBody:@"" isHTML:NO];
			}else {
                
                [picker setToRecipients:[NSArray arrayWithObject:@"aplusflashcardspro@gmail.com"]];
				[picker setSubject:@"Awesome flashcards application for iPhone/iPad!"];
				[picker setMessageBody:@"Check out A+ FlashCards app for iPhone/iPad - <a href='http://bit.ly/aplusflashcards'>http://bit.ly/aplusflashcards</a>" isHTML:YES];
			}
            
			
			
			[self presentViewController:picker animated:YES completion:nil];
			[picker release];
			
		}
		
	}
	
}


- (void) rateOniTunes {
    if ([Util isFullVersion]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=352320289"]];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=395248242"]];
    }
	
}


- (void) moreApps {
    if ([Util connectedToNetwork]) {
        FIWebViewController *webViewController = [[FIWebViewController alloc] init];
        webViewController.isHTML = NO;
        webViewController.titleStr = @"More apps";
        if ([Util isFullVersion]) {
            webViewController.path = @"http://ads-sg.com/i/flashcardspro/index.html";
        }else{
            webViewController.path = @"http://ads-sg.com/i/flashcards/index.html";
        }
        [self presentModalViewController:webViewController animated:YES];
        [webViewController release];
    }
	
}


- (void) newsletter {
	FINewsletter_SignupViewController* newsletterController = [[FINewsletter_SignupViewController alloc] init];
	newsletterController.delegate = self;
	[self presentModalViewController:newsletterController animated:YES];
	[newsletterController release];
}

-(void)loadHTML
{
	NSString* path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"i_aboutIP" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
	[webView loadHTMLString:path baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
