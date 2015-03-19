//
//  flashCardsAppDelegate.m
//  flashCards
//
//  Created by Руслан Руслан on 1/8/10.
//  Copyright МГУ 2010. All rights reserved.
//

#import "flashCardsAppDelegate.h"
#import "FDBController.h"
#import "ZipArchive.h"
#import "ModalAlert.h"
#import "FCSVParser.h"
#import "FAdMobController.h"
#import "RIMainViewCotroller.h"
#import "FISplashController.h"
#import "Util.h"
#import "iRate.h"
#import "DBTime.h"
#import "FIFCImport.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BWHockeyManager.h"
#import "BWQuincyManager.h"
#import "UAirship.h"
#import "UAPush.h"
#import "Constant.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface flashCardsAppDelegate(Private)
-(void)changeBadgeNumber;
-(void)setApplicationBadgeNumber:(NSNumber*)bNumber;
-(void)scheduleLocalNotification;
-(BOOL)checkDefaultImport;
-(void)importFileAtPath:(NSString*)url;
-(void)addHockey;
-(void)iRateInit;
-(void)initAirship:(NSDictionary *)launchOptions;

@end


@implementation flashCardsAppDelegate



@synthesize window;


void _uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}



- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Override point for customization after app launch
	srand(time(NULL));
	
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.items = nil;
	
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
	
	[Util createNeededDir];
	//[FITestImport testAll];

//    +(BOOL)isFullVersion
    
#ifdef _FULL_
    [Util buyVersion];
#endif
    
    [self addHockey];
    [self iRateInit];
    
    /*[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];*/
    NSSetUncaughtExceptionHandler(&_uncaughtExceptionHandler);
    
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	
	AVAudioSession *avSession = [AVAudioSession sharedInstance];
	[avSession setCategory:AVAudioSessionCategoryAmbient error:nil];
	
	UInt32 doSetProperty = 0;
    AudioSessionSetProperty (
							 kAudioSessionProperty_OverrideCategoryMixWithOthers,
							 sizeof (doSetProperty),
							 &doSetProperty
							 );
	
	if ([Util isPhone]) {
		[[FAdMobController sharedAdMobController] setFlurryVersion:@"Iphone version"];
	}else {
		[[FAdMobController sharedAdMobController] setFlurryVersion:@"Ipad version"];
	}
    
	[[FAdMobController sharedAdMobController] startFlurySession];
    
	rootForIphone = [[RIMainViewCotroller alloc] init];
	iphoneRootNavigation = [[UINavigationController alloc] initWithRootViewController:rootForIphone];
	iphoneRootNavigation.navigationBar.hidden = YES;
	
    
	if ([Util isPhone]) {
		UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"i_bg.png"]];
        if (IS_IPHONE_5) {
            bgView.frame = CGRectMake(0,0,320,568);
            window.frame = CGRectMake(0,0,320,568);// Original

//            window.frame = CGRectMake(0,0,568,320); // Changed temporary
            
            if(IS_OS_8_OR_LATER) {
                bgView.frame = CGRectMake(0,0,320,568);
                window.frame = CGRectMake(0,0,320,568);// Original
            }

        }
        else{
            bgView.frame =CGRectMake(0,0,320,480);
            window.frame = CGRectMake(0,0,320,480); // Original

//            window.frame = CGRectMake(0,0,480,320);// Changed temporary
            
            if(IS_OS_8_OR_LATER) {
                bgView.frame =CGRectMake(0,0,320,480);
                window.frame = CGRectMake(0,0,320,480);// Original
            }
        }
		[window addSubview:bgView];
		[bgView release];
	}else {
		
	}
    
    [self scheduleLocalNotification];
    if (![self checkDefaultImport]){
        r_loadingController = [[RIImportSetController alloc] init];
        r_loadingController.delegate = self;
        //[window addSubview:r_loadingController.view];
        window.rootViewController = r_loadingController;
        [r_loadingController startImporting];
    }else{
        window.rootViewController = iphoneRootNavigation;
        //[window addSubview:iphoneRootNavigation.view];
    }
    
  	[window makeKeyAndVisible];
    NSLog(@"%f,%f",window.frame.size.width,window.frame.size.height);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/*if (launchOptions && [launchOptions count]>0) {
     NSURL *url = (NSURL*)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
     
     if (url && [url isFileURL]) {
     if (url) {
     NSString *filePath = [url path];
     if (filePath) {
     [self importFileAtPath:filePath];
     }
     }
     }
     
     }*/
    [self initAirship:launchOptions];
	[self applicationDidFinishLaunching:application];
	return YES;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskAll;
}
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    
//    NSUInteger orientations = UIInterfaceOrientationMaskLandscape |UIInterfaceOrientationMaskPortrait;
//    
//    if(self.window.rootViewController){
//        
//        UIViewController *presentedViewController = [[(UINavigationController *)self.window.rootViewController viewControllers] lastObject];
//        
//        orientations = [presentedViewController supportedInterfaceOrientations];
//    }
//    
//    return orientations;
//}

