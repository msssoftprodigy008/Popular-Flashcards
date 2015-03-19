//
//  UIControl+SSToolkitAdditions.m
//  SSToolkit
//
//  Created by Sam Soffes on 4/19/10.
//  Copyright 2009-2010 Sam Soffes. All rights reserved.
//

#import "UIControl+SSToolkitAdditions.h"

@implementation UIControl (SSToolkitAdditions)

- (void)removeAllTargets {
	for (id target in [self allTargets]) {
		[self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
	}
}

@end
