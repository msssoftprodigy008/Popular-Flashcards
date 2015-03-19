//
//  FIFlashCardCell.m
//  flashCards
//
//  Created by Ruslan on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIFlashCardCell.h"
#import <QuartzCore/QuartzCore.h>

@interface FIFlashCardCell(Private)

-(void)editPressed;

@end


@implementation FIFlashCardCell
@synthesize rightEditImageView;
@synthesize leftImageView;
@synthesize idNum;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		CGRect cellFrame = self.frame;
		CGRect leftFrame = CGRectMake(cellFrame.size.width-26-5,cellFrame.size.height/2-11,26,22);
		
		rightEditImageView = [[FIBouncingView alloc] initWithImages:leftFrame
														 forActive:[UIImage imageNamed:@"i_arrow_2.png"]
													 forNoneActive:[UIImage imageNamed:@"i_arrow_1.png"]
													   forDelegate:self];
		[self addSubview:rightEditImageView];
		[rightEditImageView release];
		
		leftImageView = [[FIBouncingView alloc] initWithImages:CGRectMake(5,cellFrame.size.height/2-13,25,25)
													 forActive:[UIImage imageNamed:@"i_pic.png"]
												 forNoneActive:nil
												   forDelegate:self];
		leftImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:leftImageView];
		[leftImageView release];
		
		rightEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
		rightEditButton.frame = CGRectMake(cellFrame.size.width,cellFrame.size.height/2-cellFrame.size.height/4,cellFrame.size.height,cellFrame.size.height/2);
		rightEditButton.backgroundColor = [UIColor clearColor];
		[rightEditButton setImage:[UIImage imageNamed:@"i_edit_cell_1.png"] forState:UIControlStateNormal];
		[rightEditButton setImage:[UIImage imageNamed:@"i_edit_cell_2.png"] forState:UIControlStateHighlighted];	
		[rightEditButton addTarget:self
							action:@selector(editPressed)
				  forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:rightEditButton];
		
		self.accessoryView.hidden = YES;
		
    }
    return self;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
	
	
	
	CGRect contentFrame = self.contentView.frame;
	CGRect textLabelFrame = self.textLabel.frame;
	CGRect detailFrame = self.detailTextLabel.frame;
	
	
	textLabelFrame.size.width = self.frame.size.width-75;
	detailFrame.size.width = self.frame.size.width-75;
	contentFrame = CGRectMake(30,contentFrame.origin.y,self.frame.size.width-75,contentFrame.size.height);
	
	
	
	self.textLabel.frame = textLabelFrame;
	self.detailTextLabel.frame = detailFrame;
    [self.contentView setFrame:contentFrame];
	
	[self bringSubviewToFront:rightEditImageView];
	[self bringSubviewToFront:leftImageView];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	isEditing = editing;
		
	CATransition *animation = [CATransition animation];
	[animation setDelegate:self];
	[animation setDuration:0.5f];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype: kCATransitionFromLeft];
	[animation setSpeed:1.5];
	
	CGPoint butPoint = rightEditButton.center;
	
	
	
	if (editing) {
		self.contentView.userInteractionEnabled = NO;
		[leftImageView changeImages:[UIImage imageNamed:@"i_delete_2.png"] forNoneActive:[UIImage imageNamed:@"i_delete_1.png"]];
		rightEditImageView.hidden = YES;
		butPoint = CGPointMake(self.frame.size.width-rightEditButton.frame.size.width/2-5.0,butPoint.y);

	}
	else {
		self.contentView.userInteractionEnabled = YES;
		[leftImageView changeImages:[UIImage imageNamed:@"i_arrow_2.png"] forNoneActive:[UIImage imageNamed:@"i_arrow_1.png"]];
		rightEditImageView.hidden = NO;
		butPoint = CGPointMake(self.frame.size.width+rightEditButton.frame.size.width/2,butPoint.y);
		
	}
	
	if (delegate && [delegate respondsToSelector:@selector(updateCell:)]) {
		[delegate updateCell:self];
	}
	
	if (animated) 
		[[leftImageView layer] addAnimation:animation forKey:@"changeState"];
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
	
		rightEditButton.center = butPoint;
		
	[UIView commitAnimations];
		
	}else {
		rightEditButton.center = butPoint;
	}
	
}

- (void)prepareForReuse
{
	if (isEditing) {
		self.accessoryView.hidden = YES;
	}
	else {
		self.accessoryView.hidden = NO;
	}
}

#pragma mark -
#pragma mark FIBouncingViewDelegate methods
-(void)stateChanged:(BOOL)newState
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"stateChanged" object:self];
}

#pragma mark -

#pragma mark -
#pragma mark private

-(void)editPressed
{
	if (delegate && [delegate respondsToSelector:@selector(editPressed:)]) {
		[delegate editPressed:self];
	}
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}


@end
