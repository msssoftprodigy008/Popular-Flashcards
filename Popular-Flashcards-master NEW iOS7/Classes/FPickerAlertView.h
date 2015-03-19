//
//  FPickerAlertView.h
//  flashCards
//
//  Created by Ruslan on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FPickerAlertViewDelegate

-(void)langPicked:(NSString*)fromL next:(NSString*)toLan;

@end


@interface FPickerAlertView : UIAlertView<UIPickerViewDelegate,UIPickerViewDataSource> {
	NSMutableDictionary *currentData;
	NSMutableArray *fA;
	NSMutableArray *sA;
	UIPickerView *picker;
	UIButton *selectButton;
	id Mydelegate; 
	
	NSString *fromLan;
	NSString *toLan;
	

}

-(id)initWithDicAndDelegate:(NSDictionary*)picDic andForDelegate:(id)Adelegate forFLan:(NSString*)firL forSLan:(NSString*)secLan;
- (void)show;
@end
