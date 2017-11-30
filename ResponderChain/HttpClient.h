//
//  CCNet.h
//  ResponderChain
//
//  Created by Chan on 2017/11/28.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef void(^success)(id responseObject,NSURLResponse *response);

typedef void(^failure)(NSError *error);

typedef void(^downProgress)(UIProgressView *progressView);

@interface HttpClient : NSObject

- (NSURLSessionDataTask *)PostWithpath:(NSString *)path
                                params:(id)params
                                sucess:(success)success
                               failure:(failure)failure;

- (NSURLSessionDownloadTask *)DownLoadWithpath:(NSString *)path
                                        params:(id)params
                              downLoadProgress:(downProgress)downProgress
                                        sucess:(success)success
                                       failure:(failure)failure;

@end
