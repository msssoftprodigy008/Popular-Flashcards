//
//  FICardEditController.m
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FICardEditController.h"
#import "FDBController.h"
#import "FRecordController.h"
#import "FIAudioManageController.h"
#import "FIAnimationController.h"
#import "FIToolBar.h"
#import "Util.h"
#import "Constants.h"
#import "Constant.h"
#import "FIPickerViewIOS7.h"

@interface FICardEditController(Private)

-(void)initTopBar;
-(void)initContent;
-(void)initBgLinesView;
-(void)changeBgLinesView;
-(void)rightPressed;
-(void)firstImage;
-(void)secondImage;
-(void)initToolBarForKeyBoard;

-(void)translatePressed;
-(void)languagePressed:(id)sender;
-(void)onlinePressed;
-(void)searchPressed;

-(void)saveLang;
-(void)initLang;

-(void)cancelPressed;
-(void)audioButtonPressed:(id)sender;
-(void)audioSearchButtonPressed:(id)sender;

-(void)addCard;
-(NSString*)lanCodeForStr:(NSString*)lang;
-(NSString*)countryForCode:(NSString*)lang;
-(void)addTextToCard:(NSString*)text;
-(void)addImageToCard:(UIImage*)image;
-(void)addAudioToCard:(NSData*)audio;

@end


@implementation FICardEditController
@synthesize delegate;
@synthesize orientation;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

-(id)initWithType:(FIEditCardType)type forCategory:(NSString*)Acategory forArg:(NSDictionary*)arguments
{
	editTipe = type;
	
	if (Acategory) {
		category = [[NSString alloc] initWithString:Acategory];
		setTemplate = [[FDBController sharedDatabase] templateForSet:category];
	}
	
	aImage = nil;
	qImage = nil;
	
	if ((type == FIEditCardTypeUpdate) && arguments) {
		if ([arguments objectForKey:@"question"])
			q = [NSString stringWithString:[arguments objectForKey:@"question"]];
        
		if ([arguments objectForKey:@"answer"])
			a = [NSString stringWithString:[arguments objectForKey:@"answer"]];
		
        if ([arguments objectForKey:@"cardId"]) {
            cardId = [[arguments objectForKey:@"cardId"] intValue];
        }else{
            cardId = -1;
        }
        
		if (kt_isFrontPic(setTemplate)) {
			if ([arguments objectForKey:@"qImage"]) {
				qImage = [[UIImage alloc] initWithData:(NSData*)[arguments objectForKey:@"qImage"]];
			}
		}
		
		if (kt_isBackPic(setTemplate)) {
			if ([arguments objectForKey:@"aImage"]) {
				aImage = [[UIImage alloc] initWithData:(NSData*)[arguments objectForKey:@"aImage"]];
			}
		}
	}
	imageType = FIImagePickedTypeNone;
	
	isTrans = NO;
	
	return [self init];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	
	CGRect frame;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([Util isPhone]) {
            if (IS_IPHONE_5) {
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                        [self prefersStatusBarHidden];
                        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                    } else {
                        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                    }
                    frame = CGRectMake(0,0,568,190);
                }
                else{
                    frame = CGRectMake(0,0,568,170);
                }
                
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
                frame = CGRectMake(0,0,480,190);
            }
            else{
                frame = CGRectMake(0,0,480,170);
            }
            
            
        }
	}else {
		frame = CGRectMake(0,0,500,256);   // ipad retina
	}
    
    
	UIView *contentView = [[UIView alloc] initWithFrame:frame];
	self.view = contentView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view.backgroundColor = [UIColor whiteColor];
	[contentView release];
	
	[self initBgLinesView];
	
    
	[self initLang];
	[self initContent];
	[self initTopBar];
	[self initToolBarForKeyBoard];
	
    if (cardId == -1) {
        editTipe = FIEditCardTypeAdd;
    }
	
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    //changed sanjeev reddy
    if ([Util isPhone]) {
        
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    }else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error: nil];
        UInt64 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                 sizeof (audioRouteOverride),&audioRouteOverride);
    
    }
    
   
	[super viewDidLoad];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (![Util isPhone]) {
		return (toInterfaceOrientation==UIInterfaceOrientationPortrait);
    }else {
		return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
	}
    
}


- (NSUInteger)supportedInterfaceOrientations
{
    
    
    return UIInterfaceOrientationMaskLandscape;

    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [self supportedInterfaceOrientations];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

-(void)viewWillDisappear:(BOOL)animated
{
	
}

-(void)viewDidAppear:(BOOL)animated
{
	if (Q){
        Q.autocorrectionType = UITextAutocorrectionTypeDefault;
    }
    
    if (A){
        A.autocorrectionType = UITextAutocorrectionTypeDefault;
    }
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark FLanguageTranslateDelegate Methods

-(void)translatingFnished:(BOOL)result translated:(NSString*)translatedText
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    
	if (result)
	{
		[self addTextToCard:translatedText];
        
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Translation failed. Please try again."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		
	}
	
	
}

#pragma mark -
#pragma mark FIMicrosoftTranslate delegate

-(void)supportedLanguages:(NSArray*)languages
{
    translate.enabled = YES;
    language.enabled = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	NSMutableDictionary *suppLan = [NSMutableDictionary dictionary];
	NSDictionary *lanCodes = [Util lanCode];
	NSArray *keys = [lanCodes allKeys];
	for (NSString *key in keys) {
		for (NSString *l in languages) {
			if ([l isEqualToString:[lanCodes objectForKey:key]]) {
				[suppLan setObject:l forKey:key];
				break;
			}
		}
	}

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        FIPickerViewIOS7 *lanPicker = [[FIPickerViewIOS7 alloc] initWithDicAndDelegate:suppLan andForDelegate:self forFLan:@"English" forSLan:@"English"];
        [lanPicker init];
        [lanPicker show];
        [lanPicker release];  // working now changed by sanjeev reddy
//        FIPickerView *lanPicker = [[FIPickerView alloc] initWithDicAndDelegate:suppLan andForDelegate:self forFLan:@"English" forSLan:@"English"];
//        [lanPicker show];
//        [lanPicker release];
    }
    else{
        FIPickerView *lanPicker = [[FIPickerView alloc] initWithDicAndDelegate:suppLan andForDelegate:self forFLan:@"English" forSLan:@"English"];
        [lanPicker show];
        [lanPicker release];
    }

//    FIPickerView *pic = [[FIPickerView alloc] initWithDicAndDelegate:suppLan
//                                                      andForDelegate:self
//                                                             forFLan:firstLan
//                                                             forSLan:secondLan];
//    [pic show];
//    [pic release];
    
}

-(void)translatingFailed:(NSString*)desription
{
    translate.enabled = YES;
    language.enabled = YES;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (desription) {
		[Util showMessage:@"Translate"
			   forMessage:desription
		   forButtonTitle:@"OK"];
	}
}

-(void)translatedText:(NSString*)text
{
    translate.enabled = YES;
    language.enabled = YES;
    
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	if (text)
	{
		[self addTextToCard:text];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Translation failed. Please try again."
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
}


#pragma mark FIMicrosoftTranslate delegate ends

#pragma mark -
#pragma mark FIPickerAlertViewDelegate Methods

-(void)languagePicked:(NSString*)fromL next:(NSString*)toLan
{
	if (firstLan) {
		[firstLan release];
	}
	
	if (secondLan) {
		[secondLan release];
	}
    
	
	firstLan = [[NSString alloc] initWithString:fromL];
	secondLan = [[NSString alloc] initWithString:toLan];
	
	NSString *fL = [self lanCodeForStr:firstLan];
	NSString *sL = [self lanCodeForStr:secondLan];
	
	if (language) {
        UIButton *customButton = (UIButton*)language.customView;
        if (fL && sL) {
            [customButton setTitle:[NSString stringWithFormat:@"%@->%@",fL,sL] forState:UIControlStateNormal];
            [customButton setTitle:[NSString stringWithFormat:@"%@->%@",fL,sL] forState:UIControlStateHighlighted];
        }else{
            [customButton setTitle:@"Lang" forState:UIControlStateNormal];
            [customButton setTitle:@"Lang" forState:UIControlStateHighlighted];
        }
	}
    
	
	[self saveLang];
    
    if (isNeedTranslate) {
        isNeedTranslate = NO;
        [self translatePressedUpdatedByNil];
    }
    [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(displayTextField) userInfo:nil repeats:NO];

//    [A becomeFirstResponder];
}
- (void)displayTextField{
    [Q becomeFirstResponder];
}

#pragma mark -
#pragma mark UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex]) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		[Q becomeFirstResponder];
	}
    
}

