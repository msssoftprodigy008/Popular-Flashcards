//
//  FRecordController.h
//  flashCards
//
//  Created by Ruslan on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FAdMobController.h"
#import "FRootConstants.h"
#import "RIBlinkButton.h"
#import <AVFoundation/AVFoundation.h>

@protocol FRecordControllerDelegate

-(void)soundForCard:(NSData*)sound forWhat:(BOOL)isQ;

@end


@interface FRecordController : UIViewController {
	AVAudioPlayer *player;
	AVAudioRecorder *recoder;
	BOOL isRecording;
	BOOL isPlaing;
	NSString *category;
	NSInteger cardId;
	BOOL isQuestion;
	
	UIBarButtonItem *playButton;
	UIBarButtonItem *recordButton;
    UIBarButtonItem *ipadDeleteButton;
	NSData *sound;
	
	UILabel *timeLabel;
	UILabel *reverseTimeLabel;
	
	NSInteger seconds;
	NSInteger minutes;
	NSInteger reverseSeconds;
	NSInteger reverseMinutes;
	
	NSTimer *timer;
	NSTimeInterval playTo;
	id delegate;
	
	FIOrientation orientation;
	
	BOOL isRecorded;
	BOOL isTimeLabelExist;
    
     NSDictionary *recordSetting;//added sanjeev
}

@property(nonatomic,readwrite)FIOrientation orientation;
@property(nonatomic,assign)id delegate;

-(void)setCard:(NSString*)catName forSide:(BOOL)isQ forSound:(NSData*)audio;

@end
