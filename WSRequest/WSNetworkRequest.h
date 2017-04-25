//
//  WSNetworkRequest.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSNetworkEnum.h"

@interface WSNetworkRequest : NSObject

/** 请求地址 */
@property (nonatomic, copy) NSString *urlStr;

/** 请求方法 */
@property (nonatomic, assign) WSRequestMethod method;

/** 请求参数 */
@property (nonatomic, strong) NSDictionary *params;

/** 请求头 */
@property (nonatomic, strong) NSDictionary *header;

/** 缓存方式 */
@property (nonatomic, assign) BOOL iscache;
/** 是否显示提示框*/
@property (nonatomic, strong) NSString * showHUDText;

/** 请求序列化格式 */
@property (nonatomic, assign) WSRequestSerializer requestSerializer;

/** 请求超时时间 */
@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;


/**
 创建一个网络请求对象
 
 @param urlStr 请求地址
 @param method 请求方法
 @param params 请求参数
 @return 网络请求对象
@end
 */
+ (instancetype)requestWithUrlStr:(NSString *)urlStr method:(WSRequestMethod)method params:(NSDictionary *)params;

@end
