//
//  FDefinitionController.m
//  flashCards
//
//  Created by Ruslan on 7/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#define RESULT_SIZE 8

#import "FDefinitionController.h"
#import "FHTMLConverter.h"
#import "ModalAlert.h"
#import "JSON.h"
#import "FILoadingView.h"
//#define k_key_id @"8ef8aad0150489e8f22080b1bb80c9d9b9e92568c95983d62"
//#define kFlicker_key @"1c2b73e896ec3cc2f4d1426933c5339a"

//#define k_key_id @"779ee2468ec91b990368bd4f848b4f2b"
#define k_key_id @"a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5"
#define kFlicker_key @"779ee2468ec91b990368bd4f848b4f2b"



//#define kBingApi_key @"341F1AB488ABC170D3ED233B33E033D79AFFF7AD"

#define kBingApi_key @"aOT8wzwQnK/N4v8hy1PqrDoCRmAr1/bvBFY42UVcGgk"

FDefinitionController* shDef = nil;
id Defdelegate = nil;

@interface FDefinitionController(Private)


-(void)parseJSONDef:(NSString*)JSONStr;
-(void)parseJSONPhr:(NSString*)JSONStr;
-(void)parseJSONExm:(NSString*)JSONStr;
-(void)parseJSONRel:(NSString*)JSONStr;
-(void)parseJSONAudio:(NSString*)JSONStr;
-(void)parseJSONFlick:(NSString*)JSONStr;
-(void)parseJSONBing:(NSString*)JSONStr;

@end



@implementation FDefinitionController





+(id)sharedDefinitionWithDelegate:(id)Adelegate
{
	if (!shDef) {
		shDef = [[FDefinitionController alloc] init];
	}
	
	Defdelegate = Adelegate;
	return shDef;
}

-(void)cancelOperation
{
	[[FAxilDefUtil sharedWordSpel:self] cancelAllOperations];
	
	if (connection) {
		[connection cancel];
		[connection release];
		connection = nil;
	}
	
	if (currentData) {
		[currentData release];
		currentData = nil;
	}
	curMode = -1;
	Defdelegate = nil;
	
	
}

-(void)getDefinitionForTerm:(NSString*)term forWhich:(NSInteger)what
{
	if (!term) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	wordnikMode = wordnikAPIDefinition;
	curMode = what;
	[[FAxilDefUtil sharedWordSpel:self] trueWordSpel:term];
}

-(void)getAudioForTerm:(NSString*)term
{
	if (!term) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	wordnikMode = wordnikAPIAudio;
	[[FAxilDefUtil sharedWordSpel:self] trueWordSpel:term];
}

-(void)getFlickerForTerm:(NSString*)term forPage:(NSInteger)page
{
	if (!term) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	wordnikMode = flickerAPI;
	
	NSString *urlStr = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&text=%@&per_page=9&page=%d&format=json",kFlicker_key,term,page];
	urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlStr];
	
	if (url) {
		if (connection) {
			[connection cancel];
			[connection release];
		}	
	
		if (currentData) {
			[currentData release];
			currentData = nil;
		}
		lastStatusCode = -1;
		connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:shDef];
		currentData = [[NSMutableData alloc] init];
	}else {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
	}

	
}


-(void)getBingForTerm:(NSString*)term forImageNum:(NSInteger)imageNum
{
	if (!term) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	wordnikMode = bingAPI;
//	https://api.datamarket.azure.com/Bing/Search/v1/json.aspx?Appid=0aXKSpJRylIbTQm9oonQC2cMYgfayZyr7KbuiM3Md5g=&query='Nature'&sources=image&Image.Count=10&Image.Offset=0
//	NSString *urlStr = [NSString stringWithFormat:@"http://api.search.live.net/json.aspx?Appid=%@&query=%@&sources=image&Image.Count=%d&Image.Offset=0",
//						kBingApi_key,
//						term,
//						imageNum];
    //http://api.bing.net/json.aspx?AppId=Insert your AppId here&Query=xbox%20site:microsoft.com&Sources=Image&Version=2.0&Market=en-us&Adult=Moderate&Image.Count=10&Image.Offset=0&JsonType=callback&JsonCallback=SearchCompleted
 
   
   // NSString *urlStr = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8&imgsz=medium",term];
  
    
    NSString *urlStr = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&resultFormat=text&start=%D&rsz=%D", [term stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], imageNum, RESULT_SIZE];// its working sanjeev reddy
    
                                    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    
	if (url) {
		if (connection) {
			[connection cancel];
			[connection release];
		}	
		
		if (currentData) {
			[currentData release];
			currentData = nil;
		}
		lastStatusCode = -1;
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:shDef];
		currentData = [[NSMutableData alloc] init];
	}else {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
	}
        
    
    
}

