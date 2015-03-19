    //
//  FRecordController.m
//  flashCards
//
//  Created by Ruslan on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FRecordController.h"
#import "FIToolBar.h"
#import "Util.h"
#import "Constant.h"
@interface FRecordController(Private)

//targets
-(void)playButtonPressed:(id)sender;
-(void)recordButtonPressed:(id)sender;
-(void)progressSliderChanged:(id)sender;

//private methods
-(NSString*)pathForTMPFile;
-(void)updateSoundFromTMPFile;
-(void)changeTime:(id)sender;
-(void)stopPlaing;
-(void)stopRecording;
-(void)saveButtonPressed:(id)sender;
-(void)backButtonPressed:(id)sender;
-(void)deleteButtonPressed:(id)sender;
-(void)initIphoneTopBar;

@end


@implementation FRecordController
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





// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	UIView *contentView;
	
    
    
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,500.0,256.0)];
	else
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,((IS_IPHONE_5)?568:480),300.0)];

	self.view = contentView;
	[contentView release];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIImageView *bgView = [[UIImageView alloc] init];
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		bgView.frame = CGRectMake(0,0,137.0,206.0);	
		bgView.image = [UIImage imageNamed:@"ip_recordbg.png"];
		bgView.center = CGPointMake(250.0,108.0);
	}else {
		bgView.frame = CGRectMake(0,0,200.0,280.0);
		bgView.image = [UIImage imageNamed:@"i_recordbg.png"];
		bgView.center = CGPointMake(((IS_IPHONE_5)?284:240),130.0);
	}

	[self.view addSubview:bgView];
	[bgView release];
	
	seconds = 0;
	minutes = 0;
	
	reverseSeconds = 0;
	reverseMinutes = 0;
	
	if (isTimeLabelExist) {
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(35.0,100.0,60.0,30.0)];
		else
			timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,((IS_IPHONE_5)?244.0:200.0),45.0,30.0)];

		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.textAlignment = UITextAlignmentRight;
		timeLabel.text = @"0:00";
	
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			timeLabel.textColor = [UIColor colorWithRed:0.231f green:0.133f blue:0.071f alpha:1.0f];
			timeLabel.shadowColor = [UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
		}

	
		[self.view addSubview:timeLabel];
		[timeLabel release];
	
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
			reverseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(405.0,100.0,60.0,30.0)];
		else
			reverseTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(((IS_IPHONE_5)?244.0:200.0),((IS_IPHONE_5)?309.0:265.0),45.0,30.0)];

		reverseTimeLabel.backgroundColor = [UIColor clearColor];
		reverseTimeLabel.text = @"-0:00";
		[self.view addSubview:reverseTimeLabel];
	
		if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
		{
			reverseTimeLabel.textColor = [UIColor colorWithRed:0.231f green:0.133f blue:0.071f alpha:1.0f];
			reverseTimeLabel.shadowColor = [UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
		}
	
		[reverseTimeLabel release];
	
	}
	
	FIToolBar *buttonBar = [[FIToolBar alloc] init];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		buttonBar.frame = CGRectMake(0.0,206.0,500.0,50.0);
        buttonBar.bgImage = [Util imageFromBundle:@"add_bg.png"];
    }
	else
	{
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
                    [self prefersStatusBarHidden];
                    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
                } else {
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
                }
                buttonBar.frame = CGRectMake(0.0,272,((IS_IPHONE_5)?568:480),48.0);
            }
            else{
                buttonBar.frame = CGRectMake(0.0,252.0,((IS_IPHONE_5)?568:480),48.0);
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
                buttonBar.frame = CGRectMake(0.0,272.0,((IS_IPHONE_5)?568:480),48.0);
            }
            else{
                buttonBar.frame = CGRectMake(0.0,252.0,((IS_IPHONE_5)?568:480),48.0);
            }
        }

		
        buttonBar.bgImage = [Util imageFromBundle:@"i_images_bottombg.png"];
        
        
	}
    
    
	
	[self.view addSubview:buttonBar];
	
	UIButton *customPlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *playImage = [Util imageFromBundle:@"i_record_play.png"];
    customPlayButton.frame = CGRectMake(0, 0, playImage.size.width, playImage.size.height);
    [customPlayButton setImage:playImage forState:UIControlStateNormal];
    [customPlayButton setImage:playImage forState:UIControlStateHighlighted];
    [customPlayButton addTarget:self
                         action:@selector(playButtonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
    playButton = [[UIBarButtonItem alloc] initWithCustomView:customPlayButton];

    UIImage *recordImage = [Util imageFromBundle:@"i_record_rec1.png"];
    RIBlinkButton *customRecordButton = [[RIBlinkButton alloc] initWithFrame:CGRectMake(0, 0, recordImage.size.width, recordImage.size.height)];
    [customRecordButton setImages:[NSArray arrayWithObjects:[Util imageFromBundle:@"i_record_rec1.png"],
                                    [Util imageFromBundle:@"i_record_rec2.png"],
                                    [Util imageFromBundle:@"i_record_rec3.png"],nil]];

    [customRecordButton addTarget:self
                         action:@selector(recordButtonPressed:)
                 forControlEvents:UIControlEventTouchUpInside];
    recordButton = [[UIBarButtonItem alloc] initWithCustomView:customRecordButton];
    	
    UIBarButtonItem *backButton;
	
    UIButton *customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [Util imageFromBundle:@"i_add_done1.png"];
    customBackButton.frame = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    [customBackButton setImage:backImage forState:UIControlStateNormal];
    [customBackButton setImage:[Util imageFromBundle:@"i_add_done2.png"] forState:UIControlStateHighlighted];
    [customBackButton addTarget:self
                         action:@selector(backButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
        
    backButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        
    UIButton *customDeleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *deleteImage = [Util imageFromBundle:@"i_trash1.png"];
    customDeleteButton.frame = CGRectMake(0, 0, deleteImage.size.width, deleteImage.size.height);
    [customDeleteButton setImage:deleteImage forState:UIControlStateNormal];
    [customDeleteButton setImage:[Util imageFromBundle:@"i_trash2.png"] forState:UIControlStateHighlighted];
    [customDeleteButton addTarget:self
                            action:@selector(deleteButtonPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
    ipadDeleteButton = [[UIBarButtonItem alloc] initWithCustomView:customDeleteButton];
        
	
    UIBarButtonItem *flexWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    UIBarButtonItem *fixedWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace 
                                                                                target:nil
                                                                                action:nil];
    fixedWidth.width = ((IS_IPHONE_5)?0:40);
	
    		
	[buttonBar setItems:[NSArray arrayWithObjects:ipadDeleteButton,
                         flexWidth,fixedWidth,playButton,
                         recordButton,
                         flexWidth,backButton,nil]];
	[backButton release];
    [flexWidth release];
    [fixedWidth release];
	[playButton release];
	[recordButton release];
	[buttonBar release];	
	
	isPlaing = NO;
	isRecording = NO;
	isRecorded = YES;
	NSString *fileToRec = [self pathForTMPFile];
	
	if (fileToRec && [[NSFileManager defaultManager] fileExistsAtPath:fileToRec]) {
		[[NSFileManager defaultManager] removeItemAtPath:fileToRec error:nil];
	}
	
	NSError *error;
	
	NSURL *url = [NSURL fileURLWithPath:[self pathForTMPFile]];
	
	recoder = [[AVAudioRecorder alloc] initWithURL:url
										  settings:nil
											 error:&error];
	
	
	[recoder prepareToRecord];
	
	
	if (sound) {
		if (player) {
			[player release];
			player = nil;
		}
		player = [[AVAudioPlayer alloc] initWithData:sound error:nil];
		
		reverseMinutes = ((NSInteger)(player.duration))/60;
		reverseSeconds = ((NSInteger)(player.duration))%60;
		
		if (isTimeLabelExist) {
					
			if (reverseSeconds>=10) {
				reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:%d",reverseMinutes,reverseSeconds];
			}else {
				reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:0%d",reverseMinutes,reverseSeconds];
			}
		}
		
	}else {
		ipadDeleteButton.enabled = NO;
		playButton.enabled = NO;
    }

	
	[[FAdMobController sharedAdMobController] logFlurryEnvent:@"Record audio" withParam:nil];
	
//	AVAudioSession *avSession = [AVAudioSession sharedInstance];
//	[avSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:(AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth ) error:nil];

}

-(void)viewWillDisappear:(BOOL)animated
{
	if (isPlaing) {
		[self stopPlaing];
	}
	
	if (isRecording) {
		[self stopRecording];
	}
	
		
	if (isRecorded && delegate && [delegate respondsToSelector:@selector(soundForCard:forWhat:)]) {
		[delegate soundForCard:sound forWhat:isQuestion];
	}else {
		NSLog(@"Not saved!!!");
	}
	
	AVAudioSession *avSession = [AVAudioSession sharedInstance];
	[avSession setCategory:AVAudioSessionCategoryAmbient error:nil];
	
}

-(void)setCard:(NSString*)catName forSide:(BOOL)isQ forSound:(NSData*)audio
{
	if (catName) {
		category = [[NSString alloc] initWithString:catName];
	}
	
	isQuestion = isQ;
	if (audio) {
		if (sound) {
			[sound release];
		}
		sound = [[NSData alloc] initWithData:audio];
	}else {
		sound = nil;
	}

	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
        //changed sanjeev reddy for loud audio
    AVAudioSession *session = [AVAudioSession sharedInstance];

    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:(AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth ) error:nil];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    
//    
//    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:44100],AVSampleRateKey,[NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey, [NSNumber numberWithInt:1],AVNumberOfChannelsKey, [NSNumber numberWithInt:AVAudioQualityMedium], AVEncoderAudioQualityKey, nil];

    
    if (![Util isPhone]) {
        
    
        }
    
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];

    [super viewDidLoad];
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if ([Util isPhone]) {
		return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}else {
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}

    
}

#pragma mark -
#pragma mark Statusbar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark targets

-(void)playButtonPressed:(id)sender
{
    recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    [recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    
	if (!isPlaing) {
		
		isPlaing = YES;
		
		if (isRecording) {
			[self stopRecording];
		}
	
		if (sound) {
			if (player) {
				[player release];
			}
	
			minutes = 0;
			seconds = 0;
			
			recordButton.enabled = NO;
			ipadDeleteButton.enabled = NO;
			
            UIButton *customPlay = (UIButton*)playButton.customView;
            [customPlay setImage:[Util imageFromBundle:@"i_record_stop.png"] forState:UIControlStateNormal];
            [customPlay setImage:[Util imageFromBundle:@"i_record_stop.png"] forState:UIControlStateHighlighted];
        
		
			timer = [NSTimer scheduledTimerWithTimeInterval:1.0
												 target:self
											   selector:@selector(changeTime:)
											   userInfo:nil
												repeats:YES];
			
			player = [[AVAudioPlayer alloc] initWithData:sound error:nil];
			playTo = player.duration;
            //player.volume=.0;
			
			reverseMinutes = ((NSInteger)(playTo))/60;
			reverseSeconds = ((NSInteger)(playTo))%60;
			
			[player prepareToPlay];
			[player setVolume:1.0];
			[player play];
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Media"
															message:@"Sound not found"
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}

	}else {
		[self stopPlaing];
	}

	
	
}
#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

-(void)recordButtonPressed:(id)sender
{
   
   
    

	
	if (!isRecording) {
		isRecording = YES;
		if (isPlaing) {
			isPlaing = NO;
			[self stopPlaing];
		}
		playTo = 5*60;
		
        RIBlinkButton *customRecord = (RIBlinkButton*)recordButton.customView;
        [customRecord startBlinking];
        		
		if (isTimeLabelExist) {
			reverseTimeLabel.text = @"-5:00";
		}
		
		reverseMinutes = 5;
		reverseSeconds = 0;
		playButton.enabled = NO;
		ipadDeleteButton.enabled = NO;
	
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0
											 target:self
										   selector:@selector(changeTime:)
										   userInfo:nil
											repeats:YES];
				
        

		[recoder prepareToRecord];
		[recoder record];
		
	}else {
		isRecording = NO;
		[self stopRecording];
	}



    
    
}

-(void)deleteButtonPressed:(id)sender
{
	if (isPlaing) {
		isPlaing = NO;
		[self stopPlaing];
	}
	
	if (isRecording) {
		isRecording = NO;
		[self stopRecording];
	}
	
	if (!sound) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Record"
														message:@"Current record is empty!"
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSString *message = @"Are you sure you want to delete current record?";
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Record"
														message:message
													   delegate:self
											  cancelButtonTitle:@"YES"
											  otherButtonTitles:@"NO",nil];
		[alert show];
		[alert release];
	}

}

