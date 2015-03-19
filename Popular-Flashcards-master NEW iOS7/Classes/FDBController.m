//
//  FDBController.m
//  flashCards
//
//  Created by Руслан Руслан on 1/11/10.
//  Copyright 2010 МГУ. All rights reserved.
//

#import "FDBController.h"
#import "Constants.h"
#import "DBTime.h"
#import "Util.h"

static FDBController* sharedDB=nil;
static NSMutableArray* currentCatId = nil;

@interface FDBController(Private)

-(BOOL)openDb;
-(BOOL)openQuizlet;
-(void)updateFirstLoading;
-(void)updateCurId;
-(NSString*)getCurrID;
@end


@implementation FDBController

+(FDBController*)sharedDatabase
{
	if(!sharedDB)
	{
		sharedDB=[[FDBController alloc] init];
		if([sharedDB openDb] && [sharedDB openQuizlet])
		{
			return sharedDB;
		}
		else
			return nil;
	}
	return sharedDB;
}

-(void)close
{
	if (dataBase) {
		if(sqlite3_close(dataBase) == SQLITE_OK)
			NSLog(@"%@",@"Database closed");
		dataBase = nil;
	}
}

-(BOOL)openDb
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@".Database"];
	NSString* oldDatabasePath = [databasePath stringByAppendingPathComponent:@"flashCards.sqlite"];
    NSLog(@"oldDatabasePath-->%@",oldDatabasePath);
	NSString* newDatabasePath = [databasePath stringByAppendingPathComponent:@"flashCards1.4.sqlite"];
	BOOL isDirectoryForOld = NO;
	BOOL isDirectoryForNew = NO;
	BOOL oldIsExist = [[NSFileManager defaultManager] fileExistsAtPath:oldDatabasePath isDirectory:&isDirectoryForOld];
	BOOL isNewExist = [[NSFileManager defaultManager] fileExistsAtPath:newDatabasePath isDirectory:&isDirectoryForNew];
	
	if (oldIsExist && !isDirectoryForOld) {
		NSError *error = NULL;
		if(![[NSFileManager defaultManager] moveItemAtPath:oldDatabasePath toPath:newDatabasePath error:&error])
		{
			if (error) {
				NSLog(@"%@",[error description]);
			}else {
				NSLog(@"%@",@"Old database expected but can't rename to new");
			}
			return FALSE;
		}
		isNewExist = YES;
	}
	
	if(!isNewExist || isDirectoryForNew)
	{
		NSString *atPath = [[NSBundle mainBundle] pathForResource:@"flashCard1.4" ofType:@"sqlite"];
		[[NSFileManager defaultManager] copyItemAtPath:atPath toPath:newDatabasePath error:nil];
	}
	if(sqlite3_open([newDatabasePath UTF8String],&dataBase)!=SQLITE_OK)
	{
		NSLog(@"Can't open database %@",newDatabasePath);
		return FALSE;
	}
	
	[self updateCurId];
	if(!isNewExist || isDirectoryForNew)
	{
		[self updateFirstLoading];
	}
	
	if (oldIsExist) {
		[self portToNewDatabase];
	}
	
	return TRUE;
}

-(BOOL)openQuizlet
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@".Database"];
	databasePath = [databasePath stringByAppendingPathComponent:@"quizlet.sqlite"];
    
    NSLog(@"Quizlet database %@",databasePath);
    
	BOOL isDirectory;
	BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:databasePath isDirectory:&isDirectory];
	BOOL isQuizletCopied = [[NSUserDefaults standardUserDefaults] boolForKey:@"quizletCopy"];
	if(!isExist || isDirectory || !isQuizletCopied)
	{
		if (isExist) {
			[[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
		}
		
		NSString *atPath = [[NSBundle mainBundle] pathForResource:@"quizlet" ofType:@"sqlite"];
		[[NSFileManager defaultManager] copyItemAtPath:atPath toPath:databasePath error:nil];
		isQuizletCopied = YES;
		[[NSUserDefaults standardUserDefaults] setBool:isQuizletCopied forKey:@"quizletCopy"];
	}
	if(sqlite3_open([databasePath UTF8String],&quizletBase)!=SQLITE_OK)
	{
		NSLog(@"Database error");
		return FALSE;
	}
	
	return TRUE;
	
}

-(BOOL)renameCategory:(NSString*)oldName forNewName:(NSString*)newName
{
	if (oldName && newName) {
		
		NSString *insertStr = [newName stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
		
		NSString *sqlStr = [NSString stringWithFormat:@"update category set name=\"%@\" where category=\"%@\"",insertStr,oldName];;
		sqlite3_stmt* statementC1;
		if(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK)
		{
			sqlite3_step(statementC1);
			sqlite3_finalize(statementC1);
		}
		else {
			NSLog(@"Can't rename category from %@ to %@",oldName,newName);
			return FALSE;
		}

		
		return TRUE;
		
	}
	else {
		return FALSE;
	}

}

-(BOOL)renameGroup:(NSString*)groupId forNewName:(NSString*)newName
{
	if ([self checkGroupExist:groupId]) {
		
		NSInteger gId = [[groupId substringFromIndex:1] intValue];
		
		NSString *insertStr = [newName stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
		
		NSString *sqlStr = [NSString stringWithFormat:@"update groups set name=\"%@\" where id=%d",insertStr,gId];;
		sqlite3_stmt* statementC1;
		if(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK)
		{
			sqlite3_step(statementC1);
			sqlite3_finalize(statementC1);
		}
		else {
			NSLog(@"Can't rename group to %@",newName);
			return FALSE;
		}
		
		return TRUE;
	}
	
	return FALSE;
}

-(NSMutableArray*)infoForCategory:(NSString*)category
{
	NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",category];
	NSInteger CatId;
	NSMutableArray *retArray = [[NSMutableArray alloc] init];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSString *q = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
		NSString *a = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,2) encoding:NSUTF8StringEncoding];
		CatId = sqlite3_column_int(statementC1,0);
		NSArray *addArr = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",CatId],q,a,nil];
		[retArray addObject:addArr];
	}
	sqlite3_finalize(statementC1);
	return retArray;
}

