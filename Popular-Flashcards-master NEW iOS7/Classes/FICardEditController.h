//
//  FICardEditController.h
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FIPickerView.h"
#import "FPickerAlertView.h"
#import "FLanguageTranslate.h"
#import "FISearchViewController.h"
#import "FIDefinitionViewController.h"
#import "FICardsConstants.h"
#import "FRootConstants.h"
#import "FIFlickerViewController.h"
#import "FAdMobController.h"
#import "FDownLoader.h"
#import "FDefinitionController.h"
#import "FDefinitionViewController.h"
#import "FIMicrosoftTranslate.h"
#import "FIImageEditController.h"
#import "FILinesView.h"
@protocol FICardEditDelegate
@optional

-(void)cardUpdated;
-(void)cardAdded:(NSInteger)cardId;
-(void)createdCard:(NSArray*)newCard;
-(void)updatedCard:(NSArray*)card;

@end


@interface FICardEditController : UIViewController<FIPickerViewDelegate,FLanguageDelegate,
FISearchViewControllerDelegate,FIDefinitionDelegate,FIFlickerControllerDelegate,FDownloaderDelegate,
FDefinitionControllerDelegate,FIMicrosoftTranslateDelegate,FIImageEditControllerDelegate> {
	UITextView *Q;
	UITextView *A;
	
    
    
	UIImageView *qImageView;
	UIImageView *aImageView;
	FILinesView *lines;
	FIEditCardType editTipe;
	NSInteger setTemplate;
	
	NSString *category;
	
	UIImage *qImage;
	UIImage	*aImage;
	
	NSString *q;
	NSString *a;
	id delegate;
	
	NSInteger cardId;
	
	
	FIImagePickedType imageType;
	
	//translate variables
	UIBarButtonItem *translate;
	UIBarButtonItem *language;
    UIBarButtonItem *audioButton;
	NSString *firstLan;
	NSString *secondLan;
	
	BOOL isTrans;
	
	//sound variables
	UIButton *qSoundButton;
	UIButton *aSoundButton;
	NSData *qSound;
	NSData *aSound;
	BOOL isQSoundChanged;
	BOOL isASoundChanged;
    BOOL isNeedTranslate;
	
	AVAudioPlayer *player;
	
	FIOrientation orientation;
    
    UIDeviceOrientation orientation1 ;

}

@property(nonatomic,assign)id delegate;
@property(nonatomic,readwrite)FIOrientation orientation;

-(id)initWithType:(FIEditCardType)type forCategory:(NSString*)Acategory forArg:(NSDictionary*)arguments;


@end
