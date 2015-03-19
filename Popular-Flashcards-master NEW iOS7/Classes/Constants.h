/*
 *  Constants.h
 *  flashCards
 *
 *  Created by Руслан Руслан on 1/8/10.
 *  Copyright 2010 МГУ. All rights reserved.
 *
 */

//enums
typedef enum  {
	Question_mode,
	Answer_mode,
	isFull_Mode,
	isNotFull_Mode
} FMode;



typedef enum {
	FStudyModeAll,
	FStudyModeLocal
} FStudyMode;

typedef enum 
{
	FImportNone,
	FImportS,
	FImportQ,
	FImportA,
	FImportImQ,
	FImportImA
}FImport;

typedef enum
{
	FAlertTest,
	FAlertStudy
}FAlert;

typedef enum
{
	FCardNone,
	FCardRightBox,
	FCardBottomBox,
	FCardLeftBox
}FCard;

//defines
#define RATING_TEST_PERFECT				0
#define RATING_TEST_GOOD				1
#define RATING_TEST_POOR				2
#define RATING_TEST_TERRIBLE			3
	
#define RATING_TEST_KNOW				1
#define RATING_TEST_NOT_SURE			2
#define RATING_TEST_DONT_KNOW			3

#define kLandScapeViewWidth				704
#define kLandScapeViewHeight			748
#define kPortViewWidth					768
#define kPortViewHeight					1004

#define kCellHight						56
#define kCategoryTableX					0
#define kCategoryTableY					0
#define kCategoryTableWidth				320
#define kCategoryTableHieght			375
#define kCategoryCellTLableX			60
#define kCategoryCellTLableY			1
#define kCategoryCellTLableWidth		520
#define kCategoryCellTLableHeight		35
#define kCategoryCellTELabelX			kCategoryCellTLableX+50
#define kCategoryCellSLableX			60
#define kCategoryCellSLableY			36
#define kCategoryCellSLableWidth		520
#define kCategoryCellSLableHeight		19
#define kCategoryCellESLabelX			kCategoryCellSLableX+50
#define kCategoryCellCheckBX			0
#define kCategoryCellCheckBY			15
#define kCategoryCellCheckBWidth		20
#define kCategoryCellCheckBHight		20
#define kCategoryCellECheckBX			kCategoryCellCheckBX+50
#define kCategoryToolbarX				0
#define kCategoryToolbarY				373
#define kCategoryToolbarWidth			320
#define kCategoryToolbarHeight			44
#define kFViewX							0
#define kFViewY							0
#define kFViewWidth						320
#define kFViewHieght						426
#define kPortFViewX						0
#define kPortFViewY						0
#define kPortFViewWidth					320
#define kPortFViewHeight				460
#define kLandFViewX						0
#define kLandFViewY						0
#define kLandFViewWidth					480
#define kLandFViewHeight				300
#define kFDBCardsViewTitleX				135
#define kFDBCardsViewTitleY				0
#define kFDBCardsViewTitleWidth		70
#define kFDBCardsViewTitleHieght		50
#define kFDBCardsViewTextX				20
#define kFDBCardsViewTextY				20
#define kFDBCardsViewTextWidth			440
#define kFDBCardsViewTextHieght		220
#define kFDBCardsImageViewX				15
#define kFDBCardsImageViewY				40
#define kFDBCardsImageViewWidth		410
#define kFDBCardsImageViewHieght		165
#define kToolbarX							0
#define kToolbarY							704	
#define kToolbarWidth					1024
#define kToolbarHeight					44
#define kPortToolbarX					0
#define kPortToolbarY					212
#define kPortToolbarWidth				500
#define kPortToolbarHeight				44
#define kLandToollbarX					0
#define kLandToollbarY					256
#define kLandToollbarWidth				480
#define kLandToollbarHeight				44
#define kNavigationBarX					0
#define kNavigationBarY					0
#define kNavigationBarWidth				320
#define kNavigationBarHeight			44
#define kLandNavigationBarX				0
#define kLandNavigationBarY				0
#define kLandNavigationBarWidth			480
#define kLandNavigationBarHeight		44
#define kFBaseViewControllerTableX		0
#define kFBaseViewControllerTableY		50
#define kFBaseViewControllerTableWidth	320
#define kFBaseViewControllerTableHieght	200
#define kFDBCardsBackButtonX			10
#define kFDBCardsBackButtonY			270
#define kFDBCardsBackButtonWidth		60
#define kFDBCardsBackButtonHeight		40
#define kFDBCardsShowAButtonX			40
#define kFDBCardsShowAButtonY			kFDBCardsBackButtonY
#define kFDBCardsShowAButtonWidth		390
#define kFDBCardsShowAButtonHeight		kFDBCardsBackButtonHeight
#define kFDBCardsBackButtonLandX		10
#define kFDBCardsBackButtonLandY		430
#define kFDBCardsBackButtonLandWidth	60
#define kFDBCardsBackButtonLandHeight	40
#define kFDBCardsShowAButtonLandX		75
#define kFDBCardsShowAButtonLandY		430
#define kFDBCardsShowAButtonLandWidth	240
#define kFDBCardsShowAButtonLandHeight	40
#define kFSetControllerImageViewX		0
#define kFSetControllerImageViewY		0
#define kFSetControllerImageViewWidth	320
#define kFSetControllerImageViewHeight	60
#define kFSetManageEditX				0
#define kFSetManageEditY				0
#define kFSetManageEditWidth			400
#define kFSetManageEditHeight			70
#define kFSetPortManageEditX			84
#define kFSetPortManageEditY			267
#define kFSetPortManageEditWidth		600
#define kFSetPortManageEditHeight		70
#define kFCardsManageText1X				90
#define kFCardsManageText1Y				0
#define kFCardsManageText1Width		400
#define kFCardsManageText1Height		120
#define kFCardsManageText2X				90
#define kFCardsManageText2Y				110
#define kFCardsManageText2Width		400
#define kFCardsManageText2Height		120
#define kFCardsManageText1PortX		0
#define kFCardsManageText1PortY		0
#define kFCardsManageText1PortWidth	500
#define kFCardsManageText1PortHeight	128
#define kFCardsManageText2PortX		0
#define kFCardsManageText2PortY		128
#define kFCardsManageText2PortWidth	500
#define kFCardsManageText2PortHeight	128
#define kFLandShowAnswerButtonX		80
#define kFLandShowAnswerButtonY		2
#define kFLandShowAnswerButtonWidth	320
#define kFLandShowAnswerButtonHeight	40
#define kFPortShowAnswerButtonX		60
#define kFPortShowAnswerButtonY		2
#define kFPortShowAnswerButtonWidth	200
#define kFPortShowAnswerButtonHeight	40
#define kFSettingsSliderX				10
#define kFSettingsSliderY				230
#define kFSettingsSliderWidth			240
#define kFSettingsSliderHeight			7
#define kFSettingsSliderLabelX			270
#define kFSettingsSliderLabelY			229
#define kFSettingsSliderLabelWidth		55
#define kFSettingsSliderLabelHeight		20

