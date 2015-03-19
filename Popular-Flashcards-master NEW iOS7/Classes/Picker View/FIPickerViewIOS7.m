//
//  FIPickerView.m
//  flashCards
//
//  Created by Ruslan on 8/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FIPickerViewIOS7.h"
#import "Util.h"
#import "Constant.h"
@interface FIPickerViewIOS7(Private)

-(void)saveButtonPressed;
-(void)selectFirstComp;
-(void)selectSecComp;
-(void)rotated:(NSNotification*)sender;
@end


@implementation FIPickerViewIOS7


-(id)initWithDicAndDelegate:(NSDictionary*)picDic andForDelegate:(id)Adelegate forFLan:(NSString*)firL forSLan:(NSString*)secLan{
    if ((self = [super init])) {
        // Initialization code
		//self.title = @"Select language";
        [self setContainerView:[self createPickerView]];
        
        arrSorted = [[NSMutableArray alloc] init];
        
		currentData = [[NSMutableDictionary alloc] initWithDictionary:picDic];
		
        NSArray * sortedKeys = [[currentData allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        [arrSorted addObject:@"English"];
        [arrSorted addObject:@"Math / Symbols"];
        
        for (int i=0;i<sortedKeys.count;i++) {
            if (![sortedKeys[i] isEqualToString:@"English"] && ![sortedKeys[i] isEqualToString:@"Math / Symbols"]) {
                [arrSorted addObject:sortedKeys[i]];
            }
        }
        
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rotated:)
                                                     name:@"UIDeviceOrientationDidChangeNotification"
                                                   object:nil];
		
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
    
    
    picker.frame = CGRectMake(0,0,320,216);

	[super show];
	
	  
       // self.bounds = CGRectMake(0,0,((IS_IPHONE_5)?568:480),330); removed sanjeev reddy for to work in ipad
    
}

-(void)rotated{
    [self rotated:nil];
}

-(void)rotated:(NSNotification*)sender{
    if ([Util isPhone]) {
        picker.frame = CGRectMake(14,50,272,216);
    }else
        
    {
      picker. frame = CGRectMake(0,0,320,216);
    }
   // self.bounds = CGRectMake(0,0,((IS_IPHONE_5)?568:300),330);
}
- (UIView *)createPickerView
{
    UIView *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0,8,290,20)];
    lblTitle.text = @"Select language";
    lblTitle.textAlignment = UITextAlignmentCenter;
    lblTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    
    UILabel *lblTitleHeader = [[UILabel alloc] initWithFrame:CGRectMake(20,38,250,20)];
    lblTitleHeader.text = @"Front                       Back";
    lblTitleHeader.textAlignment = UITextAlignmentCenter;
    lblTitleHeader.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    //lblTitleHeader.backgroundColor = [UIColor greenColor];
    
    if ([Util isPhone]) {
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,0,200,160)];
    }else{
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,0,320,216)];
    }
    picker.showsSelectionIndicator = YES;	// note this is default to NO
    
    // this view controller is the data source and delegate
    picker.delegate = self;
    picker.dataSource = self;
    
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([Util isPhone]) {
        saveButton.frame = CGRectMake(88,270,128,43);
    }else{
        saveButton.frame = CGRectMake(88,270,128,43);
    }
    
    [saveButton setImage:[UIImage imageNamed:@"ok_1.png"] forState:UIControlStateNormal];
    [saveButton setImage:[UIImage imageNamed:@"ok_2.png"] forState:UIControlStateHighlighted];
    [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [demoView addSubview:lblTitle];
    [demoView addSubview:lblTitleHeader];
    [demoView addSubview:picker];
    //[demoView addSubview:saveButton];
    
    return demoView;
}
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
    [self saveButtonPressed];
    [self close];
}
#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (component == 0) {
		
		if (fromLan) {
			[fromLan release];
		}
		
		fromLan = [[NSString alloc] initWithString:[arrSorted objectAtIndex:row]];
	}
	else {
		
		if (toLan) {
			[toLan release];
		}
		
		toLan = [[NSString alloc] initWithString:[arrSorted objectAtIndex:row]];
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
        //NSArray * sortedKeys = [[currentData allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        
		//returnStr = [[currentData allKeys] objectAtIndex:row];
        returnStr = [arrSorted objectAtIndex:row];
		
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
	NSArray *arr = arrSorted;
    
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
	NSArray *arr = arrSorted;
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
	if (Mydelegate && [Mydelegate respondsToSelector:@selector(languagePicked:next:)]) {
		[Mydelegate languagePicked:fromLan next:toLan];
	}
	//[self dismissWithClickedButtonIndex:0 animated:YES];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[fromLan release];
	[toLan release];
	[picker release];
	[currentData release];
    [super dealloc];
}

@end