-(NSString*)addCategory:(NSString*)category
{
	if (!category) {
		return nil;
	}
	
	NSString *item = [self getCurrID];
	NSString *sqlStr = [NSString stringWithFormat:@"CREATE TABLE %@(id integer primary key not null,question text,answer text,interval integer,diff integer,recall integer,lapses integer,next integer,last integer,drill integer)",item];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't create table for category %@ and item %@",category,item);
		return nil;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	NSString *insertStr = [category stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	sqlStr = [NSString stringWithFormat:@"insert into category(category,exist,session,name,opened) values(\"%@\",1,1,\"%@\",0)",item,insertStr];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't add category with name %@",category);
		return nil;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	NSString *ret = [NSString stringWithString:item];
	[item release];
	return ret;
}

-(NSString*)addCategory:(NSString *)category withTemplate:(NSInteger)t
{
	if (!category) {
		NSLog(@"Can't add set with template!");
		return nil;
	}
	
	NSString *item = [self addCategory:category];
	
	if (item) {
		[self insertTemplate:category withTemplate:t];
	}
	
	return item;
}

-(NSString*)addCategory:(NSString*)category toGroup:(NSString*)groupId
{
	if (!category || !groupId || ![self checkGroupExist:groupId]) {
		return nil;
	}
	
	NSString *catId = [self addCategory:category];
	
	if (!catId || [catId length]<2) {
		NSLog(@"Can't add %@ to %@",category,groupId);
		return nil;
	}
	
	NSInteger cId = [[catId substringFromIndex:1] intValue];
	
	if (cId<0) {
		NSLog(@"Strange id %d for set %@",cId,catId);
		return nil;
	}
	
	NSString* sqlStr = [NSString stringWithFormat:@"insert into %@(cId) values(%d)",groupId,cId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't insert %@ to %@ with id %d",category,groupId,cId);
		return nil;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return catId;
}

-(NSString*)addCategory:(NSString*)category toGroup:(NSString*)groupId withTemplate:(NSInteger)t
{
	if (!category || !groupId) {
		NSLog(@"Can't add set to group with template");
		return nil;
	}
	
	NSString* item = [self addCategory:category toGroup:groupId];
	
	if (item) {
		[self insertTemplate:item withTemplate:t];
	}
	
	return item;
	
}

-(BOOL)insertCategory:(NSString*)category toGroup:(NSString*)groupId
{
	if (!category || !groupId || ![self checkGroupExist:groupId] || [category length]<2) {
		return NO;
	}
	
	NSInteger cId = [[category substringFromIndex:1] intValue];
	
	if (cId<0) {
		NSLog(@"Strange id %d for set %@",cId,category);
		return NO;
	}
	
	NSString* sqlStr = [NSString stringWithFormat:@"insert into %@(cId) values(%d)",groupId,cId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't insert %@ to %@ with id %d",category,groupId,cId);
		return NO;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return YES;
}

-(BOOL)insertTemplate:(NSString*)category withTemplate:(NSInteger)t
{
	if (!category) {
		NSLog(@"Can't insert template. Category is empty!");
		return NO;
	}
	
	NSString* sqlStr = [NSString stringWithFormat:@"update category set exist=%d where category=\"%@\"",t,category];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't update category withId %@",category);
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	return YES;
	
}

-(NSInteger)templateForSet:(NSString*)setId
{
	if (!setId) {
		NSLog(@"Empty setId while getting template!");
		return -1;
	}
	NSInteger t;
	NSString* sqlStr = [NSString stringWithFormat:@"select exist from category where category=\"%@\"",setId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't get template withId %@",setId);
		return FALSE;
	}
	if(sqlite3_step(statementC1) == SQLITE_ERROR)
	{
		NSLog(@"Error while getting template for setId %@",setId);
		return -1;
	}else{
		t = sqlite3_column_int(statementC1,0);
	}
	   
	sqlite3_finalize(statementC1);   
	return t; 
}

-(BOOL)transmitCategory:(NSString*)category fromGroup:(NSString*)groupId1 toGroup:(NSString*)groupId2
{
	if (!category || !groupId1 || !groupId2 || [category length]<2 || ![self checkGroupExist:groupId1] || ![self checkGroupExist:groupId2]) {
		return NO;
	}
	
	NSInteger cId = [[category substringFromIndex:1] intValue];
	
	if (cId<0) {
		NSLog(@"can't transmit %@",category);
		return NO;
	}
	
	NSString* sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE cId=%d",groupId1,cId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"can't delete %@ from %@ while transmitting to %@",category,groupId1,groupId2);
		return NO;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	NSString *categoryName = [self nameForCategory:category];
	
	if (!categoryName) {
		NSLog(@"can't find name for set %@",category);
		return NO;
	}
	
	sqlStr = [NSString stringWithFormat:@"insert into %@(cId) values(%d)",groupId2,cId];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"can't add %@ to %@ while transmitting",category,groupId2);
		return NO;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return YES;
}

-(BOOL)removeCategory:(NSString *)category fromGroup:(NSString*)groupId
{
	if (!category || !groupId || ![self checkGroupExist:groupId] || [category length]<2) {
		return NO;
	}
	
	if (![self removeCategory:category])
	{
		NSLog(@"can't remove %@",category);
		return NO;
	}
	
	NSInteger cId = [[category substringFromIndex:1] intValue];
	
	if (cId<0) {
		NSLog(@"can't remove %@",category);
		return NO;
	}
	
	NSString* sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE cId=%d",groupId,cId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"can't delete %@ from %@",category,groupId);
		return NO;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return YES;
}

-(BOOL)removeGroup:(NSString*)groupId
{
	if (!groupId || ![self checkGroupExist:groupId] || [groupId length]<2) {
		return NO;
	}
	
	NSString *sqlStr = [NSString stringWithFormat:@"DROP TABLE %@",groupId];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't drop table for group with name %@",groupId);
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	NSInteger gId = [[groupId substringFromIndex:1] intValue];
	
	if (gId<0) {
		return FALSE;
	}
	
	sqlStr = [NSString stringWithFormat:@"DELETE FROM groups WHERE id=%d",gId];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"can't remove group with id %@",groupId);
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return YES;
}

-(NSString*)addGroup:(NSString*)group
{
	if (!group) {
		return nil;
	}
	
	NSString *groupToInsert = [group stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	
	NSString* sqlStr = [NSString stringWithFormat:@"insert into groups(name) values(\"%@\")",groupToInsert];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"createing group with name %@ failed",group);
		return nil;
	}
	sqlite3_step(statementC1);
	NSInteger gId = sqlite3_last_insert_rowid(dataBase);
	sqlite3_finalize(statementC1);
	
	NSString *gTableName = [NSString stringWithFormat:@"g%d",gId];
	
	sqlStr = [NSString stringWithFormat:@"CREATE TABLE %@(id integer primary key not null,cId integer)",gTableName];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"createing group table with name %@ failed",gTableName);
		return nil;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	return gTableName;
}


