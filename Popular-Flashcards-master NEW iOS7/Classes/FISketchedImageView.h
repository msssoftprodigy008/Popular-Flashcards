//
//  FISketchedImageView.h
//  flashCards
//
//  Created by Ruslan on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FISketchedImageView : UIView {
	NSMutableDictionary *r_atrributes;
	CGRect r_drrect;
	CGRect r_borderRect;
	CGRect r_topRect;
	CGRect r_botRect;
}

-(id)initWithAtrributes:(CGRect)frame attr:(NSDictionary*)attr;
-(CGRect)changeAtributes:(NSDictionary*)attributes;
-(CGSize)drawnedImageSize;

@end
