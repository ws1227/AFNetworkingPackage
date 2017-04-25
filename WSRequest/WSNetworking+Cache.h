//
//  WSNetworking+Cache.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/24.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworking.h"
#define  WeakSelf(name,className)  __weak typeof(className)name=className;

@interface WSNetworking (Cache)
/**
 *  添加缓存
 *
 *  @param responseObject 请求成功数据
 *  @param urlString      请求地址
 *  @param params         拼接的参数
 */

- (void)cacheResponseObject:(id)responseObject urlString:(NSString *)urlString parameters:(id)params;


/**
 *  读取缓存
 *
 *  @param url    请求地址
 *  @param params 拼接的参数
 *
 *  @return 数据data
 */
- (id)cahceResponseWithURL:(NSString *)url parameters:(id)params;
/**
 *  清理缓存
 */
+ (void)clearCaches;

/**
 *  获取网络缓存文件大小
 *
 *  @return 多少内存
 */
+ (NSString *)getCacheFileSize;

@end