-(BOOL)removeCategory:(NSString*)category
{
	NSString *sqlStr = [NSString stringWithFormat:@"DROP TABLE %@",category];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	NSInteger stepRes = sqlite3_step(statementC1);
    NSLog(@"%d",stepRes);
	sqlite3_finalize(statementC1);
	sqlStr = [NSString stringWithFormat:@"DELETE FROM category WHERE category=\"%@\"",category];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
	sqlStr = [NSString stringWithFormat:@"insert into UniqueId(puid) values(\"%@\")",category];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	NSInteger catId = sqlite3_last_insert_rowid(dataBase);
	
	NSArray *catArr = [NSArray arrayWithObjects:[NSNumber numberWithInt:catId],category,nil];
	[currentCatId addObject:catArr];
	
	return TRUE;
}

-(BOOL)checkCategoryExisting:(NSString*)category
{
	if (!category) {
		return YES;
	}
	
	NSString *sqlStr = [NSString stringWithFormat:@"select category from category where category=\"%@\"",category];
    sqlite3_stmt* stm;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stm, NULL) != SQLITE_OK) {
        NSLog(@"Can't check set existing %@",category);
        return NO;
    }
    
    BOOL ex = NO;
    
    if (sqlite3_step(stm) == SQLITE_ROW) {
        ex = YES;
    }
    sqlite3_finalize(stm);
    return ex;
}

