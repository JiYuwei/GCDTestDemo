//
//  ViewController.m
//  GCDTestDemo
//
//  Created by 纪宇伟 on 2017/6/25.
//  Copyright © 2017年 jyw. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

/*
* 获取主队列
* dispatch_queue_t mainQueue = dispatch_get_main_queue();
*
* 获取全局队列 第一个参数为优先级 第二个参数为flag作为保留字段（一般为0）
* dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
*
* 创建自定义队列 第一个参数为名称 第二个参数为队列类型（串行 DISPATCH_QUEUE_SERIAL／并发 DISPATCH_QUEUE_CONCURRENT）
* dispatch_queue_t customQueue = dispatch_queue_create("customQueue", DISPATCH_QUEUE_SERIAL);
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"GCDTest";
    
//    [self syncSerialQueue];
//    [self asyncSerialQueue];
//    [self syncConcurrentQueue];
//    [self asyncConcruuentQueue];
//    [self syncMainQueue];
//    [self asyncMainQueue];
//    [self deadLockTest];
//    [self gcdApplyTest];
//    [self barrierTest];
}

// 串行队列 + 同步
-(void)syncSerialQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}

// 串行队列 + 异步
-(void)asyncSerialQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}

// 并发队列 + 同步
-(void)syncConcurrentQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}

// 并发队列 + 异步
-(void)asyncConcruuentQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}

// 主队列 + 异步
-(void)asyncMainQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}

// 主队列 + 同步
-(void)syncMainQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}


//向并发队列中同步添加任务
- (void)deadLockTest
{
    dispatch_queue_t customQueue = dispatch_queue_create("customQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(customQueue, ^{
        NSLog(@"begin");
        
        for (int i=1; i<=10; i++) {
            dispatch_async(customQueue, ^{
                NSLog(@"%@ task %d",[NSThread currentThread], i);
            });
        }
        
        NSLog(@"end");
    });
    
}

- (void)gcdApplyTest
{
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t i) {
        NSLog(@"output %ld",i);
    });
}

-(void)barrierTest
{
    dispatch_queue_t queue = dispatch_queue_create("barrierTest", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"test -> 1");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 2");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 3");
    });
    
    dispatch_barrier_async(queue, ^{
        sleep(2);
        NSLog(@"hold on");
    });
    
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 4");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 5");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 6");
    });
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}


@end
