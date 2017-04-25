//
//  WSNetworking+Cache.m
//  AFNetworkingPackage
//
//  Created by panhongliu on 2017/4/24.
//  Copyright © 2017年 wangsen. All rights reserved.
//

#import "WSNetworking+Cache.h"
#import <CommonCrypto/CommonDigest.h>
#define CacheDefaults [NSUserDefaults standardUserDefaults]

#ifdef DEBUG // 调试状态, 打开LOG功能
#define NetworkLog(FORMAT, ...) fprintf(stderr,"[%s:%d行]\n %s\n\n",__func__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#define BNBLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define BNBLog(...)
#endif
// 网络缓存文件夹名
#define NetworkCache @"NetworkCache"

@implementation WSNetworking (Cache)


// 仅对一级字典结构起作用
- (NSString *)generateGETAbsoluteURL:(NSString *)url params:(id)params {
    if (params == nil || ![params isKindOfClass:[NSDictionary class]] || [params count] == 0) {
        return url;
    }
    NSString *queries = @"";
    for (NSString *key in params) {
        id value = [params objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            continue;
        } else if ([value isKindOfClass:[NSArray class]]) {
            continue;
        } else if ([value isKindOfClass:[NSSet class]]) {
            continue;
        } else {
            queries = [NSString stringWithFormat:@"%@%@=%@&",
                       (queries.length == 0 ? @"&" : queries),
                       key,
                       value];
        }
    }
    
    if (queries.length > 1) {
        queries = [queries substringToIndex:queries.length - 1];
    }
    
    if (([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) && queries.length > 1) {
        if ([url rangeOfString:@"?"].location != NSNotFound
            || [url rangeOfString:@"#"].location != NSNotFound) {
            url = [NSString stringWithFormat:@"%@%@", url, queries];
        } else {
            queries = [queries substringFromIndex:1];
            url = [NSString stringWithFormat:@"%@?%@", url, queries];
        }
    }
    
    return url.length == 0 ? queries : url;
}

-(NSString *)networkingUrlString_md5:(NSString *)string {
    if (string == nil || [string length] == 0) {
        return nil;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH], i;
    CC_MD5([string UTF8String], (int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], digest);
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x", (int)(digest[i])];
    }
    return [ms copy];
}
- (NSString *)cacheKey:(NSString *)urlString params:(id)params{
    NSString *absoluteURL = [self generateGETAbsoluteURL:urlString params:params];
    NSString *key = [self networkingUrlString_md5:absoluteURL];
    return key;
}

// 缓存路径
static inline NSString *cachePath() {
    //Caches目录
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *pathcaches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *createPath = [pathcaches stringByAppendingPathComponent:NetworkCache];
    // 判断文件夹是否存在，如果不存在，则创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:createPath]) {
        [fileManager createDirectoryAtPath:createPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return createPath;
}

/**
 *  添加缓存
 *
 *  @param responseObject 请求成功数据
 *  @param urlString      请求地址
 *  @param params         拼接的参数
 */
- (void)cacheResponseObject:(id)responseObject urlString:(NSString *)urlString parameters:(id)params {
    NSString *key = [self cacheKey:urlString params:params];
    NSString *path = [cachePath() stringByAppendingPathComponent:key];
    [self deleteFileWithPath:path];
    NSData *data = nil;
    NSError *error = nil;

    if ([responseObject isKindOfClass:[NSData class]]) {
        data = responseObject;
        
    } else {
        data = [NSJSONSerialization dataWithJSONObject:responseObject
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        
    }
    

    BOOL isOk = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    if (isOk) {
        NetworkLog(@"cache file success: %@\n", path);
    } else {
        NetworkLog(@"cache file error: %@\n", path);
    }
}

/**
 *  读取缓存
 *
 *  @param url    请求地址
 *  @param params 拼接的参数
 *
 *  @return 数据data
 */
- (id)cahceResponseWithURL:(NSString *)url parameters:(id)params {
    id cacheData = nil;
    if (url) {
        // 读取本地缓存
        NSString *key = [self cacheKey:url params:params];
        NSString *path = [cachePath() stringByAppendingPathComponent:key];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        if (data) {
            //因为存的是data所以转化为json
            id dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
            
            cacheData = dict;
        }

        
    }
    return cacheData;
}

// 清空缓存
+ (void)clearCaches {
    // 删除CacheDefaults中的存放时间和地址的键值对，并删除cache文件夹
    NSString *directoryPath = cachePath();
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:directoryPath]){
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:directoryPath] objectEnumerator];
        NSString *key;
        while ((key = [childFilesEnumerator nextObject]) != nil){
            NetworkLog(@"remove_key ==%@",key);
            [CacheDefaults removeObjectForKey:key];
        }
    }
    if ([manager fileExistsAtPath:directoryPath isDirectory:nil]) {
        NSError *error = nil;
        [manager removeItemAtPath:directoryPath error:&error];
        if (error) {
            NetworkLog(@"clear caches error: %@", error);
        } else {
            NetworkLog(@"clear caches success");
        }
    }
}

//单个文件的大小
+ (long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少KB
+ (NSString *)getCacheFileSize{
    NSString *folderPath = cachePath();
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long cacheSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        cacheSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    
    if (cacheSize < 1024) {
        return [NSString stringWithFormat:@"%ldB",(long)cacheSize];
    } else if (cacheSize < powf(1024.f, 2)) {
        return [NSString stringWithFormat:@"%.2fKB",cacheSize / 1024.f];
    } else if (cacheSize < powf(1024.f, 3)) {
        return [NSString stringWithFormat:@"%.2fMB",cacheSize / powf(1024.f, 2)];
    } else {
        return [NSString stringWithFormat:@"%.2fGB",cacheSize / powf(1024.f, 3)];
    }

}

/**
 *  判断文件是否已经存在，若存在删除
 *
 *  @param path 文件路径
 */
- (void)deleteFileWithPath:(NSString *)path
{
    NSURL *url = [NSURL fileURLWithPath:path];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NetworkLog(@"file deleted success");
        if (err) {
            NetworkLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NetworkLog(@"no file by that name");
    }
}

@end
