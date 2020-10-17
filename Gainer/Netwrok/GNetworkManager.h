//
//  GNetworkManager.h
//  Gainer
//
//  Created by Gloryyin on 2020/10/17.
//  Copyright © 2020 Gloryyin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GNetworkManager : NSObject

//绑定信号源
+ (NSURLSessionDataTask *)changeAgentPostsWithUserId:(NSString *)idstr token:(NSString *)token smallTransactionNumber:(NSString *)smallTransactionNumber origin_user_id:(NSString *)origin_user_id;
//MARK:解绑信号源
+ (NSURLSessionDataTask *)unbindWithId:(NSString *)idstr token:(NSString *)token;
//MARK:获取token
+ (NSURLSessionDataTask *)getTokenWithUserName:(NSString *)name password:(NSString *)password completion:(void(^)(NSString * token))completion;
//MARK:获取userID
+ (NSURLSessionDataTask *)getUserIdWithToken:(NSString *)token completion:(void(^)(NSString * userId))completion;
//MARK:获取开单信息
+ (NSURLSessionDataTask *)getOpenOrderListCompletion:(void(^)(id))completion;
//MARK:获取当前所有跟单机构
+ (NSURLSessionDataTask *)getPagePlan:(NSString *)userId token:(NSString *)token completion:(void(^)(NSArray * bindIds,NSArray * unBindIds))completion;
@end

NS_ASSUME_NONNULL_END
