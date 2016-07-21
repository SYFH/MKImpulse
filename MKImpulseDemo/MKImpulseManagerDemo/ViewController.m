//
//  ViewController.m
//  MKImpulseManagerDemo
//
//  Created by 云翼天 on 16/7/19.
//  Copyright © 2016年 SYFH. All rights reserved.
//

#import "ViewController.h"
#import "MKImpulseManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置脉冲管理策略为只执行最后添加的脉冲器
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAbolish];
    // 开始一个默认的脉冲器
    [[MKImpulseManager defaultManager] impulseWithAction:^{
        NSLog(@"action_1:%@", [NSThread currentThread]);
    }];
    
    // 当有线程堵塞时, 脉冲器会依然执行
    sleep(2);
    
    // 取消当前正在运行的脉冲器
    [[MKImpulseManager defaultManager] cancelImpulse];
    
    // 开始一个只循环3次的脉冲器
    [[MKImpulseManager defaultManager] impulseWithRepeat:3 action:^{
        NSLog(@"action_2:%@", [NSThread currentThread]);
    }];
    
    sleep(5);
    
    // 在执行中改变管理器的管理策略为执行所有脉冲器
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAppend];
    // 开始一个在子线程中无限运行的脉冲
    [[MKImpulseManager defaultManager] impulseWithQueue:IMPULSE_GLOBAL_QUEUE
                                                 repeat:IMPULSE_UNLIMITED
                                                  start:1
                                               interval:2
                                               accuracy:0
                                                 target:self
                                               selector:@selector(testMethod)];
    
    sleep(10);
    
    // 取消所有的脉冲器
    [[MKImpulseManager defaultManager] cancelImpulseAll];
}

- (void)testMethod {
    NSLog(@"action_3:%@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
