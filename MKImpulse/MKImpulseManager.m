//
//  MKImpulseManager.m
//
//  Created by 云翼天 on 16/7/18.
//  Copyright © 2016年 SYFH. All rights reserved.
//

#import "MKImpulseManager.h"
#import "MKImpulse.h"

#define IMPULSE_EXEC_NOW      @(0)
#define IMPULSE_EXEC_INTERVAL @(1)
#define IMPULSE_EXEC_ACCURACY @(0)

@interface MKImpulseManager ()

@property (nonatomic, assign) MKImpulseExecType execType;

@property (nonatomic, assign) NSUInteger repeatCount;

@property (nonatomic, strong) NSNumber          *repeat;
@property (nonatomic, strong) dispatch_source_t impulse;
@property (nonatomic, copy  ) dispatch_block_t  action;
@property (nonatomic, weak  ) id                target;
@property (nonatomic, assign) SEL               selector;

@property (nonatomic, copy) NSMutableArray *impulseGroup;

@end

@implementation MKImpulseManager
#pragma mark - 自定义初始化 -
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    static MKImpulseManager *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[MKImpulseManager alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.execType = MKImpulseExecTypeAbolish;
    }
    return self;
}

- (void)scheduleImpulseExecType:(MKImpulseExecType)execType {
    self.execType = execType;
}

#pragma mark - 开始进行脉冲 -
- (void)impulseWithAction:(dispatch_block_t)action {
    [self impulseWithQueue:nil
                    repeat:@(IMPULSE_UNLIMITED)
                 StartTime:nil
                  interval:nil
                  accuracy:nil
                    action:action
                    target:nil
                  selector:nil];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                   action:(dispatch_block_t)action {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:nil
                  interval:nil
                  accuracy:nil
                    action:action
                    target:nil
                  selector:nil];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                 interval:(NSTimeInterval)interval
                   action:(dispatch_block_t)action {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:nil
                  interval:@(interval)
                  accuracy:nil
                    action:action
                    target:nil
                  selector:nil];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                   action:(dispatch_block_t)action {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:@(interval)
                  accuracy:nil
                    action:action
                    target:nil
                  selector:nil];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                 accuracy:(NSTimeInterval)accuracy
                   action:(dispatch_block_t)action {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:@(interval)
                  accuracy:@(accuracy)
                    action:action
                    target:nil
                  selector:nil];
}

- (void)impulseWithQueue:(dispatch_queue_t)queue
                  repeat:(NSInteger)repeat
                   start:(NSTimeInterval)start
                interval:(NSTimeInterval)interval
                accuracy:(NSTimeInterval)accuracy
                  action:(dispatch_block_t)action {
    [self impulseWithQueue:queue
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:@(interval)
                  accuracy:@(accuracy)
                    action:action
                    target:nil
                  selector:nil];
}

#pragma mark - 控制脉冲 -
- (void)suspendImpulse {
    dispatch_suspend(self.impulse);
}

- (void)suspendImpulseAll {
    [self.impulseGroup enumerateObjectsUsingBlock:^(MKImpulse *impulse, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_suspend(impulse.impulse_t);
    }];
}

- (void)resumeImpulse {
    dispatch_resume(self.impulse);
}

- (void)resumeImpulseAll {
    [self.impulseGroup enumerateObjectsUsingBlock:^(MKImpulse *impulse, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_resume(impulse.impulse_t);
    }];
}

- (void)cancelImpulse {
    if (self.impulse) {
        dispatch_source_cancel(self.impulse);
        self.impulse  = nil;
        self.target   = nil;
        self.selector = nil;
    }
}

- (void)cancelImpulseAll {
    [self.impulseGroup enumerateObjectsUsingBlock:^(MKImpulse *impulse, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_source_cancel(impulse.impulse_t);
    }];
    [self.impulseGroup removeAllObjects];
}

// 从脉冲器组里删除某一个脉冲器
- (void)cancelSingelImpulseAction:(dispatch_source_t)impulse_t {
    __block NSUInteger index = 0;
    [self.impulseGroup enumerateObjectsUsingBlock:^(MKImpulse *impulse, NSUInteger idx, BOOL * _Nonnull stop) {
        if (impulse.impulse_t == impulse_t) {
            index = idx;
        }
    }];
    dispatch_source_cancel(impulse_t);
    [self.impulseGroup removeObjectAtIndex:index];
}

