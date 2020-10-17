//
//  YCStorage.m
//  DaGuZhe
//
//  Created by administrator on 2017/7/24.
//  Copyright © 2017年 star. All rights reserved.
//

#import "YCStorage.h"

//线程队列名称
static char *queueName = "YCStorageQueue";

@implementation YCStorage{
    //读写队列
    dispatch_queue_t _queue;
}

+ (instancetype)shareInstance
{
    static YCStorage * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance->_queue = dispatch_queue_create(queueName, DISPATCH_QUEUE_CONCURRENT);
    });
    
    return instance;
}

+ (id) allocWithZone:(struct _NSZone *)zone{
    return [YCStorage shareInstance];
}

- (id) copyWithZone:(struct _NSZone *)zone
{
    return [YCStorage shareInstance] ;
}


+(NSDictionary * )readDataFromFilepathClass:(NSString *)path{
    NSString *path1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [path1 stringByAppendingPathComponent:path];
    
    NSDictionary * ob = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return ob;
}

//移除文件
+ (void)removeData:(NSString *)path{
    [self removeData:path complete:nil];
}

+ (void) removeData:(NSString *)path complete:(void (^)(BOOL result))complete{
    YCStorage * instance = [YCStorage shareInstance];
    dispatch_sync(instance -> _queue, ^{
        NSString *path1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *filePath = [path1 stringByAppendingPathComponent:path];
        
        NSFileManager * manager = [NSFileManager defaultManager];
        BOOL result = [manager removeItemAtPath:filePath error:nil];
        
        if (complete) {
            complete(result);
        }
    });
}

//写入文件
+ (void)writeData:(id)object toFilepath:(NSString *)toPath{
    [self writeData:object toFilepath:toPath complete:nil];
}

+ (void)writeData:(id)object toFilepath:(NSString *)toPath complete:(void (^)(BOOL))complete{
    
    YCStorage * instance = [YCStorage shareInstance];
    dispatch_barrier_sync(instance->_queue, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"objectClass"]];
        NSMutableDictionary * classDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [classDic setValue:NSStringFromClass([object class]) forKey:toPath];
        
        //    NSLog(@"class = %@ ,%@, %@",classDic,NSStringFromClass([[NSArray new] class]),[object class]);
        
        NSString *filePath = [path stringByAppendingPathComponent:toPath];
        [object writeToFile:filePath atomically:YES];
        
        NSString *classFilePath = [path stringByAppendingPathComponent:@"objectClass"];
        BOOL result = [classDic writeToFile:classFilePath atomically:YES];
        
        if (complete) {
            complete(result);
        }
        //    NSLog(@"isSucess = %d \n %@\n%@",[object writeToFile:filePath atomically:YES],filePath,classFilePath);
    });
    
}
//读取文件
+ (id )readDataFromFilepath:(NSString *)path{
    
    __block id ob ;
    
    YCStorage * instance = [YCStorage shareInstance];
    
    dispatch_sync(instance -> _queue, ^{
        NSDictionary *classDic = [self readDataFromFilepathClass:@"objectClass"];
        NSString * classStr = classDic[path];
        
        NSString *path1 = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        
        NSString *filePath = [path1 stringByAppendingPathComponent:path];
        
        
        NSError * error;
        if ([classStr isEqualToString:NSStringFromClass([[NSArray new] class])]
            || [classStr isEqualToString:NSStringFromClass([[NSMutableArray new] class])]) {
            
            ob = [NSArray arrayWithContentsOfFile:filePath];
        }
        else if([classStr isEqualToString:NSStringFromClass([[NSDictionary new]class])]
                || [classStr isEqualToString:NSStringFromClass([[NSMutableDictionary new] class])]){
            
            ob = [NSDictionary dictionaryWithContentsOfFile:filePath];
        }
        else if ([classStr isEqualToString:NSStringFromClass([[NSString new] class])] ||
                 [classStr isEqualToString:NSStringFromClass([[NSMutableString new] class])]){
            
            ob = [NSString stringWithContentsOfFile:filePath encoding:4 error:&error];
        }
    });
    
    return ob;
}
//归档
+(void) encodeData:(id)object forKey:(NSString *)key{
    
    YCStorage * instance = [YCStorage shareInstance];
    
    dispatch_barrier_sync(instance -> _queue, ^{
        NSMutableData *data = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:key];
        
        [archiver encodeObject:object forKey:key];
        [archiver finishEncoding];
        BOOL sucess = [data writeToFile:filePath atomically:YES];
            NSLog(@"encode data %@",sucess==YES?@"sucess":@"fail");
    });
    
}
//解档
+(id)readArchiverDataFromFilePath:(NSString *)string{
    
    __block id obj;
    YCStorage * instance = [YCStorage shareInstance];
    dispatch_sync(instance -> _queue, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:string];
        NSData * data = [[NSData alloc]initWithContentsOfFile:filePath];
        
        //    NSLog(@"%@",filePath);
        
        NSKeyedUnarchiver *unarchiver;
        if (data) {
            unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
        }
        
         obj = [unarchiver decodeObjectForKey:string];
        [unarchiver finishDecoding];
    });
    
    return obj;
}

@end
