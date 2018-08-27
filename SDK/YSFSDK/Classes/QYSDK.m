//
//  QYSDK.m
//  QYSDK
//
//  Created by towik on 12/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "QYSDK_Private.h"
#import "QYSessionViewController_Private.h"
#import "YSFKit.h"
#import "YSFHttpApi.h"
#import "YSFConversationManager.h"
#import "NIMSDKConfig.h"
#import "QYCustomUIConfig.h"
#import "YSFDataProvider.h"
#import "YSFSetLeaveStatusRequest.h"
#import "YSFCustomObjectParser.h"
#import "YSFPushMessageRequest.h"
#import "YSFCancelWaitingRequest.h"
#import "NIMDataTracker.h"
#import "YSFDARequest.h"

@implementation QYSDK

+ (instancetype)sharedSDK
{
    static QYSDK *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QYSDK alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        
        //路径需要最先进行配置
        _pathManager        = [[YSFPathManager alloc] init];
        [[YSF_NIMSDKConfig sharedConfig] setSdkDir:[_pathManager sdkRootPath]];
                
        _infoManager        = [[YSFAppInfoManager alloc] init];
        _sessionManager     = [[YSFSessionManager alloc] init];
        
        [YSF_NIMCustomObject registerCustomDecoder:[YSFCustomObjectParser new]];
        
        [[YSFKit sharedKit] setProvider:[YSFDataProvider new]];
    }
    return self;
}

- (NSString *)serverAddress
{
    NSString *serverAddress = @"";
    if (_serverSetting == YSFUseServerSettingTest)
    {
        serverAddress = @"ysf.space";
    }
    else if (_serverSetting == YSFUseServerSettingPre)
    {
        serverAddress = @"qiyukf.netease.com";
    }
    else if (_serverSetting == YSFUseServerSettingOnline)
    {
        serverAddress = @"qiyukf.com";
    }
    
    return serverAddress;
}

- (void)registerAppId:(NSString *)appKey
              appName:(NSString *)appName
{
    YSFLogApp(@"appKey: %@ appName: %@", appKey, appName);

    
    [[YSF_NIMSDK sharedSDK] registerWithAppID:YES appKey:appKey
                                  cerName:appName];
    
    /**
     * 去掉wfd.netease.im域名访问，云信已不采集此部分数据
     YSF_NIMDataTrackerOption *trackerOption = [YSF_NIMDataTrackerOption new];
     trackerOption.name      = @"qy";
     trackerOption.version   = [[QYSDK sharedSDK].infoManager version];
     trackerOption.appKey    = appKey;
     [[YSF_NIMDataTracker shared] start:trackerOption];
     */
    
    [_pathManager setup:appKey];
    [_infoManager checkAppInfo];
    
    [_sessionManager readData];
}

- (void)trackHistory:(NSString *)title enterOrOut:(BOOL)enterOrOut key:(NSString *)key
{
    YSFLogApp(@"trackHistory title:%@ enterOrOut:%@", title, enterOrOut);

    __weak typeof(self) weakSelf = self;
    ysf_main_async(^{
        [weakSelf.infoManager trackHistory:title enterOrOut:enterOrOut key:key];
    });
}

//- (void)trackHistory:(NSString *)urlString
//      withAttributes:(NSDictionary *)attributes
//{
//    YSFLogApp(@"urlString: %@ attributes: %@", urlString, attributes);
//
//    YSFViewHistoryRequest *request = [[YSFViewHistoryRequest alloc] init];
//    request.urlString = urlString;
//    request.attributes= attributes;
//
//    [YSFHttpApi get:request
//         completion:nil];
//}

- (void)setUserInfo:(QYUserInfo *)userInfo
{
    YSFLogApp(@"userInfoId: %@  userInfoData: %@", userInfo.userId, userInfo.data);
    ysf_main_async(^{
        [_infoManager setUserInfo:userInfo authTokenVerificationResultBlock:nil];
    });
}

