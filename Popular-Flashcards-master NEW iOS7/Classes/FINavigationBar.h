//
//  FINavigationBar.h
//  flashCards
//
//  Created by Ruslan on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FINavigationBar : UINavigationBar {
	UIImage *bgImage;
    UILabel *titleLabel;
}

@property(nonatomic,retain)UIImage *bgImage;
@property(nonatomic,readonly)UILabel *titleLabel;

@end
