//
//  TCDatabseUtil.h
//  融云-Demo
//
//  Created by TailC on 16/5/16.
//  Copyright © 2016年 TailC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  可以存储数据类型  string  integer  data  boolean  date
 *  keyTypes      存储的字段  以及对应数据类型
 *  keyValues     存储的字段  以及对应的值
 */
//数据库数据流类型枚举
typedef NS_ENUM(NSInteger, DBdatatype) {
	DBdatatypeNSString      = 0,
	DBdatatypeInteger       = 1,
	DBdatatypeNSdata        = 2,
	DBdatatypeNSdate        = 3,
	DBdatatypeBoolean       = 4,
	DBdatatypeDouble        = 5,
};

@class FMDatabaseQueue;

@interface TCDatabseUtil : NSObject

/**
 *  单例
 *
 *  @return DataBaseHelper
 */
+ (instancetype)sharedInstance;

/**
 *  创建数据库
 *
 *  @param dbName 数据库名称(带后缀.sqlite)
 *
 *  @return DatabaseQueue
 */
-(FMDatabaseQueue *)DatabaseWithDBName:(NSString *)dbName;

/**
 *  建表
 *
 *  @param table    表名
 *  @param keyTypes 所含字段以及对应字段类型 字典
 */
-(BOOL)createTable:(NSString *)table WithKey:(NSDictionary *)keyTypes;

/**
 *  表添加值
 *
 *  @param table     表名
 *  @param keyValues 字段及对应的值
 */
-(BOOL)insertInTable:(NSString *)table WithKey:(NSDictionary *)keyValues;

/**
 *  查询数据 限制数据条数10
 *
 *  @param table     表名
 *  @param keyValues 查询字段以及对应字段类型 字典
 *
 *  @return 查询结果字典数组
 */
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes;

/**
 *  条件查询表中的数据 限制数据条数10
 *
 *  @param table     表名
 *  @param keyValues 查询字段以及对应字段类型 字典
 *  @param condition 条件
 *
 *  @return 查询结果字典数组
 */
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereCondition:(NSDictionary *)condition;

/**
 *  模糊查询 某字段以指定字符串开头的数据 限制数据条数10
 *
 *  @param table     表名
 *  @param keyValues 查询字段以及对应字段类型 字典
 *  @param key       条件字段
 *  @param str       开头字符串
 *
 *  @return 查询结果字典数组
 */
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key beginWithStr:(NSString *)str;

/**
 *  模糊查询 某字段包含指定字符串的数据 限制数据条数10
 *
 *  @param table     表名
 *  @param keyValues 查询字段以及对应字段类型 字典
 *  @param key       条件字段
 *  @param str       包含字符串
 *
 *  @return 查询结果字典数组
 */
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key containStr:(NSString *)str;

/**
 *  模糊查询 某字段以指定字符串结尾的数据 限制数据条数10
 *
 *  @param table     表名
 *  @param keyValues 查询字段以及对应字段类型 字典
 *  @param key       条件字段
 *  @param str       结尾字符串
 *
 *  @return 查询结果字典数组
 */
-(NSMutableArray *)selectInTable:(NSString *)table WithKey:(NSDictionary *)keyTypes whereKey:(NSString *)key endWithStr:(NSString *)str;

/**
 *  给指定的表更新值
 *
 *  @param table     表名
 *  @param keyValues 要更新字段及对应的值 字典
 *
 *  @return YES/NO
 */
-(BOOL)updateInTable:(NSString *)table WithKey:(NSDictionary *)keyValues;

/**
 *  条件更新
 *
 *  @param table     表名
 *  @param keyValues 要更新字段及对应的值 字典
 *  @param condition 条件
 *
 *  @return YES/NO
 */
-(BOOL)updateInTable:(NSString *)table WithKey:(NSDictionary *)keyValues whereCondition:(NSDictionary *)condition;

/**
 *  删除
 *
 *  @param table        表名
 *  @param keyValues    字段及对应的值 字典
 *
 *  @return YES/NO
 */
-(BOOL)deleteInTable:(NSString *)table WithKey:(NSDictionary *)keyValues;

/**
 *  删除表（只删除数据不删除数据库）
 *
 *  @param table 表名
 *
 *  @return YES/NO
 */
-(BOOL)cleanTable:(NSString *)table;


@end
