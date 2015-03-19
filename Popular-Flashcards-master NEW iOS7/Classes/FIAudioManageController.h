//
//  FIAudioManageController.h
//  flashCards
//
//  Created by Ruslan on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FILoadingView.h"
#import <AVFoundation/AVFoundation.h>
#import "FIAnimationController.h"
#import "FAdMobController.h"
#import "FRootConstants.h"

@protocol FIAudioManageControllerDelegate

-(void)audioFromWordnik:(NSData*)audio;

@end


@interface FIAudioManageController : UIViewController<UISearchBarDelegate,AVAudioPlayerDelegate> {
	UISearchBar *audioSearchBar;
	FILoadingView *loadingView;
	UIView *animationView;
	UILabel *audioLabel;
	NSMutableDictionary *dicForSound;
	NSData *soundData;
	NSMutableArray *audioInfo;
	NSString *term;
	id delegate;
	
	AVAudioPlayer *audioPlayer;
	
	FIOrientation orientation;
	
	NSInteger currTag;
}

-(id)initWithTerm:(NSString*)Aterm;

@property(nonatomic,readwrite)FIOrientation orientation;
@property(nonatomic,assign)id delegate; 

@end
