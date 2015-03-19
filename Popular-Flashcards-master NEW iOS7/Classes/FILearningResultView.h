//
//  FILearningResultView.h
//  flashCards
//
//  Created by Ruslan on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "FRootConstants.h"

@protocol FILearningResultDelegate<NSObject>
@optional
-(void)cancelSelected;
-(void)quitSelected;

@end


@interface FILearningResultView : UIView {
	NSDictionary *_result;
	NSString *_title;
	UILabel *_knowLabel;
	UILabel *_notSureLabel;
	UILabel *_dontKnowLabel;
	UIImageView *_knowImageView;
	UIImageView *_notSureImageView;
	UIImageView *_dontKnowImageView;
	
	NSInteger _dontKnowVal;
	NSInteger _notSureVal;
	NSInteger _knowVal;
	
    SystemSoundID playerCalc;
    
	NSTimer *_knowTimer;
	NSTimer *_notSureTimer;
	NSTimer *_dontKnowTimer;
	
	id<FILearningResultDelegate> delegate;
	
	FILearningProccesType _learningType;
}

@property(nonatomic,assign)id<FILearningResultDelegate> delegate;

-(id)initWithResult:(NSDictionary*)result forType:(FILearningProccesType) type;
-(void)startShowingResult;

@end
