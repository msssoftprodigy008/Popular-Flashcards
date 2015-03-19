//
//  FImportSet.h
//  flashCards
//
//  Created by Руслан Руслан on 2/22/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol FImportSetDelegate
@optional
-(void)importFinished:(BOOL)result forCat:(NSString*)cat;
-(void)recivedCards:(NSArray*)cards;
-(void)justForget;
-(void)dataContentLen:(NSInteger)cL;
-(void)dataRecived:(NSInteger)len;
@end


@interface FImportSet : NSObject {
	id delegate;
	NSString *currentSet;
	NSString *resultingString;
	NSMutableData *curData;
	NSURLConnection *connection;
	NSMutableArray *indexes;
	NSMutableDictionary *setToImport;
	BOOL isAddSet;
	BOOL isReversed;
}

-(id)initWithDelegate:(id)Adelegate;
-(void)importWithFileName:(NSString*)Aname forId:(NSString*)idStr withAdd:(BOOL)add;
-(void)addArrToCategory:(NSString*)category forArr:(NSArray*)set forRev:(BOOL)isRev;
-(void)cancelDownload;
@end
