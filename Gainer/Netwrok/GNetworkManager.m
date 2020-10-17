//
//  GNetworkManager.m
//  Gainer
//
//  Created by Gloryyin on 2020/10/17.
//  Copyright © 2020 Gloryyin. All rights reserved.
//

#import "GNetworkManager.h"
#import <AFNetworking.h>
#import "AFAppDotNetAPIClient.h"

@implementation GNetworkManager

+ (NSURLSessionDataTask *)unbindWithId:(NSString *)idstr token:(NSString *)token {

    NSString * urlStr = [NSString stringWithFormat:@"http://www.enjoytrader88.com/StrategyPlan/untie?id=%@",idstr];
    
    return  [self post:urlStr parameters:@{} headers:@{@"TOKEN":token} success:^(id respond) {
        NSLog(@"解绑信号源：%@",idstr);
    }];
}

//MARK:绑定信号源
+ (NSURLSessionDataTask *)changeAgentPostsWithUserId:(NSString *)idstr token:(NSString *)token smallTransactionNumber:(NSString *)smallTransactionNumber origin_user_id:(NSString *)origin_user_id{
    
    NSString * urlStr = [NSString stringWithFormat:@"http://enjoytrader88.com/StrategyPlan/addStrategyPlan?bigTransactionNumber=-1&bigTransactionNumberCHECK=true&ratio=2000&documentaryNumber=-1&documentaryNumberCHECK=true&smallTransactionNumber=%@&smallTransactionNumberCHECK=true&stopProfit=-1&stopProfitCHECK=true&stopLoss=-1&stopLossCHECK=true&reverse=false&user_id=%@&origin_user_id=%@",smallTransactionNumber,idstr,origin_user_id];
    
    return  [self post:urlStr parameters:@{} headers:@{@"TOKEN":token} success:^(id respond) {
        NSLog(@"绑定信号源：%@",origin_user_id);
    }];
}

//MARK:获取token
+ (NSURLSessionDataTask *)getTokenWithUserName:(NSString *)name password:(NSString *)password completion:(void(^)(NSString * token))completion{
    NSTimeInterval _t = [[NSDate new] timeIntervalSince1970] *1000;
    NSString * urlStr = [NSString stringWithFormat:@"http://www.enjoytrader88.com/common/Login?_t=%.0f&mobile=%@&password=%@&remember=false",_t ,name,password];
    
    return  [self get:urlStr parameters:@{} headers:@{} success:^(id respond) {
        if (completion) {
            completion(respond);
        }
    }];
}

//MARK:获取userID
+ (NSURLSessionDataTask *)getUserIdWithToken:(NSString *)token completion:(void(^)(NSString * userId))completion{
    NSTimeInterval _t = [[NSDate new] timeIntervalSince1970] *1000;
    NSString * urlStr = [NSString stringWithFormat:@"http://www.enjoytrader88.com/common/sysUsers/3366?_t=%.0f",_t];
    
    return  [self get:urlStr parameters:@{} headers:@{@"TOKEN":token} success:^(id respond) {
//        NSLog(@"%@",respond);
        NSString * userId = [[respond valueForKey:@"id"] stringValue];
        if (completion) {
            completion(userId);
        }
    }];
}

//MARK:获取开单信息
+ (NSURLSessionDataTask *)getOpenOrderListCompletion:(void(^)(id))completion {
    NSString * urlStr = [NSString stringWithFormat:@"http://www.enjoytrader88.com/sorder/transactionList?size=20"];
        
        return  [self get:urlStr parameters:@{} headers:@{@"TOKEN":@""} success:^(id respond) {
    //        NSLog(@"%@",respond);
            if ([respond isKindOfClass:[NSDictionary class]]) {
                if (completion) {
                    completion([respond valueForKey:@"content"]);
                }
            }
            
        }];
}

//MARK:获取当前所有跟单机构
+ (NSURLSessionDataTask *)getPagePlan:(NSString *)userId token:(NSString *)token completion:(void(^)(NSArray * bindIds,NSArray * unBindIds))completion{
    NSTimeInterval _t = [[NSDate new] timeIntervalSince1970] *1000;
    NSString * urlStr = [NSString stringWithFormat:@"http://www.enjoytrader88.com/StrategyPlan/getPagePlan?_t=%0.f&page=0&mechanism=1&user_id=%@",_t,userId];
    return  [self get:urlStr parameters:@{} headers:@{@"TOKEN":token} success:^(id respond) {
    //        NSLog(@"%@",respond);
            if ([respond isKindOfClass:[NSDictionary class]]) {
                NSArray * array = [respond valueForKey:@"content"];
                NSMutableArray * ids = [NSMutableArray new];
                 NSMutableArray * origin_user_ids = [NSMutableArray new];
                for (NSDictionary * mechanism in array) {
                    [origin_user_ids addObject:[[mechanism valueForKey:@"origin_user_id"] stringValue]];
                    [ids addObject:[[mechanism valueForKey:@"id"] stringValue]];
                }
                if (completion) {
                    completion(origin_user_ids,ids);
                }
            }
            
        }];
}

+ (NSURLSessionDataTask *)post:(NSString *)url parameters:(nullable id)parameters headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(void(^)(id respond))success{
    [AFAppDotNetAPIClient sharedClient].requestSerializer = [AFJSONRequestSerializer serializer];
    [AFAppDotNetAPIClient sharedClient].responseSerializer = [AFHTTPResponseSerializer serializer];
    [[AFAppDotNetAPIClient sharedClient].requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [[AFAppDotNetAPIClient sharedClient]
            POST:url parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"responseObject=%@",object);
        if (success) {
            success(object);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=%@",error);
    }];
}

+ (NSURLSessionDataTask *)get:(NSString *)url parameters:(nullable id)parameters headers:(nullable NSDictionary <NSString *, NSString *> *)headers success:(void(^)(id respond))success{
    [AFAppDotNetAPIClient sharedClient].requestSerializer = [AFJSONRequestSerializer serializer];
    [AFAppDotNetAPIClient sharedClient].responseSerializer = [AFHTTPResponseSerializer serializer];
    [[AFAppDotNetAPIClient sharedClient].requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [[AFAppDotNetAPIClient sharedClient]
            GET:url parameters:parameters headers:headers progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        if (!object) {
            object = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        NSLog(@"responseObject=%@",object);
        if (success) {
            success(object);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error=%@",error);
    }];
}
@end