#pragma mark -
#pragma mark axilSpelDelegate

-(void)spellingWord:(NSString*)term
{
	if (!term) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}


		NSString *parStr = [NSString stringWithString:term];
		parStr = [parStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *urlStr;
	
		if (wordnikMode == wordnikAPIDefinition) {
			switch (curMode) {
				case 0:
//       urlStr = [NSString stringWithFormat:@" http://api.wordnik.com/v4/word.json/%@/definitions",parStr];
                
                    urlStr = [NSString stringWithFormat:@"http://api.wordnik.com:80/v4/word.json/%@/definitions?limit=200&includeRelated=true&useCanonical=false&includeTags=false",parStr];// its working sanjeev reddy

                 
					break;
				case 1:
//					urlStr = [NSString stringWithFormat:@"http://api.wordnik.com/v4/word.json/%@/phrases",parStr];
                    urlStr = [NSString stringWithFormat:@"http://api.wordnik.com:80/v4/word.json/%@/phrases?limit=5&wlmi=0&useCanonical=false",parStr];// its working sanjeev reddy

					break;
				case 2:
//					urlStr = [NSString stringWithFormat:@"http://api.wordnik.com/v4/word.json/%@/examples",parStr];
                    urlStr = [NSString stringWithFormat:@"http://api.wordnik.com:80/v4/word.json/%@/examples?includeDuplicates=false&useCanonical=false&skip=0&limit=5",parStr];
					break;
				case 3:
//					urlStr = [NSString stringWithFormat:@"http://api.wordnik.com/v4/word.json/%@/related",parStr];
                    //urlStr = [NSString stringWithFormat:@"https://www.wordnik.com/words/%@",parStr];
                    
                
                    urlStr = [NSString stringWithFormat:@"http://api.wordnik.com:80/v4/word.json/%@/relatedWords?useCanonical=false&limitPerRelationshipType=10",parStr]; // its working sanjeev reddy

					break;
			
				default:
					break;
			}
		}else {
          //  http://api.wordnik.com:80/v4/word.json/home/audio?useCanonical=false&limit=50&api_key=a2a73e7b926c924fad7001ca3111acd55af2ffabf50eb4ae5
			//urlStr = [NSString stringWithFormat:@"http://api.wordnik.com/v4/word.json/%@/audio",parStr];
           
            
            urlStr = [NSString stringWithFormat:@"http://api.wordnik.com:80/v4/word.json/%@/audio?useCanonical=false&limit=50",parStr];   ///hurrayyyyy its working sanjeev reddy
           
            
            
            // urlStr = [NSString stringWithFormat:@"https://www.wordnik.com/words/%@",parStr];

		}

	
		NSURL	*url = [NSURL URLWithString:urlStr];
    NSLog(@"url for word definition ,phrase %@",url);
	
		if (!url) {
			if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
				[Defdelegate definitionFailed];
			}
			return;
		}
	
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
		if (!request) {
			if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
				[Defdelegate definitionFailed];
			}
			return;
		}
	
		NSDictionary *header = [NSDictionary dictionaryWithObject:k_key_id forKey:@"api_key"];
	
		if (!header) {
			if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
				[Defdelegate definitionFailed];
			}
			return;
		}
	
		[request setAllHTTPHeaderFields:header];
       //NSLog(@"url for word definition ,phrase request %@",request);

	
		if (connection) {
			[connection cancel];
			[connection release];
		}
	
		if (currentData) {
			[currentData release];
			currentData = nil;
		}
		lastStatusCode = -1;
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:shDef];
		currentData = [[NSMutableData alloc] init];
	

}

-(void)spellingFailed
{
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
		[Defdelegate definitionFailed];
	}
}