#pragma mark -
#pragma mark  search delegate


-(void)someDataToSave:(NSDictionary*)data
{
	NSString *text = (NSString*)[data objectForKey:@"text"];
	UIImage *image = (UIImage*)[data objectForKey:@"image"];
	
	[self addTextToCard:text];
	[self addImageToCard:image];
	
	
}

#pragma mark -
#pragma mark FIDefinition delegate

-(void)definitionWasPicked:(NSString*)definition
{
	if (definition) {
		if (A) {
			
			if (![A hasText] || [A.text isEqualToString:@""]) {
				A.text = definition;
			}else {
				A.text = [A.text stringByAppendingFormat:@"\n%@",definition];
			}
			
		}else {
			if (Q) {
				if (![Q hasText] || [Q.text isEqualToString:@""]) {
					Q.text = definition;
				}else {
					Q.text = [Q.text stringByAppendingFormat:@"\n%@",definition];
				}
			}
		}
        
	}
}

#pragma mark -
#pragma mark FIDefinition delegate Ipad
-(void)definitionPicked:(NSString*)definition
{
	[self definitionWasPicked:definition];
}

#pragma mark -

#pragma mark -
#pragma mark translate methods

-(void)initLang
{
	NSArray *langArr = [[NSUserDefaults standardUserDefaults] arrayForKey:[NSString stringWithFormat:@"%@_lang",category]];
	
	if (firstLan) {
		[firstLan release];
	}
	
	if (secondLan) {
		[secondLan release];
	}
	
	if (langArr) {
		firstLan = [[NSString alloc] initWithString:[langArr objectAtIndex:0]];
		secondLan = [[NSString alloc] initWithString:[langArr objectAtIndex:1]];
	}
	else {
        firstLan = nil;
        secondLan = nil;
	}
	
}

-(void)saveLang
{
	if (firstLan && secondLan) {
		NSArray *arr = [NSArray arrayWithObjects:firstLan,secondLan,nil];
		[[NSUserDefaults standardUserDefaults] setObject:arr forKey:[NSString stringWithFormat:@"%@_lang",category]];
	}
}

#pragma mark -
#pragma mark FRecordControllerDelegate
-(void)soundForCard:(NSData*)sound forWhat:(BOOL)isQ
{
	if (isQ) {
		
		if (qSound) {
			[qSound release];
			qSound = nil;
		}
		
		if (sound) {
			qSound = [[NSData alloc] initWithData:sound];
			if ([Util isPhone]) {
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
			}else {
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
			}
		}else {
			if ([Util isPhone]) {
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}else {
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
			}
            
		}
		
		isQSoundChanged = YES;
		
	}else {
		if (aSound) {
			[aSound release];
			aSound = nil;
		}
		
		if (sound) {
			aSound = [[NSData alloc] initWithData:sound];
			if ([Util isPhone]) {
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
			}else {
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
			}
		}else {
			if ([Util isPhone]) {
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}else {
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
			}
		}
		
		isASoundChanged = YES;
	}
    
}

#pragma mark -
#pragma mark AudioSearch delegate

-(void)audioFromWordnik:(NSData*)audio
{
	[self addAudioToCard:audio];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


#pragma mark -
#pragma mark flickerController delegate

-(void)pictureForTerm:(UIImage*)pic pop:(BOOL)pop
{
	if (imageType == FIimagePickedTypeQuestion) {
		
		if (qImage) {
			[qImage release];
			
		}
		
		if (pic) {
			qImage = [[UIImage alloc] initWithCGImage:pic.CGImage];
			qImageView.image = qImage;
		}
		else {
			qImage = nil;
            if ([Util isPhone]) {
                qImageView.image = [UIImage imageNamed:@"i_add_image.png"];
            }else{
                qImageView.image = [UIImage imageNamed:@"add_image_1.png"];
            }
		}
		
		
		
	}
	else {
		
		if (aImage) {
			[aImage release];
			
		}
		
		if (pic) {
			aImage = [[UIImage alloc] initWithCGImage:pic.CGImage];
			aImageView.image = aImage;
		}
		else {
			aImage = nil;
            if ([Util isPhone]) {
                aImageView.image = 	[UIImage imageNamed:@"i_add_image.png"];
            }else{
                aImageView.image = 	[UIImage imageNamed:@"add_image_1.png"];
            }
		}
		
		
		
	}
	
	if (pop) {
		[self.navigationController popToViewController:self animated:YES];
	}
}

#pragma mark -

#pragma mark -
#pragma mark FIImageEditControllerDelegate

-(void)imageWasDeleted{
	[self pictureForTerm:nil pop:YES];
	
}


#pragma mark -
#pragma mark FDefinitionController delegate

-(void)audioForTerm:(NSMutableArray*)audioArr
{
	if (audioArr && [audioArr count]>0) {
		NSDictionary *audio = [audioArr objectAtIndex:0];
		NSString *fileUrl = [audio objectForKey:@"fileUrl"];
		
		if (fileUrl) {
			[[FDownLoader sharedDownloader:nil] cancelDownloading];
			[[FDownLoader sharedDownloader:self] download:[NSArray arrayWithObject:fileUrl]];
		}
		
		
	}else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Audio"
															message:@"Audio not found"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
    
}

-(void)definitionFailed
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Audio"
														message:@"Connection failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

#pragma mark FDefinitionController delegate ends

#pragma mark -
#pragma mark FDownLoader

-(void)downloadedDataRecived:(NSData*)downloadedData
{
	if (downloadedData) {
		
		[self addAudioToCard:downloadedData];
		
		if (player) {
			if ([player isPlaying]) {
				[player stop];
			}
            
			[player release];
		}
		
		player = [[AVAudioPlayer alloc] initWithData:downloadedData error:nil];
        player.volume = 1.0;
		[player prepareToPlay];
		[player play];
        
        [downloadedData release];
	}
}

-(void)downloadingFinished:(BOOL)result
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)downloadingDidFailed:(NSString*)url
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Audio"
														message:@"Connection failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


#pragma mark FDownLoader delegate ends


#pragma mark -
#pragma mark targets

-(void)audioButtonPressed:(id)sender
{
	if (![Util isPhone]) {
		if (Q) {
			[Q resignFirstResponder];
		}
		
		if (A) {
			[A resignFirstResponder];
		}
	}
	
	UIButton *senderButton = (UIButton*)sender;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	
	FRecordController *recorder = [[FRecordController alloc] init];
	recorder.delegate = self;
	
	if ([Util isPhone]) {
		recorder.orientation = FIOrientationLandscape;
	}else {
		recorder.contentSizeForViewInPopover = CGSizeMake(500,256);
	}
    
	if (senderButton.tag == 7) {
		[recorder setCard:category forSide:YES forSound:qSound];
	}else {
		[recorder setCard:category forSide:NO forSound:aSound];
	}
	
	[self.navigationController pushViewController:recorder animated:YES];
	[recorder release];
    
	
}

