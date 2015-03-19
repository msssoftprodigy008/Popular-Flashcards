//
//  FDefinitionController.h
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FAxilDefUtil.h"
#import "Constants.h"

@protocol FDefinitionControllerDelegate
@optional
-(void)definitionsForTerm:(NSString*)Aterm forDef:(NSArray*)definitions whichDef:(NSInteger)whatDef;
-(void)audioForTerm:(NSMutableArray*)audioArr;
-(void)flickerRespForTerm:(NSDictionary*)flicDic;
-(void)bingRespForTerm:(NSMutableArray*)imageArr;
-(void)definitionFailed;
@end





@interface FDefinitionController : NSObject<FAxilSpelDelegate,NSURLConnectionDataDelegate> {
	NSURLConnection *connection;
	NSMutableData *currentData;
	NSInteger curMode;
	NSInteger lastStatusCode;
	wordnikAPI wordnikMode;

    
    
}




+(id)sharedDefinitionWithDelegate:(id)Adelegate;
-(void)getDefinitionForTerm:(NSString*)term forWhich:(NSInteger)what;
-(void)getAudioForTerm:(NSString*)term;
-(void)getFlickerForTerm:(NSString*)term  forPage:(NSInteger)page;
-(void)getBingForTerm:(NSString*)term forImageNum:(NSInteger)imageNum;

-(void)cancelOperation;
@end
