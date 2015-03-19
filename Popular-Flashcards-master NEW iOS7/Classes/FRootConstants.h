/*
 *  FRootConstants.h
 *  flashCards
 *
 *  Created by Ruslan on 7/30/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef enum{
	FIOrientationPortrait,
	FIOrientationLandscape
} FIOrientation;

typedef enum  {
	FILearningProccesTypeTest,
	FILearningProccesTypeStudy
} FILearningProccesType;

typedef enum{
	FIBoxMovingDirectionForward,
	FIBoxMovingDirectionBack
}FIBoxMovingDirection;

typedef enum{
	FIActiveBoxNone,
	FIActiveBoxLeft,
	FIActiveBoxRight,
	FIActiveBoxBottom
}FIActiveBox;

typedef enum{
	FIDirectionLeft,
	FIDirectionRight,
	FIDirectionDown
}FIDirection;

typedef enum{
	FITableStateAll,
	FITableStateNotAll,
	FITableStateFav,
	FITableStateNone
}FITableState;

//TEMPLATE DEFINES
#define kFrontTextTemplate 1<<0
#define kBackTextTemplate 1<<1
#define kFrontPicTemplate 1<<2
#define kBackPicTemplate 1<<3
#define kFrontAudioTemplate 1<<4
#define kBackAudioTemplate 1<<5
#define kTranslateTemplate 1<<6
#define kAudioTemplate 1<<7
#define kImageTemplate 1<<8
#define kDefinitionTemplate 1<<9
#define kWebTemplate 1<<10

#define kCustomTemplate ((1<<11)-1)

#define kt_isFrontText(x) (x & kFrontTextTemplate)
#define kt_isBackText(x) (x & kBackTextTemplate)
#define kt_isBothText(x) (kt_isFrontText(x) && kt_isBackText(x))
#define kt_isFrontPic(x) (x & kFrontPicTemplate)
#define kt_isBackPic(x) (x & kBackPicTemplate)
#define kt_isBothPic(x) (kt_isFrontPic(x) && kt_isBackPic(x))
#define kt_isFrontAudio(x) (x & kFrontAudioTemplate)
#define kt_isBackAudio(x) (x & kBackAudioTemplate)
#define kt_isBothAudio(x) (kt_isFrontAudio(x) && kt_isBackAudio(x))
#define kt_isTranslate(x) (x & kTranslateTemplate)
#define kt_isAudio(x) (x & kAudioTemplate)
#define kt_isImage(x) (x & kImageTemplate)
#define kt_isDefinition(x) (x & kDefinitionTemplate)
#define kt_isWeb(x) (x & kWebTemplate)

#define kFILeftSceneBoxWidth	61.0f
#define kFILeftSceneBoxHeight	69.0f
#define kFIRightSceneBoxWidth	61.0f
#define kFIRightSceneBoxHeight	69.0f
#define kFIBottomSceneBoxWidth	61.0f	
#define kFIBottomSceneBoxHeight	71.0f
#define kFISceneBoxLeftButtonWidth	23.0f
#define kFISceneBoxLeftButtonHeight	69.0f
#define kFISceneBoxRightButtonWidth	23.0f
#define kFISceneBoxRightButtonHeight 69.0f
#define kFISceneBoxBottomButtonWidth	69.0f
#define kFISceneBoxBottomButtonHeight 24.0f

//box area

#define kFILeftSceneAreaWidth	61.f
#define kFILeftSceneAreaHeight	69.f
#define kFIRightSceneAreaWidth	61.f
#define kFIRightSceneAreaHeight	69.f
#define kFIBottomSceneAreaWidth	61.f
#define kFIBottomSceneAreaHeight	71.f

#define kDefaultNavColor [UIColor colorWithRed:205.0/255.0 green:175.0/255.0 blue:149.0/255.0 alpha:1.0]
#define kDefaultBgColor [UIColor colorWithRed:205.0/255.0 green:170.0/255.0 blue:125.0/255.0 alpha:1.0]
#define kDefaultIPadAddNavigationColor [UIColor colorWithRed:0.094 green:0.145 blue:0.271 alpha:1.0]
#define kDefaultTextColor [UIColor colorWithRed:104.0/255.0 green:56.0/255.0 blue:12.0/255.0 alpha:1.0] 
