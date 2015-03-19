//
//  FITextViewController.h
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FITextViewControllerDelegate

-(void)addTextForCard:(NSString*)Atext;

@end

@interface FITextViewController : UIViewController {
	UITextView *textView;
	NSString *currText;
	NSString *titleText;
	id delegate;
}

@property(nonatomic,assign)id delegate;

-(void)showText:(NSString*)Atext forTitle:(NSString*)titleStr;

@end
