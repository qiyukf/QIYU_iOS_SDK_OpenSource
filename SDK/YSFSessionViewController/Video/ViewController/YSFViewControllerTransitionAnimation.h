//
//  YSFViewControllerTransitionAnimation.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/18.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSFViewControllerTransitionAnimation : NSObject  <UIViewControllerAnimatedTransitioning>

/**
 * 动画时间
 */
@property (nonatomic, assign) CGFloat duration;

/**
 * 原始位置
 */
@property (nonatomic, assign) CGRect originFrame;

/**
 * present or dismiss
 */
@property (nonatomic, assign) BOOL present;

@end

NS_ASSUME_NONNULL_END