//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
//    return UIInterfaceOrientationMaskAll;
//}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSString *schema = [url scheme];
    if (schema && [schema isEqualToString:@"fcads"]) {
        NSString *code = [Util getParamStringFromUrl:[url absoluteString] needle:@"code="];
        if (code) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"QuizletCode" object:code];
        }
        
    }else{
        if (url && [url isFileURL]) {
            NSString *filePath = [url path];
            if (filePath) {
                [self importFileAtPath:filePath];
            }
        }
    }
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.items = nil;
    
    badgeThread = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(changeBadgeNumber)
                                            object:nil];
    [badgeThread start];
    [rootForIphone termination];
}
//-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//        return UIInterfaceOrientationMaskAll;
//    else  /* iphone */
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//}
//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    return UIInterfaceOrientationMaskAll;
//}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
	UIPasteboard *board = [UIPasteboard generalPasteboard];
	if (board) {
		NSString *term = [board string];
		if (term) {
			[rootForIphone performSelector:@selector(importTerm:)
								withObject:term
								afterDelay:1.0f];
		}
	}
    [self scheduleLocalNotification];
	[rootForIphone makeActive];
    
    if (badgeThread && [badgeThread isExecuting]) {
        [badgeThread cancel];
    }
    
    if (badgeThread) {
        [badgeThread release];
        badgeThread = nil;
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"terminator" object:nil];
	UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
	pasteBoard.items = nil;
	[rootForIphone termination];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"%@",deviceToken);
    [[UAPush shared] registerDeviceToken:deviceToken];
    /*NSMutableString *tokenString = [NSMutableString stringWithString:
     [[deviceToken description] uppercaseString]];
     [tokenString replaceOccurrencesOfString:@"<"
     withString:@""
     options:0
     range:NSMakeRange(0, tokenString.length)];
     [tokenString replaceOccurrencesOfString:@">"
     withString:@""
     options:0
     range:NSMakeRange(0, tokenString.length)];
     [tokenString replaceOccurrencesOfString:@" "
     withString:@""
     options:0
     range:NSMakeRange(0, tokenString.length)];
     NSLog(@"Token: %@", tokenString);
     
     if (tokenString) {
     [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"token"];
     }
     
     // Create the NSURL for the request
     NSString *bundleid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
     NSString *urlFormat = @"http://easylearningapps.com:4000/pushnotif/regdevice/?&token=%@&udid=%@&bundleid=%@";
     NSURL *registrationURL = [NSURL URLWithString:[NSString stringWithFormat:
     urlFormat, tokenString, [[UIDevice currentDevice] uniqueIdentifier],bundleid]];
     NSLog(@"%@",[registrationURL absoluteString]);
     // Create the registration request
     NSMutableURLRequest *registrationRequest = [[NSMutableURLRequest alloc]
     initWithURL:registrationURL];
     
     // And fire it off
     NSURLConnection *connection = [NSURLConnection connectionWithRequest:registrationRequest
     delegate:self];
     [connection start];
     
     
     [registrationRequest release];*/
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }else{
        NSLog(@"%@",@"can't recieve token");
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    NSLog(@"%@",@"Recieved remote notification");
    UIApplicationState appState = UIApplicationStateActive;
    if ([application respondsToSelector:@selector(applicationState)]) {
        appState = application.applicationState;
    }
    
    [[UAPush shared] handleNotification:userInfo applicationState:appState];
}