#pragma mark - 统一创建 -
- (void)impulseWithQueue:(dispatch_queue_t)queue
                  repeat:(NSNumber *)repeat
               StartTime:(NSNumber *)start
                interval:(NSNumber *)interval
                accuracy:(NSNumber *)accuracy
                  action:(dispatch_block_t)action
                  target:(id)target
                selector:(SEL)selector {

    // 初始化默认值
    if (!queue)     { queue    = IMPULSE_GLOBAL_QUEUE;  } // 默认为子线程
    if (!repeat)    { repeat   = IMPULSE_SINGLE;        } // 默认只执行一次
    if (!start)     { start    = IMPULSE_EXEC_NOW;      } // 默认立即开始
    if (!interval)  { interval = IMPULSE_EXEC_INTERVAL; } // 默认间隔一秒
    if (!accuracy)  { accuracy = IMPULSE_EXEC_ACCURACY; } // 默认为最高精度
    
    // 创建Timer
    dispatch_source_t impulse_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t delay_time  = dispatch_time(DISPATCH_TIME_NOW, [start doubleValue] * NSEC_PER_SEC);
    uint64_t start_time         = [interval doubleValue] * NSEC_PER_SEC;
    uint64_t accuracy_time      = [accuracy doubleValue] * NSEC_PER_SEC;
    dispatch_source_set_timer(impulse_t, delay_time, start_time, accuracy_time);
    dispatch_resume(impulse_t);
    
    switch (self.execType) {
        case MKImpulseExecTypeAbolish: { // 废除之前的
            [self.impulseGroup removeAllObjects];
            if (self.impulse) { [self cancelImpulse]; }
            // 记录当前脉冲器
            self.impulse  = impulse_t;
            self.repeat = repeat;
            self.repeatCount = 0;
            self.action = action;
            self.target = target;
            self.selector = selector;
            // 执行当前脉冲器
            [self impulseExec];
        }break;
            
        case MKImpulseExecTypeAppend: { // 执行所有的
            MKImpulse *impulse = [[MKImpulse alloc] init];
            impulse.impulse_t = impulse_t;
            impulse.repeat = repeat;
            impulse.repeatCount = @(0);
            impulse.action = action;
            impulse.target = target;
            impulse.selector = selector;
            [self.impulseGroup addObject:impulse];
            [self impulseExecAll];
        }break;
    }
}

// 执行脉冲器
- (void)impulseExec {
    dispatch_source_set_event_handler(self.impulse, ^{
        if (self.repeatCount == [self.repeat integerValue]) {
            [self cancelImpulse];
            return;
        }
        
        if (self.action) { self.action(); }
        if (self.target && self.selector) {
            IMP imp = [self.target methodForSelector:self.selector];
            void (*exec)(id, SEL) = (void *)imp;
            exec(self.target, self.selector);
        }
        
        self.repeatCount ++;
    });
}

// 执行所有脉冲器
- (void)impulseExecAll {
    for (MKImpulse *impulse in self.impulseGroup) {
        dispatch_source_t impulse_t    = impulse.impulse_t;
        __block NSUInteger repeatCount = [impulse.repeatCount integerValue];
        NSUInteger repeat              = [impulse.repeat integerValue];
        dispatch_block_t action        = impulse.action;
        id target                      = impulse.target;
        SEL selector                   = impulse.selector;
        dispatch_source_set_event_handler(impulse_t, ^{
            if (repeatCount == repeat) {
                [self cancelSingelImpulseAction:impulse_t];
                return;
            }
            
            if (action) { action(); }
            if (target && selector) {
                IMP imp = [target methodForSelector:selector];
                void (*exec)(id, SEL) = (void *)imp;
                exec(target, selector);
            }
            
            // 排除中途切换执行模式时的干扰
            if (self.execType == MKImpulseExecTypeAbolish) { return; }
            
            repeatCount ++;
        });
    }
}

#pragma mark - 懒加载 -
- (NSMutableArray *)impulseGroup {
    if (!_impulseGroup) {
        _impulseGroup = [NSMutableArray array];
    }
    return _impulseGroup;
}

@end

@implementation MKImpulseManager (selectorImpulse)
- (void)impulseWithTarget:(id)target
                 selector:(SEL)selector {
    [self impulseWithQueue:nil
                    repeat:@(IMPULSE_UNLIMITED)
                 StartTime:nil
                  interval:nil
                  accuracy:nil
                    action:nil
                    target:target
                  selector:selector];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                   target:(id)target
                 selector:(SEL)selector {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:nil
                  interval:nil
                  accuracy:nil
                    action:nil
                    target:target
                  selector:selector];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                 interval:(NSTimeInterval)interval
                   target:(id)target
                 selector:(SEL)selector {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:nil
                  interval:@(interval)
                  accuracy:nil
                    action:nil
                    target:target
                  selector:selector];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                   target:(id)target
                 selector:(SEL)selector {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:nil
                  accuracy:nil
                    action:nil
                    target:target
                  selector:selector];
}

- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                 accuracy:(NSTimeInterval)accuracy
                   target:(id)target
                 selector:(SEL)selector {
    [self impulseWithQueue:nil
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:@(interval)
                  accuracy:@(accuracy)
                    action:nil
                    target:target
                  selector:selector];
}

- (void)impulseWithQueue:(dispatch_queue_t)queue
                  repeat:(NSInteger)repeat
                   start:(NSTimeInterval)start
                interval:(NSTimeInterval)interval
                accuracy:(NSTimeInterval)accuracy
                  target:(id)target
                selector:(SEL)selector {
    [self impulseWithQueue:queue
                    repeat:@(repeat)
                 StartTime:@(start)
                  interval:@(interval)
                  accuracy:@(accuracy)
                    action:nil
                    target:target
                  selector:selector];
}

@end
