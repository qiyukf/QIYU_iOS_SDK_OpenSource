//
//  NIMUserManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class YSF_NIMUserRequest;
@class YSF_NIMUser;

/**
 *  好友信息操作Block
 *
 *  @param error 错误信息
 */
typedef void(^YSF_NIMUserBlock)(NSError *error);

/**
 *  好友协议委托
 */
@protocol YSF_NIMUserManagerDelegate <NSObject>

@optional

/**
 *  好友状态发生变化
 *
 *  @param user 好友对象
 */
- (void)onFriendChanged:(YSF_NIMUser *)user;

/**
 *  黑名单状态发生变化
 */
- (void)onBlackListChanged;

@end

/**
 *  好友协议
 */
@protocol YSF_NIMUserManager <NSObject>

/**
 *  添加好友
 *
 *  @param request 添加好友请求
 *  @param block   完成回调
 */
- (void)requestFriend:(YSF_NIMUserRequest *)request
           completion:(YSF_NIMUserBlock)block;

/**
 *  删除好友
 *
 *  @param userId 好友Id
 *  @param block  完成回调
 */
- (void)deleteFriend:(NSString *)userId
          completion:(YSF_NIMUserBlock)block;

/**
 *  返回我的好友列表
 *
 *  @return YSF_NIMUser列表
 */
- (NSArray *)myFriends;

/**
 *  添加用户到黑名单
 *
 *  @param userId     用户Id
 *  @param block      完成block
 */
- (void)addToBlackList:(NSString *)userId
            completion:(YSF_NIMUserBlock)block;

/**
 *  将用户从黑名单移除
 *
 *  @param userId     用户Id
 *  @param block      完成block
 */
- (void)removeFromBlackBlackList:(NSString *)userId
                      completion:(YSF_NIMUserBlock)block;

/**
 *  判断用户是否已被拉黑
 *
 *  @param userId 用户Id
 *
 *  @return 是否已被拉黑
 */
- (BOOL)isUserInBlackList:(NSString *)userId;

/**
 *  返回所有在黑名单中的用户列表
 *
 *  @return 黑名单成员列表
 */
- (NSArray *)myBlackList;


/**
 *  设置消息提醒
 *
 *  @param notify     是否提醒
 *  @param userId     用户Id
 *  @param block      完成block
 */
- (void)updateNotifyState:(BOOL)notify
                  forUser:(NSString *)userId
               completion:(YSF_NIMUserBlock)block;


/**
 *  是否需要消息通知
 *
 *  @param userId 用户Id
 *
 *  @return 是否需要消息通知
 */
- (BOOL)notifyForNewMsg:(NSString *)userId;

/**
 *  静音列表
 *
 *  @return 返回被我设置为取消消息通知的用户列表
 */
- (NSArray *)myMuteUserList;

/**
 *  添加好友委托
 *
 *  @param delegate 好友委托
 */
- (void)addDelegate:(id<YSF_NIMUserManagerDelegate>)delegate;

/**
 *  移除好友委托
 *
 *  @param delegate 好友委托
 */
- (void)removeDelegate:(id<YSF_NIMUserManagerDelegate>)delegate;

@end
