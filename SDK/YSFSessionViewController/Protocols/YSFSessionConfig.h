//
//  YSFSessionConfig.h
//  YSFKit
//
//  Created by amao on 8/12/15.
//  Copyright (c) 2015 NetEase. All rights reserved.
//

#import "YSFMediaItem.h"
#import "YSFCellLayoutConfig.h"


@protocol YSFSessionConfig <NSObject>
@optional

/**
 *  可以显示在点击输入框“+”按钮之后的多媒体按钮
 */
- (NSArray *)mediaItems;

/**
 *  是否隐藏多媒体按钮
 *  @param item 多媒体按钮
 */
- (BOOL)shouldHideItem:(YSFMediaItem *)item;


/**
 *  是否禁用输入控件
 */
- (BOOL)disableInputView;

/**
 *  输入控件最大输入长度
 */
- (NSInteger)maxInputLength;


/**
 *  输入控件最大显示行数
 */
- (NSInteger)maxInputLines;

/**
 *  输入控件placeholder
 *
 *  @return placeholder
 */
- (NSString *)inputViewPlaceholder;


/**
 *  一次最多显示的消息条数
 *
 *  @return 消息分页条数
 */
- (NSInteger)messageLimit;


/**
 *  返回多久显示一次消息顶部的时间戳
 *
 *  @return 消息顶部时间戳的显示间隔，秒为单位
 */
- (NSTimeInterval)showTimestampInterval;

/**
 *  消息的排版配置，只有使用默认的NIMMessageCell，才会触发此回调
 *
 *  @param message 需要排版的消息
 *
 *  @return 排版配置
 */
- (id<YSFCellLayoutConfig>)layoutConfigWithMessage:(YSF_NIMMessage *)message;

@end
