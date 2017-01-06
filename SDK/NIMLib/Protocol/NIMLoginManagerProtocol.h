//
//  NIMLoginManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMLoginClient.h"

/**
 *  登录服务相关Block
 *
 *  @param error 执行结果,如果成功error为nil
 */
typedef void(^YSF_NIMLoginHandler)(NSError *error);

/**
 *  登录步骤枚举
 */
typedef NS_ENUM(NSInteger, YSF_NIMLoginStep)
{
    /**
     *  连接服务器
     */
    YSF_NIMLoginStepLinking = 1,
    /**
     *  连接服务器成功
     */
    YSF_NIMLoginStepLinkOK,
    /**
     *  连接服务器失败
     */
    YSF_NIMLoginStepLinkFailed,
    /**
     *  登录
     */
    YSF_NIMLoginStepLogining,
    /**
     *  登录成功
     */
    YSF_NIMLoginStepLoginOK,
    /**
     *  登录失败
     */
    YSF_NIMLoginStepLoginFailed,
    /**
     *  开始同步
     */
    YSF_NIMLoginStepSyncing,
    /**
     *  同步完成
     */
    YSF_NIMLoginStepSyncOK,
    /**
     *  网络切换
     *  @discussion 这个并不是登录步骤的一种,但是UI有可能需要通过这个状态进行UI展现
     */
    YSF_NIMLoginStepNetChanged,
};

/**
 *  被踢下线的原因
 */
typedef NS_ENUM(NSInteger, YSF_NIMKickReason)
{
    /**
     *  被另外一个客户端踢下线 (互斥客户端一端登录挤掉上一个登录中的客户端)
     */
    YSF_NIMKickReasonByClient = 1,
    /**
     *  被服务器踢下线
     */
    YSF_NIMKickReasonByServer = 2,
    /**
     *  被另外一个客户端手动选择踢下线
     */
    YSF_NIMKickReasonByClientManually   = 3,
};

/**
 *  登录相关回调
 */
@protocol YSF_NIMLoginManagerDelegate <NSObject>

@optional
/**
 *  被踢(服务器/其他端)回调
 *
 *  @param code        被踢原因
 *  @param clientType  发起踢出的客户端类型
 */
- (void)onKick:(YSF_NIMKickReason)code clientType:(YSF_NIMLoginClientType)clientType;

/**
 *  登录回调
 *
 *  @param step 登录步骤
 *  @discussion 这个回调主要用于客户端UI的刷新
 */
- (void)onLogin:(YSF_NIMLoginStep)step;

/**
 *  自动登录失败回调
 *
 *  @param error 失败原因
 */
- (void)onAutoLoginFailed:(NSError *)error;

/**
 *  多端登录发生变化
 */
- (void)onMultiLoginClientsChanged;
@end

/**
 *  登录协议
 */
@protocol YSF_NIMLoginManager <NSObject>

/**
 *  登录
 *
 *  @param account    帐号
 *  @param token      令牌 (在后台绑定的登录token)
 *  @param completion 完成回调
 */
- (void)login:(NSString *)account
        token:(NSString *)token
   completion:(YSF_NIMLoginHandler)completion;


/**
 *  自动登录
 *
 *  @param account    帐号
 *  @param token      令牌 (在后台绑定的登录token)
 *  @discussion 启动APP如果已经保存了用户帐号和令牌,建议使用这个登录方式,使用这种方式可以在无网络时直接打开会话窗口
 */
- (void)autoLogin:(NSString *)account
            token:(NSString *)token;
/**
 *  登出
 *
 *  @param completion 完成回调
 */
- (void)logout:(YSF_NIMLoginHandler)completion;

/**
 *  踢人
 *
 *  @param client     当前登录的其他帐号
 *  @param completion 完成回调
 */
- (void)kickOtherClient:(YSF_NIMLoginClient *)client
             completion:(YSF_NIMLoginHandler)completion;

/**
 *  返回当前登录帐号
 *
 *  @return 当前登录帐号,如果没有登录成功,这个地方会返回nil
 */
- (NSString *)currentAccount;

/**
 *  返回当前登录的设备列表
 *
 *  @return 当前登录设备列表 内部是YSF_NIMLoginClient,不包括自己
 */
- (NSArray *)currentLoginClients;

/**
 *  添加登录委托
 *
 *  @param delegate 登录委托
 */
- (void)addDelegate:(id<YSF_NIMLoginManagerDelegate>)delegate;

/**
 *  移除登录委托
 *
 *  @param delegate 登录委托
 */
- (void)removeDelegate:(id<YSF_NIMLoginManagerDelegate>)delegate;
@end
