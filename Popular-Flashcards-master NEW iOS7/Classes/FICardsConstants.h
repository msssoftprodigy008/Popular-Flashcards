/*
 *  FICardsConstants.h
 *  flashCards
 *
 *  Created by Ruslan on 7/29/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef enum{
	FIEditCardTypeAdd,
	FIEditCardTypeUpdate
}FIEditCardType;

typedef enum{
	FIImagePickedTypeNone,
	FIimagePickedTypeQuestion,
	FIimagePickedTypeAnswer
}FIImagePickedType;

typedef enum{
	FITranslateModeTranslate,
	FITranslateModeLaguage
}FITranslateMode;

typedef enum{
	FICheckboxStateNotChecked,
	FICheckboxStateChecked
}FICheckboxState;

#define kFCardWidthIPhone5 548.0f
#define kFCardWidth 460.0f
#define kFCardHieght 300.0f
#define kFCardSmallWidth 66.75f
#define kFCardSmallHeight 52.75f
#define kFCardLargeWidth	654
#define kFCardLargeHeight	491
#define kFCardInBoxWidth 22.0f
#define kFCardInBoxHeight 21.0f
#define kFBoxPlainWidth 40.0f
#define kFBoxPlainHeight 49.0f
#define kFBoxPlainOffsetX 10.0f
#define kFBoxPlainOffsetY 10.0f	
#define kFCardResizeWidth 200.25f
#define kFCardResizeHeight 158.25f

//card sizes
#define kFICardBigLineHeight 45.0f
#define kFICardSmallLineHeight 30.0f
#define kFINormalLine 25.0f

//pic parameters

#define kFPicFrameTopOffset kFICardBigLineHeight+kFICardSmallLineHeight
#define kFPicFrameBottomOffset 8.0f
#define kFPicFrameLeftOffset 0.0f
#define kFPicFrameRightOffset 0.0f
#define kFPicFrameNormalWidth kFCardWidth-kFPicFrameLeftOffset-kFPicFrameRightOffset
#define kFPicFrameNormalHeight kFCardHieght-kFPicFrameTopOffset-kFPicFrameBottomOffset
#define kFPicFrameSmallWidth kFCardWidth/2-kFPicFrameLeftOffset-kFPicFrameRightOffset
#define kFPicFrameSmallHeight kFCardHieght-kFPicFrameTopOffset-kFPicFrameBottomOffset

#define kFPicTopOffset 23.0f
#define kFPicBottomOffset 23.0f
#define kFPicLeftOffset 22.0f
#define kFPicRightOffset 22.0f
#define kFPicNormalWidth kFPicFrameNormalWidth-kFPicLeftOffset-kFPicRightOffset
#define kFPicNormalHeight kFPicFrameNormalHeight-kFPicTopOffset-kFPicBottomOffset-60
#define kFPicSmallWidth	kFPicFrameSmallWidth-kFPicLeftOffset-kFPicRightOffset
#define kFPicSmallHeight kFPicFrameSmallHeight-kFPicTopOffset-kFPicBottomOffset-60

//shadow 
#define kFShadowOffsetX -70.0f
#define kFShadowOffsetY	40.0f
#define kFShadowWidth	500.0f
#define kFShadowHeight	300.0f

typedef enum{
	FICardPositionLeft,
	FICardPositionCenter,
	FICardPositionRight
}FICardPosition;

