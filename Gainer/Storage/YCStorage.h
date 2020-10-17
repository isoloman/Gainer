//
//  YCStorage.h
//  DaGuZhe
//
//  Created by administrator on 2017/7/24.
//  Copyright © 2017年 star. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCStorage : NSObject
//读写文件
+ (instancetype)shareInstance;

/*!
 @brief 将本地的文件移除
 @param path 要移除的文件名
 */
+ (void) removeData:(NSString *)path;

+ (void) removeData:(NSString *)path complete:(void (^)(BOOL result))complete;

/*!
 @brief 将信息(object：仅限数组、字典、字符串)保存在本地
 @param object 要保存的object
 @param toPath 要保存文件名
 */
+ (void) writeData:(id)object toFilepath:(NSString *)toPath;

+ (void) writeData:(id)object toFilepath:(NSString *)toPath complete:(void (^)(BOOL result))complete;

/*!
 @brief 将信息(object：仅限数组、字典、字符串)读取出来
 @param path 保存文件名
 @return 返回存储的信息
 */
+ (id) readDataFromFilepath:(NSString *)path;

//归档、解档文件

/*!
 @brief 将信息归档保存在本地
 @param object 要保存的object（必须遵循NSCoding协议）
 @param key 要保存文件名
 */
+(void) encodeData:(id)object forKey:(NSString *)key;

/*!
 @brief 将信息解档
 @param string 要解档文件名
 */
+(id)readArchiverDataFromFilePath:(NSString *)string;

@end
