//
//  FImportApiMainController.h
//  flashCards
//
//  Created by Ruslan on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIndicatorView.h"
#import "QIRequest.h"

@protocol ApiControllerDelegate

-(void)importFinished:(BOOL)result newCat:(NSString*)cat;

@end


@interface FImportApiMainController : UIViewController<UITableViewDelegate,UITableViewDataSource,QIRequestDelegate> {
	NSMutableArray *currentSets;
	NSDictionary *currDic;
	NSString *category;
	UITableView *setTable;
	UIView *proccesView;
	UIActivityIndicatorView *indicator;
    id delegate;
	BOOL isSearch;
}

-(void)setDelegateAndCategory:(id)Adelegate forCategory:(NSString*)Acategory;
@property(nonatomic,copy)NSString* title;

@end