-(void)saveButtonPressed:(id)sender
{
	if (isRecording) {
		isRecording = NO;
		[self stopRecording];
	}
	
	if (isPlaing) {
		isPlaing = NO;
		[self stopPlaing];
	}
	
	[self updateSoundFromTMPFile];
	
	if (delegate && [delegate respondsToSelector:@selector(soundForCard:forWhat:)]) {
		[delegate soundForCard:sound forWhat:isQuestion];
	}else {
		NSLog(@"Not saved!!!");
	}
	
	
	[self.navigationController popViewControllerAnimated:YES];
	
}

-(void)backButtonPressed:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


-(void)progressSliderChanged:(id)sender
{
	
}

-(void)changeTime:(id)sender
{
	seconds++;
	
	if (seconds>=60) {
		seconds = 0;
		minutes++;
	}
	
	if (isTimeLabelExist) {
		if (seconds>=10) {
			timeLabel.text = [NSString stringWithFormat:@"%d:%d",minutes,seconds];
		}else {
			timeLabel.text = [NSString stringWithFormat:@"%d:0%d",minutes,seconds];
		}
	}
	

	if (reverseSeconds == 0) {
		reverseSeconds = 59;
		reverseMinutes--;
	}else {
		reverseSeconds--;
	}
		
	if (reverseMinutes<0) {
		reverseMinutes = 0;
		reverseSeconds = 0;
	}
	
	if (isTimeLabelExist) {
		if (reverseSeconds>=10) {
			reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:%d",reverseMinutes,reverseSeconds];
		}else {
			reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:0%d",reverseMinutes,reverseSeconds];
		}
	}
	
	
	
	
	if (playTo<=minutes*60+seconds) {
		[timer invalidate];
		timer = nil;
		
		if (isPlaing) {
			isPlaing = NO;
			[self stopPlaing];
		}
		
		if (isRecording) {
			isRecording = NO;
			[self stopRecording];
		}
		
	}
	
}

