//
//  FIRoundedProgress.h
//  flashCards
//
//  Created by Ruslan on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FIRoundedProgress : UIView {
	NSDictionary *r_attributes;
}

-(id)initWithColors:(CGRect)frame attributes:(NSDictionary*)attr;
-(void)changeValue:(NSDictionary*)newVal;

@end
