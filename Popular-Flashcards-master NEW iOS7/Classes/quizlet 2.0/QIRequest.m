//
//  QIRequest.m
//  flashCards
//
//  Created by Ruslan on 10/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QIRequest.h"
#import "JSON.h"
#import "UIImage+Resize.h"
#import "Util.h"

//#define kClientId @"4ujbB4kPCT"
//#define kSecretToken @"pOF8IbxQtER.NmLqtX9BPg"
#define kClientId @"iicmvavd0wocw0os"
#define kSecretToken @"unXh21i.s.mxxeZrG3JiXw"
#define kScope @"read write_set write_group"

#define kRedirUrl @"fcads:"

static QIRequest *sharedQIInstance = nil;

@interface QIRequest(Private)
-(void)notifyDelegateWithError:(NSString*)error;
-(NSMutableURLRequest*)requestToUploadImages:(NSString*)url fileName:(NSArray*)fileNames;
-(void)nextImageUpload;

@end

@implementation QIRequest

#pragma mark main methods

+(id)sharedRequest{
    if (!sharedQIInstance) {
        sharedQIInstance = [[QIRequest alloc] init];
    }
    
    return sharedQIInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)dealloc{
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    
    if (_data) {
        [_data release];
        _data = nil;
    }
    
    if (_imagePaths) {
        [_imagePaths release];
        _imagePaths = nil;
    }
    
    if (_returnImageIDs) {
        [_returnImageIDs release];
        _returnImageIDs = nil;
    }
    
    [super dealloc];
    
}


+(NSMutableDictionary*)parametersForOAuth{
    
    NSString* uniqueIdentifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) { // >=iOS 7
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else { //<=iOS6, Use UDID of Device
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
        uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
        CFRelease(uuid);
    }
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"code",@"response_type",
     kScope,@"scope",
     uniqueIdentifier,@"state",
     kClientId,@"client_id",
     kRedirUrl,@"redirect_uri",nil];
    
    /*return [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"code",@"response_type",
     kScope,@"scope",
     [UIDevice currentDevice].uniqueIdentifier,@"state",
     kClientId,@"client_id",
     kRedirUrl,@"redirect_uri",nil];*/
//    return nil;
}
+(NSString*)AuthUrl{
    return @"https://quizlet.com/authorize/";
}

+(void)saveCode:(NSString*)code expTime:(NSDate*)expTime{
    if (code) {
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"QICode"];
    }
    if (expTime) {
        [[NSUserDefaults standardUserDefaults] setObject:expTime forKey:@"QIExpDate"];
    }
    
}

+ (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params {
    return [self serializeURL:baseUrl params:params httpMethod:@"GET"];
}

/**
 * Generate get URL
 */
+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod {
    
    NSURL* parsedURL = [NSURL URLWithString:baseUrl];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]])
            ||([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            if ([httpMethod isEqualToString:@"GET"]) {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

+ (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return str;
}

#pragma mark -

#pragma mark system

-(void)cancelFetch{
    if (_connection) {
        [_connection cancel];
        [_connection release];
        _connection = nil;
    }
    
    if (_data) {
        [_data release];
        _data = nil;
    }
    
    _delegate = nil;
    
    if (_returnImageIDs) {
        [_returnImageIDs release];
        _returnImageIDs = nil;
    }
    if (_imagePaths) {
        [_imagePaths release];
        _imagePaths = nil;
    }
    
}

#pragma mark -

#pragma mark Auth

-(void)login:(id<QIRequestDelegate>)delegate{
    _reqType = QIRequestTypeLogin;
    _delegate = delegate;
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:@"QICode"];
    if (!code) {
        [self notifyDelegateWithError:@"code not found"];
        return;
    }
    
    NSString *urlStr = @"https://api.quizlet.com/oauth/token";
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"authorization_code",@"grant_type",
                                       code,@"code",
                                       kRedirUrl,@"redirect_uri",
                                       kClientId,@"client_id",
                                       kSecretToken,@"client_secret",
                                       kScope,@"scope",nil];
    urlStr = [QIRequest serializeURL:urlStr params:parameters httpMethod:@"POST"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSLog(@"%@",urlStr);
    if (!url) {
        [self notifyDelegateWithError:@"url for login not valid"];
        return;
    }
    
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    
    if (_data) {
        [_data release];
    }
    
    _data = [[NSMutableData alloc] init];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30.0];
    [request setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)logout:(id<QIRequestDelegate>)delegate{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QIToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QITokenExpTime"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QIUser_id"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QICode"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"QIAccount"];
    NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray* facebookCookies = [cookies cookiesForURL:
                                [NSURL URLWithString:[QIRequest AuthUrl]]];
    
    for (NSHTTPCookie* cookie in facebookCookies) {
        [cookies deleteCookie:cookie];
    }
    
    if (delegate && [delegate respondsToSelector:@selector(qiLogoutSucceed:)]) {
        [delegate qiLogoutSucceed:self];
    }
}

-(BOOL)isAuthorized{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"QITokenExpDate"];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"] && date && [[date laterDate:[NSDate date]] isEqualToDate:date]) {
        return YES;
    }
    return NO;
}

