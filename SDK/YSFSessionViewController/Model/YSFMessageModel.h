//
//  NIMMessageModel.h
//  YSFKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"
#import "NIMSDK.h"

@interface YSFMessageModel : NSObject

/**
 *  消息数据
 */
@property (nonatomic, strong) YSF_NIMMessage *message;

/**
 *  YSF_NIMMessage封装成NIMMessageModel的方法
 *
 *  @param  message 消息体
 *
 *  @return NIMMessageModel实例
 */
- (instancetype)initWithMessage:(YSF_NIMMessage*)message;

/**
 *  消息对应的布局配置
 */
@property (nonatomic,strong,readonly) id<YSFCellLayoutConfig> layoutConfig;


@property (nonatomic, readonly) CGSize     contentSize;

@property (nonatomic, readonly) UIEdgeInsets  contentViewInsets;

@property (nonatomic, readonly) UIEdgeInsets  bubbleViewInsets;

@property (nonatomic, readonly) BOOL shouldShowAvatar;

@property (nonatomic, readonly) BOOL shouldShowNickName;

/**
 *  计算内容大小
 *
 *  @param width 内容宽度
 */
- (void)calculateContent:(CGFloat)width;

- (void)reCalculateContent:(CGFloat)width;

- (void)cleanLayoutConfig;
- (void)cleanCache;

@end
