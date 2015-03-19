//
//  FPickerAlertView.m
//  flashCards
//
//  Created by Ruslan on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FPickerAlertView.h"

@interface FPickerAlertView(Private)

-(void)saveButtonPressed;
-(void)selectFirstComp;
-(void)selectSecComp;
@end


@implementation FPickerAlertView


-(id)initWithDicAndDelegate:(NSDictionary*)picDic andForDelegate:(id)Adelegate forFLan:(NSString*)firL forSLan:(NSString*)secLan{
    if ((self = [super init])) {
        // Initialization code
		self.title = @"Select language";
		currentData = [[NSMutableDictionary alloc] initWithDictionary:picDic];
		
		
		
		picker = [[UIPickerView alloc] initWithFrame:CGRectMake(6,50,270,200)];
		picker.showsSelectionIndicator = YES;	// note this is default to NO
		
		// this view controller is the data source and delegate
		picker.delegate = self;
		picker.dataSource = self;
		
		UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		saveButton.frame = CGRectMake(71,265,128,43);
		[saveButton setImage:[UIImage imageNamed:@"ok_1.png"] forState:UIControlStateNormal];
		[saveButton setImage:[UIImage imageNamed:@"ok_2.png"] forState:UIControlStateHighlighted];
		[saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		
		[self addSubview:picker];
		[self addSubview:saveButton];
		
        if (firL && secLan) {
            fromLan = [[NSString alloc] initWithString:firL];
            toLan = [[NSString alloc] initWithString:secLan];
        }else{
            fromLan = [[NSString alloc] initWithString:@"English"];
            toLan = [[NSString alloc] initWithString:@"Spanish"];
        }
		
		[self selectFirstComp];
		[self selectSecComp];
		
		Mydelegate = Adelegate;
		
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void) show {
	[super show];
	
	self.bounds = CGRectMake(0,0,300,330);
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		
		if (fromLan) {
			[fromLan release];
		}
		
		fromLan = [[NSString alloc] initWithString:[[currentData allKeys] objectAtIndex:row]];
	}
	else {
		
		if (toLan) {
			[toLan release];
		}
		
		toLan = [[NSString alloc] initWithString:[[currentData allKeys] objectAtIndex:row]];
	}

}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == picker)
	{
		
		returnStr = [[currentData allKeys] objectAtIndex:row];
		
	}
	
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 125.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [[currentData allKeys] count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}

#pragma mark private methods

-(void)selectFirstComp
{
	NSArray *arr = [currentData allKeys];
	int c = [arr count];
	for (int i=0;i<c;i++) {
		if ([fromLan isEqualToString:[arr objectAtIndex:i]]) {
			[picker selectRow:i inComponent:0 animated:NO];
			return;
		}
	}
	
}

-(void)selectSecComp
{
	NSArray *arr = [currentData allKeys];
	int c = [arr count];
	for (int i=0;i<c;i++) {
		if ([toLan isEqualToString:[arr objectAtIndex:i]]) {
			[picker selectRow:i inComponent:1 animated:NO];
			return;
		}
	}
}

-(void)saveButtonPressed
{
	[Mydelegate langPicked:fromLan next:toLan];
	[self dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)dealloc {
	[fromLan release];
	[toLan release];
	[picker release];
	[currentData release];
    [super dealloc];
}


@end