-(BOOL)checkGroupExist:(NSString*)groupId
{   
    if (!groupId || [groupId length]!=2) {
        return NO;
    }
	
    NSInteger gid = [[groupId substringFromIndex:1] intValue];
    if (gid<=0) {
        return NO;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select id from groups where id=%d",gid];
    sqlite3_stmt* stm;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stm, NULL) != SQLITE_OK) {
        NSLog(@"Can't check group existing %@",groupId);
        return NO;
    }
    
    BOOL ex = NO;
    
    if (sqlite3_step(stm) == SQLITE_ROW) {
        ex = YES;
    }
    sqlite3_finalize(stm);
    return ex;
}

-(NSString*)idForGroupName:(NSString *)name
{
	if (!name) {
		return nil;
	}
	
    NSString *sqlStr = [NSString stringWithFormat:@"select id from groups where name=\"%@\"",name];
    sqlite3_stmt* stm;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stm, NULL) != SQLITE_OK) {
        NSLog(@"Can't get id by name %@",name);
        return nil;
    }
    
    NSString *gid = nil;
    
    if (sqlite3_step(stm) == SQLITE_ROW) {
        gid = [NSString stringWithFormat:@"g%d",sqlite3_column_int(stm, 0)];
    }
    sqlite3_finalize(stm);
	return gid;
}

-(BOOL)isCardExist:(NSInteger)cardId forCategory:(NSString *)category
{
	if (!category) {
        return NO;
    }
	
	NSString *sqlStr = [NSString stringWithFormat:@"select id from %@ where id=%d",category,cardId];
    sqlite3_stmt* stm;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stm, NULL) != SQLITE_OK) {
        NSLog(@"Can't check card existing in %@",category);
        return NO;
    }
    
    BOOL ex = NO;
    
    if (sqlite3_step(stm) == SQLITE_ROW) {
        ex = YES;
    }
    sqlite3_finalize(stm);
    return ex;
	
}

-(NSInteger)addQuestionToCategory:(NSString*)category question:(NSString*)q answer:(NSString*)a
{
	NSString* qInsert = [q stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString* aInsert = [a stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
    NSInteger session = [self sessionForSet:category];
    
    if ([self isSessionOpened:category]) {
        session++;
    }
    
	NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(question,answer,interval,diff,recall,lapses,next,last,drill) values(\"%@\",\"%@\",0,0,%d,0,0,0,0)",
						category,
						qInsert,
						aInsert,
						session];
	sqlite3_stmt* statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Database Error");
		return -1;
	}
	sqlite3_step(statementC1);
	NSInteger ind = sqlite3_last_insert_rowid(dataBase);
	sqlite3_finalize(statementC1);
	return ind;
}

-(BOOL)updateCategoryAtIndex:(NSString*)category question:(NSString*)q answer:(NSString*)a forInd:(NSInteger)index
{
	NSString* qInsert = [q stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString* aInsert = [a stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString *sqlStr = [NSString stringWithFormat:@"update %@ set question=\"%@\", answer=\"%@\" where id=%d",category,qInsert,aInsert,index];
	sqlite3_stmt* statementC1;
	if(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK)
	{
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
		return TRUE;
	}
	return FALSE;
	
}

-(BOOL)removeQuestion:(NSString*)category forIndex:(NSInteger)index
{
	NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id=%d",category,index];
	sqlite3_stmt* statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	return TRUE;
}

-(NSMutableArray*)getTestListForCategory:(NSString*)category
{
	NSMutableArray* TestListForCategory = [[NSMutableArray alloc] init];
    NSInteger session = [self sessionForSet:category];
	NSString *sqlStr = [NSString stringWithFormat:@"select id from %@ where recall=%d and drill=0",category,session];
	NSInteger CatId;
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		CatId = sqlite3_column_int(statementC1,0);
		[TestListForCategory addObject:[NSArray arrayWithObjects:category,
								 [NSString stringWithFormat:@"%d",CatId],nil]];
				
	}
	sqlite3_finalize(statementC1);
	return TestListForCategory;
}

-(void)updateCurId
{
	//update category id
	
	if (!currentCatId) {
		currentCatId = [[NSMutableArray alloc] init];
        NSLog(@"currentCatId%@",currentCatId);
	}else {
		[currentCatId removeAllObjects];
	}
	
	NSString *sqlStr = [NSString stringWithString:@"select * from UniqueId"];
	sqlite3_stmt* statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Reading category id from database failed");
		return;
	}
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSInteger uid = sqlite3_column_int(statementC1,0);
		NSString *puid = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
		NSLog(@"%@",puid);	
		NSArray *ids = [NSArray arrayWithObjects:[NSNumber numberWithInt:uid],puid,nil];
		[currentCatId addObject:ids];
	}
	NSLog(@"%@",@"++++++++");
	sqlite3_finalize(statementC1);
}

