//
//  WSNetworkResponse.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSNetworkResponse : NSObject
/** 原始数据 */
@property (nonatomic, strong) id rawData;

/** 错误 */
@property (nonatomic, strong) NSError *error;

/**
 创建一个响应对象
 
 @param rawData 原始数据
 @param error 错误
 @return 响应对象
 */
+ (instancetype)responseWithRawData:(id)rawData error:(NSError *)error;

@end