- (void)setAuthToken:(NSString *)authToken
{
    _authToken = authToken;
}

- (void)setUserInfo:(QYUserInfo *)userInfo authTokenVerificationResultBlock:(QYCompletionWithResultBlock)block
{
    YSFLogApp(@"userInfoId: %@  userInfoData: %@", userInfo.userId, userInfo.data);
    
    ysf_main_async(^{
        [_infoManager setUserInfo:userInfo authTokenVerificationResultBlock:block];
    });
}

- (void)getPushMessage:(NSString *)messageId
{
    YSFLogApp(@"messageId: %@", messageId);

    YSFPushMessageRequest *request = [[YSFPushMessageRequest alloc] init];
    request.messageId = messageId;
    [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
    }];
}

- (void)registerPushMessageNotification:(QYPushMessageBlock)block
{
    YSFLogApp(@"");

    self.pushMessageBlock = block;
}

- (void)updateApnsToken:(NSData *)token
{
    YSFLogApp(@"");

    [[YSF_NIMSDK sharedSDK] updateApnsToken:token];
}

- (void)logoutNim:(QYCompletionBlock)completion
{
    YSFLogApp(@"begin to logoutNim");

    [[[YSF_NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        [_sessionManager clear];
        [_infoManager logout];
        
        if (completion) {
            completion();
        }
        YSFLogApp(@"logout end");
    }];
}

- (void)logout:(QYCompletionBlock)completion
{
    YSFLogApp(@"begin to logout");
    
    YSFSessionManager *sessionManager = [[QYSDK sharedSDK] sessionManager];
    [sessionManager.sessions enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull shopId, YSFServiceSession *_Nonnull session, BOOL * _Nonnull stop) {
        YSFCancelWaitingRequest *cancelWaitingRequest = [YSFCancelWaitingRequest new];
        cancelWaitingRequest.sessionId = session.sessionId;
        [YSFIMCustomSystemMessageApi sendMessage:cancelWaitingRequest shopId:shopId completion:^(NSError *error){
        }];
    }];
    
    YSFSetLeaveStatusRequest *request = [[YSFSetLeaveStatusRequest alloc] init];
    [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
        [self logoutNim:completion];
    }];
}


- (QYSessionViewController *)sessionViewController
{
    YSFLogApp(@"");

    QYSessionViewController *vc = [[QYSessionViewController alloc] init];
    return vc;
}

- (NSString *)appKey
{
    YSFLogApp(@"");

    return [[YSF_NIMSDK sharedSDK] appKey];
}

- (QYConversationManager *)conversationManager
{
    YSFLogApp(@"");

    if (_sdkConversationManager == nil)
    {
        _sdkConversationManager = [[YSFConversationManager alloc] init];
    }
    return _sdkConversationManager;
}

- (QYCustomUIConfig *)customUIConfig
{
    YSFLogApp(@"");

    return [QYCustomUIConfig sharedInstance];
}

- (QYCustomActionConfig *)customActionConfig
{
    YSFLogApp(@"");

    return [QYCustomActionConfig sharedInstance];
}

- (void)cleanResourceCacheWithBlock:(QYCleanResourceCacheCompleteBlock)completeBlock
{
    YSFLogApp(@"");

    [[[YSF_NIMSDK sharedSDK] resourceManager] cleanResourceCacheWithBlock:^(NSError *error) {
        if (completeBlock) {
            completeBlock(error);
        }
    }];
}

#pragma mark - 内部接口

- (NSString *)qiyuLogPath
{
    return [[YSF_NIMSDK sharedSDK] currentLogFilepath];
}

- (NSString *)currentForeignUserId
{
    return [_infoManager currentForeignUserId];
}

- (NSString *)deviceId
{
    return [_infoManager appDeviceId];
}

+ (void)cleanMessageCache
{
    [[[YSF_NIMSDK sharedSDK] conversationManager] deleteAllMessages:YES];
}

@end
