//
//  UIProgressView+customView.m
//  flashCards
//
//  Created by Sanjeevareddy Nandela on 3/10/15.
//
//

#import "UIProgressView+customView.h"

@implementation UIProgressView (customView)

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize newSize = CGSizeMake(self.frame.size.width, 9);
    return newSize;
}

@end
