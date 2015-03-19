    //
//  AboutViewController.m
//  ArtPuzzles
//
//  Created by Developer on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "flashCardsAppDelegate.h"
#import "Util.h"
#import "FRootConstants.h"
@interface AboutViewController(Private)

-(void)initNewsletter;

@end


@implementation AboutViewController
@synthesize delegate;

- (id) init {
	if (self = [super init]) {
		
	}
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(33.5f, 191.5f, 701.0f, 641.0f)];
    
   // 33.5f, 191.5f, 701.0f, 641.0f
	self.view = contentView;
	[contentView release];
	[self.view setBackgroundColor:[UIColor clearColor]];
	
	UIImageView* Background = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 701.0f, 641.0f)];
	[Background setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"about" ofType:@"png"]]];
	[self.view addSubview:Background];
	[Background release];
	
	UIButton* bClose = [[UIButton alloc]initWithFrame:CGRectMake(595.3f, 39.0f, 53.0f, 53.0f)];
	[bClose setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"quit_2" ofType:@"png"]] forState:UIControlStateHighlighted];
	[bClose addTarget:self action:@selector(hideController) forControlEvents:UIControlEventTouchUpInside];
	bClose.backgroundColor = [UIColor clearColor];
	[self.view addSubview:bClose];
	[bClose release];
	
	state = aboutStateWebView;
	
	aboutTableView = [[UITableView alloc]initWithFrame:CGRectMake(44.0f, 90.0f, 206.0f, 264.0f) style:UITableViewStylePlain];
	aboutTableView.delegate = self;
	[aboutTableView setBackgroundColor:[UIColor clearColor]];
	[aboutTableView setScrollEnabled:NO];
	aboutTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	aboutTableView.dataSource = self;
	aboutTableView.rowHeight = 44.0f;
	[self.view addSubview:aboutTableView];
	[aboutTableView release];
	
	[self initNewsletter];
//    [self initTopBar];
//    [self initWebView];
	newsletterController.view.hidden = YES;
	
	aboutWebView = [[UIWebView alloc]initWithFrame:CGRectMake(267.0f, 111.0f, 366.0f, 450.0f)];
	aboutWebView.delegate = self;
	[aboutWebView setBackgroundColor:[UIColor clearColor]];

	if ([Util isFullVersion]) {
        [aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ads-sg.com/i/flashcardspro/index.html"]]];
    }else{
        [aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ads-sg.com/i/flashcards/index.html"]]];
    }
    
	[self.view addSubview:aboutWebView];
	[aboutWebView release];
	
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(preferredInterfaceOrientationForPresentation)
//     name:UIDeviceOrientationDidChangeNotification
//     object:[UIDevice currentDevice]];
		
}
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    return UIInterfaceOrientationMaskLandscape;
//    
//}

- (void) viewWillAppear:(BOOL)animated {
	
}

-(void)viewDidAppear:(BOOL)animated
{

	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(loadHTML)
               withObject:nil
               afterDelay:0.0f];//[super viewDidLoad];
}
-(void)loadHTML
{
    NSString* path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"i_aboutIPad" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    [aboutWebView loadHTMLString:path baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
}
// changed by sanjeev reddy
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
//	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
//		self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
//	} else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
//	} else if (interfaceOrientation == UIInterfaceOrientationPortrait) {
//		self.view.transform = CGAffineTransformMakeRotation(0);
//	} else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
//		self.view.transform = CGAffineTransformMakeRotation(M_PI);
//	}
//    return YES;
    
    
    return UIInterfaceOrientationMaskLandscape;
    
}


-(NSUInteger)supportedInterfaceOrientations
{

    return UIInterfaceOrientationMaskLandscape;

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


- (void) hideController {
	if (delegate && [delegate respondsToSelector:@selector(aboutClosed:)]) {
		[delegate aboutClosed:self];
	}
}


//- (void)displayComposerSheet:(NSInteger)typeOfEmail {
//	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
//	[picker setModalPresentationStyle:UIModalPresentationFormSheet];
//	picker.mailComposeDelegate = self;
//	
//	if (typeOfEmail) {
//		[picker setToRecipients:[NSArray arrayWithObject:@"support@ads-sg.com"]];
//		[picker setSubject:@"Feedback from A+ FlashCards"];
//		[picker setMessageBody:@"" isHTML:NO];
//	}else {
//		[picker setSubject:@"Awesome Flashcards application for iPhone/iPad!"];
//		[picker setMessageBody:@"Check out A+ Flashcards for iPhone and iPad - <a href='http://bit.ly/aplusflashcards'>http://bit.ly/aplusflashcards</a>" isHTML:YES];
//	}
//	
//	[self presentViewController:picker animated:YES completion:nil];
//   [picker release];
//}


- (void)launchMailAppOnDevice:(NSInteger)typeOfEmail {

}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {	
	[self dismissViewControllerAnimated:YES completion:nil];
}


//- (void) sendEmail:(NSInteger)typeOfEmail {
//	Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
//	if (mailClass != nil) {
//		if ([mailClass canSendMail]) {
//			[self displayComposerSheet:typeOfEmail];
//		}
//		else {
//			[self launchMailAppOnDevice:typeOfEmail];
//		}
//	}
//	else {
//		[self launchMailAppOnDevice:typeOfEmail];
//	}
//}
- (void) sendEmail:(NSInteger)typeOfEmail {   // changed by sanjeev reddy
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
	if ([Util isFullVersion]) {
        [aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ads-sg.com/i/flashcardspro/index.html"]]];
    }else{
        [aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ads-sg.com/i/flashcards/index.html"]]];
    }

	
}

-(void)initNewsletter
{
	newsletterController = [[FINewsletter_SignupViewController alloc] init];
	newsletterController.delegate = self;
	[self.view addSubview:newsletterController.view];
}

- (void) newsletter {
		
}


- (void) license {
	NSString* path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"about" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
	[aboutWebView loadHTMLString:path baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]bundlePath]]];
}

