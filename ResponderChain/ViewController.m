//
//  ViewController.m
//  ResponderChain
//
//  Created by Chan on 2017/11/16.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "ViewController.h"
#import "AView.h"
#import "BView.h"
#import "CView.h"
#import <objc/runtime.h>
#import "CJRequest.h"
#import <AFNetworking.h>

@interface ViewController ()<NSURLConnectionDataDelegate> {
    NSMutableData *_cacheData;
    NSMutableDictionary *_info;
    NSURLConnection *_connection;
    NSTimer *_timer;
    NSString *_fileName;
    long long _currentDownLoadLength;
    NSMutableData *_responseData;
    long long _totalLength;
    UIImageView*_imageView;
    NSMutableArray *_pathArray;
    NSMutableArray *_connectionArray;
    NSMutableArray *_fileHandelArray;
    NSInteger _finishedCount;
    
}

@end

@implementation ViewController


#pragma mark --NSURLConnectionDownLoadDelegate
/*- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long) expectedTotalBytes {
    NSString *subStr = @"%";
    NSLog(@"进度 = %@%.2f", subStr,1.0 * totalBytesWritten / expectedTotalBytes * 100.0);
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *) destinationURL {
    NSLog(@"destination= %@",destinationURL.path);///Users/soung1314/Library/Developer/CoreSimulator/Devices/04B350B3-3A36-48AB-AE32-1911DB5A1545/data/Containers/Data/Application/6F12281E-B9FE-405F-89B5-11152B96BBDE/tmp/2b66fa1c93d8322d5299a1befc59b16c.txt*/
    /*NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:_fileName];
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:destinationURL.path
                                                           toPath:dbPath
                                                            error:&error];*/
    /*//断点下载
    NSString *range = [NSString stringWithFormat:@"bytes=%lld-",_currentDownLoadLength];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:connection.currentRequest.URL];
    [request setValue:range forHTTPHeaderField:@"Range"];
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                  delegate:self];
    if (_connection) {
        [_connection start];
    }*/
    /*if (error) {
        NSLog(@"errorr = %@",[error  description]);
    }
    if (success) {
        NSLog(@"success!");
    } else {
        NSLog(@"failure");
    }*/
//}

#pragma mark --downLoadTask
- (void)downLoadTask {
    _pathArray = [NSMutableArray new];
    _fileHandelArray = [NSMutableArray new];
    _connectionArray = [NSMutableArray new];
    
    _finishedCount = 0;
    _responseData = [NSMutableData new];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] ;
    NSLog(@"dbPath = %@",documentPath);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://download.xmcdn.com/group18/M01/BC/91/wKgJKlfAEN6wZgwhANQvLrUQ3Pg146.aac"]];
    _connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:YES];
    
}

