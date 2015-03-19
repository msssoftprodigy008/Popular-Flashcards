//
//  FTextAlertView.h
//  flashCards
//
//  Created by Ruslan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"


@interface FTextAlertView : UIAlertView<UITextFieldDelegate> {
	UITextField *nameField;
	NSInteger currentLen;
}

@property(nonatomic,readonly)UITextField* nameField;
//@property(nonatomic,readonly)UIAlertView* alertview;

-(id)init;
-(NSString*)name;
-(void)show;
@end
