//
//  QIRequest.h
//  flashCards
//
//  Created by Ruslan on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QIRequest;

typedef enum{
    QIRequestTypeLogin,
    QIRequestTypeUser,
    QIRequestTypeSearchGroup,
    QIRequestTypeSearchSet,
    QIRequestTypeGroupSet,
    QIRequestTypeSetCards,
    QIRequestTypeAddSet,
    QIRequestTypeImageUpload
}QIRequestType;

typedef enum{
    QISetTypeCreator,
    QISetTypeTerm,
    QISetTypeSubject
}QISetType;

@protocol QIRequestDelegate <NSObject>
@optional
-(void)qiLoginSucceed:(QIRequest*)request user_id:(NSString*)user;
-(void)qiLogoutSucceed:(QIRequest*)request;
-(void)qiLoginFailed:(QIRequest*)request canceled:(BOOL)isCanceled;
-(void)qiRequestFailed:(QIRequest*)request error:(NSDictionary*)errorInfo;

-(void)qiUserInfo:(QIRequest*)request info:(NSDictionary*)info;

-(void)qiGroupFind:(QIRequest*)request group:(NSDictionary*)group;
-(void)qiSetFind:(QIRequest*)request set:(NSDictionary*)set;
-(void)qiGroupSet:(QIRequest*)request set:(NSArray*)set;
-(void)qiSetCards:(QIRequest*)request cards:(NSDictionary*)cards;
-(void)qiPostCards:(QIRequest*)request;

-(void)qiPostImages:(QIRequest*)request ids:(NSArray*)imagesIDs;

-(void)qiPostLen:(QIRequest*)request length:(NSInteger)len;
-(void)qiPostedLen:(QIRequest*)request length:(NSInteger)len;

@end

@interface QIRequest : NSObject{
    NSURLConnection *_connection;
    NSMutableData *_data;
    NSMutableArray *_imagePaths;
    NSInteger _curImagePos;
    NSMutableArray *_returnImageIDs;
    id<QIRequestDelegate> _delegate;
    QIRequestType _reqType;
}

+(id)sharedRequest;
+(NSMutableDictionary*)parametersForOAuth;
+(NSString*)AuthUrl;
+(void)saveCode:(NSString*)code expTime:(NSDate*)expTime;

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params;

+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod;

+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle;

-(void)cancelFetch;

-(void)login:(id<QIRequestDelegate>)delegate;
-(void)logout:(id<QIRequestDelegate>)delegate;
-(BOOL)isAuthorized;
-(NSString*)userId;
-(NSString*)account;

-(void)fetchUserInfo:(id<QIRequestDelegate>)delegate;
-(void)fetchGroupFind:(NSString*)term delegate:(id<QIRequestDelegate>)delegate page:(NSInteger)page;
-(void)fetchSetFind:(NSString*)term delegate:(id<QIRequestDelegate>)delegate options:(QISetType)setType page:(NSInteger)page;
-(void)fetchSetsForGroup:(id<QIRequestDelegate>)delegate group:(NSString*)groupID page:(NSInteger)page;
-(void)fetchSetCards:(id<QIRequestDelegate>)delegate set:(NSString*)setID;

-(void)fetchImageUpload:(id<QIRequestDelegate>)delegate images:(NSArray*)imagePaths;
-(void)postSet:(id<QIRequestDelegate>)delegate 
         title:(NSString*)title 
         terms:(NSArray*)terms 
           def:(NSArray*)definitions
        images:(NSArray*)images   
         tlang:(NSString*)termLang 
         dlang:(NSString*)defLang;

@end