-(NSString*)getCurrID
{
	if (currentCatId && [currentCatId count]>0) {
		
		NSArray *cardId = [currentCatId lastObject];
		NSInteger curId = [[cardId objectAtIndex:0] intValue];
		NSString *curIdS = [[NSString alloc] initWithString:[cardId objectAtIndex:1]];
		[currentCatId removeLastObject];
		
		NSString *sqlStr = [NSString stringWithFormat:@"DELETE FROM UniqueId WHERE id=%d",curId];
		sqlite3_stmt* statementC1;
		if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
		{
			NSLog(@"Removing category id %@ from database failed",curIdS);
			return nil;
		}
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
		
		return curIdS;
	}else {
		NSInteger height = 0;
		
        NSArray *setsid = [self setsid];
		for (NSString *set in setsid) {
			NSInteger catId = [[set substringFromIndex:1] intValue];
			
			if (catId>height) {
				height = catId;
			}
			
		}
				
		NSString *item = [[NSString alloc] initWithFormat:@"i%d",height+1];
		return item;	
	}

}

-(NSInteger)getTestNumForCategory:(NSString*)category
{
	NSInteger testNum=0;
	sqlite3_stmt *statementC1;
    NSInteger session = [self sessionForSet:category];
	NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from %@ where recall=%d and drill=0",category,session];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return FALSE;
	}
	
    if(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		testNum = sqlite3_column_int(statementC1,0);
	}
	sqlite3_finalize(statementC1);
	return testNum;
}

-(int)getNumberOfItems:(NSString*)cat
{
	NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from %@",cat];
	sqlite3_stmt *statementC1;
	int height = 0;
	if (sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK) 
	{
		sqlite3_step(statementC1);
		height= sqlite3_column_int(statementC1,0);
	}
	sqlite3_finalize(statementC1);
	return height;	
}

-(NSInteger)numOfSets
{   
	NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from category"];
	sqlite3_stmt *statementC1;
	int height = 0;
	if (sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK) 
	{
		sqlite3_step(statementC1);
		height= sqlite3_column_int(statementC1,0);
	}
	sqlite3_finalize(statementC1);
	return height;
}


-(NSMutableArray*)getCategoriesForGroup:(NSString*)groupId
{
	if (!groupId || ![self checkGroupExist:groupId]) {
		return nil;
	}
	
	NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",groupId];
	sqlite3_stmt *statementC1;
	NSMutableArray *retArray = [[NSMutableArray alloc] init];
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"can't get categories from %@",groupId);
		return nil;
	}
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSInteger cId = sqlite3_column_int(statementC1,1);
		NSString *categoryId = [NSString stringWithFormat:@"i%d",cId];
		[retArray addObject:categoryId];
	}
    sqlite3_finalize(statementC1);
	return retArray;
}

-(NSInteger)learnedCards:(NSString*)category
{
	NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from %@ where drill=1",category];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error while getting learned cards");
		return FALSE;
	}
	NSInteger count = 0;
	if(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		count = sqlite3_column_int(statementC1,0);
	}
	sqlite3_finalize(statementC1);
	return count;
}

-(NSInteger)numOfItemsInGroup:(NSString*)groupId
{
	if (!groupId || ![self checkGroupExist:groupId]) {
		return -1;
	}
	
	NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from %@",groupId];
	sqlite3_stmt *statementC1;
	int count = -1;
	if (sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK) 
	{
		sqlite3_step(statementC1);
		count = sqlite3_column_int(statementC1,0);
	}
	sqlite3_finalize(statementC1);
	return count;	
}

-(NSMutableArray*)getCardArray:(NSString*)cat forIndex:(int)index
{
	NSString *sqlStr = [NSString stringWithFormat:@"select id,question,answer from %@ where id=%d",cat,index];
	sqlite3_stmt *statementC1;
	NSMutableArray *retArray = [[NSMutableArray alloc] init];
	if (sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK) 
	{
		sqlite3_step(statementC1);
		NSString *CQuestion = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
		NSString *CAnswer = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,2) encoding:NSUTF8StringEncoding];
		[retArray addObject:CQuestion];
		[retArray addObject:CAnswer];
	}
	sqlite3_finalize(statementC1);
	return retArray;
}


-(BOOL)updateStatistic:(NSArray*)statistic forCategory:(NSString*)category forIndex:(int)index
{
	NSString *sql = [NSString stringWithFormat:@"update %@ set interval=%d, diff=%d, recall=%d, lapses=%d, next=%d, last=%d, drill=%d where id=%d",category,
					 [[statistic objectAtIndex:0] intValue],
					 [[statistic objectAtIndex:1] intValue],
					 [[statistic objectAtIndex:2] intValue],
					 [[statistic objectAtIndex:3] intValue],
					 [[statistic objectAtIndex:4] intValue],
					 [[statistic objectAtIndex:5] intValue],
					 [[statistic objectAtIndex:6] intValue],
					 index];;
	sqlite3_stmt* statementC1;
	if(sqlite3_prepare_v2(dataBase,[sql UTF8String],-1,&statementC1,NULL)==SQLITE_OK)
	{
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
		return TRUE;
	}
	return FALSE;
}