-(void)audioSearchButtonPressed:(id)sender  ///////Pronounce
{
	if ([Util connectedToNetwork]) {
		if (Q && ![Q.text isEqualToString:@""]) {
			
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
			[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
			[[FDownLoader sharedDownloader:nil] cancelDownloading];
			[[FDefinitionController sharedDefinitionWithDelegate:self] getAudioForTerm:Q.text];
            
            NSLog(@"text from textview %@",Q.text);
            
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card"
															message:@"Field for search is empty"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Card"
														message:@"Connection failed"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
    
}

#pragma mark -
#pragma mark private methods

-(void)initTopBar
{
	if (![Util isPhone]){
		
		if (editTipe != FIEditCardTypeUpdate) {
			self.navigationController.title = @"Add";
		}
		else {
			self.navigationController.title = @"Edit";
		}
		
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
																	   style:UIBarButtonItemStyleDone
																	  target:self
																	  action:@selector(rightPressed)];
		UIBarButtonItem *cancelButton;
		
		cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
														style:UIBarButtonItemStyleBordered
													   target:self
													   action:@selector(cancelPressed)];
        
		UINavigationItem *navIt =  self.navigationController.navigationBar.topItem;
		navIt.rightBarButtonItem = saveButton;
		navIt.leftBarButtonItem = cancelButton;
		[saveButton release];
		[cancelButton release];
		
	}
}

-(void)initContent
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		if (kt_isBothText(setTemplate)) {
			
			if (kt_isFrontPic(setTemplate) || kt_isFrontAudio(setTemplate)) {
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0,235,140)];
                    }
                    else{
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0,235,120)];
                    }
                    
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0,190,140)];
                    }
                    else{
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0,190,120)];
                    }
                }
				
			}else {
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0,275,140)];
                    }
                    else{
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0,275,120)];
                    }
                    
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0,225,140)];
                    }
                    else{
                        Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0,225,120)];
                    }
                }
                
				
			}
			
			if (kt_isBackPic(setTemplate) || kt_isBackAudio(setTemplate)) {
                
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+50,
                                                                         0,
                                                                         568-(Q.frame.origin.x+Q.frame.size.width+60),
                                                                         140)];
                    }
                    else{
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+50,
                                                                         0,
                                                                         568-(Q.frame.origin.x+Q.frame.size.width+60),
                                                                         120)];
                    }
                    
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+50,
                                                                         0,
                                                                         480-(Q.frame.origin.x+Q.frame.size.width+60),
                                                                         140)];
                    }
                    else{
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+50,
                                                                         0,
                                                                         480-(Q.frame.origin.x+Q.frame.size.width+60),
                                                                         120)];
                    }
                }
                
                
				
			}else {
                
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+15,
                                                                         0,
                                                                         568-(Q.frame.origin.x+Q.frame.size.width+20),
                                                                         140)];
                    }
                    else{
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+15,
                                                                         0,
                                                                         568-(Q.frame.origin.x+Q.frame.size.width+20),
                                                                         120)];
                    }
                    
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+15,
                                                                         0,
                                                                         480-(Q.frame.origin.x+Q.frame.size.width+20),
                                                                         140)];
                    }
                    else{
                        A = [[UITextView alloc] initWithFrame:CGRectMake(Q.frame.origin.x+Q.frame.size.width+15,
                                                                         0,
                                                                         480-(Q.frame.origin.x+Q.frame.size.width+20),
                                                                         120)];
                    }
                }
                
                
				
			}
		}else {
			if (kt_isFrontPic(setTemplate) || kt_isFrontAudio(setTemplate)) {
				
				if (kt_isBackPic(setTemplate) || kt_isFrontAudio(setTemplate)) {
					Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0.0,380,120)];
				}else {
					Q = [[UITextView alloc] initWithFrame:CGRectMake(45,0.0,425,120)];
				}
                
			}else {
				if (kt_isBackPic(setTemplate) || kt_isFrontAudio(setTemplate)) {
					Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0,425,120)];
				}else {
					Q = [[UITextView alloc] initWithFrame:CGRectMake(10,0.0,460,120)];
				}
			}
		}
        
		if (Q){
            Q.font = [UIFont fontWithName:@"Helvetica" size:14];
        }
        
		if (A){
            A.font = [UIFont fontWithName:@"Helvetica" size:14];
        }
		
	}else {
		if (kt_isBothText(setTemplate)) {
			
			if (kt_isFrontPic(setTemplate) || kt_isBackPic(setTemplate)) {
				Q = [[UITextView alloc] initWithFrame:CGRectMake(kFCardsManageText1X,
                                                                 kFCardsManageText1Y,
                                                                 kFCardsManageText1Width,
                                                                 kFCardsManageText1Height)]; // ipad retina
				A = [[UITextView alloc] initWithFrame:CGRectMake(kFCardsManageText2X,
                                                                 kFCardsManageText2Y,
                                                                 kFCardsManageText2Width,
                                                                 kFCardsManageText2Height)]; // ipad retina
			}else {
				Q = [[UITextView alloc] initWithFrame:CGRectMake(10,
																 kFCardsManageText1Y,
																 kFCardsManageText1Width+kFCardsManageText1X-20,
																 kFCardsManageText1Height)];
				A = [[UITextView alloc] initWithFrame:CGRectMake(10,
																 kFCardsManageText2Y,
																 kFCardsManageText2Width+kFCardsManageText2X-20,
																 kFCardsManageText2Height)];
			}
			
		}else {
			if (kt_isFrontPic(setTemplate) || kt_isBackPic(setTemplate) ) {
				
				Q = [[UITextView alloc] initWithFrame:CGRectMake(kFCardsManageText1X,
                                                                 kFCardsManageText1Y,
                                                                 kFCardsManageText1Width,
                                                                 2*kFCardsManageText1Height+kFCardsManageText2Height+kFCardsManageText1Y-kFCardsManageText2Y)];
			}else {
				Q = [[UITextView alloc] initWithFrame:CGRectMake(10,
																 kFCardsManageText1Y,
																 kFCardsManageText1Width+kFCardsManageText1X-20,
																 2*kFCardsManageText1Height+kFCardsManageText2Height+kFCardsManageText1Y-kFCardsManageText2Y)];
			}
            
        }
        
        if (kt_isFrontAudio(setTemplate) || kt_isBackAudio(setTemplate)) {
            if (Q) {
                CGRect frame = Q.frame; // ipad retina
                frame.size.width -= 50; // ipad retina
                Q.frame = frame; // ipad retina
            }
            
            if (A) {
                CGRect frame = A.frame; // ipad retina
                frame.size.width -= 50; // ipad retina
                A.frame = frame; // ipad retina
            }
        }
		
		if (Q){
            Q.font = [UIFont systemFontOfSize:22]; // ipad retina
        }
		
		if (A){
            A.font = [UIFont systemFontOfSize:22]; // ipad retina
        }
	}
	if (Q) {
		[Q addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:NULL];
	}
	if (A) {
		[A addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:NULL];
	}
	
	if (Q) {
		Q.backgroundColor = [UIColor clearColor];
		Q.textColor = [UIColor blackColor];
        
		[self.view addSubview:Q];
		[Q becomeFirstResponder];
	}
	if(A){
		A.backgroundColor = [UIColor clearColor];
		A.textColor = [UIColor blackColor];
        
		[self.view addSubview:A];
	}
	
    if (Q){
        Q.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    if (A){
        A.autocorrectionType = UITextAutocorrectionTypeNo;
    }
	
	if (kt_isFrontPic(setTemplate)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			qImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,5,40,50)];
			qImageView.image = [UIImage imageNamed:@"i_add_image.png"];
		}else {
			qImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,80,100)]; // ipad retina  (10,40,80,100,ipad mini)
			qImageView.image = [UIImage imageNamed:@"add_image_1.png"];
		}
        
        
		qImageView.userInteractionEnabled = YES;
		qImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.view addSubview:qImageView];
		
		UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firstImage)];
		[qImageView addGestureRecognizer:tap];
		[tap release];
	}
	
	if (kt_isBackPic(setTemplate)) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			
			if (kt_isBothText(setTemplate)) {
                
                if ([Util isPhone]) {
                    if (IS_IPHONE_5) {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                            aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(284,5,40,50)];
                        }
                        else{
                            aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(240,5,40,50)];
                        }
                        
                    }
                    else {
                        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                            aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(240,5,40,50)];
                        }
                        else{
                            aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(240,5,40,50)];
                        }
                    }
                }
				
			}else {
				aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(430,5,40,50)];
			}
            
			aImageView.image = [UIImage imageNamed:@"i_add_image.png"];
		}else {
			aImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10,115,80,100)]; // ipad retina 10,145,80,100(mini)
			aImageView.image = [UIImage imageNamed:@"add_image_1.png"];
		}
        
        
		aImageView.userInteractionEnabled = YES;
		aImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self.view addSubview:aImageView];
		
		UITapGestureRecognizer* tap	 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(secondImage)];
		[aImageView addGestureRecognizer:tap];
		[tap release];
	}
	
	if (kt_isFrontAudio(setTemplate)) {
		qSoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			if (!kt_isFrontPic(setTemplate)) {
				qSoundButton.frame = CGRectMake(5,29,40.0,40.0);
			}else {
				qSoundButton.frame = CGRectMake(5,
												qImageView.frame.origin.y+qImageView.frame.size.height,
												40.0,40.0);
			}
			[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
			[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
		}else {
            UIImage *soundImage = [Util imageFromBundle:@"add_sound1.png"];
			qSoundButton.frame = CGRectMake(self.view.frame.size.width-15-soundImage.size.width,
                                            (self.view.frame.size.height-40)/4.0-soundImage.size.height/2.0,
                                            soundImage.size.width,
                                            soundImage.size.height); // ipad retina (self.view.frame.size.height+50,mini)
			[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
			[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
		}
        
        
		qSoundButton.tag = 7;
		[qSoundButton addTarget:self action:@selector(audioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:qSoundButton];
	}
	
	if (kt_isBackAudio(setTemplate)) {
		aSoundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			if (kt_isBackPic(setTemplate)) {
                if ([Util isPhone]) {
                    if (IS_IPHONE_5) {
                        aSoundButton.frame = CGRectMake(284,
                                                        aImageView.frame.origin.y+aImageView.frame.size.height,
                                                        40.0,40.0);
                        
                    }
                    else {
                        aSoundButton.frame = CGRectMake(240,
                                                        aImageView.frame.origin.y+aImageView.frame.size.height,
                                                        40.0,40.0);
                    }
                }
                
				
			}else {
				if (kt_isBothText(setTemplate)) {
                    if ([Util isPhone]) {
                        if (IS_IPHONE_5) {
                            aSoundButton.frame = CGRectMake(284,29,40.0,40.0);
                        }
                        else {
                            aSoundButton.frame = CGRectMake(240,29,40.0,40.0);
                        }
                    }
				}else {
                    if ([Util isPhone]) {
                        if (IS_IPHONE_5) {
                            aSoundButton.frame = CGRectMake(473,29,40.0,40.0);
                        }
                        else {
                            aSoundButton.frame = CGRectMake(473,29,40.0,40.0);
                        }
                    }
					
				}
                
			}
            
			[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
			[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
		}else {
            UIImage *soundImage = [Util imageFromBundle:@"add_sound1.png"];
			aSoundButton.frame = CGRectMake(self.view.frame.size.width-15-soundImage.size.width,
                                            0.75*(self.view.frame.size.height-40)-soundImage.size.height/2.0,
                                            soundImage.size.width,
                                            soundImage.size.height); // ipad retina  0.75*(self.view.frame.size.height-10,mini)
			[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
			[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
		}
        
        
		aSoundButton.tag = -7;
		[aSoundButton addTarget:self action:@selector(audioButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:aSoundButton];
	}
	
	isQSoundChanged = NO;
	isASoundChanged = NO;
	
	if (editTipe == FIEditCardTypeUpdate) {
		
		if (Q) {
			
			if (kt_isFrontText(setTemplate) || kt_isBothText(setTemplate)) {
				if (q) {
					Q.text = q;
				}
				else
					Q.text = @"";
			}else {
				if (kt_isBackText(setTemplate) && a) {
					Q.text = a;
				}else {
					Q.text = @"";
				}
                
			}
            
		}
		
		if (A) {
			if (a && kt_isBothText(setTemplate)) {
				A.text = a;
			}else {
				A.text = @"";
			}
            
		}
		
		if (qImageView) {
			if (qImage)
				qImageView.image = qImage;
			
		}
		
		if (aImageView) {
			if (aImage)
				aImageView.image = aImage;
		}
		
		
		if (qSound) {
			[qSound release];
			qSound = nil;
		}
		
		if (kt_isFrontAudio(setTemplate)) {
			if ([Util checkSoundForCard:category forId:cardId forWhat:YES]) {
				qSound = [[NSData alloc] initWithData:[Util getSoundForCard:category
																	  forId:cardId
																	forWhat:YES]];
                
			}else {
				
				if (qSoundButton) {
					if ([Util isPhone])
					{
						[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
						[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
					}
					else{
						[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
						[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
					}
				}
                
			}
		}
        
		if (aSound) {
			[aSound release];
			aSound = nil;
		}
		
		if (kt_isBackAudio(setTemplate)) {
			if ([Util checkSoundForCard:category forId:cardId forWhat:NO]) {
				aSound = [[NSData alloc] initWithData:[Util getSoundForCard:category
																	  forId:cardId
																	forWhat:NO]];
                
			}else {
                
				if (aSoundButton) {
					if ([Util isPhone]){
						[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
						[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
					}
					else{
						[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
						[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
					}
				}
			}
		}
        
		
	}else {
		if (A) {
			A.text = @"";
		}
		if (Q) {
			Q.text = @"";
		}
		
		if ([Util isPhone]) {
			if (qSoundButton) {
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}
			if (aSoundButton) {
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}
		}else {
			if (qSoundButton) { // ipad retina
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
			}
			if (aSoundButton) { // ipad retina
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
				
			}
		}
        
	}
    
	
	if (qImageView) {
		[qImageView release];
	}
	if (aImageView) {
		[aImageView release];
	}
	
	if (A) {
		[A release];
	}
	
	if (Q) {
		[Q release];
	}
	
    [self changeBgLinesView];
}


-(void)initBgLinesView
{
	if ([Util isPhone]) {
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,568,140)
                                                         forDic:nil];
            }
            else{
                lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,568,120)
                                                         forDic:nil];
            }
            
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,480,140)
                                                         forDic:nil];
            }
            else{
                lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,480,120)
                                                         forDic:nil];
            }
            
            
        }
        
		
	}else {
        if (kt_isBackAudio(setTemplate) || kt_isFrontAudio(setTemplate)) {
            lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,440,250)
                                                     forDic:nil]; // ipad retina  0 0 440 250mini
        }else{
            lines = [[FILinesView alloc] initWithAttributes:CGRectMake(0,0,500,250)
                                                     forDic:nil];
        }
	}
    
	
	[self.view addSubview:lines];
	[lines release];
}

-(void)changeBgLinesView
{
	if ([Util isPhone]) {
		
		NSMutableArray *attributes = [NSMutableArray array];
		
		NSInteger QnumberOfLines = 4;
		NSInteger AnumberOfLines = 0;
		if (kt_isBothText(setTemplate)) {
			AnumberOfLines = 4;
		}
		
		NSInteger offsetX;
		if (Q) {
			offsetX	= Q.frame.origin.x+10;
		}
		
		NSInteger QbegOffsetY = 23;
		NSInteger AbegOffsetY = 23;
		
		if (Q && ((NSInteger)Q.contentOffset.y)!=0) {
			QnumberOfLines = 5;
			QbegOffsetY = 13;
		}
		
		if (A && ((NSInteger)A.contentOffset.y)!=0) {
			AnumberOfLines = 5;
			AbegOffsetY = 13;
		}
		
		
		NSInteger offsetY = [Q font].capHeight+6;
        
		NSInteger lineWidth = 0;
		
		if (Q) {
			lineWidth = [Q frame].size.width-20;
		}
        
		NSInteger lineHeight = 2;
		
		BOOL isRounded = YES;
		
		UIColor *blueColor = [UIColor colorWithRed:224.0/255.0
											 green:224.0/255.0
											  blue:224.0/255.0
											 alpha:1.0];
		
		for (int i=0;i<QnumberOfLines;i++) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[dic setObject:[NSNumber numberWithInt:offsetX] forKey:@"offsetX"];
			[dic setObject:[NSNumber numberWithInt:QbegOffsetY+offsetY*i+lineHeight*i] forKey:@"offsetY"];
			[dic setObject:[NSNumber numberWithInt:lineWidth] forKey:@"width"];
			[dic setObject:[NSNumber numberWithBool:isRounded] forKey:@"rounded"];
			[dic setObject:[NSNumber numberWithInt:lineHeight] forKey:@"height"];
			[dic setObject:blueColor forKey:@"color"];
			[attributes addObject:dic];
		}
		
		for (int i=0;i<AnumberOfLines;i++) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[dic setObject:[NSNumber numberWithInt:offsetX*2+lineWidth+15] forKey:@"offsetX"];
			[dic setObject:[NSNumber numberWithInt:AbegOffsetY+offsetY*i+lineHeight*i] forKey:@"offsetY"];
			[dic setObject:[NSNumber numberWithInt:lineWidth] forKey:@"width"];
			[dic setObject:[NSNumber numberWithBool:isRounded] forKey:@"rounded"];
			[dic setObject:[NSNumber numberWithInt:lineHeight] forKey:@"height"];
			[dic setObject:blueColor forKey:@"color"];
			[attributes addObject:dic];
		}
		
		[lines changeAttributes:attributes];
	}else {
		
		NSMutableArray *attributes = [NSMutableArray array];
		
		NSInteger QnumberOfLines = 7;
		NSInteger AnumberOfLines = 0;
		if (kt_isBothText(setTemplate)) {
			QnumberOfLines = 4;
			AnumberOfLines = 3;
		}
		
		NSInteger offsetX;
		if (Q) {
			offsetX	= Q.frame.origin.x+10;
		}
		
		NSInteger begOffsetY = 23;
		if (Q) {
			begOffsetY = [Q font].capHeight+15;
		}
		
		NSInteger offsetY = [Q font].capHeight+10;
		
		NSInteger lineWidth = 0;
		
		if (Q) {
			lineWidth = [Q frame].size.width-20;
		}
		
		NSInteger lineHeight = 2;
		
		BOOL isRounded = YES;
		
		UIColor *blueColor = [UIColor colorWithRed:72.0/255.0
											 green:118.0/255.0
											  blue:255.0/255.0
											 alpha:0.5];
		
		UIColor *redColor = [UIColor colorWithRed:255.0/255.0
											green:0.0/255.0
											 blue:0.0/255.0
											alpha:0.5];
		
		for (int i=0;i<QnumberOfLines;i++) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[dic setObject:[NSNumber numberWithInt:offsetX] forKey:@"offsetX"];
			[dic setObject:[NSNumber numberWithInt:begOffsetY+offsetY*i+lineHeight*i] forKey:@"offsetY"];
			[dic setObject:[NSNumber numberWithBool:isRounded] forKey:@"rounded"];
			[dic setObject:[NSNumber numberWithInt:lineWidth] forKey:@"width"];
			
			if (i==QnumberOfLines-1 && kt_isBothText(setTemplate)) {
				[dic setObject:[NSNumber numberWithInt:2*lineHeight] forKey:@"height"];
				[dic setObject:redColor forKey:@"color"];
			}else {
				[dic setObject:[NSNumber numberWithInt:lineHeight] forKey:@"height"];
				[dic setObject:blueColor forKey:@"color"];
			}
            
			[attributes addObject:dic];
		}
		
		for (int i=0;i<AnumberOfLines;i++) {
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[dic setObject:[NSNumber numberWithInt:offsetX] forKey:@"offsetX"];
            [dic setObject:[NSNumber numberWithInt:begOffsetY+offsetY*(i+QnumberOfLines)+lineHeight*(i+QnumberOfLines-1)+2*lineHeight] forKey:@"offsetY"];
			[dic setObject:[NSNumber numberWithInt:lineWidth] forKey:@"width"];
			[dic setObject:[NSNumber numberWithBool:isRounded] forKey:@"rounded"];
			[dic setObject:[NSNumber numberWithInt:lineHeight] forKey:@"height"];
            [dic setObject:blueColor forKey:@"color"];
            [attributes addObject:dic];
		}
		
		[lines changeAttributes:attributes];
	}
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self changeBgLinesView];
}

