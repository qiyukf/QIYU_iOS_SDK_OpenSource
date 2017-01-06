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
#import "YSFViewHistoryRequest.h"
#import "YSFConversationManager.h"
#import "NIMSDKConfig.h"
#import "QYCustomUIConfig.h"
#import "YSFDataProvider.h"
#import "YSFSetLeaveStatusRequest.h"
#import "YSFCustomObjectParser.h"
#import "YSFPushMessageRequest.h"

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
        
        
        _serverSetting      = [[YSFServerSetting alloc] init];
        _infoManager        = [[YSFAppInfoManager alloc] init];
        _sessionManager     = [[YSFSessionManager alloc] init];
        
        [YSF_NIMCustomObject registerCustomDecoder:[YSFCustomObjectParser new]];
        
        [[YSFKit sharedKit] setProvider:[YSFDataProvider new]];
    }
    return self;
}

- (void)registerAppId:(NSString *)appKey
              appName:(NSString *)appName
{
    [[YSF_NIMSDK sharedSDK] registerWithAppID:YES appKey:appKey
                                  cerName:appName];
    
    [_pathManager setup:appKey];
    [_infoManager checkAppInfo];
    
    [_sessionManager readData];
}


- (void)trackHistory:(NSString *)urlString
      withAttributes:(NSDictionary *)attributes
{
    YSFViewHistoryRequest *request = [[YSFViewHistoryRequest alloc] init];
    request.urlString = urlString;
    request.attributes= attributes;
    
    [YSFHttpApi get:request
         completion:nil];
}

- (void)setUserInfo:(QYUserInfo *)userInfo
{
    ysf_main_async(^{
        [_infoManager setUserInfo:userInfo];
    });
}

- (void)getPushMessage:(NSString *)messageId
{
    YSFPushMessageRequest *request = [[YSFPushMessageRequest alloc] init];
    request.messageId = messageId;
    [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
    }];
}

- (void)registerPushMessageNotification:(QYPushMessageBlock)block
{
    self.pushMessageBlock = block;
}

- (void)updateApnsToken:(NSData *)token
{
    [[YSF_NIMSDK sharedSDK] updateApnsToken:token];
}

- (void) logoutNim:(QYCompletionBlock)completion
{
    [[[YSF_NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
        [_sessionManager clear];
        [_infoManager logout];
        
        if (completion) {
            completion();
        }
        NIMLogApp(@"logout end");
    }];
}

- (void)logout:(QYCompletionBlock)completion
{
    NIMLogApp(@"begin to logout");
    
    YSFSetLeaveStatusRequest *request = [[YSFSetLeaveStatusRequest alloc] init];
    [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
        [self logoutNim:completion];
    }];
}


- (QYSessionViewController *)sessionViewController
{
    QYSessionViewController *vc = [[QYSessionViewController alloc] init];
    return vc;
}

- (NSString *)appKey
{
    return [[YSF_NIMSDK sharedSDK] appKey];
}

- (QYConversationManager *)conversationManager
{
    if (_sdkConversationManager == nil)
    {
        _sdkConversationManager = [[YSFConversationManager alloc] init];
    }
    return _sdkConversationManager;
}

- (QYCustomUIConfig *)customUIConfig
{
    return [QYCustomUIConfig sharedInstance];
}

- (QYCustomActionConfig *)customActionConfig
{
    return [QYCustomActionConfig sharedInstance];
}

#pragma mark - 内部接口

- (NSString *)nimLog
{
    return [[YSF_NIMSDK sharedSDK] currentLogFilepath];
}

- (NSString *)currentForeignUserId
{
    return [_infoManager currentForeignUserId];
}

- (void)setServerSetting:(YSFServerSetting *)serverSetting
{
    [_serverSetting update:serverSetting];
}

- (NSString *)deviceId
{
    return [_infoManager appDeviceId];
}


@end
