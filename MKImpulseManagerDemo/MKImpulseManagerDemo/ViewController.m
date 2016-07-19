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
    // Do any additional setup after loading the view, typically from a nib.
    
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAbolish];
    [[MKImpulseManager defaultManager] impulseWithAction:^{
        NSLog(@"action_1:%@", [NSThread currentThread]);
    }];
    
    sleep(2);
    
    [[MKImpulseManager defaultManager] cancelImpulse];
    
    // 当为 MKImpulseExecTypeAbolish 模式时, 进行线程延迟, 可以看做是依次执行脉冲器, 即使之前为无限执行的脉冲器
//    sleep(3);
    
    [[MKImpulseManager defaultManager] impulseWithRepeat:3 action:^{
        NSLog(@"action_2:%@", [NSThread currentThread]);
    }];
    
    sleep(5);
    
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAppend];
    [[MKImpulseManager defaultManager] impulseWithRepeat:10 target:self selector:@selector(testMethod)];
    
    sleep(5);
    
    [[MKImpulseManager defaultManager] cancelImpulseAll];
}

- (void)testMethod {
    NSLog(@"action_3:%@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