-(NSMutableArray*)getStatistic:(NSString*)category forIndex:(int)index
{
	NSString *sqlStr = [NSString stringWithFormat:@"select id,interval,diff,recall,lapses,next,last,drill from %@ where id=%d",category,index];
	sqlite3_stmt *statementC1;
	NSMutableArray *retArray = [[NSMutableArray alloc] init];
	if (sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL) == SQLITE_OK) 
	{
		sqlite3_step(statementC1);
		int interval = sqlite3_column_int(statementC1,1);
		int diff = sqlite3_column_int(statementC1,2);
		int recall = sqlite3_column_int(statementC1,3);
		int lapses = sqlite3_column_int(statementC1,4);
		int next = sqlite3_column_int(statementC1,5);
		int last = sqlite3_column_int(statementC1,6);
		int drill = sqlite3_column_int(statementC1,7);
		[retArray addObject:[NSString stringWithFormat:@"%d",interval]];
		[retArray addObject:[NSString stringWithFormat:@"%d",diff]];
		[retArray addObject:[NSString stringWithFormat:@"%d",recall]];
		[retArray addObject:[NSString stringWithFormat:@"%d",lapses]];
		[retArray addObject:[NSString stringWithFormat:@"%d",next]];
		[retArray addObject:[NSString stringWithFormat:@"%d",last]];
		[retArray addObject:[NSString stringWithFormat:@"%d",drill]];
	}
  	sqlite3_finalize(statementC1);
	return retArray;
}

-(NSInteger)getIDForCategory:(NSString*)category
{
	if (!category) {
        return -1;
    }	
    
    NSString *sqlStr = [NSString stringWithFormat:@"select id from category where category=\"%@\"",category];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't get category id %@",category);
        return -1;
    }
    
    NSInteger sid = -1;
    
    if (sqlite3_step(stmt)) {
        sid = sqlite3_column_int(stmt, 0);
    }
    
    sqlite3_finalize(stmt);
    return sid;
}

-(NSString*)checkCatExistWithName:(NSString*)name{
    if (name) {
        return nil;
    }	
    
    NSString *sqlStr = [NSString stringWithFormat:@"select category from category where name=\"%@\"",name];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't get category id %@",name);
        return nil;
    }
    
    NSString* cid;
    
    if (sqlite3_step(stmt)) {
        cid = [NSString stringWithCString:(char*)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
    }
    
    sqlite3_finalize(stmt);
    return cid;
}

-(NSArray*)setsid{
    NSString *sqlStr = [NSString stringWithString:@"select category from category"];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Can't get sets id");
        return nil;
    }
    
    NSMutableArray *setsid = [NSMutableArray array];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *setid = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 0)
                                             encoding:NSUTF8StringEncoding];
        [setsid addObject:setid];
    }
    
    sqlite3_finalize(statement);
    return setsid;
    
}
-(NSArray*)groupsid{
    NSString *sqlStr = [NSString stringWithString:@"select id from groups"];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Can't get sets id");
        return nil;
    }
    
    NSMutableArray *groupsid = [NSMutableArray array];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *groupid = [NSString stringWithFormat:@"g%d",sqlite3_column_int(statement, 0)];
        [groupsid addObject:groupid];
    }
    
    sqlite3_finalize(statement);
    return groupsid;
}

-(NSArray*)setsInGroup:(NSString*)group{
    NSString *sqlStr = [NSString stringWithFormat:@"select cId from %@",group];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Can't get sets id");
        return nil;
    }
    
    NSMutableArray *setsid = [NSMutableArray array];
    
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSString *setid = [NSString stringWithFormat:@"i%d",sqlite3_column_int(statement, 0)];
        [setsid addObject:setid];
    }
    
    sqlite3_finalize(statement);
    return setsid;
}

-(void)updateFirstLoading
{
	NSArray *setsid = [self setsid];
	for(NSString* setId in setsid)
	{
		[self clearSetSession:setId];
	}
    
	return;
}

-(NSString*)nameForCategory:(NSString*)category
{
	if (!category) {
		return nil;
	}
	
	NSString *sqlStr = [NSString stringWithFormat:@"select name from category where category=\"%@\"",category];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL)!=SQLITE_OK) {
        NSLog(@"Can't get name for category %@",category);
        return nil;
    }
    
    NSString *name = nil;
    
    if (sqlite3_step(stmt)) {
        name = [NSString stringWithCString:(char*)sqlite3_column_text(stmt, 0)
                                  encoding:NSUTF8StringEncoding];
    }
	sqlite3_finalize(stmt);
	return name;
}

-(NSInteger)sessionForSet:(NSString*)set_id{
    
    if (!set_id) {
        NSLog(@"Invalid set id to get session");
        return -1;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select session from category where category=\"%@\"",set_id];
	sqlite3_stmt *statementC1;
    NSInteger code = sqlite3_prepare_v2(dataBase,[sqlStr UTF8String], -1, &statementC1, NULL);
	if (code != SQLITE_OK) 
	{
        NSLog(@"Can't find set with id %@",set_id);
        return -1;
	}
    
    NSInteger session = -1;
    if (sqlite3_step(statementC1)==SQLITE_ROW) {
        session = sqlite3_column_int(statementC1, 0);
    }
    sqlite3_finalize(statementC1);
    return session;
}

