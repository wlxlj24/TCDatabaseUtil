//
//  TCDatabseUtil.m
//  融云-Demo
//
//  Created by TailC on 16/5/16.
//  Copyright © 2016年 TailC. All rights reserved.
//

#import "TCDatabseUtil.h"
#import <FMDB.h>

@interface TCDatabseUtil ()

@property (nonatomic,readwrite,strong) FMDatabaseQueue * dbQueue;

@end

@implementation TCDatabseUtil

+ (instancetype)sharedInstance {
	static id sharedInstance = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}


#pragma mark 创建数据库
-(FMDatabaseQueue *)DatabaseWithDBName:(NSString *)dbName
{
	NSString * dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:dbName];
	NSLog(@"DB path is %@",dbPath);
	_dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
	return _dbQueue;
}
#pragma mark 创建表
-(BOOL)createTable:(NSString *)table WithKey:(NSDictionary *)keyTypes
{
	__block BOOL ret = YES;
	NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"create table if not exists %@ (",table]];
	NSArray *keys = [keyTypes allKeys];
	for (NSInteger i = 0; i < keys.count; i++) {
		switch ([[keyTypes valueForKey:keys[i]]integerValue]) {
			case DBdatatypeNSString:
				[sql appendFormat:@"%@ %@",keys[i],@"text"];
				break;
			case DBdatatypeInteger:
				[sql appendFormat:@"%@ %@",keys[i],@"integer"];
				break;
			case DBdatatypeNSdate:
				[sql appendFormat:@"%@ %@",keys[i],@"date"];
				break;
			case DBdatatypeNSdata:
				[sql appendFormat:@"%@ %@",keys[i],@"blob"];
				break;
			case DBdatatypeBoolean:
				[sql appendFormat:@"%@ %@",keys[i],@"boolean"];
				break;
			case DBdatatypeDouble:
				[sql appendFormat:@"%@ %@",keys[i],@"double"];
				break;
			default:
				break;
		}
		if (i<keys.count-1) {
			[sql appendString:@","];
		}
	}
	[sql appendString:@")"];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		if (![db executeUpdate:sql]) {
			ret = NO;
		}
	}];
	return ret;
}
#pragma mark 添加
-(BOOL)insertInTable:(NSString *)table WithKey:(NSDictionary *)keyValues
{
	__block BOOL ret = YES;
	NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"insert into %@ (", table]];
	NSMutableString *values = [[NSMutableString alloc] initWithString:@") values ("];
	NSArray *keys = [keyValues allKeys];
	for (NSInteger i = 0; i < keys.count; i++) {
		[sql appendString:keys[i]];
		[values appendString:@"?"];
		if (i<keys.count-1) {
			[sql appendString:@","];
			[values appendString:@","];
		}
	}
	[sql appendFormat:@"%@%@",values,@")"];
	[_dbQueue inDatabase:^(FMDatabase *db) {
		if (![db executeUpdate:sql withArgumentsInArray:[keyValues allValues]]) {
			ret = NO;
		}
		
	}];
	return ret;
}
#pragma mark 修改更新
-(BOOL)updateInTable:(NSString *)table WithKey:(NSDictionary *)keyValues
{
	__block BOOL ret = YES;
	for (NSString *key in keyValues) {
		NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = ?", table, key];
		[_dbQueue inDatabase:^(FMDatabase *db) {
			if (![db executeUpdate:sql,[keyValues valueForKey:key]]) {
				ret = NO;
			}
			
		}];
	}
	return ret;
}
#pragma mark --条件更新
-(BOOL)updateInTable:(NSString *)table WithKey:(NSDictionary *)keyValues whereCondition:(NSDictionary *)condition
{
	__block BOOL ret = YES;
	for (NSString *key in keyValues) {
		NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?", table, key, [condition allKeys][0]]];
		[_dbQueue inDatabase:^(FMDatabase *db) {
			if (![db executeUpdate:sql,[keyValues valueForKey:key],[keyValues valueForKey:[condition allKeys][0]]]) {
				ret = NO;
			}
		}];
	}
	return ret;
}

