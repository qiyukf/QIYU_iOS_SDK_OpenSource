//
//  YSF_NIMRecentSession.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YSF_NIMMessage;
@class YSF_NIMSession;

/**
 *  最近会话
 */
@interface YSF_NIMRecentSession : NSObject

/**
 *  当前会话
 */
@property (nonatomic,readonly,strong)   YSF_NIMSession  *session;

/**
 *  最后一条消息
 */
@property (nonatomic,readonly,strong)   YSF_NIMMessage  *lastMessage;

/**
 *  未读消息数(此接口需要在UI线程上调用)
 */
@property (nonatomic,readonly,assign)   NSInteger   unreadCount;

+ (instancetype)recentSessionWithSession:(YSF_NIMSession *)session;

@end
