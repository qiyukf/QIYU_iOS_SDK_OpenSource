//
//  NIMMessageModel.h
//  YSFKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"
#import "YSFExtraCellLayoutConfig.h"
#import "NIMSDK.h"

@interface YSFMessageModel : NSObject

/**
 *  消息数据
 */
@property (nonatomic, strong) YSF_NIMMessage *message;

/**
 *  消息对应的布局配置
 */
@property (nonatomic, strong, readonly) id<YSFCellLayoutConfig> layoutConfig;
@property (nonatomic, assign, readonly) CGSize contentSize;
@property (nonatomic, assign, readonly) UIEdgeInsets contentViewInsets;
@property (nonatomic, assign, readonly) UIEdgeInsets bubbleViewInsets;
@property (nonatomic, assign, readonly) CGFloat avatarBubbleSpace;
@property (nonatomic, assign, readonly) BOOL shouldShowAvatar;
@property (nonatomic, assign, readonly) BOOL shouldShowNickName;

/**
 *  扩展消息布局配置
 */
@property (nonatomic, strong, readonly) id<YSFExtraCellLayoutConfig> extraLayoutConfig;
@property (nonatomic, assign, readonly) CGSize extraViewSize;
@property (nonatomic, assign, readonly) UIEdgeInsets extraViewInsets;
@property (nonatomic, assign, readonly) BOOL shouldShowExtraView;

/**
 *  YSF_NIMMessage封装成YSFMessageModel的方法
 *
 *  @param  message 消息体
 *
 *  @return YSFMessageModel实例
 */
- (instancetype)initWithMessage:(YSF_NIMMessage *)message;

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