#pragma mark -
#pragma mark Hockey

-(void)addHockey{
    
    NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:@"hockeyAppID"];
    if (!appId) {
        if ([Util isFullVersion]) {
            appId = @"0907cd8b90f9416e49217e79c58d2741";
            [[NSUserDefaults standardUserDefaults] setObject:@"0907cd8b90f9416e49217e79c58d2741" forKey:@"hockeyAppID"];
        }else{
            appId = @"ed127962483134399a031081d64851a7";
            [[NSUserDefaults standardUserDefaults] setObject:@"ed127962483134399a031081d64851a7" forKey:@"hockeyAppID"];
        }
    }
    
#if defined CONFIGURATION_Release
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:appId];
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:NO];
    [[BWHockeyManager sharedHockeyManager] setCheckForUpdateOnLaunch:NO];
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:appId];
    [[BWQuincyManager sharedQuincyManager] setAutoSubmitCrashReport:YES];
#endif
}

#pragma mark -

#pragma mark iRate

-(void)iRateInit{
    [iRate sharedInstance].appStoreID = 352320289;
    [iRate sharedInstance].applicationName = @"A+";
    [iRate sharedInstance].messageTitle = @"A+";
    [iRate sharedInstance].rateButtonLabel = @"Rate";
    [iRate sharedInstance].cancelButtonLabel = @"No, thanks";
    [iRate sharedInstance].remindButtonLabel = @"Remind later";
    [iRate sharedInstance].daysUntilPrompt = 2;
    [iRate sharedInstance].usesUntilPrompt = 5;
    [iRate sharedInstance].remindPeriod = 3;
    
}

#pragma mark Airship
-(void)initAirship:(NSDictionary *)launchOptions{
    
    [UAirship setLogLevel:UALogLevelTrace];
    
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
    // You can then programatically override the plist values:
    // config.developmentAppKey = @"YourKey";
    // etc.
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    
    // Print out the application configuration for debugging (optional)
    UA_LDEBUG(@"Config:\n%@", [config description]);
    
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    // Set the notification types required for the app (optional). This value defaults
    // to badge, alert and sound, so it's only necessary to set it if you want
    // to add or remove types.
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeAlert |
                                             UIRemoteNotificationTypeBadge |
                                             UIRemoteNotificationTypeSound);

    /*
    //Init Airship launch options
    NSMutableDictionary *takeOffOptions = [[[NSMutableDictionary alloc] init] autorelease];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airhship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    //   [[UAPush shared] resetBadge];//zero badge on startup
    
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];
     */
}

- (void)failIfSimulator {
    if ([[[UIDevice currentDevice] model] compare:@"iPhone Simulator"] == NSOrderedSame) {
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle:@"Notice"
                                                            message:@"You will not be able to recieve push notifications in the simulator."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        
        [someError show];
        [someError release];
    }
}

#pragma mark Default import

-(BOOL)checkDefaultImport{
    BOOL defaultSetsImp = [[NSUserDefaults standardUserDefaults] boolForKey:@"DefaultSetsImp"];
	return defaultSetsImp;
}

