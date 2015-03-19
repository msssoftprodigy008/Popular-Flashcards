//
//  RIImportSetController.h
//  flashCards
//
//  Created by Ruslan on 9/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RILoadingView.h"

@protocol RIImportSetControllerDelegate <NSObject>

-(void)importEnded;

@end

@interface RIImportSetController : UIViewController{
    RILoadingView *_loadingView;
    id<RIImportSetControllerDelegate> delegate;
    UIImageView *_bgViewLand;
    UIImageView *_bgViewPort;
}

@property(nonatomic,assign)id<RIImportSetControllerDelegate> delegate;

-(void)startImporting;

@end
