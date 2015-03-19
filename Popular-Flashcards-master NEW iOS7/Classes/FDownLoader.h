//
//  FDownLoader.h
//  flashCards
//
//  Created by Ruslan on 6/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol FDownloaderDelegate
@optional

-(void)downloadedDataRecived:(NSData*)downloadedData;
-(void)downloadingFinished:(BOOL)result;
-(void)downloadingDidFailed:(NSString*)url;

@end


@interface FDownLoader : NSObject {
	NSURLConnection *currConnection;
	NSMutableData *currData;
	
}

+(FDownLoader*)sharedDownloader:(id)Adelegate;
-(void)addToDowload:(NSArray*)urls;
-(void)download:(NSArray*)urls;
-(void)stopDownloading;
-(BOOL)continueDownloading;
-(void)cancelDownloading;
-(BOOL)isDownloading;
-(void)cleanDownloader;
@end
