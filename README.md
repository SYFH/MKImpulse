## MKImpulse 

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/SYFH/MKImpulse/blob/master/LICENSE)
[![CocoaPods](http://img.shields.io/cocoapods/v/MKImpulse.svg?style=flat)](https://cocoapods.org/?q=MKImpulse)
[![CocoaPods](http://img.shields.io/cocoapods/p/MKImpulse.svg?style=flat)](https://cocoapods.org/?q=MKImpulse)
[![Support](https://img.shields.io/badge/support-iOS%207%2B%20-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Build Status](https://travis-ci.org/SYFH/MKImpulse.svg?branch=master)](https://travis-ci.org/SYFH/MKImpulse)
[![Gitter](http://badges.gitter.im/SYFH/MKImpulse.svg)](https://gitter.im/SYFH/MKImpulse)


MKImpulse是一个用来代替系统NSTimer的高精度脉冲器  
系统的NSTimer是添加到Runloop中的, 在系统繁忙时会造成偏差, 时间越长, 偏差越大  
而MKImpulse是基于GCD编写的脉冲器, 精度由CPU时钟进行计算, 误差基本可以忽略不计

### 优点
 - 高精度
 - 高度可控性
 - 自防止内存泄漏
 - 进行多任务操作

### 安装
使用CocoaPods安装(1.0.0及之后的版本)
```
source 'https://github.com/CocoaPods/Specs.git'
target 'your project name' do
	pod 'MKImpulse'
end
```
使用CocoaPods安装(1.0.0之前的版本)
```
pod 'MKImpulse'
```

### 手动安装
从终端下载仓库
```
$git clone https://github.com/SYFH/MKImpulse.git
```

## 使用 

### 简单使用
回调式
```
#import "MKImpulseManager.h"
[[MKImpulseManager defaultManager] impulseWithRepeat:3 action:^{
	NSLog(@"action_2:%@", [NSThread currentThread]);
}];
```

目标-响应式
```
#import "MKImpulseManager.h"
[[MKImpulseManager defaultManager] impulseWithRepeat:10 target:self selector:@selector(testMethod)];
```

### 自定属性
自定脉冲间隔, 开始时间, 脉冲间隔, 脉冲精度, 执行线程
```
[[MKImpulseManager defaultManager] impulseWithQueue:IMPULSE_GLOBAL_QUEUE
                                             repeat:5
                                              start:1
                                           interval:2
                                           accuracy:0
                                             action:^{
                                                 NSLog(@"你要执行的任务");
                                             }];

[[MKImpulseManager defaultManager] impulseWithQueue:IMPULSE_GLOBAL_QUEUE
                                             repeat:IMPULSE_UNLIMITED
                                              start:1
                                           interval:2
                                           accuracy:0
                                             target:self
                                           selector:@selector(testMethod)];
```

## 联系

- 如果程序有问题, 请提交[issue](https://github.com/SYFH/MKImpulse/issues)
- 如果有其他的建议, 请写邮件到syfh@live.com
- 如果有什么疑问, 可以进入[Gitter聊天室](https://gitter.im/SYFH/MKImpulse)
