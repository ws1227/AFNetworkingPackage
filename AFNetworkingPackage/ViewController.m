//
//  ViewController.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/21.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Request.h"
#import "WSNetworking.h"
#import "WSNetworkResponse.h"
#import "WSNetworkRequest.h"
#import "WSNetworking+Cache.h"

#ifdef DEBUG

#define DLog( s, ... ) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] )

#else

#define DLog( s, ... )

#endif
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    WSNetworking *net=[[WSNetworking alloc]init];
    
    DLog(@"返回缓存%@",[WSNetworking getCacheFileSize]);

//    [WSNetworking clearCaches];
    
    
//    [[WSNetworking networkManager].get(@"/api/hp/more/1000000").showHUDTexts(@"正在加载") requestCallback:^(WSNetworkRequest *request, WSNetworkResponse *response) {
//        if (!response.error) {
//            DLog(@"请求结果%@",response.rawData);
//
//        }
//      
//        
//     }];
    
    
    [WSNetworking networkManager].get(@"http://itunes.apple.com/lookup?id=1140827531").showHUDTexts(@"正在请求数据").isCacheData(NO).responseObject=^(WSNetworkRequest *request, WSNetworkResponse *response) {
        
        DLog(@"请求结果2 %@：%@",request.iscache?@"YES":@"NO",response.rawData);

    };
//
//    [WSNetworking IsSetupCache:NO];
//    
//    net.get(@"http://itunes.apple.com/lookup?id=1140827531").showHUDTexts(@"正在加载").callback(
//                                                                      ^(WSNetworkRequest *request, WSNetworkResponse *response) {
//                                                                          NSLog(@"请求结果3：%@",response.rawData);
//                                                                          
//                                                                      }
//    );
    
//     [net.get(@"http://itunes.apple.com/lookup?id=1140827531") requestStarWithSuccess:^(id responseObject) {
//         NSLog(@"请求结果4：%@",responseObject);
//
//     } failed:^(NSError *error) {
//         NSLog(@"❎4：%@",error);
//   
//     }];
//    
    // Do any additional setup after loading the view, typically from a nib.
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
