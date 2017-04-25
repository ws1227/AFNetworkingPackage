//
//  WSNetworkEnum.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#ifndef WSNetworkEnum_h
#define WSNetworkEnum_h


typedef NS_ENUM(NSUInteger, WSNetworkStatus) {
    /** 网络状态未知 */
    DKNetworkStatusUnknown,
    /** 无网络 */
    DKNetworkStatusNotReachable,
    /** 手机网络（蜂窝） */
    DKNetworkStatusReachableViaWWAN,
    /** WIFI网络 */
    DKNetworkStatusReachableViaWiFi
};

typedef NS_ENUM(NSUInteger, WSRequestSerializer) {
    /** 请求数据为二进制格式 */
    WSRequestSerializerHTTP,
    /** 请求数据为JSON格式 */
    WSRequestSerializerJSON
};

typedef NS_ENUM(NSUInteger, WSResponseSerializer) {
    /** 响应数据为JSON格式*/
    WSResponseSerializerJSON,
    /** 响应数据为二进制格式*/
    WSResponseSerializerHTTP
};

typedef NS_ENUM(NSUInteger, WSRequestMethod) {
    /** GET请求 */
    WSRequestMethodGET,
    /** POST请求 */
    WSRequestMethodPOST,
    /** PUT请求 */
    WSRequestMethodPUT,
    /** DELETE请求 */
    WSRequestMethodDELETE,
    /** PATCH请求 */
    WSRequestMethodPATCH
};

#endif /* WSNetworkEnum_h */
