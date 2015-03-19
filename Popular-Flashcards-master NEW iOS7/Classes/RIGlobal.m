//
//  RIGlobal.m
//  flashCards
//
//  Created by Ruslan on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RIGlobal.h"


@implementation RIGlobal

+(void)say:(NSString*)message
{
	if (message) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
														message:message
													   delegate:nil
											  cancelButtonTitle:@"NO"
											  otherButtonTitles:@"OK",nil];
		[alert show];
		[alert release];
	}
}

@end
