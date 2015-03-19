//
//  NSMutableArrayExtensions.m
//  flashCards
//
//  Created by Ruslan on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArrayExtensions.h"


@implementation NSMutableArray(Shuffle)

int randomSort(id obj1, id obj2, void *context ) {
	// returns random number -1 0 1
    return (random()%3 - 1);    
}

- (void)shuffle {
	// call custom sort function
    [self sortUsingFunction:randomSort context:nil];
}

@end