#pragma mark -
#pragma mark alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([alertView cancelButtonIndex]==buttonIndex) {
		if (sound) {
			[sound release];
			sound = nil;
		}
		
		reverseSeconds = 0;
		reverseSeconds = 0;
		
		if (isTimeLabelExist) {
			reverseTimeLabel.text = @"-0:00";
		}
						
		NSString *pathForRecord = [self pathForTMPFile];
		if (pathForRecord && [[NSFileManager defaultManager] fileExistsAtPath:pathForRecord]) {
			[[NSFileManager defaultManager] removeItemAtPath:pathForRecord error:nil];
		}
		
		ipadDeleteButton.enabled = NO;
		playButton.enabled = NO;
        isRecorded = YES;
	}
}

#pragma mark -
#pragma mark Private

-(NSString*)pathForTMPFile
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *tmpFile = [documentsDirectory stringByAppendingPathComponent:@".tmpSound.caf"];
//    NSURL *url = [NSURL fileURLWithPath:tmpFile];
//    recoder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:nil];
    
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:tmpFile];
	
	if (success) {
		[[NSFileManager defaultManager] removeItemAtPath:tmpFile
												   error:nil];
		
	}
	
	return tmpFile;
}

-(void)updateSoundFromTMPFile
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
	NSString *documentsDirectory = [path objectAtIndex:0];
	NSString *tmpFile = [documentsDirectory stringByAppendingPathComponent:@".tmpSound.caf"];
	
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:tmpFile];
	
	if (success) {
		if (sound) {
			[sound release];
		}
		
		sound = [[NSData alloc] initWithContentsOfFile:tmpFile];
	}else {

		NSLog(@"File not found");
	}

}