#pragma mark -
#pragma mark NSURLConnection methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *Aresponse = (NSHTTPURLResponse *)response;
        lastStatusCode = [Aresponse statusCode];
		NSLog(@"Status code: %d",lastStatusCode);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if (currentData)
        [currentData appendData:data];
	
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if (error) 
		NSLog(@"%@",[error description]);
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
		[Defdelegate definitionFailed];
	}
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	
	
    NSMutableString *JSONstr ;//= [NSMutableString string];

    JSONstr = [[NSMutableString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
 
    if (JSONstr && lastStatusCode!=404) {
		//NSLog(@"%@",JSONstr);
        
		if (wordnikMode == wordnikAPIDefinition) {
			if (curMode<0) {
				return;
			}
            NSLog(@"%@",JSONstr);
			switch (curMode) {
				case 0:
					[self parseJSONDef:JSONstr];
					break;
				case 1:
					[self parseJSONPhr:JSONstr];
					break;
				case 2:
					[self parseJSONExm:JSONstr];
					break;
				case 3:
					[self parseJSONRel:JSONstr];
					break;
				default:
					break;
			}
		}else if (wordnikMode == wordnikAPIAudio) {
				[self parseJSONAudio:JSONstr];
			}else if (wordnikMode == flickerAPI) {
						[self parseJSONFlick:JSONstr];
				}else if (wordnikMode == bingAPI) {
					[self parseJSONBing:JSONstr];
				}

		
	}
	else {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
	}
	
	if (JSONstr) {
		[JSONstr release];
		JSONstr = nil;
	}
	
}

#pragma mark -
#pragma mark private methods

-(void)parseJSONDef:(NSString*)JSONStr
{
 
    NSMutableArray *returnDef = [NSMutableArray array];
    //NSArray *definitions = [[JSONStr JSONValue]objectForKey:@"title"];
	NSArray *definitions = [JSONStr JSONValue];
	
	if (!definitions) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	
	for (NSDictionary *def in definitions) {
		
		//get text value
		NSString *text = [def valueForKey:@"text"];
		
		if (text) {
			FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:text];
			NSString *resultStr = [NSString stringWithUTF8String:[str UTF8String]];
            [convert release];
            [str release];
            NSString *attributionText = [def valueForKey:@"attributionText"];
            if (attributionText) {
                FHTMLConverter* aconvert = [[FHTMLConverter alloc] init];
                NSString* astr = [aconvert convertEntiesInString:attributionText];
                resultStr = [resultStr stringByAppendingFormat:@"\n\n%@",astr];
                [aconvert release];
                [astr release];
            }
			[returnDef addObject:resultStr];
		}
		
		//get notes
		NSArray *notes = [def objectForKey:@"notes"];
		
		if (notes) {
			
			for (NSDictionary *noteDic in notes) {
							
				NSString *note = [noteDic objectForKey:@"value"];
				
				if (note) {
					FHTMLConverter *convert = [[FHTMLConverter alloc] init];
                    NSString *str = [convert convertEntiesInString:note];
					NSString *resultStr = [NSString stringWithUTF8String:[str UTF8String]];
					[convert release];
                    [str release];
					[returnDef addObject:resultStr];
				}
			}
		}
		
		//get sources
		NSArray *cit = [def objectForKey:@"citations"];
		
		if (cit) {
			
			for (NSDictionary *citations in cit) {
				NSString *source = [citations objectForKey:@"source"];
				NSString *cite = [citations objectForKey:@"cite"];
			
				if (source) {
					FHTMLConverter *convert = [[FHTMLConverter alloc] init];
                    NSString *str = [convert convertEntiesInString:source];
					source = [NSString stringWithUTF8String:[str UTF8String]];
					[convert release];
                    [str release];
				}
			
				if (cite) {
					FHTMLConverter *convert = [[FHTMLConverter alloc] init];
                    NSString *str = [convert convertEntiesInString:cite];
					cite = [NSString stringWithUTF8String:[str UTF8String]];
					[convert release];
                    [str release];
				}
			
				if (cite && source) {
					NSString *result = [NSString stringWithUTF8String:[[NSString stringWithFormat:@"%@\n\n%@",cite,source] UTF8String]];
					[returnDef addObject:result];
				}
			}
		}
	}
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionsForTerm:forDef:whichDef:)]) {
		[Defdelegate definitionsForTerm:nil forDef:returnDef whichDef:0];
	}
	
}

