//
//  FDBController.h
//  flashCards
//
//  Created by Руслан Руслан on 1/11/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "Constants.h"
#import "FRootConstants.h"

@interface FDBController : NSObject {
	sqlite3 *dataBase;
	sqlite3 *quizletBase;
}

+(FDBController*)sharedDatabase;

-(NSMutableArray*)getCardArray:(NSString*)cat forIndex:(int)index; 
-(int)getNumberOfItems:(NSString*)cat;
-(BOOL)renameCategory:(NSString*)oldName forNewName:(NSString*)newName;
-(BOOL)renameGroup:(NSString*)groupId forNewName:(NSString*)newName;
-(NSInteger)getIDForCategory:(NSString*)category;
-(BOOL)updateStatistic:(NSArray*)statistic forCategory:(NSString*)category forIndex:(int)index;
-(NSMutableArray*)getStatistic:(NSString*)category forIndex:(int)index;
-(NSMutableArray*)getCategoriesForGroup:(NSString*)groupId;
-(NSInteger)numOfItemsInGroup:(NSString*)groupId;
-(NSInteger)getTestNumForCategory:(NSString*)category;
-(NSMutableArray*)getTestListForCategory:(NSString*)category;
-(NSString*)addCategory:(NSString*)category;
-(NSString*)addCategory:(NSString *)category withTemplate:(NSInteger)t;
-(NSString*)addCategory:(NSString*)category toGroup:(NSString*)groupId;
-(NSString*)addCategory:(NSString*)category toGroup:(NSString*)groupId withTemplate:(NSInteger)t;
-(BOOL)insertCategory:(NSString*)category toGroup:(NSString*)groupId;
-(BOOL)insertTemplate:(NSString*)category withTemplate:(NSInteger)t;
-(NSInteger)templateForSet:(NSString*)setId;
-(BOOL)transmitCategory:(NSString*)category fromGroup:(NSString*)groupId1 toGroup:(NSString*)groupId2;
-(NSString*)addGroup:(NSString*)group;
-(BOOL)removeCategory:(NSString*)category;
-(BOOL)removeCategory:(NSString *)category fromGroup:(NSString*)groupId;
-(BOOL)removeGroup:(NSString*)groupId;
-(BOOL)removeQuestion:(NSString*)category forIndex:(NSInteger)index;
-(NSInteger)addQuestionToCategory:(NSString*)category question:(NSString*)q answer:(NSString*)a;
-(BOOL)updateCategoryAtIndex:(NSString*)category question:(NSString*)q answer:(NSString*)a forInd:(NSInteger)index;
-(NSMutableArray*)infoForCategory:(NSString*)category;
-(NSInteger)sessionForSet:(NSString*)set_id;
-(BOOL)updateSessionForSet:(NSString*)set_id session:(NSInteger)s;
-(BOOL)checkCategoryExisting:(NSString*)category;
-(BOOL)checkGroupExist:(NSString*)groupId;
-(NSString*)idForGroupName:(NSString *)name;
-(void)clearStatisticForSet:(NSString*)category;
-(void)clearSetSession:(NSString*)set;
-(void)changeSessionState:(NSInteger)sessionState forSet:(NSString*)setId;
-(BOOL)isSessionOpened:(NSString*)setId;
-(BOOL)isAllLearned:(NSString*)setId;
-(NSInteger)minSession:(NSString*)setId;
-(NSArray*)setsid;
-(NSArray*)groupsid;
-(NSArray*)setsInGroup:(NSString*)group;
-(NSString*)nameForCategory:(NSString*)category;
-(NSString*)nameForGroup:(NSString*)groupId;
-(NSInteger)learnedCards:(NSString*)category;
-(void)close;
-(NSString*)checkCatExistWithName:(NSString*)name;
-(BOOL)isCardExist:(NSInteger)cardId forCategory:(NSString *)category;
-(NSInteger)numOfSets;

//min
-(NSArray*)cardWithMinId:(NSString*)categoryId;
-(NSArray*)cardWithMinIdForTest:(NSString*)categoryId;


//quzlet.com
-(NSMutableArray*)quizletCategories;
-(NSMutableArray*)quizletSubsets:(NSInteger)catId;
-(NSMutableArray*)quizletGroups:(NSInteger)catId;

//portation
-(BOOL)portToNewDatabase;

@end
