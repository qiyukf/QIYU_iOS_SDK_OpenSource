//
//  YSFCellConfig.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

@class YSFSessionMessageContentView;
@class YSFMessageModel;

@protocol YSFCellLayoutConfig <NSObject>

@optional

/**
 * @return 返回message的内容大小
 */
- (CGSize)contentSize:(YSFMessageModel *)model cellWidth:(CGFloat)width;


/**
 *  需要构造的cellContent类名
 */
- (NSString *)cellContent:(YSFMessageModel *)model;

/**
 *  cell气泡距离整个cell的内间距
 */
- (UIEdgeInsets)cellInsets:(YSFMessageModel *)model;

/**
 *  cell内容距离气泡的内间距
 */
- (UIEdgeInsets)contentViewInsets:(YSFMessageModel *)model;


/**
 *  是否显示头像
 */
- (BOOL)shouldShowAvatar:(YSFMessageModel *)model;

/**
 *  是否显示姓名
 */
- (BOOL)shouldShowNickName:(YSFMessageModel *)model;

/**
 *  是否显示扩展视图
 */
- (BOOL)shouldShowExtraView:(YSFMessageModel *)model;

/**
 *  格式化消息文本
 *  @discussion ，仅当cellContent为NIMSessionNotificationContentView时会调用.如果是NIMSessionNotificationContentView的子类,需要继承refresh:方法。
 */
- (NSString *)formatedMessage:(YSFMessageModel *)model;

@end
