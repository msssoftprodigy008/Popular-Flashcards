//
//  FTextAlertView.m
//  flashCards
//
//  Created by Ruslan on 7/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FTextAlertView.h"
#import "Constant.h"
@interface FTextAlertView(Private)

-(void)stringChanged:(id)sender;
-(void)orientationChanged;

@end


@implementation FTextAlertView
@synthesize nameField;

- (id)init{
    if ((self = [super init])) {
        // Initialization code
		[self setTitle:@"Enter new name"];
		[self setMessage:@" "];
		[self addButtonWithTitle:@"Cancel"]; 
		[self addButtonWithTitle:@"OK"]; 
        //_alertview.delegate=self ;
        nameField.delegate=self;
        
        if ([Util isPhone]) {
			nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 30.0, 245.0, 25.0)] ;
		}else {
			nameField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 40.0, 245.0, 25.0)] ;
		}
        nameField.delegate=self;
        
        if (IS_IPHONE_5) {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                self.alertViewStyle = UIAlertViewStylePlainTextInput;
                
                UITextField *textField = [self textFieldAtIndex:0];
                [textField addTarget:self action:@selector(stringChanged:) forControlEvents:UIControlEventEditingChanged];
            }
            else{
                [nameField setBackgroundColor:[UIColor whiteColor]];
                [self addSubview:nameField];
                nameField.placeholder = @"Category name";
                [nameField addTarget:self action:@selector(stringChanged:) forControlEvents:UIControlEventEditingChanged];
            }
            
        }
        else {
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                self.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *textField = [self textFieldAtIndex:0];
                if (IS_IPHONE_5) {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        UITextField *textField = [self textFieldAtIndex:0];
                        nameField = textField;
                    }
                }
                else {
                    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
                        UITextField *textField = [self textFieldAtIndex:0];
                        nameField = textField;
                    }
                }
                
                [textField addTarget:self action:@selector(stringChanged:) forControlEvents:UIControlEventEditingChanged];
            }
            else{
                [nameField setBackgroundColor:[UIColor whiteColor]];
                [self addSubview:nameField];
                nameField.placeholder = @"Category name";
                
                [nameField addTarget:self action:@selector(stringChanged:) forControlEvents:UIControlEventEditingChanged];
            }
        }
		
		currentLen = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(orientationChanged)
													 name:@"orientationChanged"
												   object:nil];
		 
    }
    return self;
}

-(NSString*)name
{

   if (nameField.text.length !=0 )
    {
      
    return nameField.text;
        
    }
	
	return nil;
}

-(void)show
{
	
	
	[nameField becomeFirstResponder];
	[super show];
}

-(void)orientationChanged
{
	if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0) {
		//CGAffineTransform moveUp = CGAffineTransformMakeTranslation(0.0,-90.0);
		//[self setTransform:CGAffineTransformIdentity]; 
		if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft ||
			[UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationDuration:0.2f];
			self.transform = CGAffineTransformTranslate(self.transform,0.0,-90.0);
			[UIView commitAnimations];
		}
		
		
		
	}
}

#pragma mark -
#pragma mark textfield handlers

-(void)stringChanged:(id)sender
{
    if (IS_IPHONE_5) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            UITextField *textField = [self textFieldAtIndex:0];
            nameField = textField;
        }
    }
    else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
            UITextField *textField = [self textFieldAtIndex:0];
            nameField = textField;
        }
    }
   
//         NSString *currentName = nameField.text;
      // allow only alphanumeric chars//sanjeev reddy
        NSString* newStr = [nameField.text stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
        
        if ([newStr length] < [nameField.text length])
        {
            nameField.text = newStr;
        }
  
 //   NSInteger nameLen = [currentName length];
    
  //  NSCharacterSet *numSet = [NSCharacterSet alphanumericCharacterSet];
//	if (nameLen>currentLen) {
//		unichar c = [currentName characterAtIndex:nameLen-1];
//		
//		if (((c>='0' && c<='9') || ![numSet characterIsMember:c]) && nameLen==1) {
//			nameLen = 0;
//			nameField.text = @"";
//		}else {
//			if (nameLen>1 && ![numSet characterIsMember:c] && c!=' ') {
//				nameLen--;
//				currentName = [currentName substringToIndex:nameLen-1];
//				nameField.text = currentName;
//			}
//		}
//
//		
//	}
//	
//	currentLen = nameLen;
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#define ACCEPTABLE_CHARECTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *acceptedInput = [NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS];
    
    if (![[string componentsSeparatedByCharactersInSet:acceptedInput] count] > 1)
        return NO;
    else
        return YES;
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}


@end