-(void)importFileAtPath:(NSString*)url{
    if (url) {
        NSString *tmpPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
        tmpPath = [tmpPath stringByAppendingPathComponent:[url lastPathComponent]];
        if ([[NSFileManager defaultManager] copyItemAtPath:url toPath:tmpPath error:nil]) {
            NSString *item = [FIFCImport importFCFileWithPath:tmpPath];
            NSString *groupId = [rootForIphone getCurrentGroup];
            if (groupId) {
                if (item) {
                    [[FDBController sharedDatabase] insertCategory:item toGroup:groupId];
                    [[FDBController sharedDatabase] insertTemplate:item withTemplate:kCustomTemplate];
                    [rootForIphone reloadCurrentGroup:groupId category:[[FDBController sharedDatabase] nameForGroup:groupId]];
                }
            }else{
                groupId = [[FDBController sharedDatabase] addGroup:@"Default"];
                if (groupId && item) {
                    [[FDBController sharedDatabase] insertCategory:item toGroup:groupId];
                    [[FDBController sharedDatabase] insertTemplate:item withTemplate:kCustomTemplate];
                    [rootForIphone reloadCurrentGroup:groupId category:@"Default"];
                }
            }
        }
    }
}

#pragma mark -

#pragma mark -
#pragma mark RIImortSetController delegate

-(void)importEnded{
    [r_loadingController.view removeFromSuperview];
    [r_loadingController release];
    window.rootViewController = iphoneRootNavigation;
    //[window addSubview:iphoneRootNavigation.view];
}

#pragma mark -

#pragma mark -
#pragma mark FISplashControllerDelegate

-(void)splashScreenDidAppear:(FISplashController*)splashController
{
}

-(void)splashScreenWillDisappear:(FISplashController*)splashController
{
	
}

-(void)splashScreenDidDisappear:(FISplashController*)splashController
{
	if (splashController) {
		[splashController release];
		splashController = nil;
	}
}


#pragma mark -

#pragma mark -
#pragma mark local notificatons


-(void)changeBadgeNumber{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSDictionary *info = [rootForIphone infoForCurrentCategory];
    
    [self performSelectorOnMainThread:@selector(setApplicationBadgeNumber:)
                           withObject:[info objectForKey:@"learnCount"]
                        waitUntilDone:YES];
    
    [pool release];
}

-(void)setApplicationBadgeNumber:(NSNumber*)bNumber{
//    if (bNumber) {
//        [UIApplication sharedApplication].applicationIconBadgeNumber = [bNumber intValue];
//    }
}

-(void)scheduleLocalNotification{
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit
                                                   fromDate:today];
    NSString *time = [[NSUserDefaults standardUserDefaults] objectForKey:@"SchedLocTime"];
    if (time && [time isEqualToString:@"0"]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }else{
        BOOL isSound = NO;
        NSNumber* sound = [[NSUserDefaults standardUserDefaults] objectForKey:@"play_sound"];
        if (sound) {
            isSound = [sound boolValue];
        }else{
            isSound = YES;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"play_sound"];
        }
        NSInteger min = 0;
        NSInteger hours = 8;
        if (time) {
            NSArray *arr = [time componentsSeparatedByString:@":"];
            min = [[arr objectAtIndex:1] intValue];
            hours = [[arr objectAtIndex:0] intValue];
        }
        
        dateComponents.second = 0;
        dateComponents.minute = min;
        dateComponents.hour = hours;
        NSDate *fireDate = [calendar dateFromComponents:dateComponents];
        [calendar release];
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = fireDate;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
//        localNotification.repeatInterval = NSDayCalendarUnit;
        localNotification.repeatInterval = NSWeekCalendarUnit;
        localNotification.alertBody = @"It's time to check your flashcards planned for today!";
        localNotification.alertAction = @"Go!";
        if (isSound) {
            localNotification.soundName = UILocalNotificationDefaultSoundName;
        }else{
            localNotification.soundName = nil;
        }
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [localNotification release];
    }
    
}

#pragma mark -

- (void)dealloc {
	if (iphoneRootNavigation) {
		[iphoneRootNavigation release];
	}
	
	if (rootForIphone) {
		[rootForIphone release];
	}
	
    if (badgeThread) {
        if ([badgeThread isExecuting]) {
            [badgeThread cancel];
        }
        
        [badgeThread release];
        badgeThread = nil;
    }
    
    [window release];
    [super dealloc];
}


@end
