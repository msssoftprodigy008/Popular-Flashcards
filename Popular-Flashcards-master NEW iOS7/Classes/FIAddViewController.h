//
//  FIAddViewController.h
//  flashCards
//
//  Created by Ruslan on 7/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FIAddViewController : UIViewController {
    UIButton *itunesButton;
  	UIButton *quizletButton;
	id delegate;
}

@property(nonatomic,assign)id delegate;


@end
