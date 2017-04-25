//
//  WSNetworking.h
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSNetworkRequest.h"
#import "WSNetworkResponse.h"
#import "WSNetworking.h"

#define WSNetworkManager [WSNetworking networkManager]

static BOOL isOpenLog;
typedef NSTimeInterval WSRequestTimeoutInterval;

/** 请求回调Block */
typedef void(^WSNetworkBlock)(WSNetworkRequest *request, WSNetworkResponse *response);

typedef void(^RequestSuccess)(id responseObject);
typedef void(^RequestFaild)(NSError *error);


@interface WSNetworking : NSObject


/** 是否缓存 */
@property (nonatomic, assign, readonly) BOOL isCache;
/** 提示框文字内容 */
@property (nonatomic, strong, readonly) NSString * showHUDText;
/** 请求状态成功数据失败是否显示后台定义的提示文字 */
@property (nonatomic, assign, readonly) BOOL isHideServerText;
/** 请求数据失败定义的后台返回的错误信息的标记 */
@property (nonatomic, assign, readonly) NSString * serverFailedTitle;
/**后台返回数据的用于标示正确或者错误数据的字段通常用的是statu 由后台数据定***/
@property (nonatomic, assign, readonly) NSString *NetworkErrorcode;



/** 请求序列化格式 */
@property (nonatomic, assign, readonly) WSRequestSerializer networkRequestSerializer;
/** 响应反序列化格式 */
@property (nonatomic, assign, readonly) WSResponseSerializer networkResponseSerializer;
/** 请求超时时间 */
@property (nonatomic, assign, readonly) WSRequestTimeoutInterval networkRequestTimeoutInterval;
/** 请求头 */
@property (nonatomic, strong, readonly) NSDictionary *networkHeader;

/****请求结果***/
@property (nonatomic, strong)WSNetworkBlock responseObject;
@property (nonatomic, strong)RequestSuccess requestSuccess;
@property (nonatomic, strong)RequestFaild requestFaild;

/**
 单例对象
 */
+ (instancetype)networkManager;
/**
 设置接口根路径, 设置后所有的网络访问都使用相对路径
 @param baseURL 根路径
 */
+ (void)setupBaseURL:(NSString *)baseURL;


/** 链式调用 */
- (WSNetworking *(^)(NSString *url))get;
- (WSNetworking *(^)(NSString *))post;
- (WSNetworking *(^)(NSString *url))put;
- (WSNetworking *(^)(NSString *url))deletes;
- (WSNetworking *(^)(NSString *url))patch;
- (WSNetworking *(^)(NSDictionary *header))header;
- (WSNetworking *(^)(BOOL isCache))isCacheData;
- (WSNetworking *(^)(NSString * text))showHUDTexts;

- (WSNetworking *(^)(WSRequestSerializer requestSerializer))requestSerializer;
- (WSNetworking *(^)(WSResponseSerializer responseSerializer))responseSerializer;
- (WSNetworking *(^)(WSRequestTimeoutInterval requestTimeoutInterval))requestTimeoutInterval;


/****设置请求参数****/
- (WSNetworking *(^)(NSDictionary *params))params;
- (void (^)(WSNetworkBlock))callback;
- (void)requestStarWithSuccess:(RequestSuccess)success failed:(RequestFaild)failed;

- (void)requestCallback:(WSNetworkBlock)callback;


#pragma mark - Reset SessionManager

/**
 开启日志打印 (Debug)
 */
+ (void)openLog:(BOOL)open;

/***是否设置缓存*****/

+ (void)IsSetupCache:(BOOL)cache;


/***设置提示文字*****/

+(void)setHUDWithText:(NSString *)text;


/***设置后台返回数据的用于标示正确或者错误的字段*****/

+(void)setServerSuccessOrFailCode:(NSString * )code;


/***请求状态成功 数据失败 是否不显示错误提示，如要永久不显示需要修改实现方法，这里只是单次针对一个请求设定的 提示文字由后台而定*****/

+(void)IsHideServerFailText:(BOOL )isShow;

/***数据请求失败时候后台返回的错误文字的字段 通常类用message 由后台而定*****/
+(void)setShowServerFailContant:(NSString * )text;



/**
 设置网络请求参数的格式 : 默认为二进制格式
 
 @param requestSerializer WSRequestSerializerJSON:JSON格式, DKRequestSerializerHTTP:二进制格式
 */
+ (void)setRequestSerializer:(WSRequestSerializer)requestSerializer;

/**
 设置服务器响应数据格式 : 默认为JSON格式
 
 @param responseSerializer WSResponseSerializerJSON:JSON格式, DKResponseSerializerHTTP:二进制格式
 */
+ (void)setResponseSerializer:(WSResponseSerializer)responseSerializer;

/**
 设置请求超时时间 : 默认10秒
 
 @param time 请求超时时长(秒)
 */
+ (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 设置一对请求头参数
 
 @param value 请求头参数值
 @param field 请求头参数名
 */
+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 设置多对请求头参数
 
 @param networkHeader 请求头参数字典
 */
+ (void)setNetworkHeader:(NSDictionary *)networkHeader;

/**
 *
 *	取消所有下载任务请求
 */
+ (void)cancelAllDownTask;
/**
 *
 *  取消某个下载任务呀的请求
 *	@param url URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
+ (void)cancelDowntTaskwithURL:(NSString *)url;



@end
