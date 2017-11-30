//
//  CCNet.m
//  ResponderChain
//
//  Created by Chan on 2017/11/28.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "HttpClient.h"

@interface HttpClient () <NSURLSessionDataDelegate>{
    UIProgressView *progressView;
    NSURLSession *_session;
    NSURLSessionDataTask *_task;
}

@end
@implementation HttpClient

-(NSURLSessionDataTask *)PostWithpath:(NSString *)path
                               params:(id)params
                               sucess:(success)success
                              failure:(failure)failure {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSMutableURLRequest *request = [self requestWithPath:path params:params];
NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            if (error) {
                                                if (failure) {
                                                    failure(error);
                                                }
                                            } else {
                                                if (success) {
                                                    success(data,response);
                                                }
                                            }
                                        }];
    [task resume];
    return task;
}

- (NSURLSessionDownloadTask *)DownLoadWithpath:(NSString *)path
                                        params:(id)params
                              downLoadProgress:(downProgress)downProgress
                                        sucess:(success)success
                                       failure:(failure)failure {
    NSMutableURLRequest *request = [self requestWithPath:path params:params];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                        if (error) {
                                                            if (failure) {
                                                                failure(error);
                                                            }
                                                        } else {
                                                            
                                                        }
                                                    }];
    if (task) {
        [task resume];
    }
    return task;
}

/**
 构建request对象
 @param path 路径
 @param params params description
 @return NSMutableURLRequest对象
 */
- (NSMutableURLRequest *)requestWithPath:(NSString *)path
                                  params:(id)params {
    //转码
    if (path) {
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[NSURL URLWithString:path]];
    if (params) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params
                                                           options:kNilOptions
                                                             error:nil];
    }
    return request;
}

@end