#pragma mark 查询
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes
{
	__block NSMutableArray * arr = [NSMutableArray array];
	__weak typeof(self) wSelf = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet * set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ limit 10",table]];
		arr = [wSelf getArrWithFMResultSet:set keyTypes:keyTypes];
	}];
	return arr;
}
#pragma mark --条件查询数据库中的数据
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereCondition:(NSDictionary *)condition
{
	__block NSMutableArray * arr = [NSMutableArray array];
	__weak typeof(self) wSelf = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet * set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ = ? limit 10",table, [condition allKeys][0]], [condition valueForKey:[condition allKeys][0]]];
		arr = [wSelf getArrWithFMResultSet:set keyTypes:keyTypes];
	}];
	return arr;
}
#pragma mark --模糊查询 某字段以指定字符串开头的数据
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key beginWithStr:(NSString *)str
{
	__block NSMutableArray * arr = [NSMutableArray array];
	__weak typeof(self) wSelf = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet * set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ like %@%% limit 10",table, key, str]];
		arr = [wSelf getArrWithFMResultSet:set keyTypes:keyTypes];
	}];
	return arr;
}
#pragma mark --模糊查询 某字段包含指定字符串的数据
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key containStr:(NSString *)str
{
	__block NSMutableArray * arr = [NSMutableArray array];
	__weak typeof(self) wSelf = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet * set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ like %%%@%% limit 10",table, key, str]];
		arr = [wSelf getArrWithFMResultSet:set keyTypes:keyTypes];
	}];
	return arr;
}
#pragma mark --模糊查询 某字段以指定字符串结尾的数据
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key endWithStr:(NSString *)str
{
	__block NSMutableArray * arr = [NSMutableArray array];
	__weak typeof(self) wSelf = self;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		FMResultSet * set = [db executeQuery:[NSString stringWithFormat:@"select * from %@ where %@ like %%%@ limit 10",table, key, str]];
		arr = [wSelf getArrWithFMResultSet:set keyTypes:keyTypes];
	}];
	return arr;
}
#pragma mark --CommonMethod
-(NSMutableArray *)getArrWithFMResultSet:(FMResultSet *)result keyTypes:(NSDictionary *)keyTypes
{
	NSMutableArray *tempArr = [NSMutableArray array];
	while ([result next]) {
		NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
		for (int i = 0; i < keyTypes.count; i++) {
			NSString *key = [keyTypes allKeys][i];
			switch ([[keyTypes valueForKey:key] integerValue]) {
				case DBdatatypeNSString:
					//                字符串
					[tempDic setValue:[result stringForColumn:key] forKey:key];
					break;
				case DBdatatypeInteger:
					//                带符号整数类型
					[tempDic setValue:[NSNumber numberWithInt:[result intForColumn:key]]forKey:key];
					break;
				case DBdatatypeNSdata:
					//                二进制data
					[tempDic setValue:[result dataForColumn:key] forKey:key];
					break;
				case DBdatatypeNSdate:
					//                date
					[tempDic setValue:[result dateForColumn:key] forKey:key];
					break;
				case DBdatatypeBoolean:
					//                BOOL型
					[tempDic setValue:[NSNumber numberWithBool:[result boolForColumn:key]] forKey:key];
					break;
				case DBdatatypeDouble:
					//                Double型
					[tempDic setValue:[NSNumber numberWithDouble:[result doubleForColumn:key]] forKey:key];
					break;
				default:
					break;
			}
		}
		[tempArr addObject:tempDic];
	}
	return tempArr;
	
}
#pragma mark 清理/删除数据
-(BOOL)deleteInTable:(NSString *)table WithKey:(NSDictionary *)keyValues
{
	__block BOOL ret = YES;
	for (NSString *key in keyValues) {
		NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=?", table, key];
		[_dbQueue inDatabase:^(FMDatabase *db) {
			if (![db executeUpdate:sql,[keyValues valueForKey:key]]) {
				ret = NO;
			}
		}];
	}
	return ret;
}
-(BOOL)cleanTable:(NSString *)table
{
	__block BOOL ret = YES;
	[_dbQueue inDatabase:^(FMDatabase *db) {
		if (![db executeUpdate:[NSString stringWithFormat:@"delete from %@",table]]) {
			ret = NO;
		}
	}];
	return ret;
}



@end
