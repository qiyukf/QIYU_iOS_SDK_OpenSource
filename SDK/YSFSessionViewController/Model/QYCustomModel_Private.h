//
//  QYCustomModel_Private.h
//  YSFSDK
//
//  Created by liaosipei on 2018/11/26.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYCustomMessage.h"

static CGFloat kBubbleViewMinMargin = 112.0f;

@interface QYCustomModel()

/**
 *  外部消息数据
 */
@property (nonatomic, strong, readwrite) QYCustomMessage *message;

/**
 *  内部消息数据
 */
@property (nonatomic, strong, readwrite) YSF_NIMMessage *ysfMessage;

/**
 *  消息对应的布局配置
 */
@property (nonatomic, assign, readwrite) CGSize contentSize;
@property (nonatomic, assign, readwrite) UIEdgeInsets contentInsets;
@property (nonatomic, assign, readwrite) UIEdgeInsets bubbleInsets;
@property (nonatomic, assign, readwrite) CGFloat bubbleLeftSpace;
@property (nonatomic, assign, readwrite) BOOL shouldShowAvatar;
@property (nonatomic, assign, readwrite) BOOL shouldShowBubble;

/**
 *  YSF_NIMMessage封装成YSFCustomMessageModel的方法
 *  @param  message 消息体
 *  @return YSFCustomMessageModel实例
 */
- (instancetype)initWithMessage:(YSF_NIMMessage *)message;

/**
 *  计算内容大小
 *  @param width 内容宽度
 */
- (void)calculateContent:(CGFloat)width;
- (void)recalculateContent:(CGFloat)width;

/**
 *  清除数据
 */
- (void)cleanCache;

@end
