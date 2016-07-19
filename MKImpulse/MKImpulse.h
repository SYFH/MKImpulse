//
//  MKImpulse.h
//  脉冲测试
//
//  Created by 云翼天 on 16/7/19.
//  Copyright © 2016年 SYFH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKImpulse : NSObject

@property (nonatomic, strong) dispatch_source_t impulse_t;
@property (nonatomic, strong) NSNumber          *repeat;
@property (nonatomic, strong) NSNumber          *repeatCount;
@property (nonatomic, copy  ) dispatch_block_t  action;
@property (nonatomic, weak  ) id                target;
@property (nonatomic, assign) SEL               selector;

@end
