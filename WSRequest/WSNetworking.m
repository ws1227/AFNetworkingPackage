//
//  WSNetworking.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworking.h"
#import "WSNetworkRequest.h"
#import "WSNetworkSessionManager.h"
#import "WSNetworking+Cache.h"
#import "MBProgressHUD+MJ.h"
#import "UIView+Toast.h"
#define KeyWindow       [[UIApplication sharedApplication] keyWindow]

#ifdef DEBUG // 调试状态, 打开LOG功能
#define DeBugLog(FORMAT, ...) fprintf(stderr,"[%s:%d行]\n %s\n\n",__func__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define BNBLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define BNBLog(...)
#endif




static WSNetworking *networkManager;
static WSNetworkSessionManager *sessionManager;
static NSMutableArray<NSURLSessionTask *> *allSessionTask;

static CGFloat const kDefaultTimeoutInterval = 10.f;


@interface WSNetworking ()
@property (nonatomic, strong) WSNetworkRequest *request;
@end

@implementation WSNetworking
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [super allocWithZone:zone];
    });
    return networkManager;
}


- (WSNetworking *(^)(NSString *))post
{
    return ^WSNetworking *(NSString *url){
        self.request.method = WSRequestMethodPOST;
        self.request.urlStr = url;
        return self;
    };
}
- (WSNetworking *(^)(NSString *))get
{
    return ^WSNetworking *(NSString *url){
        self.request.method = WSRequestMethodGET;
        self.request.urlStr = url;
        return self;
    };
}
- (WSNetworking *(^)(NSString *))put
{
    return ^WSNetworking *(NSString *url){
        self.request.method = WSRequestMethodPUT;
        self.request.urlStr = url;
        return self;
    };
}

- (WSNetworking *(^)(NSString *))deletes
{
    return ^WSNetworking *(NSString *url){
        self.request.method = WSRequestMethodDELETE;
        self.request.urlStr = url;
        return self;
    };
}

- (WSNetworking *(^)(NSString *))patch
{
    return ^WSNetworking *(NSString *url){
        self.request.method = WSRequestMethodPATCH;
        self.request.urlStr = url;
        return self;
    };
}

- (WSNetworking *(^)(NSDictionary *header))header
{
    
    return ^WSNetworking *(NSDictionary *header){
        [WSNetworking setNetworkHeader:header];
        return self;
    };
    
}

- (WSNetworking *(^)(BOOL isCache))isCacheData;
{
    return ^WSNetworking *(BOOL cachedata){
        [self setupCacheType:cachedata];
        return self;
    };
}
- (WSNetworking *(^)(NSString * text))showHUDTexts;
{
    
    return ^WSNetworking *(NSString * text){
        [self sHowViewHUD:text];
        return self;
    };
}

- (WSNetworking *(^)(NSDictionary *params))params
{
    WSNetworking * (^ params)(NSDictionary *paramss) =^(NSDictionary *params){
        self.request.params = params;
        return  self;
        
    };
    return params;
    
    
    
}


-(void)setResponseObject:(WSNetworkBlock)responseObject
{
    _responseObject=responseObject;
    
    [self request:self.request callback:^(WSNetworkRequest *request, WSNetworkResponse *response) {
        responseObject(request, response);
        self.request = nil;
    }];
    
}

- (void)requestCallback:(WSNetworkBlock)callback
{
    
    [self request:self.request callback:^(WSNetworkRequest *request, WSNetworkResponse *response) {
        
        callback(request, response);
        self.request = nil;
    }];
}

- (void (^)(WSNetworkBlock))callback
{
    return ^void(WSNetworkBlock block){
        [self request:self.request callback:^(WSNetworkRequest *request, WSNetworkResponse *response) {
            block(request, response);
            self.request = nil;
        }];
    };
}

- (void)requestStarWithSuccess:(RequestSuccess)success failed:(RequestFaild)failed
{
    __weak typeof(self)weakSelf=self;
    
   
        [weakSelf request:weakSelf.request callback:^(WSNetworkRequest *request, WSNetworkResponse *response) {
        
            if (response.error) {
                failed(response.error);
            }else{
               success(response.rawData);
             }
            weakSelf.request = nil;
            
                }];
}


