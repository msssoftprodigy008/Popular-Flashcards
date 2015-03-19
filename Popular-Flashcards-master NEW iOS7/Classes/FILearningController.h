//
//  FILearningController.h
//  flashCards
//
//  Created by Ruslan on 8/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRootConstants.h"

@interface FILearningController : UIViewController {
	NSString *category;
	FILearningProccesType learnType;
	NSInteger right;
	NSInteger wrong;
	NSInteger notSure;
}

-(id)initWithCategory:(NSString*)Acategory forType:(FILearningProccesType)type;
-(NSArray*)learningArray;
-(NSDictionary*)statisticForSession;
-(NSInteger)updateAnswer:(NSInteger)cardId forAnswer:(NSInteger)result;
-(NSInteger)getIntervalForAnswer:(NSInteger)result;

@end