-(NSString*)userId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"QIUser_id"];
}

-(NSString*)account{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"QIAccount"];
}

#pragma mark -

#pragma mark User

-(void)fetchUserInfo:(id<QIRequestDelegate>)delegate{
    _reqType = QIRequestTypeUser;
    _delegate = delegate;
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    if (![self isAuthorized]) {
        [self notifyDelegateWithError:@"Access denied, please authorize"];
        return;
    }
    
    NSString *userId = [self userId];
    if (!userId) {
        [self notifyDelegateWithError:@"User id not found"];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"https://api.quizlet.com/2.0/users/%@",userId];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (![self isAuthorized]) {
        [params setObject:kClientId forKey:@"client_id"];
    }
    urlStr = [QIRequest serializeURL:urlStr params:params];
    NSLog(@"%@",urlStr);
    if (_data) {
        [_data release];
    }
    
    _data = [[NSMutableData alloc] init];
    
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setTimeoutInterval:30];
    if ([self isAuthorized]) {
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

#pragma mark -

#pragma mark search

-(void)fetchGroupFind:(NSString*)term delegate:(id<QIRequestDelegate>)delegate page:(NSInteger)page{
    _delegate = delegate;
    if (!term) {
        [self notifyDelegateWithError:@"Empty term"];
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    _reqType = QIRequestTypeSearchGroup;
    NSString *urlString = @"https://api.quizlet.com/2.0/search/groups";
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:term,@"q",
                                  [NSString stringWithFormat:@"%d",page],@"page",nil];
    if (![self isAuthorized]) {
        [param setObject:kClientId forKey:@"client_id"];
    }
    NSURL *url = [NSURL URLWithString:[QIRequest serializeURL:urlString params:param]];
    if (_data) {
        [_data release];
    }
    _data = [[NSMutableData alloc] init];
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    if ([self isAuthorized]) {
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

-(void)fetchSetFind:(NSString*)term delegate:(id<QIRequestDelegate>)delegate options:(QISetType)setType page:(NSInteger)page{
    _delegate = delegate;
    if (!term) {
        [self notifyDelegateWithError:@"Empty term"];
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    _reqType = QIRequestTypeSearchSet;
    NSString *urlString = @"https://api.quizlet.com/2.0/search/sets";
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"most_studied",@"sort",
                                  [NSString stringWithFormat:@"%d",page],@"page",nil];
    if (![self isAuthorized]) {
        [param setObject:kClientId forKey:@"client_id"];
    }
    switch (setType) {
        case QISetTypeCreator:
            [param setObject:term forKey:@"creator"];
            break;
        case QISetTypeTerm:
            [param setObject:term forKey:@"term"];
            break;
        case QISetTypeSubject:
            [param setObject:term forKey:@"q"];
            break;
        default:
            break;
    }
    
    NSURL *url = [NSURL URLWithString:[QIRequest serializeURL:urlString params:param]];
    if (_data) {
        [_data release];
    }
    _data = [[NSMutableData alloc] init];
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    if ([self isAuthorized]) {
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)fetchSetsForGroup:(id<QIRequestDelegate>)delegate group:(NSString*)groupID page:(NSInteger)page{
    _delegate = delegate;
    if (!groupID) {
        [self notifyDelegateWithError:@"Group id is empty."];
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"https://api.quizlet.com/2.0/groups/%@/sets",groupID];
    _reqType = QIRequestTypeGroupSet;
    
  
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"most_studied",@"sort",
                                  [NSString stringWithFormat:@"%d",page],@"page",nil];
    if (![self isAuthorized]) {
        [param setObject:kClientId forKey:@"client_id"];
    }
    NSLog(@"%@",[QIRequest serializeURL:urlStr params:param]);
    NSURL *url = [NSURL URLWithString:[QIRequest serializeURL:urlStr params:param]];
    if (_data) {
        [_data release];
    }
    _data = [[NSMutableData alloc] init];
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    if ([self isAuthorized]) {
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)fetchSetCards:(id<QIRequestDelegate>)delegate set:(NSString*)setID{
    _delegate = delegate;
    if (!setID) {
        [self notifyDelegateWithError:@"Set id is empty."];
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"https://api.quizlet.com/2.0/sets/%@",setID];
    _reqType = QIRequestTypeSetCards;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (![self isAuthorized]) {
        [param setObject:kClientId forKey:@"client_id"];
    }
    NSURL *url = [NSURL URLWithString:[QIRequest serializeURL:urlStr params:param]];
    if (_data) {
        [_data release];
    }
    _data = [[NSMutableData alloc] init];
    if (_connection) {
        [_connection cancel];
        [_connection release];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    if ([self isAuthorized]) {
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark -

#pragma mark post

-(void)fetchImageUpload:(id<QIRequestDelegate>)delegate images:(NSArray*)imagePaths{
    _delegate = delegate;
    if (![[QIRequest sharedRequest] isAuthorized]) {
        NSLog(@"You should be authorized to upload set");
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    if (_imagePaths) {
        [_imagePaths removeAllObjects];
    }else{
        _imagePaths = [[NSMutableArray alloc] init];
    }
    [_imagePaths addObjectsFromArray:imagePaths];
    if (_returnImageIDs) {
        [_returnImageIDs removeAllObjects];
    }else{
        _returnImageIDs = [[NSMutableArray alloc] init];
    }
    _curImagePos = 0;
    
    [self nextImageUpload];
}

-(void)nextImageUpload{
    if (_imagePaths && _curImagePos<[_imagePaths count]) {
        _reqType = QIRequestTypeImageUpload;
        NSString *urlStr = @"https://api.quizlet.com/2.0/images";
        if (_data) {
            [_data release];
        }
        _data = [[NSMutableData alloc] init];
        
        if (_connection) {
            [_connection cancel];
            [_connection release];
        }
        NSMutableURLRequest *request = [self requestToUploadImages:urlStr  fileName:_imagePaths];
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
        [request setTimeoutInterval:30];
        if (_delegate && [_delegate respondsToSelector:@selector(qiPostLen:length:)]) {
            [_delegate qiPostLen:self length:[[request HTTPBody] length]];
        }
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(NSMutableURLRequest*)requestToUploadImages:(NSString*)url fileName:(NSArray*)fileNames{
    NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] init] autorelease];
    [urlRequest setURL:[NSURL URLWithString:url]];
    [urlRequest setHTTPMethod:@"POST"];
    NSString *myboundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",myboundary];
    [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postData = [NSMutableData data];
    NSInteger size = 0;
    NSInteger from = _curImagePos;
    NSInteger to = [fileNames count];
    for (int i = from;i<to;i++) {
        NSString *imPath = [fileNames objectAtIndex:i];
        UIImage *image = [UIImage imageWithContentsOfFile:imPath];
        if (image) {
            if (image.size.width>500) {
                image = [image resizedImage:CGSizeMake(500, image.size.height*500/image.size.width) interpolationQuality:kCGInterpolationDefault];
            }
            
            if (image.size.height>500) {
                image = [image resizedImage:CGSizeMake(image.size.width*500/image.size.height, 500) interpolationQuality:kCGInterpolationDefault];
            }
            
            NSData *imageData = UIImagePNGRepresentation(image);
            size+=[imageData length];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"imageData[]\"; filename=\"%@\"\r\n", fileNames]dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[NSData dataWithData:imageData]];
        }
        _curImagePos++;
        if (size>15*1024*1024) {
            NSLog(@"first part");
            break;
        }
    }
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}

-(void)postSet:(id<QIRequestDelegate>)delegate
         title:(NSString*)title
         terms:(NSArray*)terms
           def:(NSArray*)definitions
        images:(NSArray*)images
         tlang:(NSString*)termLang
         dlang:(NSString*)defLang{
    _delegate = delegate;
    BOOL withImages = NO;
    NSString *acType = [self account];
    if (acType && [acType isEqualToString:@"plus"]) {
        withImages = YES;
    }
    if (![[QIRequest sharedRequest] isAuthorized]) {
        NSLog(@"You should be authorized to upload set");
        return;
    }
    if (![Util connectedToNetwork]) {
        [self notifyDelegateWithError:@"Please, check internet connection and try again."];
        return;
    }
    _reqType = QIRequestTypeAddSet;
    NSString *urlStr = @"https://api.quizlet.com/2.0/sets";
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:title,@"title",
                                   kScope,@"scope",
                                   termLang,@"lang_terms",
                                   defLang,@"lang_definitions",nil];
    NSString *paramString = [NSString stringWithString:@""];
    for (NSString* key in [params keyEnumerator]) {
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        if (![paramString isEqualToString:@""]) {
            paramString = [paramString stringByAppendingFormat:@"&%@=%@",key,escaped_value];
        }else{
            paramString = [paramString stringByAppendingFormat:@"%@=%@",key,escaped_value];
        }
        
        [escaped_value release];
    }
    
    for (int i=0;i<[terms count];i++) {
        NSString* escaped_value1 = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                       NULL, /* allocator */
                                                                                       (CFStringRef)[terms objectAtIndex:i],
                                                                                       NULL, /* charactersToLeaveUnescaped */
                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                       kCFStringEncodingUTF8);
        NSString* escaped_value2 = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                       NULL, /* allocator */
                                                                                       (CFStringRef)[definitions objectAtIndex:i],
                                                                                       NULL, /* charactersToLeaveUnescaped */
                                                                                       (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                       kCFStringEncodingUTF8);
        
        
        paramString = [paramString stringByAppendingFormat:@"&terms[]=%@",escaped_value1];
        paramString = [paramString stringByAppendingFormat:@"&definitions[]=%@",escaped_value2];
        if (withImages) {
            paramString = [paramString stringByAppendingFormat:@"&images[]=%@",[images objectAtIndex:i]];
        }
        
        [escaped_value1 release];
        [escaped_value2 release];
    }
    NSLog(@"%@",paramString);
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
        [request addValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"QIToken"]] forHTTPHeaderField:@"Authorization"];
        
        if (_data) {
            [_data release];
        }
        if (_connection) {
            [_connection cancel];
            [_connection release];
        }
        _data = [[NSMutableData alloc] init];
        if (_delegate && [_delegate respondsToSelector:@selector(qiPostLen:length:)]) {
            [_delegate qiPostLen:self length:[[request HTTPBody] length]];
        }
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    
}

#pragma mark -

#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    
	NSLog(@"Did recieve response");


}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
    if (_reqType == QIRequestTypeImageUpload || _reqType == QIRequestTypeAddSet) {
        if (_delegate && [_delegate respondsToSelector:@selector(qiPostedLen:length:)]) {
            [_delegate qiPostedLen:self length:totalBytesWritten];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	if (error) {
        [self notifyDelegateWithError:[error localizedDescription]];
    }else{
        [self notifyDelegateWithError:@"request failed"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
	NSString *jsonStr = [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
    
    if (_data) {
        [_data release];
        _data = nil;
    }
    
    if (_connection) {
        [_connection release];
        _connection = nil;
    }
    
    if (jsonStr) {
        NSLog(@"%@",jsonStr);
        if (_reqType == QIRequestTypeLogin) {
            NSDictionary *tokenDic = [jsonStr JSONValue];
            if ([tokenDic objectForKey:@"access_token"]) {
                NSString *accesToken = [tokenDic objectForKey:@"access_token"];
                NSLog(@"%@ token",accesToken);
                [[NSUserDefaults standardUserDefaults] setObject:accesToken forKey:@"QIToken"];
                if ([tokenDic objectForKey:@"expires_in"]) {
                    NSInteger expIn = [[tokenDic objectForKey:@"expires_in"] intValue];
                    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:expIn];
                    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"QITokenExpDate"];
                }
                
                NSString *userName = [tokenDic objectForKey:@"user_id"];
                if (userName) {
                    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"QIUser_id"];
                    if (_delegate && [_delegate respondsToSelector:@selector(qiLoginSucceed:user_id:)]) {
                        [_delegate qiLoginSucceed:self user_id:userName];
                    }
                }
                
            }else if([tokenDic objectForKey:@"error"]){
                NSString *error = [tokenDic objectForKey:@"error_description"];
                [self notifyDelegateWithError:error];
            }else{
                [self notifyDelegateWithError:@"Unknown error"];
            }
        }else if(_reqType == QIRequestTypeUser){
            NSDictionary *tokenDic = [jsonStr JSONValue];
            NSString *acType = [tokenDic objectForKey:@"account_type"];
            if (acType) {
                [[NSUserDefaults standardUserDefaults] setObject:acType forKey:@"QIAccount"];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(qiUserInfo:info:)]) {
                [_delegate qiUserInfo:self info:tokenDic];
            }
        }else if(_reqType == QIRequestTypeSearchSet){
            NSDictionary *setDic = [jsonStr JSONValue];
            if ([setDic objectForKey:@"error"]) {
                NSString *error = [setDic objectForKey:@"error_description"];
                [self notifyDelegateWithError:error];
            }else{
                if (_delegate && [_delegate respondsToSelector:@selector(qiSetFind:set:)]) {
                    [_delegate qiSetFind:self set:setDic];
                }
            }
        }else if(_reqType == QIRequestTypeSearchGroup){
            NSDictionary *groupDic = [jsonStr JSONValue];
            if ([groupDic objectForKey:@"error"]) {
                NSString *error = [groupDic objectForKey:@"error_description"];
                [self notifyDelegateWithError:error];
            }else{
                NSNumber *totalRes = [groupDic objectForKey:@"total_results"];
                if (totalRes && [totalRes intValue]>0) {
                    if (_delegate && [_delegate respondsToSelector:@selector(qiGroupFind:group:)]) {
                        [_delegate qiGroupFind:self group:groupDic];
                    }
                }else{
                    NSString *error = @"Your search - did not match any flashcard groups on Quizlet. Please try again with a different search.";
                    [self notifyDelegateWithError:error];
                }
                
            }
            
        }else if(_reqType == QIRequestTypeGroupSet){
            id sets = [jsonStr JSONValue];
            if ([sets isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errorDic = (NSDictionary*)sets;
                if ([errorDic objectForKey:@"error"]) {
                    NSString *error = [errorDic objectForKey:@"error_description"];
                    [self notifyDelegateWithError:error];
                }else{
                    [self notifyDelegateWithError:@"error"];
                }
            }else{
                if (_delegate && [_delegate respondsToSelector:@selector(qiGroupSet:set:)]) {
                    [_delegate qiGroupSet:self set:(NSArray*)sets];
                }
            }
        }else if(_reqType == QIRequestTypeSetCards){
            NSDictionary *set = [jsonStr JSONValue];
            if (_delegate && [_delegate respondsToSelector:@selector(qiSetCards:cards:)]) {
                [_delegate qiSetCards:self cards:set];
            }
        }else if(_reqType == QIRequestTypeAddSet){
            NSDictionary *set = [jsonStr JSONValue];
            if ([set objectForKey:@"error"]) {
                NSString *error = [set objectForKey:@"error_description"];
                [self notifyDelegateWithError:error];
            }else{
                if (_delegate && [_delegate respondsToSelector:@selector(qiPostCards:)]) {
                    [_delegate qiPostCards:self];
                }
            }
        }else if(_reqType == QIRequestTypeImageUpload){
            id result = [jsonStr JSONValue];
            if ([result isKindOfClass:[NSDictionary class]]) {
                NSDictionary *errorDic = (NSDictionary*)result;
                if ([errorDic objectForKey:@"error"]) {
                    NSString *error = [errorDic objectForKey:@"error_description"];
                    [self notifyDelegateWithError:error];
                }else{
                    [self notifyDelegateWithError:@"error"];
                }
            }else{
                if (_returnImageIDs) {
                    [_returnImageIDs addObjectsFromArray:result];
                    if (_curImagePos>=[_imagePaths count]) {
                        if (_delegate && [_delegate respondsToSelector:@selector(qiPostImages:ids:)]) {
                            [_delegate qiPostImages:self ids:_returnImageIDs];
                        }
                    }else{
                        [self nextImageUpload];
                    }
                }
            }
        }
        
        [jsonStr release];
    }
    
    
}


#pragma mark -

#pragma mark private

-(void)notifyDelegateWithError:(NSString*)error{
    if (_delegate && [_delegate respondsToSelector:@selector(qiRequestFailed:error:)]) {
        if (error) {
            [_delegate qiRequestFailed:self error:[NSDictionary dictionaryWithObjectsAndKeys:error,@"errorMsg", nil]];
        }else{
            [_delegate qiRequestFailed:self error:[NSDictionary dictionaryWithObjectsAndKeys:@"error",@"errorMsg", nil]];
        }
        
    }
}

#pragma mark -

@end