-(void)rightPressed
{
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	[[FLanguageTranslate initWithDelegate:nil] clear];
	[[FIMicrosoftTranslate initWithDelegate:nil] clear];
	
	if (kt_isBothText(setTemplate)) {
		if ([Q.text isEqualToString:@""] && [A.text isEqualToString:@""] && !qImage && !aImage && !qSound && !aSound) {//after done pressed
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
															message:@"Can't create empty card"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}else {
		if ([Q.text isEqualToString:@""] && !qImage && !aImage && !qSound && !aSound) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
															message:@"Can't create empty card"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			return;
		}
	}
    
	
	NSString *uQ = @"";
	NSString *uA = @"";
	
	if (Q && (kt_isFrontText(setTemplate) || kt_isBothText(setTemplate))) {
		uQ = [NSString stringWithString:Q.text];
	}
	
	if (A && kt_isBothText(setTemplate)) {
		uA = [NSString stringWithString:A.text];
	}
	
	if (Q && (kt_isBackText(setTemplate) && !kt_isFrontText(setTemplate))) {
		uA = [NSString stringWithString:Q.text];
	}
	
	if (editTipe == FIEditCardTypeUpdate) {
		
		[[FDBController sharedDatabase] updateCategoryAtIndex:category question:uQ answer:uA forInd:cardId];
		
		if (kt_isFrontPic(setTemplate)) {
			if (qImage) {
                
				[Util saveImageWithName:qImage
							   withName:category
								  forId:cardId
								forWhat:YES];
			}
			else {
				[Util removeImageWithName:category
								   withId:cardId
								  forWhat:YES];
			}
		}
		
		
		if (kt_isBackPic(setTemplate)) {
			if (aImage) {
				[Util saveImageWithName:aImage
							   withName:category
								  forId:cardId
								forWhat:NO];
			}
			else {
				[Util removeImageWithName:category
								   withId:cardId
								  forWhat:NO];
			}
		}
		
		if (kt_isFrontAudio(setTemplate) && isQSoundChanged) {
			if (qSound) {
				[Util saveSoundForCard:qSound
						   forCategory:category
								 forId:cardId
							   forWhat:YES];
			}else {
				[Util removeSoundForCard:category
								   forId:cardId
								 forWhat:NO];
			}
		}
		
		if (kt_isBackAudio(setTemplate) && isASoundChanged) {
			if (aSound) {
				[Util saveSoundForCard:aSound
						   forCategory:category
								 forId:cardId
							   forWhat:NO];
            }else {
				[Util removeSoundForCard:category
								   forId:cardId
								 forWhat:NO];
			}
		}
        
		
		NSArray *uCard = [NSArray arrayWithObjects:[NSNumber numberWithInt:cardId],uQ,uA,nil];
		
		if (delegate && [delegate respondsToSelector:@selector(updatedCard:)]) {
			[delegate updatedCard:uCard];
		}
		
		
		if (delegate && [delegate respondsToSelector:@selector(cardUpdated)]) {
			[delegate cardUpdated];
		}
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[self.navigationController popViewControllerAnimated:YES];
        
        if (![Util isPhone]) { //changed by sanjeev reddy ,on done dismiss
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dissmisPopover" object:nil];

        }
    }
	else {
		
        [[FIAnimationController sharedAnimation:nil] fallAndTrembell:self.view dir:kCATransitionFromLeft];//ater done pressed
        
		[self addCard];
		
		if(Q)
			Q.text = @"";
		if (A)
			A.text = @"";
		
		if (qImage) {
			[qImage release];
			qImage = nil;
		}
		
		if (aImage) {
			[aImage release];
			aImage = nil;
		}
		
		if (qSound) {
			[qSound release];
			qSound = nil;
		}
		
		if (aSound) {
			[aSound release];
			aSound = nil;
			
		}
		
		isQSoundChanged = NO;
		isASoundChanged = NO;
		
        if ([Util isPhone]) {
            
            if (qImageView) {
                qImageView.image = [UIImage imageNamed:@"i_add_image.png"];
            }
            if (aImageView) {
                aImageView.image = [UIImage imageNamed:@"i_add_image.png"];
            }
        }else{
            if (qImageView) {
                qImageView.image = [UIImage imageNamed:@"add_image_1.png"];
            }
            if (aImageView) {
                aImageView.image = [UIImage imageNamed:@"add_image_1.png"];
            }
        }
		
		if ([Util isPhone]) {
			if (qSoundButton) {
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}
			if (aSoundButton) {
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound1.png"] forState:UIControlStateHighlighted];
			}
		}else {
			if (qSoundButton) {
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[qSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
			}
			if (aSoundButton) {
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateNormal];
				[aSoundButton setImage:[UIImage imageNamed:@"add_sound1.png"] forState:UIControlStateHighlighted];
				
			}
		}
        
        if (Q && ![Q isFirstResponder]) {
            [Q becomeFirstResponder];
            [Q performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.5f];
        }
        
	}
	
	
    
}


