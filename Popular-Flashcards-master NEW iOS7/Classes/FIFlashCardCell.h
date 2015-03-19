//
//  FIFlashCardCell.h
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIBouncingView.h"

@protocol FIFlashCardCellDelegate

-(void)updateCell:(UITableViewCell*)cell;
-(void)editPressed:(UITableViewCell*)cel;

@end


@interface FIFlashCardCell : UITableViewCell<FIBouncingViewDelegate> {
	FIBouncingView *rightEditImageView;
	FIBouncingView	*leftImageView;
	UIButton *rightEditButton;
	BOOL isEditing;
	NSInteger idNum;
	id delegate;
}



@property(nonatomic,readonly)FIBouncingView *rightEditImageView;
@property(nonatomic,readonly)FIBouncingView *leftImageView;
@property(nonatomic,readwrite)NSInteger idNum;
@property(nonatomic,assign)id delegate;

@end
