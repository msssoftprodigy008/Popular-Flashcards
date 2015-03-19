//
//  FITestImport.h
//  flashCards
//
//  Created by Ruslan on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	FIImportTestCSV,
	FIImportTestAnki
}FIImportTest;

@interface FITestImport : NSObject {

}

+(BOOL)testCSVorAnki:(FIImportTest)testType;
+(BOOL)testAll;

@end
