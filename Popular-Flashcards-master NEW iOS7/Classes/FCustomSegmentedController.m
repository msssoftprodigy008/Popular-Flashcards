//
//  FCustomSegmentedController.m
//  flashCards
//
//  Created by Ruslan on 7/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FCustomSegmentedController.h"

@interface FCustomSegmentedController(Private)

-(void)buttonPressed:(id)sender;

@end


@implementation FCustomSegmentedController
@synthesize selectedSegmentIndex;

/*- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}*/

-(id)initWithItems:(NSArray*)items
{
	if (self = [super initWithFrame:CGRectZero]) {
		if (!items) {
			return nil;
		}
	
		CGRect frame = CGRectMake(0,0,0,0);
	
		buttonArray = [[NSMutableArray alloc] init];
		int tag = 300;
		for (NSArray *currentButton in items) {
			if ([currentButton count]<3) {
				return nil;
			}
		
			UIImage *norm = [currentButton objectAtIndex:0];
			UIImage *high = [currentButton objectAtIndex:1];
			UIImage *select = [currentButton objectAtIndex:2];
		
			CGFloat width = norm.size.width;
			CGFloat height = norm.size.height;
			
			UIButton *but = [UIButton buttonWithType:UIButtonTypeCustom];
			but.frame = CGRectMake(frame.origin.x,frame.origin.y,width,height);
			[but setImage:norm forState:UIControlStateNormal];
			[but setImage:high  forState:UIControlStateHighlighted];
			[but addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
			but.tag = tag;
			tag++;
			[self addSubview:but];
			NSArray *contentArray = [NSArray arrayWithObjects:but,norm,high,select,nil];
			[buttonArray addObject:contentArray];
			frame.origin.x+=width-1;
			frame.size.width+=width-1;
			frame.size.height = height;
		}
		self.frame = CGRectMake(0,0,frame.size.width,frame.size.height);
		selectedSegmentIndex = -1;
		return self;
	}
	
	return nil;
}

-(void)setSelectedSegmentIndex:(NSInteger)index
{
	if (index == -1) {
		
		if (selectedSegmentIndex>=0) {
			NSArray *prevSel = [buttonArray objectAtIndex:selectedSegmentIndex];
			UIButton *prevBut = [prevSel objectAtIndex:0];
			UIImage *prevImageNorm = [prevSel objectAtIndex:1];
			prevBut.userInteractionEnabled = YES;
			[prevBut setImage:prevImageNorm forState:UIControlStateNormal];
		}
		
		selectedSegmentIndex = -1;
		
		return;
	}
	
	if (index<0 || index>=[buttonArray count] || selectedSegmentIndex==index) {
		return;
	}
	
	UIButton *sender = [[buttonArray objectAtIndex:index] objectAtIndex:0];
	[self buttonPressed:sender];
	
}


-(NSInteger)selectedSegmentIndex
{
	return selectedSegmentIndex;
}

#pragma mark -
#pragma mark private methods

-(void)buttonPressed:(id)sender
{
	UIButton *selButton = (UIButton*)sender;
	NSInteger index = selButton.tag-300;
	NSArray *curArr = [buttonArray objectAtIndex:index];
	UIImage *setImage = [curArr objectAtIndex:3];
	[selButton setImage:setImage forState:UIControlStateNormal];
	selButton.userInteractionEnabled = NO;
	
	if (selectedSegmentIndex>=0) {
		NSArray *prevSel = [buttonArray objectAtIndex:selectedSegmentIndex];
		UIButton *prevBut = [prevSel objectAtIndex:0];
		UIImage *prevImageNorm = [prevSel objectAtIndex:1];
		prevBut.userInteractionEnabled = YES;
		[prevBut setImage:prevImageNorm forState:UIControlStateNormal];
	}

	selectedSegmentIndex = index;
	[self sendActionsForControlEvents:UIControlEventValueChanged];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[buttonArray release];
    [super dealloc];
}


@end
