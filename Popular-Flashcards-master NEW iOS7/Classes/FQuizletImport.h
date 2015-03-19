//
//  FQuizletImport.h
//  flashCards
//
//  Created by Ruslan on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FQuizletImportDelegate
@optional
-(void)listFormed:(BOOL)isSucces forData:(NSDictionary*)dic forError:(NSString*)errorMsg;
@end


@interface FQuizletImport : NSObject {
	
	NSMutableData *downloadingData;
	NSURLConnection *connection;	
	id delegate;
	
}

-(id)initWithDelegate:(id)Adelegate;
-(void)setDelegate:(id)Adelegate;

-(void)findByTerm:(NSString*)term sortBy:(NSInteger)sort pages:(NSInteger)pageNum;
-(void)findByCreator:(NSString*)creator sortBy:(NSInteger)sort pages:(NSInteger)pageNum;
-(void)findBySubject:(NSString*)subject sortBy:(NSInteger)sort pages:(NSInteger)pageNum;
-(void)cancel;

@property(nonatomic,retain)id delegate;

@end