-(BOOL)updateSessionForSet:(NSString*)set_id session:(NSInteger)s{
    if (!set_id) {
        NSLog(@"Can't update session with id %@",set_id);
        return NO;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"update category set session=%d where category=\"%@\"",s,set_id];
	sqlite3_stmt* statementC1;
	if(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK)
	{
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
		return TRUE;
	}
	return FALSE;
    
}

-(NSString*)nameForGroup:(NSString*)groupId
{
	
	if (!groupId) {
		return nil;
	}
	
    NSInteger gid = [[groupId substringFromIndex:1] intValue];
    
	NSString *sqlStr = [NSString stringWithFormat:@"select name from groups where id=%d",gid];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL)!=SQLITE_OK) {
        NSLog(@"Can't get name for group %@",groupId);
        return nil;
    }
    
    NSString *name = nil;
    
    if (sqlite3_step(stmt)) {
        name = [NSString stringWithCString:(char*)sqlite3_column_text(stmt, 0)
                                  encoding:NSUTF8StringEncoding];
    }
	sqlite3_finalize(stmt);
	return name;
}

-(void)clearStatisticForSet:(NSString*)category
{
	if (!category) {
		return;
	}
	
	NSInteger recall = 1;
	NSInteger lapses = 0;
	NSInteger drill = 0;
	
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set recall=%d, lapses=%d, drill=%d",category,recall,lapses,drill];
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statement, NULL) != SQLITE_OK) {
        NSLog(@"Can't clear set %@",category);
        return;
    }
	
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    return;
}

-(void)clearSetSession:(NSString*)set{
    
    if (!set) {
        return;
    }
    
    [self clearStatisticForSet:set];
    
    NSString *sqlStr = [NSString stringWithFormat:@"update category set session=1,opened=0 where category=\"%@\"",set];
    sqlite3_stmt *stmt;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't clear set %@",set);
    }
    
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    
    return;
}

-(void)changeSessionState:(NSInteger)sessionState forSet:(NSString*)setId{
    if (!setId) {
        return;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"update category set opened=%d where category=\"%@\"",sessionState,setId];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't change session state to %d for set %@",sessionState,setId);
        return;
    }
    
    sqlite3_step(stmt);
    sqlite3_finalize(stmt);
    return;
}

-(NSInteger)minSession:(NSString*)setId{
    
    if (!setId) {
        return -1;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select recall from %@ where drill=0 order by recall limit 1",setId];
    sqlite3_stmt* stmt;
    
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't get min session for %@",setId);
        return -1;
    }
    
    NSInteger session = -1;
    if (sqlite3_step(stmt) == SQLITE_ROW) {
        session = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    return session;
}

-(BOOL)isSessionOpened:(NSString*)setId{
    if (!setId) {
        return NO;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select opened from category where category=\"%@\"",setId];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL) != SQLITE_OK) {
        NSLog(@"Can't check session for openning for set %@",setId);
        return NO;
    }
    
    NSInteger chk = 0;
    if (sqlite3_step(stmt)) {
        chk = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    
    if (chk) {
        return YES;
    }else{
        return NO;
    }
}

-(BOOL)isAllLearned:(NSString*)setId{
    if (!setId) {
        return YES;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select count(id) from %@ where drill=0",setId];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &stmt, NULL)!=SQLITE_OK) {
        NSLog(@"Can't check all learned for set %@",setId);
        return YES;
    }
    
    NSInteger count = 0;
    
    if (sqlite3_step(stmt)) {
        count = sqlite3_column_int(stmt, 0);
    }
    sqlite3_finalize(stmt);
    
    if (count<=0) {
        return YES;
    }else{
        return NO;
    }
    
    
}

-(BOOL)portToNewDatabase
{
	//creating group database
	NSString* sqlStr = [NSString stringWithFormat:@"CREATE TABLE groups(id integer primary key not null,name text)"];
	sqlite3_stmt *statementC1;
	if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
	{
		NSLog(@"Can't create groups table while porting database");
		return FALSE;
	}
	sqlite3_step(statementC1);
	sqlite3_finalize(statementC1);
	
    //adding colunm to support sessions
    sqlStr = [NSString stringWithString:@"ALTER TABLE category ADD session integer"];
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statementC1, NULL)!=SQLITE_OK) {
        NSLog(@"Can't add column to support sessions");
        return FALSE;
    }
    sqlite3_step(statementC1);
    sqlite3_finalize(statementC1);
    
    //adding colunm to support opened
    sqlStr = [NSString stringWithString:@"ALTER TABLE category ADD opened integer"];
    if (sqlite3_prepare_v2(dataBase, [sqlStr UTF8String], -1, &statementC1, NULL)!=SQLITE_OK) {
        NSLog(@"Can't add column to support opened");
        return FALSE;
    }
    sqlite3_step(statementC1);
    sqlite3_finalize(statementC1);
    
	//uploading set to group
	
	NSString *gId = [self addGroup:@"FlashCards"];
	
	if(!gId)
		return FALSE;
	NSArray *setsid = [self setsid];	
	for (NSString *set in setsid) {
		NSInteger cId = [[set substringFromIndex:1] intValue];
		sqlStr = [NSString stringWithFormat:@"insert into %@(cId) values(%d)",gId,cId];
		if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
		{
			NSLog(@"Can't insert to %@ with id %d while porting database",gId,cId);
			return FALSE;
		}
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
        
        sqlStr = [NSString stringWithFormat:@"update category set exist=%d,session=1,opened=0 where category=\"%@\"",kCustomTemplate,set];
        
        if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
		{
			NSLog(@"Can't update category withId %@",set);
			return FALSE;
		}
		sqlite3_step(statementC1);
		sqlite3_finalize(statementC1);
        
        [self clearStatisticForSet:set];
	}
	
    return YES;
}

