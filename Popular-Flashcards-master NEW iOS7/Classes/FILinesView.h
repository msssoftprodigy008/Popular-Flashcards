//
//  FILinesView.h
//  flashCards
//
//  Created by Ruslan on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FILinesView : UIView {
	NSArray *attributes;
}

-(id)initWithAttributes:(CGRect)frame forDic:(NSArray*)attr;
-(void)changeAttributes:(NSArray*)newattr;

@end
