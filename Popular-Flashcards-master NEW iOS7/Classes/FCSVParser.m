//
//  FCSVParser.m
//  flashCards
//
//  Created by Ruslan on 4/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FCSVParser.h"
#import "HTMLParser.h"

@interface FCSVParser(Private)

+(NSString*)contentOfFile:(NSString*)filePath;
+(NSString*)parseHTML:(NSString*)HTMLstr;

@end




@implementation FCSVParser

+(NSMutableArray*)parseCSVFile:(NSString*)filePath
{
	NSString *csvString = [FCSVParser contentOfFile:filePath];
	
	if (!csvString) {
		return nil;
	}
	
	NSMutableArray *rows = [NSMutableArray array];
	
    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
	
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@"\"\t<,["];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
	
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:csvString];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
		 NSMutableArray *columns = [NSMutableArray arrayWithCapacity:4];
        NSMutableString *currentColumn = [NSMutableString string];
		 NSString *img1 = nil;	
		 NSString *img2 = nil;
		NSString *sound1 = nil;
		NSString *sound2 = nil;
        while ( !finishedRow ) {
            NSString *tempString;
				
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
			
            if ( [scanner isAtEnd] ) {
                /*if ( ![currentColumn isEqualToString:@""] )*/ [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    /*if ( ![currentColumn isEqualToString:@""] )*/ [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ([scanner scanString:@"\t" intoString:NULL]) {
					if ( insideQuotes ) {
                    [currentColumn appendString:@"\t"];
					}
					else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
					   [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
					}
			}else if ([scanner scanString:@"," intoString:NULL]) {
					if ( insideQuotes ) {
						[currentColumn appendString:@","];
					}
					else {
                    // This is a column separating comma
						[columns addObject:currentColumn];
						currentColumn = [NSMutableString string];
						[scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
					}
			}else if ([scanner scanString:@"[" intoString:NULL]) {
					if (insideQuotes) {
						[currentColumn appendString:@"["];
					}else {
						//may be anki sound
						NSMutableString *tmpstrMutable = [NSMutableString string];
						NSString *tmpStr;
						NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"]"];
						if ([scanner scanUpToCharactersFromSet:charSet intoString:&tmpStr]) {
							[tmpstrMutable appendString:tmpStr];
						}
						[scanner scanString:@"]" intoString:NULL];
						NSArray *soundArr = [tmpstrMutable componentsSeparatedByString:@":"];
						if (soundArr && [soundArr count]>=2 && [[soundArr objectAtIndex:0] isEqualToString:@"sound"]) {
							if (columns && [columns count]<6) {
								if (!sound1) {
									sound1 = [[NSString alloc] initWithString:[soundArr objectAtIndex:1]];
								}else if (!sound2) {
									sound2 = [[NSString alloc] initWithString:[soundArr objectAtIndex:1]];
								}
							}
						}
						
					}

			}else if ([scanner scanString:@"<" intoString:NULL]) {
					if (insideQuotes) {
						[currentColumn appendString:@"<"];
					}
					else {
					//HTML tag begins
					NSMutableString *tmpstrMutable = [NSMutableString string];
					[tmpstrMutable appendString:@"<"];
					NSString *tmpStr;
					NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@">"];
					if ([scanner scanUpToCharactersFromSet:charSet intoString:&tmpStr]) {
						[tmpstrMutable appendString:tmpStr];
					}
					
					if ([scanner isAtEnd]) {
						if ([columns count]<6) {
							[currentColumn appendString:tmpstrMutable];							
							[columns addObject:currentColumn];
						}
						finishedRow = YES;
					}
					else {
						[scanner scanString:@">" intoString:&tmpStr];
						[tmpstrMutable appendString:tmpStr];
						NSString *image = [self parseHTML:tmpstrMutable];
						
						if (image && [columns count]<6) {
							//[scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
							if (!img1) {
								img1 = [[NSString alloc] initWithString:image];
							}
							else if(!img2){
								img2 = [[NSString alloc] initWithString:image];
							}

						}
						else {
							[currentColumn appendString:@" "];
						}
					}

				}

			}
		
			
        }
		
		if (img1 && [columns count]<6) {
			[columns addObject:img1];
		}	
		
		if (img2 && [columns count]<6) {
			[columns addObject:img2];
		}
		
		if (sound1 && [columns count]<6) {
			[columns addObject:sound1];
		}
		
		if (sound2 && [columns count]<6) {
			[columns addObject:sound2];
		}
		
		if (img1) {
			[img1 release];
		}
		
		if (img2) {
			[img2 release];
		}
		
		if (sound1) {
			[sound1 release];
		}
		
		if (sound2) {
			[sound2 release];
		}
		
		if ( [columns count] > 0 ) [rows addObject:columns];
    }
	
    return rows;
	
}

+(NSMutableArray*)parseApiString:(NSString*)apiStr
{
	NSMutableArray *rows = [NSMutableArray array];
	
	// Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
	
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\\\"[]"];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];
	
    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:apiStr];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
		 NSMutableArray *columns = [NSMutableArray arrayWithCapacity:3];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }
			
            if ( [scanner isAtEnd] ) {
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
            }
			else if ( [scanner scanString:@"\\" intoString:NULL] ) {
               if ([scanner scanString:@"\"" intoString:nil]) {
				   [currentColumn appendString:@"\""]	;
			   }
            }else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
						if(!insideQuotes)
						{
							[columns addObject:currentColumn];
							currentColumn = [NSMutableString string];
						}
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
            }else if ( [scanner scanString:@"]" intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@"]"];
                }
                else {
                    [rows addObject:columns];
                  	finishedRow = YES;
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
			else if ( [scanner scanString:@"[" intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@"["];
                }
            }
			
        }
    }
	
    return rows;
	
}

#pragma mark privateMethods
+(NSString*)contentOfFile:(NSString*)filePath
{
	BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSLog(@"%@",filePath);
	
	if(fileExist)
	{
        NSError *error = nil;
		NSString *csvString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
        if (!csvString) {
            if (error) {
                NSLog(@"%@",[error description]); 
            }else{
                NSLog(@"error parse csv");
            }
            
        }
		return csvString;
	}
	
	return nil;
	
}

+(NSString*)parseHTML:(NSString*)HTMLstr
{
	NSError * error = nil;
	HTMLParser * parser = [[HTMLParser alloc] initWithString:HTMLstr error:nil];
	
	if (error) {
		NSLog(@"Error: %@", error);
		return nil;
	}
	HTMLNode * bodyNode = [parser body]; //Find the body tag
	
	NSArray * imageNodes = [bodyNode findChildTags:@"img"]; //Get all the <img alt="" />
	
	NSString *retStr = nil;
	
	for (HTMLNode * imageNode in imageNodes) { //Loop through all the tags
		retStr = [imageNode getAttributeNamed:@"src"]; //Echo the src=""
	}
	
	[parser release];
	
	return retStr;
}

@end