-(void)parseJSONPhr:(NSString*)JSONStr
{
	NSMutableArray *returnArr = [NSMutableArray array];
	NSArray *phr = [JSONStr JSONValue];
	
	if (!phr) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	
	for (NSDictionary *phrDic in phr) {
		NSString *phrase1 = [phrDic objectForKey:@"gram1"];
		NSString *phrase2 = [phrDic objectForKey:@"gram2"];
		
		if (phrase1 && phrase2) {
			NSString *resultStr = [NSString stringWithFormat:@"%@ %@",phrase1,phrase2];
			[returnArr addObject:resultStr];
		}
		else {
			if (phrase1) {
				[returnArr addObject:phrase1];
			}
			if (phrase2) 
			{
				[returnArr addObject:phrase2];
			}

		}
	}
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionsForTerm:forDef:whichDef:)]) {
		[Defdelegate definitionsForTerm:nil forDef:returnArr whichDef:1];
	}
	
}

-(void)parseJSONExm:(NSString*)JSONStr
{
	NSMutableArray *returnArr = [NSMutableArray array];
	NSDictionary *examplesDic = [JSONStr JSONValue];
	
	if (!examplesDic) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	
	NSArray *examples = [examplesDic objectForKey:@"examples"];
	
	
	for (NSDictionary *dic in examples) {
		NSString *display = [dic objectForKey:@"text"];
		NSString *title = [dic objectForKey:@"title"];
		NSString *year = [dic objectForKey:@"year"];
        NSDictionary *provider = [dic objectForKey:@"provider"];
        NSString *url = [dic objectForKey:@"url"];
		
		NSString *resultStr = @"";
		
		if (title) {
			FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:title];
			NSString *curStr = [NSString stringWithUTF8String:[str UTF8String]];
			[convert release];
            [str release];
			resultStr = [resultStr stringByAppendingString:curStr];
		}
		
		if (year) {
			FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:year];
			NSString *curStr = [NSString stringWithUTF8String:[str UTF8String]];
			[convert release];
            [str release];
			resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@" %@",curStr]];
		}
		
		if (display) {
			FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:display];
			NSString *curStr = [NSString stringWithUTF8String:[str UTF8String]];
			[convert release];
            [str release];
			resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"\n%@",curStr]];
		}
        
        if (provider && [provider objectForKey:@"name"]) {
            FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:[provider objectForKey:@"name"]];
			NSString *curStr = [NSString stringWithUTF8String:[str UTF8String]];
			[convert release];
            [str release];
			resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"\n\nProvider: %@",curStr]];
        }
		
        if (url) {
            FHTMLConverter *convert = [[FHTMLConverter alloc] init];
            NSString *str = [convert convertEntiesInString:url];
			NSString *curStr = [NSString stringWithUTF8String:[str UTF8String]];
			[convert release];
            [str release];
			resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"\n%@",curStr]];
        }
        
		[returnArr addObject:resultStr];
	}
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionsForTerm:forDef:whichDef:)]) {
		[Defdelegate definitionsForTerm:nil forDef:returnArr whichDef:2];
	}
}

-(void)parseJSONRel:(NSString*)JSONStr
{
	NSMutableArray *returnArr = [NSMutableArray array];
	NSArray *related = [JSONStr JSONValue];
	
	
	
	if (!related) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	
	for (NSDictionary *dic in related) {
		NSString *relationType = [dic objectForKey:@"relationshipType"];
		NSArray *arr = [dic objectForKey:@"words"];
		NSString *resultStr = @"";
		
		if (relationType) {
			resultStr = [resultStr stringByAppendingFormat:@"%@.",relationType];
		}
		
		if (arr) {
			
			BOOL isFirst = YES;
			
			for (NSString *wordStr in arr) {
				if (isFirst) {
					resultStr = [resultStr stringByAppendingFormat:@"\n\n%@",wordStr];
					isFirst = NO;
				}
				else {
					resultStr = [resultStr stringByAppendingFormat:@",%@",wordStr];
				}

			}
		}
		[returnArr addObject:resultStr];
	}
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionsForTerm:forDef:whichDef:)]) {
		[Defdelegate definitionsForTerm:nil forDef:returnArr whichDef:3];
	}
}

