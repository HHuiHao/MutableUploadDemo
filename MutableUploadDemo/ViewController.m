//
//  ViewController.m
//  MutableUploadDemo
//
//  Created by apple on 14/12/31.
//  Copyright (c) 2014年 hans. All rights reserved.
//
#import "ViewController.h"
#import "UploadTool.h"

@interface ViewController ()
{
    UploadTool *_upload;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *addImgOperation = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addImgOperation];
    addImgOperation.frame = CGRectMake(100, 100, 100, 40);
    addImgOperation.backgroundColor = [UIColor redColor];
    [addImgOperation addTarget:self action:@selector(addImageOperationEvnet) forControlEvents:UIControlEventTouchUpInside];
    [addImgOperation setTitle:@"发送图片" forState:UIControlStateNormal];
    
    UIButton *addTextOperation = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:addTextOperation];
    addTextOperation.frame = CGRectMake(100, 150, 100, 40);
    addTextOperation.backgroundColor = [UIColor redColor];
    [addTextOperation addTarget:self action:@selector(addTextOperationEvent) forControlEvents:UIControlEventTouchUpInside];
    [addTextOperation setTitle:@"发送文本" forState:UIControlStateNormal];
    
    _upload = [[UploadTool alloc] init];
    
    
}

- (void)addImageOperationEvnet
{
    
    UIImage *image = [UIImage imageNamed:@"welcome.jpg"];
    [_upload postImage:image imageName:@"welcome"];
}

- (void)addTextOperationEvent
{
    
    NSArray *tempArr = @[@"hello hans", @"welcome", @"nice to me you ~~~", @"welcome"];
    [_upload postTexts:tempArr success:^(NSDictionary *json) {
        NSLog(@"\n json == %@", json);
    } fail:^(NSError *error) {
        NSLog(@"\n error == %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
