//
//  CJRequest.m
//  ResponderChain
//
//  Created by Chan on 2017/11/22.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "CJRequest.h"

@interface CJRequest() <NSURLConnectionDataDelegate>{
    NSURLConnection *_connection;  //connection对象
    NSMutableData *_cachData;  //缓存数据
    NSMutableDictionary *_info;  //响应头信息
    resultBlock _resultBlock;   //响应
    NSProgress *_progressView;  //进度
    progressBlock _progressBlock;   //进度回调 会调用多次
}

@end
@implementation CJRequest

+ (CJRequest *)requestWithMutableRequest:(NSMutableURLRequest *)request
                             progress:(progressBlock)progress
                             resultBlock:(resultBlock)result {
    return [[CJRequest alloc]initWithMutableRequest:request
                                           progress:progress
                                        resultBlock:result];
}

- (CJRequest *)initWithMutableRequest:(NSMutableURLRequest *)request
                          progress:(progressBlock)progress
                          resultBlock:(resultBlock)result {
    if (self = [super init]) {
        _progressBlock = progress;
        _progressView = [NSProgress new];
        _resultBlock = result;
        _cachData = [NSMutableData new];
        _info = [NSMutableDictionary new];
        _connection = [[NSURLConnection alloc] initWithRequest:request
                                                      delegate:self
                                              startImmediately:YES];
        [_connection start];
    }
    return self;
}

#pragma mark --NSURLConectionDataDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_resultBlock) {
        _resultBlock(_info,_cachData,nil);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (_cachData) {
        [_cachData  appendData:data];
    }
    _progressView.completedUnitCount = _cachData.length;
    if (_progressBlock) {
        _progressBlock(_progressView);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //http请求
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        [_info setValue:httpResponse.MIMEType forKey:@"mimeType"];
        [_info setValue:@(httpResponse.expectedContentLength) forKey:@"expectedContentLength"];
         _progressView.totalUnitCount = httpResponse.expectedContentLength;
        [_info setValue:httpResponse.textEncodingName forKey:@"textEncodingName"];
        [_info setValue:httpResponse.URL forKey:@"requestUrl"];
        [_info setValue:httpResponse.suggestedFilename forKey:@"suggestedFilename"];
        [_info setValue:httpResponse.allHeaderFields forKey:@"allHeaderFields"];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (_resultBlock) {
        _resultBlock(_info,_cachData,error);
    }
}
@end