#pragma mark -
#pragma mark min

-(NSArray*)cardWithMinId:(NSString*)categoryId{
    if (!categoryId) {
        return  nil;
    }
    
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ order by id limit 1",categoryId];
    sqlite3_stmt *statementC1;
    if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
    {
        NSLog(@"error!!! while selecting min card");
        return nil;
    }
    
    
    if(sqlite3_step(statementC1) == SQLITE_ROW){
        NSString *q = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
        NSString *a = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,2) encoding:NSUTF8StringEncoding];
        NSInteger CatId = sqlite3_column_int(statementC1,0);
        NSArray *cardArr = [NSArray arrayWithObjects:[NSNumber numberWithInt:CatId],q,a,nil];
        sqlite3_finalize(statementC1);
        return cardArr;
    }
    sqlite3_finalize(statementC1);
    
    return nil;
}

-(NSArray*)cardWithMinIdForTest:(NSString*)categoryId{
    if (!categoryId) {
        return  nil;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where drill=0 order by recall,id limit 1",categoryId];
    sqlite3_stmt *statementC1;
    if(!(sqlite3_prepare_v2(dataBase,[sqlStr UTF8String],-1,&statementC1,NULL)==SQLITE_OK))
    {
        NSLog(@"error!!! while selecting min card for test");
        return nil;
    }
    
    
    if (sqlite3_step(statementC1)==SQLITE_ROW) {
        NSString *q = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
        NSString *a = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,2) encoding:NSUTF8StringEncoding];
        NSInteger CatId = sqlite3_column_int(statementC1,0);
        NSArray *cardArr = [NSArray arrayWithObjects:[NSNumber numberWithInt:CatId],q,a,nil];
        sqlite3_finalize(statementC1);
        return cardArr;
    }
    sqlite3_finalize(statementC1);
    
    return nil;
}

#pragma mark -
#pragma mark quizlet

-(NSMutableArray*)quizletCategories
{
	NSMutableArray *retArr = [NSMutableArray array];
	NSString *request = [NSString stringWithFormat:@"select rowid,sets from categories"];
	sqlite3_stmt *statementC1;
	
	if(!(sqlite3_prepare_v2(quizletBase,[request UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return nil;
	}
	
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSInteger index = sqlite3_column_int(statementC1,0);
		NSString *category = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
		
		[retArr addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:index],category,nil]];
		category = nil;
	}
	
	sqlite3_finalize(statementC1);
	return retArr;
}

-(NSMutableArray*)quizletSubsets:(NSInteger)catId
{
	NSMutableArray *retArr = [NSMutableArray array];
	NSString *request = [NSString stringWithFormat:@"select rowid,subset from subsets where categoryKey=%d",catId];
	sqlite3_stmt *statementC1;
	
	if(!(sqlite3_prepare_v2(quizletBase,[request UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return nil;
	}
	
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSInteger index = sqlite3_column_int(statementC1,0);
		NSString *category = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,1) encoding:NSUTF8StringEncoding];
		
		[retArr addObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:index],category,nil]];
		category = nil;
	}
	
	sqlite3_finalize(statementC1);
	return retArr;
}

-(NSMutableArray*)quizletGroups:(NSInteger)catId
{
	NSMutableArray *retArr = [NSMutableArray array];
	NSString *request = [NSString stringWithFormat:@"select groupName from groups where subId=%d",catId];
	sqlite3_stmt *statementC1;
	
	if(!(sqlite3_prepare_v2(quizletBase,[request UTF8String], -1, &statementC1, NULL) == SQLITE_OK)) 
	{
		NSLog(@"Database Error");
		return nil;
	}
	
	while(sqlite3_step(statementC1)==SQLITE_ROW)
	{
		NSString *category = [NSString stringWithCString:(char*)sqlite3_column_text(statementC1,0) encoding:NSUTF8StringEncoding];
		
		[retArr addObject:category];
		category = nil;
	}
	
	sqlite3_finalize(statementC1);
	return retArr;
}


@end
