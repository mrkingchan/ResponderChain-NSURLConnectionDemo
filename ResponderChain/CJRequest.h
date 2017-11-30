//
//  CJRequest.h
//  ResponderChain
//
//  Created by Chan on 2017/11/22.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^resultBlock)(NSDictionary *info,NSData *responseData,NSError *error);

typedef void(^progressBlock)(NSProgress *progress);

@interface CJRequest : NSObject


+ (CJRequest *)requestWithMutableRequest:(NSMutableURLRequest *)request
                                progress:(progressBlock)progress
                             resultBlock:(resultBlock)result;

@end
