//
//  WSNetworkSessionManager.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworkSessionManager.h"
@interface WSNetworkSessionManager () <WSNetWorkSessionManagerProtocol>

@end

@implementation WSNetworkSessionManager
- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(id)parameters completion:(WSNetworkTaskBlock)completion
{
    __block WSNetworkResponse *response;
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:method URLString:URLString parameters:parameters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        response = [WSNetworkResponse responseWithRawData:responseObject error:nil];

       
        if (completion) {
            completion(task, response);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"请求错误结果：%@",error);

        response = [WSNetworkResponse responseWithRawData:nil error:error];
        if (completion) {
            completion(task, response);
        }
    }];
    
    [dataTask resume];
    
    return dataTask;
    
}

@end
