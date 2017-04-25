//
//  WSNetworkSessionManager.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "WSNetworkResponse.h"

/** 请求任务Block */
typedef void(^WSNetworkTaskBlock)(NSURLSessionDataTask *task, WSNetworkResponse *response);

/**
 封装表单数据上传协议
 */
@protocol WSMultipartFormData <AFMultipartFormData>

@end

/**
 遵守协议，让编译通过，调用AFN私有API
 - dataTaskWithHTTPMethod:URLString:parameters:success:failure
 */
@protocol WSNetWorkSessionManagerProtocol <NSObject>

@optional

/**
 AFN底层网络请求方法
 
 @param method HTTP请求方法
 @param URLString 请求地址
 @param parameters 参数字典
 @param success 成功回调
 @param failure 失败回调
 @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgress
                                downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end



@interface WSNetworkSessionManager : AFHTTPSessionManager
- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completion:(WSNetworkTaskBlock)completion;


@end