#pragma mark --NSURLConnectionDataDelegate
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    /*NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:_fileName];
    //下载完成 写入文件
    [_responseData writeToFile:dbPath atomically:YES];*/
    
    _finishedCount ++;
    [connection cancel];
    NSUInteger index = [_connectionArray  indexOfObject:connection];
    //获取句柄
    NSFileHandle *handel = [_fileHandelArray objectAtIndex:index];
    //停止写文件
    [handel closeFile];
    handel = nil;
    if (_finishedCount == 5) {
        //合并
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString *downLoadPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:_fileName];
        //创建文总文件路径
        [manager createFileAtPath:downLoadPath contents:nil attributes:nil];
        NSFileHandle *fileHandel = [NSFileHandle fileHandleForWritingAtPath:downLoadPath];
        for (int i = 0; i < 5; i ++) {
            [fileHandel seekToEndOfFile];
            [fileHandel writeData:[NSData dataWithContentsOfFile:_pathArray[i]]];
        }
        [fileHandel closeFile];
        fileHandel = nil;
        NSLog(@"downLoadPath = %@",downLoadPath);
        NSLog(@"filesize  = %.2fM",[[manager attributesOfItemAtPath:downLoadPath error:nil] fileSize]/1024.0/1024.0);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _fileName = response.suggestedFilename;
    _totalLength = response.expectedContentLength;
    NSLog(@"fileName  = %@",response.suggestedFilename);
    //取消
    if ([connection isEqual:_connection]) {
        [_connection cancel];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        for (int i = 0; i < 5; i ++) {
            //创建5个文件句柄、Coneciton
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *filePath =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%d",_fileName,i]];
            [manager createFileAtPath:filePath contents:nil attributes:nil];
            NSFileHandle *fileHandel = [NSFileHandle fileHandleForWritingAtPath:filePath];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://download.xmcdn.com/group18/M01/BC/91/wKgJKlfAEN6wZgwhANQvLrUQ3Pg146.aac"]];
            NSString *rangeStr = [NSString stringWithFormat:@"bytes = %lld-%lld",response.expectedContentLength / 5 * i,response.expectedContentLength/5*(i + 1)];
            //设置range
            [request setValue:rangeStr forHTTPHeaderField:@"Range"];
            NSURLConnection *customConection = [NSURLConnection connectionWithRequest:request
                                                                       delegate:self];
            [customConection start];
            [_pathArray addObject:filePath];
            [_fileHandelArray addObject:fileHandel];
            [_connectionArray addObject:customConection];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    /*//拼接每次接受的数据
    [_responseData appendData:data];
    //计算目前接收到的数据总长度
    _currentDownLoadLength = _currentDownLoadLength + data.length;
    //下载进度百分比
    NSString *subStr = @"%";
    NSLog(@"进度 = %@%.2f",subStr,  100.0 *_currentDownLoadLength /_totalLength);*/
    NSUInteger index = [_connectionArray  indexOfObject:connection];
    NSFileHandle *handel = [_fileHandelArray objectAtIndex:index];
    //移到句柄末端
    [handel seekToEndOfFile];
    //写入数据
    [handel writeData:data];
}

#pragma mark --private Method
- (void)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    //断点下载
    if (button.selected) {
        //设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%lld-",_currentDownLoadLength];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://download.xmcdn.com/group18/M01/BC/91/wKgJKlfAEN6wZgwhANQvLrUQ3Pg146.aac"]];
        [request setValue:range forHTTPHeaderField:@"Range"];
        //重新请求
        _connection = [[NSURLConnection alloc] initWithRequest:request
                                         delegate:self];
        [_connection start];
    } else  {
        //暂停
        [_connection cancel];
        _connection = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self downLoadTask];
    AView *a = [[AView alloc] initWithFrame:CGRectMake(100, 100, 300, 300)];
    a.backgroundColor = [UIColor greenColor];
    [self.view addSubview:a];
    
    BView *b = [[BView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    b.backgroundColor = [UIColor redColor];
    [a addSubview:b];
    
    CView *c = [[CView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    c.backgroundColor = [UIColor blueColor];
    [b addSubview:c];
 
    /*unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([UITableViewCell class], &count);
    for (int i = 0; i < count; i++) {
        NSString *key= [NSString stringWithUTF8String:property_getName(properties[i])];
        NSLog(@"key = %@",key);
    }
    Ivar *vars = class_copyIvarList([UITableView  class], &count);
    for (int i = 0; i < count; i ++) {
        NSString *key = [ NSString stringWithUTF8String:ivar_getName(vars[i])];
        NSLog(@"key = %@",key);
    }*/
}

/*- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.weather.com.cn/data/sk/101010100"]];
    request.HTTPMethod = @"POST";
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"record"], 0.5);
    NSInputStream *streamData =[[NSInputStream alloc] initWithData:imageData];
    request.HTTPBodyStream = streamData;
    request.timeoutInterval = 1.0f;
    NSDictionary *dic = @{@"Chan" :@"Chan"};
    NSString *kBoundray = @"----WebKitFormBoundary3pVJSvbLhiFiCeZC";
    NSData *kNextLineData = [@"\r\n"  dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary = %@",kBoundray]
   forHTTPHeaderField:@"Content-Type"];
    //拼接请求体body
    NSMutableData *fileData = [NSMutableData new];
    [fileData appendData:[[NSString stringWithFormat:@"--%@",kBoundray] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileData appendData:kNextLineData];
    
    NSLog(@"headers = %@,body = %@,requestStream = %@",request.allHTTPHeaderFields,[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding],request.HTTPBodyStream);
    [CJRequest requestWithMutableRequest:request
                                progress:^(NSProgress *progress) {
                                    NSString *subStr = @"%";
                                    NSLog(@"percent = %@%.2f",subStr,progress.completedUnitCount / progress.totalUnitCount / 1.0 * 100.0);
                                }
                             resultBlock:^(NSDictionary *info, NSData *responseData, NSError *error) {
                                 NSLog(@"response info = %@",info);
                             }];
}*/

@end