- (NSURLSessionTask *)request:(WSNetworkRequest *)request callback:(WSNetworkBlock)callback
{
    
    NSAssert(request.urlStr.length, @"DKNetworking Error: URL can not be nil");
    
    request.header = WSNetworkManager.networkHeader;
    request.iscache = self.isCache;
    request.showHUDText=self.showHUDText;
    request.requestSerializer = networkManager.networkRequestSerializer;
    request.requestTimeoutInterval = networkManager.networkRequestTimeoutInterval;
    
    NSString *URL = request.urlStr;
    NSDictionary *parameters = request.params;
    NSString *method = self.methods[request.method];
    
    
    WeakSelf(weakself, self);
     if (request.iscache == YES)
     {
      id cacheData = [self cahceResponseWithURL:URL parameters:parameters];
         callback(request, [WSNetworkResponse responseWithRawData:cacheData error:nil]);

         
     }
    /*****为了方便也可以直接在这写一个固定的提示文字 用的时候直接写空即可****/
   // request.showHUDText=@"正在加载";
    
    if (request.showHUDText) {
       //为了一个视图不会重复出现两个提示框则先隐藏一个
        [MBProgressHUD hideHUDForView:[self activityViewController ].view animated:YES];

        [MBProgressHUD showMessage:request.showHUDText toView:[self activityViewController].view];
        
    }
    
    NSURLSessionTask *sessionTask = [sessionManager requestWithMethod:method URLString:URL parameters:parameters completion:^(NSURLSessionDataTask *task, WSNetworkResponse *response) {
        [[WSNetworking allSessionTask] removeObject:task];
      
        
        [MBProgressHUD hideHUDForView:[self activityViewController ].view animated:YES];
        
        if (isOpenLog)
            DeBugLog(@"*******log输出**********\n%@",response.error ? response.error : [ self WS_jsonString:response.rawData ]);
        if (callback)
        {
            //请求失败 超时没网等等
            if (response.error) {
                
                [[self activityViewController].view makeToast:@"请求错误" duration:0.0 position:@"CSToastPositionCenter"];
                
            }
            else{
                //请求成功 状态正确 正确返回数据
                if ( [self isSuccess:response.rawData]) {
                    
                    callback(request,response);

                    if (self.isCache == YES&&response.rawData) {
                        
                        [weakself cacheResponseObject:response.rawData urlString:URL parameters:parameters];
                    }
                    
 
                }
                //请求成功 状态错误 显示失败原因

                else{
                    [self showLoadRequestSuccessButAppearErrorWithResponseObject:response.rawData];
                }
                
                
            }
            
        }
       
        
    }];
    
    [[WSNetworking allSessionTask] addObject:sessionTask];
    
    return sessionTask;
}


/**
 *
 *  取消某个下载任务呀的请求
 *	@param url URL，可以是绝对URL，也可以是path（也就是不包括baseurl）
 */
+ (void)cancelDowntTaskwithURL:(NSString *)url
{
    if (url == nil) {
        return;
    }
    [[WSNetworking allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]]
            ) {
            if (isOpenLog)
            {
            DeBugLog(@"被取消的下载的网络请求：%@",task);
            }
            [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                
            }];
            if ([WSNetworking allSessionTask]>0) {
                [[WSNetworking allSessionTask] removeObject:task];
                
            }
            return;
        }
        
        
    }];
    
    
    
}

/**
 *
 *	取消所有下载任务请求
 */
+ (void)cancelAllDownTask
{
    
    @synchronized(self) {
        [[WSNetworking allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
                
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    
                }];
            }
        }];
        
        [[WSNetworking allSessionTask] removeAllObjects];
    };
}


-(BOOL)isSuccess:(id )responseObject
{
    
    
    if (self.NetworkErrorcode!=nil) {
        if ([responseObject[self.NetworkErrorcode]intValue] ==0) {
            
            return YES;
        }
        else{
            return NO;
        }
        
    }
    else{
        //必须设置一个用于标记成功或者失败的字段才知道请求是否成功  resultCount是ViewController苹果那个接口的标记  使用时请设置自己服务器的字段
        //    [NetworkManger shareManager].errorOrRightCode=@"resultCount";
        
        NSCAssert(self.NetworkErrorcode != nil, @"未设置标记与成功或者失败的字段");
        
        return nil;
        
    }
    
}

//请求失败错误提示
-(void)showLoadRequestSuccessButAppearErrorWithResponseObject:(id )responseObject{
    
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
        
        NSString *tip=responseObject[self.serverFailedTitle];
        //是否显示失败原因
        if (self.isHideServerText==YES) {
            
            
            [self IsHideServerFailText:NO];
            
            
        }
        else{
            
            if ([tip  isKindOfClass:[NSNull class]]) {
                [KeyWindow makeToast:@"未知错误" duration:.5 position:@"CSToastPositionCenter"];
            }
            else{
                 [KeyWindow makeToast:tip duration:.5 position:@"CSToastPositionCenter"];
            }
            
        }
    }
    else{
        
        DeBugLog(@"请求结果不是字典类型");
        
    }
    
    
    
}


