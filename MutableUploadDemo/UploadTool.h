//
//  UploadTool.h
//  EditorMutTextAndImgs
//
//  Created by apple on 14/12/29.
//  Copyright (c) 2014年 hans. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^Success)(NSDictionary *json);
typedef void (^Error)(NSError *error);

@interface UploadTool : NSObject

/**
 *  发送图片
 *  请求方式：post
 *  @params image 发送图片 
 *  @params name  发送图片名字
 */
- (void)postImage:(UIImage *)image imageName:(NSString *)name;

/**
 *  发送文本
 *  请求方式：post
 *  @params texts 文本【文本|替换的图片】
 */
- (void)postTexts:(NSArray *)texts success:(Success)success fail:(Error)fail;

@end
