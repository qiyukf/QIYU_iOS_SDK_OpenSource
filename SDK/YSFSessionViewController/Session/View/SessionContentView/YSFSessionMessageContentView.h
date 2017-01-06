//
//  NIMSessionMessageContentView.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFKitEvent.h"

typedef NS_ENUM(NSInteger,YSFKitBubbleType){
    YSFKitBubbleTypeChat,
    YSFKitBubbleTypeNotify,
    YSFKitBubbleTypeNone,
};

@protocol YSFMessageContentViewDelegate <NSObject>

- (void)onCatchEvent:(YSFKitEvent *)event;

@end

@class YSFMessageModel;

@interface YSFSessionMessageContentView : UIControl

@property (nonatomic,strong,readonly)  YSFMessageModel   *model;

@property (nonatomic,strong) UIImageView * bubbleImageView;

@property (nonatomic,assign) YSFKitBubbleType bubbleType;

@property (nonatomic,weak) id<YSFMessageContentViewDelegate> delegate;

/**
 *  contentView初始化方法
 *
 *  @return content实例
 */
- (instancetype)initSessionMessageContentView;

/**
 *  刷新方法
 *
 *  @param data 刷新数据
 */
- (void)refresh:(YSFMessageModel*)data;


/**
 *  手指从contentView内部抬起
 */
- (void)onTouchUpInside:(id)sender;


/**
 *  手指从contentView外部抬起
 */
- (void)onTouchUpOutside:(id)sender;


- (void)onTouchDown:(id)sender;

@end