#pragma mark -
#pragma mark newsletterControllerDelegate

-(CGRect)FINewsletterViewFrame
{
	return CGRectMake(267.0f, 111.0f, 366.0f, 450.0f);
}

-(BOOL)FINewsletterNavigationBarExist
{
	return NO;	
}

-(BOOL)FINewsletterDoneButtonExist
{
	return NO;
}

#pragma mark -

#pragma mark -
#pragma mark AlertView delegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex]) {
		[self rateOniTunes];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate

- (NSInteger) tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	//return 6;
    return 3;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"] autorelease];
			[cell.textLabel setFont:[UIFont systemFontOfSize:15]];
		
		[cell.selectedBackgroundView setBackgroundColor:[UIColor clearColor]];
				
		UIImageView* accessoryImage = [[UIImageView alloc] initWithFrame:CGRectMake(180.0f, 14.0f, 11.0f, 15.0f)];
		accessoryImage.image = [UIImage imageNamed:@"fc_startpage_arrow.png"];
		accessoryImage.highlightedImage = [UIImage imageNamed:@"fc_startpage_arrow2.png"];
		cell.accessoryView = accessoryImage;
		[accessoryImage release];		
		
		UIImageView* backgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 206.0f, 44.0f)];
		backgroundView.image = [UIImage imageNamed:@"list_1.png"];
		cell.backgroundView = backgroundView;
		[backgroundView release];
		
		UIImageView* selBackgroundView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 206.0f, 44.0f)];
		selBackgroundView.image = [UIImage imageNamed:@"list_2.png"];
		cell.selectedBackgroundView = selBackgroundView;
		[selBackgroundView release];
		
		
	}
	
	cell.textLabel.textColor = [UIColor grayColor];
//    switch (indexPath.row) {                      // changed  sanjeev reddy
//		case 0:
//			[cell.textLabel setText:@"Send to friend"];
//            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",1] ofType:@"png"]]];
//			break;
//		case 1:
//			[cell.textLabel setText:@"Send FeedBack"];
//            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",2] ofType:@"png"]]];
//			break;
//		case 2:
//			[cell.textLabel setText:@"Rate on iTunes"];
//            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",3] ofType:@"png"]]];
//			break;
//		case 3:
//			[cell.textLabel setText:@"About"];
//            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",6] ofType:@"png"]]];
//			break;
//		default:
//			break;
//	}
    
    
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
    
    
    
    
    
	/*switch (indexPath.row) {
        case 0:
			[cell.textLabel setText:@"More Apps"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",4] ofType:@"png"]]];
   			[aboutTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
			break;    
		case 1:
			[cell.textLabel setText:@"Send to friend"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",1] ofType:@"png"]]];
			break;
		case 2:
			[cell.textLabel setText:@"Send FeedBack"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",2] ofType:@"png"]]];
			break;
		case 3:
			[cell.textLabel setText:@"Rate on iTunes"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",3] ofType:@"png"]]];
			break;
		case 4:
			[cell.textLabel setText:@"Newsletter"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",5] ofType:@"png"]]];
			break;
		case 5:
			[cell.textLabel setText:@"About"];
            [cell.imageView setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"icon_%i",6] ofType:@"png"]]];
			break;
		default:
			break;
	}*/
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		
	if (indexPath.row !=4 && indexPath.row != 5 && indexPath.row != 0) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		NSIndexPath *selPath = [NSIndexPath indexPathForRow:5 inSection:0];
		[tableView selectRowAtIndexPath:selPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        newsletterController.view.hidden = YES;
        aboutWebView.hidden = NO;
	}
		
	if (indexPath.row == 4) {
		if (state == aboutStateWebView) {
			aboutWebView.hidden = YES;
			newsletterController.view.hidden = NO;
			[self.view bringSubviewToFront:newsletterController.view];
			state = aboutStateNewsletter;
		}
	}else {
		if (state == aboutStateNewsletter) {
			newsletterController.view.hidden = YES;
			aboutWebView.hidden = NO;
			[self.view bringSubviewToFront:aboutWebView];
			state = aboutStateWebView;
		}
	}

	
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


//- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.row) {
//        case 0:
//            [self moreApps];
//            break;
//        case 1:
//            [self sendEmail:0];
//            break;
//        case 2:
//            //			[self sendEmail:1];
//        {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=352320289"]];
//        }
//            break;
//        case 3:
//        {
//            NSString *msg = @"Would you like to rate the app on iTunes? 5-star rates keep free updates coming!";
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Itunes"
//                                                            message:msg
//                                                           delegate:self
//                                                  cancelButtonTitle:@"YES"
//                                                  otherButtonTitles:@"Cancel",nil];
//            [alert show];
//            [alert release];
//            break;
//        }
//        case 4:
//            [self newsletter];
//            break;
//        default:
//            break;
//    }
//
//}
//

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}


- (void)dealloc {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[newsletterController release];
	
    [super dealloc];
}


@end