-(void)addCard
{
	if (kt_isBothText(setTemplate)) {
		if ([Q.text isEqualToString:@""] && [A.text isEqualToString:@""] && !qImage && !aImage && !qSound && !aSound) {
			return;
		}
	}else {
		if ([Q.text isEqualToString:@""] && !qImage && !aImage && !qSound && !aSound) {
			return;
		}
	}
    
	
	NSString *uQ = @"";
	NSString *uA = @"";
	
	if (Q && (kt_isFrontText(setTemplate) || kt_isBothText(setTemplate))) {
		uQ = [NSString stringWithString:Q.text];
	}
	
	if (A && kt_isBothText(setTemplate)) {
		uA = [NSString stringWithString:A.text];
	}
	
	if (Q && (kt_isBackText(setTemplate) && !kt_isFrontText(setTemplate))) {
		uA = [NSString stringWithString:Q.text];
	}
	
	cardId = [[FDBController sharedDatabase] addQuestionToCategory:category
														  question:uQ
															answer:uA];
	
	if (kt_isFrontPic(setTemplate) && qImage) {
		[Util saveImageWithName:qImage
					   withName:category
						  forId:cardId
						forWhat:YES];
	}
	
	if (kt_isBackPic(setTemplate) && aImage) {
		[Util saveImageWithName:aImage
					   withName:category
						  forId:cardId
						forWhat:NO];
	}
	
	
	if (kt_isFrontAudio(setTemplate) && isQSoundChanged && qSound) {
		[Util saveSoundForCard:qSound
				   forCategory:category
						 forId:cardId
					   forWhat:YES];
        
	}
	
	
	if (kt_isBackAudio(setTemplate) && isASoundChanged && aSound) {
		[Util saveSoundForCard:aSound
				   forCategory:category
						 forId:cardId
					   forWhat:NO];
	}
	
	NSArray *newCard = [NSArray arrayWithObjects:[NSNumber numberWithInt:cardId],uQ,uA,nil];
	
	if (delegate && [delegate respondsToSelector:@selector(createdCard:)]) {
		[delegate createdCard:newCard];
	}
	
	
	if (delegate && [delegate respondsToSelector:@selector(cardAdded:)]) {
		[delegate cardAdded:cardId];
	}
}

