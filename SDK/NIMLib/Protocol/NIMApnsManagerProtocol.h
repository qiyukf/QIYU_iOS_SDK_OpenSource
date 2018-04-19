//
//  YSF_NIMApnsManager.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSF_NIMPushNotificationSetting;

/**
 *  获取 badge 回调
 *
 *  @return badge 数量
 */
typedef NSUInteger(^YSF_NIMBadgeHandler)(void);

/**
 *  更新推送回调
 *
 *  @param error 错误信息，成功则error为nil
 */
typedef void(^YSF_NIMApnsHandler)(NSError *error);

/**
 *  推送协议
 */
@protocol YSF_NIMApnsManager <NSObject>
/**
 *  获取当前的推送设置
 *
 *  @return 推送设置
 */
- (YSF_NIMPushNotificationSetting *)currentSetting;

/**
 *  更新推送设置
 *
 *  @param setting    推送设置
 *  @param completion 完成的回调
 */
- (void)updateApnsSetting:(YSF_NIMPushNotificationSetting *)setting
               completion:(YSF_NIMApnsHandler)completion;

/**
 *  注册获取 badge 数量的回调函数
 *
 *  @param handler 获取 badge 回调
 */
- (void)registerBadgeCountHandler:(YSF_NIMBadgeHandler)handler;

@end
