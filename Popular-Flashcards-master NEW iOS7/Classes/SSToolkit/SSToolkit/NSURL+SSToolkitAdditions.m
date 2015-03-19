//
//  NSURL+SSToolkitAdditions.m
//  SSToolkit
//
//  Created by Sam Soffes on 4/27/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "NSURL+SSToolkitAdditions.h"
#import "NSDictionary+SSToolkitAdditions.h"

@implementation NSURL (SSToolkitAdditions)

- (NSDictionary *)queryDictionary {
	 return [NSDictionary dictionaryWithFormEncodedString:self.query];
}

@end