-(void)addTextToCard:(NSString*)text
{
	if (text) {
		if (A) {
            
			if (![A hasText] || [A.text isEqualToString:@""]) {
				A.text = text;
			}else {
				A.text = [A.text stringByAppendingFormat:@"\n%@",text];
			}
            
		}else {
			if (Q) {
				if (![Q hasText] || [Q.text isEqualToString:@""]) {
					Q.text = text;
				}else {
					Q.text = [Q.text stringByAppendingFormat:@"\n%@",text];
				}
			}
		}
	}
}

-(void)addImageToCard:(UIImage*)image
{
	if (image) {
		
		if (kt_isBothPic(setTemplate) || kt_isBackPic(setTemplate)) {
			if (aImage)
				[aImage release];
			
			aImage = [[UIImage alloc] initWithCGImage:image.CGImage];
			aImageView.image = aImage;
		}else if (kt_isFrontPic(setTemplate)) {
			if (qImage)
				[qImage release];
			
			qImage = [[UIImage alloc] initWithCGImage:image.CGImage];
			qImageView.image = qImage;
		}
		
	}
}

-(void)addAudioToCard:(NSData*)audio
{
	if (audio) {
		if (kt_isFrontAudio(setTemplate)) {
			if (qSound) {
				[qSound release];
				qSound = nil;
			}
			
			qSound = [[NSData alloc] initWithData:audio];
			
			if (qSoundButton) {
				if ([Util isPhone]) {
					[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
					[qSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
				}else {
					[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
					[qSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
				}
			}
			
			
			isQSoundChanged = YES;
		}else if(kt_isBackAudio(setTemplate)){
            if (aSound) {
                [aSound release];
                aSound = nil;
            }
            
            aSound = [[NSData alloc] initWithData:audio];
            if (aSoundButton) {
                if ([Util isPhone]) {
					[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateNormal];
					[aSoundButton setImage:[UIImage imageNamed:@"i_add_sound2.png"] forState:UIControlStateHighlighted];
				}else {
					[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateNormal];
					[aSoundButton setImage:[UIImage imageNamed:@"add_sound2.png"] forState:UIControlStateHighlighted];
				}
            }
        }
	}
}

-(void)firstImage
{
	imageType = FIimagePickedTypeQuestion;
	
	if (![Util isPhone]) {
		if (Q) {
			[Q resignFirstResponder];
		}
		
		if (A) {
			[A resignFirstResponder];
		}
	}
	
	NSString *term = nil;
	
	if (Q && ![Q.text isEqualToString:@""]) {
		term = [NSString stringWithString:Q.text];
	}
	
    if (!qImage) {
        
        FIFlickerViewController *imageController = [[FIFlickerViewController alloc] initWithTerm:term
                                                                                         forMode:serverModeBing];
        imageController.currentImage = qImage;
        
        if (![Util isPhone]) {
            imageController.contentSizeForViewInPopover = CGSizeMake(540.0,580.0);
        }
        
        imageController.delegate = self;
        [self.navigationController pushViewController:imageController animated:YES];
        [imageController release];
        
    }else{
        FIImageEditController *imageEditController = [[FIImageEditController alloc] initWithImage:qImage];
        imageEditController.delegate = self;
        if (![Util isPhone]) {
            imageEditController.contentSizeForViewInPopover = CGSizeMake(480,300);
        }
        [self.navigationController pushViewController:imageEditController animated:YES];
        [imageEditController release];
        
    }
    
	
    
}

-(void)secondImage
{
	imageType = FIimagePickedTypeAnswer;
	
	if (![Util isPhone]) {
		if (Q) {
			[Q resignFirstResponder];
		}
		
		if (A) {
			[A resignFirstResponder];
		}
	}
	
	NSString *term = nil;
	
	if (A && ![A.text isEqualToString:@""]) {
		term = [NSString stringWithString:A.text];
	}
	
    if (!aImage) {
        FIFlickerViewController *imageController = [[FIFlickerViewController alloc] initWithTerm:term
                                                                                         forMode:serverModeBing];
        imageController.currentImage = aImage;
        
        if (![Util isPhone]) {
            imageController.contentSizeForViewInPopover = CGSizeMake(540.0,580.0);
        }
        
        imageController.delegate = self;
        [self.navigationController pushViewController:imageController animated:YES];
        [imageController release];
    }else{
        FIImageEditController *imageEditController = [[FIImageEditController alloc] initWithImage:aImage];
        imageEditController.delegate = self;
        if (![Util isPhone]) {
            imageEditController.contentSizeForViewInPopover = CGSizeMake(480,300);
        }
        [self.navigationController pushViewController:imageEditController animated:YES];
        [imageEditController release];
    }
    
}

-(void)initToolBarForKeyBoard
{
	FIToolBar *toolBar;
	
	if ([Util isPhone]) {
		toolBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,0,480,44)];
	}else {
		toolBar = [[FIToolBar alloc] initWithFrame:CGRectMake(0,210,500,40)]; // ipad retina 0 216 500 40 ,mini
	}
    
    
	if ([Util isPhone]) {
		toolBar.bgImage = [Util imageFromBundle:@"i_add_bg.png"];
		
		if (Q) {
			Q.inputAccessoryView = toolBar;
		}
		if (A) {
			A.inputAccessoryView = toolBar;
		}
	}else {
		toolBar.bgImage = [Util imageFromBundle:@"add_bg.png"]; // ipad retina
		[self.view addSubview:toolBar];
	}
	
	NSMutableArray *items = [NSMutableArray array];
	
	UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																		  target:nil
																		  action:nil];
	[items addObject:flex];
	
	if ([Util isPhone]) {
        
        UIButton *customCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *cancelButtonImage = [Util imageFromBundle:@"i_add_close1.png"];
        customCancelButton.frame = CGRectMake(0, 0, cancelButtonImage.size.width, cancelButtonImage.size.height);
        [customCancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
        [customCancelButton setImage:[Util imageFromBundle:@"i_add_close2.png"] forState:UIControlStateHighlighted];
        [customCancelButton addTarget:self
                               action:@selector(cancelPressed)
                     forControlEvents:UIControlEventTouchUpInside];
        
        
		UIBarButtonItem *cancelButton;
		cancelButton = [[UIBarButtonItem alloc] initWithCustomView:customCancelButton];
		[items addObject:cancelButton];
		[items addObject:flex];
		[cancelButton release];
	}
	
	
	if (kt_isTranslate(setTemplate)) { // ipad retina
        
        UIButton *customTranslateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *translateImage = [Util imageFromBundle:@"i_add_translate1.png"];
        customTranslateButton.frame = CGRectMake(0, 0, translateImage.size.width, translateImage.size.height);
        [customTranslateButton setImage:translateImage forState:UIControlStateNormal];
        [customTranslateButton setImage:[Util imageFromBundle:@"i_add_translate2.png"] forState:UIControlStateHighlighted];
        [customTranslateButton addTarget:self
                                  action:@selector(translatePressed)
                        forControlEvents:UIControlEventTouchUpInside];
        
        translate = [[UIBarButtonItem alloc] initWithCustomView:customTranslateButton];
        
		NSString *fL = [self lanCodeForStr:firstLan];
		NSString *sL = [self lanCodeForStr:secondLan];
        
        UIButton *customLangButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *langImage = [Util imageFromBundle:@"i_add_empty1.png"];
        customLangButton.frame = CGRectMake(0, 0, langImage.size.width, langImage.size.height);
        [customLangButton setBackgroundImage:langImage forState:UIControlStateNormal];
        [customLangButton setBackgroundImage:[Util imageFromBundle:@"i_add_empty2.png"] forState:UIControlStateHighlighted];
        [customLangButton addTarget:self
                             action:@selector(languagePressed:)
                   forControlEvents:UIControlEventTouchUpInside];
        language = [[UIBarButtonItem alloc] initWithCustomView:customLangButton];
        customLangButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14];
        customLangButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        if (fL && sL) {
            [customLangButton setTitle:[NSString stringWithFormat:@"%@->%@",fL,sL] forState:UIControlStateNormal];
            [customLangButton setTitle:[NSString stringWithFormat:@"%@->%@",fL,sL] forState:UIControlStateHighlighted];
        }else{
            [customLangButton setTitle:@"Lang" forState:UIControlStateNormal];
            [customLangButton setTitle:@"Lang" forState:UIControlStateHighlighted];
        }
        
		[items addObject:translate];
		[items addObject:flex];
		[items addObject:language];
		[items addObject:flex];
		[translate release];
		[language release];
	}
	
    
    
	if (kt_isAudio(setTemplate)) {           //////////////Pronounce
        UIButton *customAudioButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *audioImage = [Util imageFromBundle:@"i_add_audio1.png"];
        customAudioButton.frame = CGRectMake(0, 0, audioImage.size.width, audioImage.size.height);
        customAudioButton.imageEdgeInsets = UIEdgeInsetsMake(0, -1, 1, 0);
        [customAudioButton setImage:audioImage forState:UIControlStateNormal];
        [customAudioButton setImage:[Util imageFromBundle:@"i_add_audio2.png"] forState:UIControlStateHighlighted];
        [customAudioButton addTarget:self
                              action:@selector(audioSearchButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        audioButton = [[UIBarButtonItem alloc] initWithCustomView:customAudioButton];
        
		[items addObject:audioButton];
		[items addObject:flex];
		[audioButton release];
	}
	
	if (kt_isDefinition(setTemplate)) {
        UIBarButtonItem *onlineDefinition;
        
        UIButton *customDefButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *defImage = [Util imageFromBundle:@"i_add_wordnik1.png"];
        customDefButton.frame = CGRectMake(0, 0, defImage.size.width, defImage.size.height);
        [customDefButton setImage:defImage forState:UIControlStateNormal];
        [customDefButton setImage:[Util imageFromBundle:@"i_add_wordnik2.png"] forState:UIControlStateHighlighted];
        [customDefButton addTarget:self
                            action:@selector(onlinePressed)
                  forControlEvents:UIControlEventTouchUpInside];
        onlineDefinition = [[UIBarButtonItem alloc] initWithCustomView:customDefButton];
        
		[items addObject:onlineDefinition];
		[items addObject:flex];
		[onlineDefinition release];
	}
	
	if (kt_isWeb(setTemplate)) {
        UIBarButtonItem *search;
        
        UIButton *customSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *searchImage = [Util imageFromBundle:@"i_add_web1.png"];
        customSearchButton.frame = CGRectMake(0, 0, searchImage.size.width, searchImage.size.height);
        [customSearchButton setImage:searchImage forState:UIControlStateNormal];
        [customSearchButton setImage:[Util imageFromBundle:@"i_add_web2.png"] forState:UIControlStateHighlighted];
        [customSearchButton addTarget:self
                               action:@selector(searchPressed)
                     forControlEvents:UIControlEventTouchUpInside];
        search = [[UIBarButtonItem alloc] initWithCustomView:customSearchButton];
        
		[items addObject:search];
		[items addObject:flex];
		[search release];
	}
	
	
	if ([Util isPhone]) {
        UIBarButtonItem *saveButton;
        
        UIButton *customSaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *saveImage = [Util imageFromBundle:@"i_add_done1.png"];
        customSaveButton.frame = CGRectMake(0, 0, saveImage.size.width, saveImage.size.height);
        [customSaveButton setImage:saveImage forState:UIControlStateNormal];
        [customSaveButton setImage:[Util imageFromBundle:@"i_add_done2.png"] forState:UIControlStateHighlighted];
        [customSaveButton addTarget:self
                             action:@selector(rightPressed)
                   forControlEvents:UIControlEventTouchUpInside];
        saveButton = [[UIBarButtonItem alloc] initWithCustomView:customSaveButton];
        
		[items addObject:saveButton];
		[items addObject:flex];
		[saveButton release];
	}
	
	
	[toolBar setItems:items];
	[flex release];
	[toolBar release];
}

-(void)translatePressedUpdatedByNil
{
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Google Translate" withParam:nil];
	
    if (firstLan && secondLan) {
        if (Q && ![Q.text isEqualToString:@""]) {
            /*FLanguageTranslate *tranlater = [FLanguageTranslate initWithDelegate:self];
             [tranlater translate:Q.text from:firstLan to:secondLan];*/
            translate.enabled = NO;
            language.enabled = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [[FIMicrosoftTranslate initWithDelegate:nil] clear];
            FIMicrosoftTranslate *translatorController = [FIMicrosoftTranslate initWithDelegate:self];
            [translatorController translate:Q.text from:[self lanCodeForStr:firstLan] to:[self lanCodeForStr:secondLan]];
        }else {
            [Util showMessage:@"Translate"
                   forMessage:@"Translate field is empty!"
               forButtonTitle:@"OK"];
            return;
        }
    }else{
        isNeedTranslate = YES;
        [self languagePressed:nil];
    }
    
}

-(void)translatePressed
{
    
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Google Translate" withParam:nil];
	
    if (firstLan && secondLan) {
        if (Q && ![Q.text isEqualToString:@""]) {
            /*FLanguageTranslate *tranlater = [FLanguageTranslate initWithDelegate:self];
             [tranlater translate:Q.text from:firstLan to:secondLan];*/
            translate.enabled = NO;
            language.enabled = NO;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [[FIMicrosoftTranslate initWithDelegate:nil] clear];
            FIMicrosoftTranslate *translatorController = [FIMicrosoftTranslate initWithDelegate:self];
            [translatorController translate:Q.text from:[self lanCodeForStr:firstLan] to:[self lanCodeForStr:secondLan]];
        }else {
            
//            [Util showMessage:@"Translate"
//                   forMessage:@"Translate field is empty!"
//               forButtonTitle:@"OK"];
// CHanged by Nilesh Patel
            [Q resignFirstResponder];
            [A resignFirstResponder];

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Translate" message:@"Translate field is empty!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
            [alert release];
            return;
        }
    }else{
        isNeedTranslate = YES;
        [self languagePressed:nil];
    }
    
}

-(void)languagePressed:(id)sender{
    if ([Util connectedToNetwork]) {
        if (Q && ![Q.text isEqualToString:@""]) {
            [Q resignFirstResponder];
            [A resignFirstResponder];
            
            translate.enabled = NO;
            language.enabled = NO;
            [[FIMicrosoftTranslate initWithDelegate:nil] clear];
            FIMicrosoftTranslate *translatorController = [FIMicrosoftTranslate initWithDelegate:self];
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            [translatorController performSelector:@selector(getLanguageNames)
                                       withObject:nil
                                       afterDelay:0.001];
        }else
        {
            [Util showMessage:@"Alert"
                   forMessage:@"Please enter the text"
               forButtonTitle:@"OK"];
        }
    }else{
        [Util showMessage:@"Error"
               forMessage:@"Please check internet connection and try again"
           forButtonTitle:@"OK"];
    }
    
}

-(NSString*)lanCodeForStr:(NSString*)lang
{
	if (lang) {
		NSDictionary *langCode = [Util lanCode];
        
		if (langCode && [langCode objectForKey:lang]) {
			return [langCode objectForKey:lang];
		}
	}
    
	return nil;
}

-(NSString*)countryForCode:(NSString*)lang{
    if (lang) {
        NSDictionary *langCode = [Util lanCode];
        NSArray *countries = [langCode allKeys];
        
        for (NSString *c in countries) {
            if ([lang isEqualToString:[langCode objectForKey:c]]) {
                return c;
            }
        }
        
    }
    
    return  nil;
}


-(void)onlinePressed               //Wordnik
{
	if (Q && [Q hasText])
	{
		if ([Util connectedToNetwork]) {
			
			if (![Util isPhone]) {
				if (Q) {
					[Q resignFirstResponder];
				}
				
				if (A) {
					[A resignFirstResponder];
				}
			}
			
			if ([Util isPhone]) {
				FIDefinitionViewController *definitionController = [[FIDefinitionViewController alloc] init];
				definitionController.orientation = FIOrientationLandscape;
				definitionController.term = Q.text;
				definitionController.delegate = self;
				[self.navigationController pushViewController:definitionController animated:YES];
				[definitionController release];
			}else {
				[Q resignFirstResponder];
				[A resignFirstResponder];
				
				FDefinitionViewController *defController = [[FDefinitionViewController alloc] init];
				defController.delegate = self;
				defController.term = Q.text;
				defController.contentSizeForViewInPopover = CGSizeMake(500,500);
				
				UINavigationController* navCont = [[UINavigationController alloc] initWithRootViewController:defController];
				navCont.modalPresentationStyle = UIModalPresentationFormSheet;
				navCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				
				if (delegate) {
					[delegate presentModalViewController:navCont animated:YES];
				}
				
				[defController release];
				[navCont release];
			}
            
		}else {
			[Util showMessage:@"Warning" forMessage:@"Connection failed" forButtonTitle:@"OK"];
		}
        
	}
	else {
		[Util showMessage:@"Warning" forMessage:@"Your term is empty" forButtonTitle:@"OK"];
	}
    
	
}

-(void)searchPressed
{
	if (Q && [Q hasText]) {
		
		if ([Util connectedToNetwork]) {
			
			if (![Util isPhone]) {
				if (Q) {
					[Q resignFirstResponder];
				}
				
				if (A) {
					[A resignFirstResponder];
				}
			}
			
			FISearchViewController *searchController = [[FISearchViewController alloc] initWithDelegateAndSearchStr:Q.text];
			searchController.MyDelegate = self;
            searchController.set = category;
			
			if (kt_isBackPic(setTemplate) || kt_isFrontPic(setTemplate)) {
				searchController.isImageDownloadingAvailable = YES;
			}else {
				searchController.isImageDownloadingAvailable = NO;
			}
            
			
			if ([Util isPhone]) {
				searchController.orientation = orientation;
				[self.navigationController pushViewController:searchController animated:YES];
			}else {
				[Q resignFirstResponder];
				[A resignFirstResponder];
              
				if (delegate) {
					searchController.contentSizeForViewInPopover = CGSizeMake(500,500);
                        UINavigationController* navCont = [[UINavigationController alloc] initWithRootViewController:searchController];
                        
                        navCont.modalPresentationStyle = UIModalPresentationFormSheet;
                        navCont.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        
                        [delegate presentViewController:navCont animated:YES completion:nil];
                        
                        
                        //[delegate presentModalViewController:navCont animated:YES];
                        [navCont release];
                   

				}
			}
            
			[searchController release];
		}else {
			[Util showMessage:@"Warning" forMessage:@"Connection failed" forButtonTitle:@"OK"];
		}
        
	}else {
		[Util showMessage:@"Warning" forMessage:@"Your term is empty" forButtonTitle:@"OK"];
	}
    
}

-(void)cancelPressed{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[[FLanguageTranslate initWithDelegate:nil] clear];
	[[FDefinitionController sharedDefinitionWithDelegate:nil] cancelOperation];
	[[FDownLoader sharedDownloader:nil] cancelDownloading];
	[[FIMicrosoftTranslate initWithDelegate:nil] clear];
	
	[pool release];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([Util isPhone]) {
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"dissmisPopover" object:nil];
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
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	if (Q) {
		[Q removeObserver:self forKeyPath:@"contentOffset"];
	}
	if (A) {
		[A removeObserver:self forKeyPath:@"contentOffset"];
	}
	if (qImage) {
		[qImage release];
	}
	
	delegate = nil;
	
	if (aImage) {
		[aImage release];
	}
	
	if (qSound) {
		[qSound release];
	}
	
	if (aSound) {
		[aSound release];
	}
	
	
	if (category) {
		[category release];
	}
	
	if (player) {
		if ([player isPlaying]) {
			[player stop];
		}
		
		[player release];
	}
	
	[super dealloc];
	
	
}


@end