+ (void)initialize
{
    // 所有请求共用一个SessionManager
    sessionManager = [WSNetworkSessionManager manager];
    
    [self initSessionManager];
}
+ (void)setupBaseURL:(NSString *)baseURL
{
    sessionManager = [[WSNetworkSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    
    [self initSessionManager];
}


+ (void)initSessionManager
{
    sessionManager.requestSerializer = networkManager.networkRequestSerializer == WSRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = networkManager.networkResponseSerializer == WSResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
     sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];

    
    // 请求超时设定
    [sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    sessionManager.requestSerializer.timeoutInterval = networkManager.networkRequestTimeoutInterval ?: kDefaultTimeoutInterval;;
    [sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
    
    if (networkManager.networkHeader)
        [networkManager.networkHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id obj, BOOL * _Nonnull stop) {
            [sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    
}
- (void)setupCacheType:(BOOL)cacheType
{
    _isCache = cacheType;
}

+ (void)openLog:(BOOL)open;
{
    isOpenLog = open;
}


- (WSNetworking *(^)(WSRequestSerializer requestSerializer))requestSerializer
{
    return ^WSNetworking *(WSRequestSerializer requestSerializer){
        [self setRequestSerializer:requestSerializer];
        return self;
    };
}

- (WSNetworking *(^)(WSResponseSerializer responseSerializer))responseSerializer
{
    return ^WSNetworking *(WSResponseSerializer responseSerializer){
        [self setResponseSerializer:responseSerializer];
        return self;
    };
}

- (WSNetworking *(^)(WSRequestTimeoutInterval requestTimeoutInterval))requestTimeoutInterval
{
    return ^WSNetworking *(WSRequestTimeoutInterval requestTimeoutInterval){
        [self setRequestTimeoutInterval:requestTimeoutInterval];
        return self;
    };
}


#pragma mark Reset

/***请求状态成功 数据失败 提示文字由后台而定*****/

+(void)IsHideServerFailText:(BOOL )isHide
{
    [WSNetworkManager IsHideServerFailText:isHide];
}
-(void)IsHideServerFailText:(BOOL )isHide
{
    
    _isHideServerText=isHide;
}

+(void)setShowServerFailContant:(NSString * )text
{
    [WSNetworkManager setShowServerFailContant:text];
    
}

-(void)setShowServerFailContant:(NSString * )text

{
    _serverFailedTitle=text;
    
    
}
+(void)setHUDWithText:(NSString *)text
{
    [WSNetworkManager sHowViewHUD:text];
    
}
- (void)sHowViewHUD:(NSString *)text
{
    _showHUDText = text;
}

+(void)setServerSuccessOrFailCode:(NSString * )code
{
    
    [WSNetworkManager setServerSuccessOrFailCode:code];
    
}

-(void)setServerSuccessOrFailCode:(NSString * )code
{
    _NetworkErrorcode=code;
    
}


+ (void)setRequestSerializer:(WSRequestSerializer)requestSerializer;
{
    [WSNetworkManager setRequestSerializer:requestSerializer];
}

- (void)setRequestSerializer:(WSRequestSerializer)requestSerializer
{
    sessionManager.requestSerializer = requestSerializer == WSRequestSerializerHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    
    _networkRequestSerializer = requestSerializer;
}

+ (void)setResponseSerializer:(WSResponseSerializer)responseSerializer
{
    [WSNetworkManager setResponseSerializer:responseSerializer];
}

- (void)setResponseSerializer:(WSResponseSerializer)responseSerializer
{
    sessionManager.responseSerializer = responseSerializer == WSResponseSerializerHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
    
    _networkResponseSerializer = responseSerializer;
}

+ (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    [WSNetworkManager setRequestTimeoutInterval:time];
}

- (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    [sessionManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    sessionManager.requestSerializer.timeoutInterval = networkManager.networkRequestTimeoutInterval ?: kDefaultTimeoutInterval;;
    [sessionManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    

    _networkRequestTimeoutInterval = time;
}

+ (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [WSNetworkManager setValue:value forHTTPHeaderField:field];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [sessionManager.requestSerializer setValue:value forHTTPHeaderField:field];
    
    if (!_networkHeader) {
        _networkHeader = [NSDictionary dictionaryWithObject:value forKey:field];
    } else {
        NSMutableDictionary *headerTemp = [NSMutableDictionary dictionaryWithDictionary:_networkHeader];
        headerTemp[field] = value;
        _networkHeader = [headerTemp copy];
    }
}

+ (void)setNetworkHeader:(NSDictionary *)networkHeader
{
    if (networkHeader) {
        [networkHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id obj, BOOL * _Nonnull stop) {
            [self setValue:key forHTTPHeaderField:obj];
        }];
    }
}

#pragma mark - Getters && Setters

+ (instancetype)networkManager
{
    if (!networkManager) {
        networkManager = [[self alloc] init];
    }
    return networkManager;
}

- (WSNetworkRequest *)request
{
    if (!_request) {
        _request = [[WSNetworkRequest alloc] init];
    }
    return _request;
}
+ (void)IsSetupCache:(BOOL)cache
{
    
    [WSNetworkManager setupCacheType:cache];
}


/**
 存储所有请求task的数组
 */
+ (NSMutableArray *)allSessionTask
{
    if (!allSessionTask) {
        allSessionTask = [[NSMutableArray alloc] init];
    }
    return allSessionTask;
}

-(NSArray *)methods
{
    return  @[@"GET", @"POST", @"PUT", @"DELETE", @"PATCH"];
    
}



#pragma mark - 查找当前活动窗口
- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows)
        {
            if(tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0)
    {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]])
        {
            activityViewController = nextResponder;
        }
        else
        {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}

- (NSString *)WS_jsonString:(id)data
{
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    // json数据或者NSDictionary转为NSData，responseObject为json数据或者NSDictionary
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
    // NSData转为NSString
return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}





@end
