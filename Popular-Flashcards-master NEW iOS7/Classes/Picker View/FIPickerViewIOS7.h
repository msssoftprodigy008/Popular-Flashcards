//
//  FIPickerView.h
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@protocol FIPickerViewDelegate

-(void)languagePicked:(NSString*)fromL next:(NSString*)toLan;

@end
//typedef enum{
//    RIPopoverStateAddCategory,
//    RIPopoverStateAddCard,
//    RIPopoverStateSettings,
//    RIPopoverStateGroup,
//    RIPopoverStateNone
//}RIPopoverState;
@interface FIPickerViewIOS7 : CustomIOS7AlertView<UIPickerViewDelegate,UIPickerViewDataSource,CustomIOS7AlertViewDelegate> {
	NSMutableDictionary *currentData;
	NSMutableArray *fA;
	NSMutableArray *sA;
	UIPickerView *picker;
	UIButton *selectButton;
	id Mydelegate;
	NSMutableArray *arrSorted;
	NSString *fromLan;
	NSString *toLan;
    
//    RIPopoverState r_popoverState;
    
}

-(id)initWithDicAndDelegate:(NSDictionary*)picDic andForDelegate:(id)Adelegate forFLan:(NSString*)firL forSLan:(NSString*)secLan;
- (void)show;
-(void)rotated;

@end