-(void)stopPlaing
{
	if (timer && [timer isValid]) {
		[timer invalidate];
		timer = nil;
	}
	
	isPlaing = NO;
	
	
	if (player) {
		
        UIButton *customPlay = (UIButton*)playButton.customView;
        [customPlay setImage:[Util imageFromBundle:@"i_record_play.png"] forState:UIControlStateNormal];
        [customPlay setImage:[Util imageFromBundle:@"i_record_play.png"] forState:UIControlStateHighlighted];
        
		recordButton.enabled = YES;
		ipadDeleteButton.enabled = YES;
				
		reverseMinutes = ((NSInteger)(player.duration))/60;
		reverseSeconds = ((NSInteger)(player.duration))%60;
		
		if (isTimeLabelExist) {
			if (reverseSeconds>=10) {
				reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:%d",reverseMinutes,reverseSeconds];
			}else {
				reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:0%d",reverseMinutes,reverseSeconds];
			}
		}
		
		[player stop];
		[player release];
		player = nil;
	}
	
	minutes = 0;
	seconds = 0;
	
	if (isTimeLabelExist) {
		timeLabel.text = @"0:00";
	}
	
}

-(void)stopRecording
{
	if (timer && [timer isValid]) {
		[timer invalidate];
		timer = nil;
	}
	
	isRecording = NO;
	
	if (recoder) {
		[recoder stop];
	}
	
	playButton.enabled = YES;
	
	ipadDeleteButton.enabled = YES;
	
    RIBlinkButton *customRecord = (RIBlinkButton*)recordButton.customView;
    [customRecord stopBlinking];
    
	reverseMinutes = minutes;
	reverseSeconds = seconds;
	minutes = 0;
	seconds = 0;
	
	if (isTimeLabelExist) {
		timeLabel.text = @"0:00";
	
		if (reverseSeconds>=10) {
			reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:%d",reverseMinutes,reverseSeconds];
		}else {
			reverseTimeLabel.text = [NSString stringWithFormat:@"-%d:0%d",reverseMinutes,reverseSeconds];
		}
	}

	
	isRecorded = YES;
	[self updateSoundFromTMPFile];
	
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
	
	if (sound) {
		[sound release];
		sound = nil;
	}
	
	self.delegate = nil;
	
	if (player) {
		[player release];
	}
	
	if (recoder) {
		[recoder release];
	}
	
	if (timer && [timer isValid]) {
		[timer invalidate];
	}
	
    [super dealloc];
}


@end
