//
//  FIPickerView.h
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FIPickerViewDelegate

-(void)languagePicked:(NSString*)fromL next:(NSString*)toLan;

@end

@interface FIPickerView : UIAlertView<UIPickerViewDelegate,UIPickerViewDataSource> {
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
-(void)rotated;

@end
