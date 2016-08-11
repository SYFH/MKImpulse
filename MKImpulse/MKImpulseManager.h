//
//  MKImpulseManager.h
//
//  Created by 云翼天 on 16/7/18.
//  Copyright © 2016年 SYFH. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IMPULSE_MAIN_QUEUE   dispatch_get_main_queue()
#define IMPULSE_GLOBAL_QUEUE dispatch_get_global_queue(0, 0)

#define IMPULSE_UNLIMITED     (-1)
#define IMPULSE_SINGLE        @(1)

/*!
 @brief 脉冲管理器的执行策略
 */
typedef NS_ENUM(NSInteger, MKImpulseExecType) {
    /*!
     删除之前所有的脉冲器, 只执行最后一次添加的脉冲器
     */
    MKImpulseExecTypeAbolish,
    /*!
     合并所有的脉冲器, 一次性执行所有的脉冲器
     */
    MKImpulseExecTypeAppend
};

/*!
 @brief 这是一个用来替代NSTimer的高精度脉冲器, 基于GCD制作
 */
@interface MKImpulseManager : NSObject

/*!
 @brief 初始化一个脉冲器管理者单例, 用来管理所有的脉冲器
 
 @return 脉冲器管理者
 */
+ (instancetype)defaultManager;

/*!
 @brief 设置管理器的管理策略
 
 @param execType 管理策略类型
 */
- (void)scheduleImpulseExecType:(MKImpulseExecType)execType;

/****** Exec Impluse For Action ****** 执行回调脉冲 ******************************/
/*!
 @brief 
    进行回调式脉冲
    默认立即执行, 间隔1s, 无限执行, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
 @param action 需要执行的回调
 */
- (void)impulseWithAction:(dispatch_block_t)action;

/*!
 @brief 
    进行回调式脉冲, 可控制执行次数
    默认立即执行, 间隔1s, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
    
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat 执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param action 需要执行的回调
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                   action:(dispatch_block_t)action;

/*!
 @brief
    进行回调式脉冲, 可控制执行次数, 脉冲间隔时间
    默认立即开始, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param interval 脉冲间隔的时间, 单位s
 @param action   需要执行的回调
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                 interval:(NSTimeInterval)interval
                   action:(dispatch_block_t)action;

/*!
 @brief
    进行回调式脉冲, 可控制执行次数, 开始执行的时间, 脉冲间隔的时间
    默认精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行的时间, 单位s
 @param interval 脉冲间隔的时间, 单位s
 @param action   需要执行的回调
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                   action:(dispatch_block_t)action;

/*!
 @brief
    进行回调式脉冲, 可控制执行次数, 开始执行的时间, 脉冲间隔的时间, 执行精度
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行的时间, 单位s
 @param interval 脉冲间隔的时间, 单位s
 @param accuracy 执行精度, 单位s
 @param action   需要执行的回调
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                 accuracy:(NSTimeInterval)accuracy
                   action:(dispatch_block_t)action;

/*!
 @brief 
    进行回调式脉冲, 可控制执行次数, 开始执行的时间, 脉冲间隔的时间, 执行精度, 执行线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param queue    任务所执行的线程
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行的时间, 单位s
 @param interval 脉冲间隔的时间, 单位s
 @param accuracy 执行精度, 单位s
 @param action   需要执行的回调
 */
- (void)impulseWithQueue:(dispatch_queue_t)queue
                  repeat:(NSInteger)repeat
                   start:(NSTimeInterval)start
                interval:(NSTimeInterval)interval
                accuracy:(NSTimeInterval)accuracy
                  action:(dispatch_block_t)action;

/****** Control Impluse For Action ****** 控制回调脉冲 ***************************/
/*!
 @brief 暂停脉冲器
 */
- (void)suspendImpulse;
- (void)suspendImpulseAll;

/*!
 @brief 暂停脉冲器, 与 -suspendXXXX 效果同等
 */
- (void)pauseImpulse;
- (void)pauseImpulseAll;

/*!
 @brief 继续脉冲器
 */
- (void)resumeImpulse;
- (void)resumeImpulseAll;

/*!
 @brief 取消脉冲器
 */
- (void)cancelImpulse;
- (void)cancelImpulseAll;

/*!
 @brief 停止脉冲器, 与取消脉冲器同等
 */
- (void)stopImpulse;
- (void)stopImpulseAll;

@end

/*!
 @brief 以调用方法的方式来执行脉冲器, 适合需要大量操作的任务
 */
@interface MKImpulseManager (selectorImpulse)

/****** Exec Impluse For Selector ****** 执行选择器脉冲 **************************/
/*!
 @brief
    进行方法式脉冲
    默认立即执行, 间隔1s, 无限执行, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放

 @param target   执行者
 @param selector 所执行的方法
*/
- (void)impulseWithTarget:(id)target
                 selector:(SEL)selector;

/*!
 @brief
    进行方法式脉冲, 可控制执行次数
    默认立即执行, 间隔1s, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param target   执行者
 @param selector 所执行的方法
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                   target:(id)target
                 selector:(SEL)selector;

/*!
 @brief
    进行方法式脉冲, 可控制执行次数, 脉冲间隔时间
    默认立即执行, 精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param interval 脉冲间隔时间, 单位s
 @param target   执行者
 @param selector 所执行的方法
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                 interval:(NSTimeInterval)interval
                   target:(id)target
                 selector:(SEL)selector;

/*!
 @brief
    进行方法式脉冲, 可控制执行次数, 开始时间, 脉冲间隔时间
    默认精度为0s
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行时间, 单位s
 @param interval 脉冲间隔时间, 单位s
 @param target   执行者
 @param selector 所执行的方法
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                   target:(id)target
                 selector:(SEL)selector;

/*!
 @brief
    进行方法式脉冲, 可控制执行次数, 开始时间, 脉冲间隔时间, 执行精度
    所执行的代码默认在异步子线程中执行, 如需UI操作, 请自行切换线程
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行时间, 单位s
 @param interval 脉冲间隔时间, 单位s
 @param accuracy 执行精度, 单位s
 @param target   执行者
 @param selector 所执行的方法
 */
- (void)impulseWithRepeat:(NSUInteger)repeat
                    start:(NSTimeInterval)start
                 interval:(NSTimeInterval)interval
                 accuracy:(NSTimeInterval)accuracy
                   target:(id)target
                 selector:(SEL)selector;

/*!
 @brief
    进行方法式脉冲, 可控制执行线程, 执行次数, 开始时间, 脉冲间隔时间, 执行精度
 
    执行次数归零时, 该脉冲器将自行释放
 
 @param queue    执行线程
 @param repeat   执行次数, 如需无限执行, 请使用 IMPULSE_UNLIMITED
 @param start    开始执行时间, 单位s
 @param interval 脉冲间隔时间, 单位s
 @param accuracy 执行精度, 单位s
 @param target   执行者
 @param selector 所执行的方法
 */
- (void)impulseWithQueue:(dispatch_queue_t)queue
                  repeat:(NSInteger)repeat
                   start:(NSTimeInterval)start
                interval:(NSTimeInterval)interval
                accuracy:(NSTimeInterval)accuracy
                  target:(id)target
                selector:(SEL)selector;

@end
