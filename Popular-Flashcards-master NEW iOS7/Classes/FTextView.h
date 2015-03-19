//
//  FTextView.h
//  flashCards
//
//  Created by Ruslan on 7/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FTextViewDelegate

-(void)addTextToCard:(NSString*)Atext;

@end


@interface FTextView : UIViewController {
	UITextView *textView;
	NSString *currText;
	id delegate;
}

@property(nonatomic,assign)id delegate;

-(void)showText:(NSString*)Atext;

@end