-(void)parseJSONAudio:(NSString*)JSONStr
{
	NSMutableArray *returnArr = [NSMutableArray array];
	NSArray *related = [JSONStr JSONValue];
	
	
	
	if (!related) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
		return;
	}
	
	for (NSDictionary *dic in related) {
		NSMutableDictionary *audioDic = [NSMutableDictionary dictionary];
		NSString *fileUrl = [dic objectForKey:@"fileUrl"];
		NSString *author = [dic objectForKey:@"createdBy"];
		NSString *audioId = [dic objectForKey:@"id"];
		
		if(fileUrl)
			[audioDic setObject:fileUrl forKey:@"fileUrl"];
		if (author) {
			[audioDic setObject:author forKey:@"author"];
		}
		
		if (audioId) {
			[audioDic setObject:audioId forKey:@"id"];
		}
		
		[returnArr addObject:audioDic];
	}
	
	if (Defdelegate && [Defdelegate respondsToSelector:@selector(audioForTerm:)]) {
		[Defdelegate audioForTerm:returnArr];
	}
	
}

-(void)parseJSONFlick:(NSString*)JSONStr
{
	NSString *flickStr = [JSONStr stringByReplacingOccurrencesOfString:@"jsonFlickrApi(" withString:@"["];
	NSRange range;
	range.location = [flickStr length]-1;
	range.length = 1;
	flickStr = [flickStr stringByReplacingCharactersInRange:range withString:@"]"];
	
	NSLog(@"%@",flickStr);
	
	NSMutableArray *flickAr = [flickStr JSONValue];
	NSMutableDictionary *flickDic = nil;
	if (flickAr) {
		flickDic = [flickAr objectAtIndex:0];
	}
	
	
	if (flickDic) {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(flickerRespForTerm:)]) {
			[Defdelegate flickerRespForTerm:flickDic];
		}
	}else {
		if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
			[Defdelegate definitionFailed];
		}
	}

	
}

-(void)parseJSONBing:(NSString*)JSONStr
{
    // Response PARSE https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=delhi&rsz=8
    NSLog(@"%@",JSONStr);
    NSMutableDictionary *bingDic = [JSONStr JSONValue];

    if (bingDic) {
        //		bingDic = [bingDic objectForKey:@"SearchResponse"];
        bingDic = [bingDic objectForKey:@"responseData"];
        
        if (bingDic) {
            //			bingDic = [bingDic objectForKey:@"Image"];
            if (bingDic) {
                //				NSMutableArray *imageArr = [bingDic objectForKey:@"Results"];
                NSMutableArray *imageArr = [bingDic objectForKey:@"results"];
                NSMutableArray *resultArr = [NSMutableArray array];
                for (NSDictionary *imageInfo in imageArr) {
                    NSMutableDictionary *image = [NSMutableDictionary dictionary];
                    //NSString *title = [imageInfo objectForKey:@"Title"];
                    //NSString *urlStr = [imageInfo objectForKey:@"MediaUrl"];
                    
                    
                   // NSString *title = [imageInfo objectForKey:@"titleNoFormatting"];
                   // NSString *urlStr = [imageInfo objectForKey:@"url"];
                    
                    NSString *title = [imageInfo objectForKey:@"contentNoFormatting"];
                    
                    //NSString *title = [imageInfo objectForKey:@"titleNoFormatting"];
                    NSString *urlStr = [imageInfo objectForKey:@"tbUrl"];//tbUrl
                    
                    
                    if (title) {
                        [image setObject:title forKey:@"title"];
                    }
                    
                    if (urlStr) {
                        [image setObject:urlStr forKey:@"url"];
                    }
                    [resultArr addObject:image];
                }
                if (Defdelegate && [Defdelegate respondsToSelector:@selector(bingRespForTerm:)]) {
                    [Defdelegate bingRespForTerm:resultArr];
                }
            }else {
                if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
                    [Defdelegate definitionFailed];
                }
            }
            
        }else {
            if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
                [Defdelegate definitionFailed];
            }
        }
        
    }else {
        if (Defdelegate && [Defdelegate respondsToSelector:@selector(definitionFailed)]) {
            [Defdelegate definitionFailed];
        }
    }
    

}

@end
