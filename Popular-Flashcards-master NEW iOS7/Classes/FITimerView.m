//
//  FITimerView.m
//  flashCards
//
//  Created by Ruslan on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FITimerView.h"

@interface FITimerView(Private)

-(void)changeTime:(NSTimer*)timer;
-(void)setTime;

@end


@implementation FITimerView


-(id)initTimerWithTime:(CGRect)newFrame withTime:(NSString*)time withFont:(UIFont*)font{
    if ((self = [super initWithFrame:newFrame])) {
        // Initialization code
		timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,newFrame.size.width,newFrame.size.height)];
		timerLabel.font = font;
		timerLabel.text = @"";
		timerLabel.adjustsFontSizeToFitWidth = YES;
		timerLabel.backgroundColor = [UIColor clearColor];
		timerLabel.textColor = [UIColor colorWithRed:214.0/255.0
											   green:154.0/255.0
												blue:87.0/255.0
											   alpha:1.0];
		timerLabel.shadowColor = [UIColor brownColor];
		timerLabel.textAlignment = UITextAlignmentCenter;
		timerLabel.shadowOffset = CGSizeMake(0.5,0.5);
		[self addSubview:timerLabel];
		[timerLabel release];
		
		if (time) {
			NSArray *timerArr = [time componentsSeparatedByString:@":"];
			
			if (timerArr && [timerArr count]==3) {
				hours = [[timerArr objectAtIndex:0] intValue];
				minutes = [[timerArr objectAtIndex:1] intValue];
				seconds = [[timerArr objectAtIndex:2] intValue];
			}
			else {
				hours = 0;
				minutes = 0;
				seconds = 0;
			}

		}
		else {
			hours = 0;
			minutes = 0;
			seconds = 0;
		}

		[self setTime];
		clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
													  target:self
													selector:@selector(changeTime:)
													userInfo:nil
													 repeats:YES];
		
    }
    return self;
}

-(void)clearTimer
{
	hours = 0;
	minutes = 0;
	seconds = 0;
}

-(void)stopTimer
{
	if (clockTimer && [clockTimer isValid]) {
		[clockTimer invalidate];
		clockTimer = nil;
	}
}

-(void)startTimer
{
	if (clockTimer && [clockTimer isValid]) {
		[clockTimer invalidate];
		clockTimer = nil;
	}
	
	[self setTime];
	clockTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
												  target:self
												selector:@selector(changeTime:)
												userInfo:nil
												 repeats:YES];
	
}

-(NSString*)time
{
	return timerLabel.text;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark -
#pragma mark private methods

-(void)changeTime:(NSTimer*)timer
{
	minutes += (seconds+1)/60;
	hours += minutes/60;
	minutes = minutes%60;
	seconds = (seconds+1)%60;
	
	NSMutableString *time = [NSMutableString string];
	
	if (hours>0) {
		[time appendFormat:@"%d:",hours];
	}

	if (minutes<10) {
		[time appendFormat:@"0%d:",minutes];
	}
	else {
		[time appendFormat:@"%d:",minutes];
	}

	if (seconds<10) {
		[time appendFormat:@"0%d",seconds];
	}
	else {
		[time appendFormat:@"%d",seconds];
	}
	
	timerLabel.text = time;
}

-(void)setTime
{
	NSMutableString *time = [NSMutableString string];
	
	if (hours>0) {
		[time appendFormat:@"%d:",hours];
	}
	
	if (minutes<10) {
		[time appendFormat:@"0%d:",minutes];
	}
	else {
		[time appendFormat:@"%d:",minutes];
	}
	
	if (seconds<10) {
		[time appendFormat:@"0%d",seconds];
	}
	else {
		[time appendFormat:@"%d",seconds];
	}
	
	timerLabel.text = time;
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}


@end
