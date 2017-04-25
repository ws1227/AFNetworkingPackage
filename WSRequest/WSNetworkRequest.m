//
//  WSNetworkRequest.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworkRequest.h"


@implementation WSNetworkRequest
+ (instancetype)requestWithUrlStr:(NSString *)urlStr method:(WSRequestMethod)method params:(NSDictionary *)params
{
    WSNetworkRequest *request = [[self alloc] init];
    request.urlStr = urlStr;
    request.method = method;
    request.params = params;
    
    return request;
}

@end
