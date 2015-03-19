//
//  SSAddressBarTextFieldBackgroundViewInnerView.m
//  SSToolkit
//
//  Created by Sam Soffes on 2/8/11.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "SSAddressBarTextFieldBackgroundViewInnerView.h"
#import "UIImage+SSToolkitAdditions.h"

@implementation SSAddressBarTextFieldBackgroundViewInnerView

#pragma mark UIView

- (id)initWithFrame:(CGRect)aFrame {
	if ((self = [super initWithFrame:aFrame])) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.clipsToBounds = YES;
		self.userInteractionEnabled = NO;
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	CGSize size = self.frame.size;
	[[UIImage imageNamed:@"SSAddressBarTextFieldBackground.png" bundle:kSSToolkitBundleName] drawAsPatternInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
}

@end
