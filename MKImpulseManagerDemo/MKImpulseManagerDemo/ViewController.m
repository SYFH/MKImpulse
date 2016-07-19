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
    
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAbolish];
    [[MKImpulseManager defaultManager] impulseWithAction:^{
        NSLog(@"action_1:%@", [NSThread currentThread]);
    }];
    
    sleep(2);
    
    [[MKImpulseManager defaultManager] cancelImpulse];
    
    [[MKImpulseManager defaultManager] impulseWithRepeat:3 action:^{
        NSLog(@"action_2:%@", [NSThread currentThread]);
    }];
    
    sleep(5);
    
    [[MKImpulseManager defaultManager] scheduleImpulseExecType:MKImpulseExecTypeAppend];
    [[MKImpulseManager defaultManager] impulseWithQueue:IMPULSE_GLOBAL_QUEUE
                                                 repeat:IMPULSE_UNLIMITED
                                                  start:1
                                               interval:2
                                               accuracy:0
                                                 target:self
                                               selector:@selector(testMethod)];
    
    sleep(10);
    
    [[MKImpulseManager defaultManager] cancelImpulseAll];
}

- (void)testMethod {
    NSLog(@"action_3:%@", [NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
