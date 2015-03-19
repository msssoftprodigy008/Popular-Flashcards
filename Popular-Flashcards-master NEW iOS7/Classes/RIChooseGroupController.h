//
//  RIChooseGroupController.h
//  flashCards
//
//  Created by Ruslan on 10/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RIChooseGroupControllerDelegate<NSObject>
-(void)movedTo:(NSString*)gid;

@end

@interface RIChooseGroupController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_groupView;
    NSMutableArray *_groups;
    NSString *group;
    NSInteger _index;
    id<RIChooseGroupControllerDelegate> delegate;
}

@property(nonatomic,assign)id<RIChooseGroupControllerDelegate> delegate;
@property(nonatomic,copy)NSString* group;

@end
