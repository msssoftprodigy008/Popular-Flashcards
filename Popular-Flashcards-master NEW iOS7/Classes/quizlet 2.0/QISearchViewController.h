//
//  QISearchViewController.h
//  flashCards
//
//  Created by Ruslan on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QIRequest.h"
#import "FCustomSegmentedController.h"
#import "FISearchBar.h"
//#import "FILoadingView.h"
typedef enum{
    QISearchTypeGroup,
    QISearchTypeSets
}QISearchType;



@interface QISearchViewController : UIViewController<QIRequestDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>{
    FISearchBar *_searchBar;
    UITableView *_searchTableView;
    QISearchType _searchType;
    NSString *searchString;
    NSMutableDictionary *_content;
    NSMutableArray *_contentArr;
    QISetType _setType;
    BOOL _shouldReloadTable;
    
    //FILoadingView *loadingView;

}

@property(nonatomic,copy)NSString* searchString;

-(id)initWithType:(QISearchType)type;
-(void)setArray:(NSArray*)array;


@end
