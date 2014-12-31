//
//  UploadTool.m
//  EditorMutTextAndImgs
//
//  Created by apple on 14/12/29.
//  Copyright (c) 2014年 hans. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "UploadTool.h"

#define Post_Image_Url @"http://192.168.3.200/test/youku.php?action=upload"
#define Post_Text_Url @"http://192.168.3.200/test/youku.php?action=upload"
#define HMEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]

@interface UploadTool()

@property (nonatomic, retain) NSOperationQueue *queue; // 队列
@property (nonatomic, retain) NSMutableDictionary *imageDicWithDownload; // 保存上传成功后返回的的图片路径 key(图片名) -> value(图片路径)
@end


@implementation UploadTool

- (NSOperationQueue *)queue
{
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3; // 最大并发数
    }
    return _queue;
}

- (NSMutableDictionary *)imageDicWithDownload
{
    if (_imageDicWithDownload == nil) {
        _imageDicWithDownload = [NSMutableDictionary dictionary];
    }
    return _imageDicWithDownload;
}

/**
 *  发送图片
 *  请求方式：post
 *  @params image 发送图片
 *  @params name  发送图片名字
 */
- (void)postImage:(UIImage *)image imageName:(NSString *)name
{
    __unsafe_unretained UploadTool *s = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread currentThread].name = name;
        
        NSData  *data = UIImageJPEGRepresentation(image, 0.3);
        [s upload:@"file" filename:@"welcome" mimeType:@"image/png" data:data parmas:@{@"username" : @"hans",@"type" : @"XML"}];
    }];
    
//    op.name =  [NSString stringWithString:name];
    
    [self.queue addOperation:op];
}

/**
 *  发送文本
 *  请求方式：post
 *  @params texts 文本【文本|替换的图片】
 *  @params success     请求成功后回调
 *  @params fail        请求失败后回调
 */
- (void)postTexts:(NSArray *)texts success:(Success)success fail:(Error)fail
{
    // 等待其他线程完成才执行线面操作
    [self.queue waitUntilAllOperationsAreFinished];

    __unsafe_unretained UploadTool *s = self;
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^(){
        
        NSDictionary *params = @{@"message" : [self getSendMessageWith:texts]};
        [s postParams:params success:^(NSDictionary *json) {
            if (success) {
                success(json);
            }
        } fail:^(NSError *error) {
            if (fail) {
                fail(error);
            }
        }];
    }];
    [self.queue addOperation:op];
}

/**
 *  拼接文本|图片路径
 *  @params texts 文本【文本|替换的图片】
 */
- (NSString *)getSendMessageWith:(NSArray *)texts
{
    NSMutableArray *tempTexts = [NSMutableArray arrayWithArray:texts];
    
    // 获取所有已上传图片名字
    NSArray *images = [self.imageDicWithDownload allKeys];
    
    for (NSString *str1 in images){
        int i = 0;
        for (NSString *str2 in tempTexts) {
            if ([str1 isEqualToString:str2]) {
                [tempTexts replaceObjectAtIndex:i withObject:self.imageDicWithDownload[str1]];
                break;
            }
            i++;
        }
    }
    
    NSMutableString *tempSendMessage = [NSMutableString string];
    for (NSString *str in tempTexts) {
        [tempSendMessage appendString:str];
    }
    
    return tempSendMessage;
}

/**
 *  上传图片
 *  请求方式：post
 *  @params name        请求参数
 *  @params filename    服务端接收参数
 *  @params mimeType    上传类型
 *  @params data        iamge data
 *  @params params      参数
 *
 */
- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data parmas:(NSDictionary *)params
{
    // 文件上传
    NSURL *url = [NSURL URLWithString:Post_Image_Url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求体
    NSMutableData *body = [NSMutableData data];

    [body appendData:HMEncode(@"--heima\r\n")];

    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
    [body appendData:HMEncode(disposition)];
    NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType];
    [body appendData:HMEncode(type)];
    
    [body appendData:HMEncode(@"\r\n")];
    [body appendData:data];
    [body appendData:HMEncode(@"\r\n")];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [body appendData:HMEncode(@"--heima\r\n")];
        NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key];
        [body appendData:HMEncode(disposition)];
        
        [body appendData:HMEncode(@"\r\n")];
        [body appendData:HMEncode(obj)];
        [body appendData:HMEncode(@"\r\n")];
    }];
    
    [body appendData:HMEncode(@"--heima--\r\n")];
    request.HTTPBody = body;
    
    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];

    [request setValue:@"multipart/form-data; boundary=heima" forHTTPHeaderField:@"Content-Type"];
    
    // 发送请求
    NSURLResponse * response = nil;
    NSError *error = nil;
    NSData *backData = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:&response
                                                      error:&error];
    // 同步请求
    if (error == nil && backData != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableLeaves error:nil];
        
        // 保存上传成功后返回的的图片路径 key(图片名) -> value(图片路径)
        [self.imageDicWithDownload setValue:dict[@"ret"][@"url"] forKey:[NSThread currentThread].name];

        NSLog(@"%@", self.imageDicWithDownload);

    } else {
        NSLog(@"上传失败");
        
        // 任何一个任务发送失败都结束所有任务
        [self.queue cancelAllOperations];
    }
}


/**
 *  上传文本
 *  请求方式：post
 *  @params params  请求参数
 *  @params success 请求成功后回调
 *  @params fail    请求失败后回调
 *
 */
- (void)postParams:(NSDictionary *)params success:(Success)success fail:(Error)fail
{
    // 创建请求
    NSURL *url = [NSURL URLWithString:Post_Text_Url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;
    
    // 发送请求
    NSURLResponse * response = nil;
    NSError *temError = nil;
    NSData *backData = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&temError];
    // 同步请求
    if (temError == nil && backData != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableLeaves error:nil];
        
        if (success) {
            success(dict);
        }
    } else {
        if (fail) {
            
            fail(temError);
        }
        NSLog(@"发送文本失败");
    }

}

@end