//landscape card
#define kCardViewX						243
#define kCardViewY						268
#define kCardViewWidth					654
#define kCardViewHeight					491
#define kCardLeftBoxX					-133
#define kCardLeftBoxY					237
#define kCardLeftBoxWidth				245
#define kCardLeftBoxHeight				251
#define kCardRightBoxX					945
#define kCardRightBoxY					237
#define kCardRightBoxWidth				245
#define kCardRightBoxHeight				251
#define kCardBottomBoxX					388
#define kCardBottomBoxY					667
#define kCardBottomBoxWidth				251
#define kCardBottomBoxHeight			245
#define kCardLeftMsgX					0
#define kCardLeftMsgY					kCardLeftBoxY-109
#define kCardLeftMsgWidth				53
#define kCardLeftMsgHeight				455
#define kCardRightMsgX					970
#define kCardRightMsgY					kCardRightBoxY-109
#define kCardRightMsgWidth				53
#define kCardRightMsgHeight				455
#define kCardBottomMsgX					kCardBottomBoxX-119
#define kCardBottomMsgY					650
#define kCardBottomMsgWidth				455
#define kCardBottomMsgHeight			53
#define kCardSmallX						117
#define kCardSmallY						185
#define kCardSmallWidth					158
#define kCardSmallHeight				118

//portrait card
#define kCardViewPortX						148
#define kCardViewPortY						603
#define kCardViewPortWidth					424
#define kCardViewPortHeight					318
#define kCardLeftBoxPortX					-133
#define kCardLeftBoxPortY					311
#define kCardLeftBoxPortWidth				245
#define kCardLeftBoxPortHeight				251
#define kCardRightBoxPortX					690
#define kCardRightBoxPortY					311
#define kCardRightBoxPortWidth				245
#define kCardRightBoxPortHeight			251
#define kCardBottomBoxPortX					264
#define kCardBottomBoxPortY					920
#define kCardBottomBoxPortWidth			251
#define kCardBottomBoxPortHeight			245
#define kCardLeftMsgPortX					0
#define kCardLeftMsgPortY					kCardLeftBoxPortY-109
#define kCardLeftMsgPortWidth				53
#define kCardLeftMsgPortHeight				455
#define kCardRightMsgPortX					715
#define kCardRightMsgPortY					kCardRightBoxPortY-109
#define kCardRightMsgPortWidth				53
#define kCardRightMsgPortHeight			455
#define kCardBottomMsgPortX					kCardBottomBoxPortX-114
#define kCardBottomMsgPortY					903
#define kCardBottomMsgPortWidth			455
#define kCardBottomMsgPortHeight			53
#define kCardSmallPortX						117
#define kCardSmallPortY						185
#define kCardSmallPortWidth					158
#define kCardSmallPortHeight				118

#define kCardSettingsScrollX			0
#define kCardSettingsScrollY			0
#define kCardSettingsScrollWidth		540
#define kCardSettingsScrollHeight		580

#define kDefinitionControllerWidth   540
#define kDefinitionControllerHieght	 580

//wordnik constants
typedef enum {
	wordnikAPIDefinition,
	wordnikAPIAudio,
	flickerAPI,
	bingAPI
} wordnikAPI; 

//image server constants
typedef enum{
	serverModeFlickr,
	serverModeBing
}FIserverMode;

//card mode
typedef enum{
	FCardLookModeLand,
	FCardLookModePort
}FCardLookMode;
