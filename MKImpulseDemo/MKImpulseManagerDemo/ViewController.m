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
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 测试: 脉冲器的暂停和继续
    [self pauseMethod];
    
    //    测试: 在运行脉冲器时, 切换管理模式
    //    [self cutMethod];
}

// 测试: 在运行脉冲器时, 切换管理模式
- (void)cutMethod {
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
//    [[MKImpulseManager defaultManager] stopImpulse]; // 另一个取消方法, 与 -cancelXXXX 效果相同
    
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
    
    // 停止所有的脉冲器
    [[MKImpulseManager defaultManager] cancelImpulseAll];
}

// 测试: 脉冲器的暂停和继续
- (void)pauseMethod {
    // 设置脉冲管理策略为只执行最后添加的脉冲器
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAbolish];
    [[MKImpulseManager defaultManager] impulseWithAction:^{
        NSLog(@"Helo world!");
    }];
    
    sleep(5);
    
    // 暂停当前脉冲器
    [[MKImpulseManager defaultManager] suspendImpulse];
//    [[MKImpulseManager defaultManager] pauseImpulse]; // 另一个暂停方法, 与 -suspendXXXX 效果相同
    NSLog(@"脉冲器暂停中...");
    
    sleep(3);
    NSLog(@"脉冲器开始中...");
    // 恢复当前脉冲器
    [[MKImpulseManager defaultManager] resumeImpulse];
    
    sleep(5);
    // 取消(停止)当前脉冲器
    [[MKImpulseManager defaultManager] cancelImpulse];
//    [[MKImpulseManager defaultManager] stopImpulse]; // 另一个取消方法, 与 -cancelXXXX 效果相同
    NSLog(@"脉冲器已停止");
}

- (void)testMethod {
    NSLog(@"action_3:%@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
