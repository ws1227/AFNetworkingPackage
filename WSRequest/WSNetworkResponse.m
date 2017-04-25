//
//  WSNetworkResponse.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworkResponse.h"

@implementation WSNetworkResponse

+ (instancetype)responseWithRawData:(id)rawData error:(NSError *)error
{
    WSNetworkResponse *response = [[self alloc] init];
    response.rawData = rawData;
    response.error = error;
    
    return response;
}
@end
