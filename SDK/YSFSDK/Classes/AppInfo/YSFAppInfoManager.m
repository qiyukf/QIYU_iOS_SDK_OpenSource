//
//  YSFAppInfoManager.m
//  YSFSDK
//
//  Created by amao on 8/26/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAppInfoManager.h"
#import "YSFCreateAccountRequest.h"
#import "YSFHttpApi.h"
#import "YSFSetUserInfoRequest.h"
#import "YSFKeyValueStore.h"
#import "YSFLoginManager.h"
#import "YSFRelationStore.h"
#import "YSFAppSetting.h"
#import "YSFSessionStatusRequest.h"


@interface YSFAppInfoManager ()
<YSFLoginManagerDelegate,YSF_NIMLoginManagerDelegate, YSF_NIMSystemNotificationManagerDelegate>
@property (nonatomic,strong)    YSFAccountInfo      *accountInfo;
@property (nonatomic,strong)    YSFAppSetting       *appSetting;
@property (nonatomic,strong)    QYUserInfo          *qyUserInfo;
@property (nonatomic,copy)      QYCompletionWithResultBlock completionWithResultBlock;
@property (nonatomic,copy)      NSString            *currentForeignUserId;
@property (nonatomic,strong)    YSFKeyValueStore    *store;
@property (nonatomic,copy)      NSString            *deviceId;
@property (nonatomic,strong)    YSFLoginManager     *loginManager;
@property (nonatomic,strong)    YSFRelationStore    *relationStore;
@property (nonatomic,strong)    NSMutableDictionary *cachedTextDict;

@end

@implementation YSFAppInfoManager

- (instancetype)init
{
    if (self = [super init])
    {
        _loginManager = [[YSFLoginManager alloc] init];
        _loginManager.delegate = self;
        
        [[[YSF_NIMSDK sharedSDK] loginManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];

    }
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (NSString *)currentUserId
{
    return _accountInfo.accid;
}

- (NSString *)currentForeignUserId
{
    return _currentForeignUserId;
}

- (void)checkAppInfo
{
    [self readAccountInfo];
    [self readUserInfo];
    
    if (![_accountInfo isValid]) {
        [self createAccount];
    }
    else
    {
        [self login];
    }
}

- (NSString *)appDeviceId
{
    @synchronized(self)
    {
        if(_deviceId == nil)
        {
            _deviceId = [[self store] valueByKey:YSFDeviceInfoKey];;
            if ([_deviceId length] == 0)
            {
                _deviceId = [[[[[NSUUID UUID] UUIDString] lowercaseString] componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
                [[self store] saveValue:_deviceId forKey:YSFDeviceInfoKey];
            }
        }
        return _deviceId;
    }
}

- (void)setUserInfo:(QYUserInfo *)userInfo authTokenVerificationResultBlock:(QYCompletionWithResultBlock)block;
{
    if (userInfo) {
        self.qyUserInfo = userInfo;
        self.currentForeignUserId = userInfo.userId;
        self.completionWithResultBlock = block;
        [self saveUserInfo];
        [self reportUserInfo];
    }
}

- (BOOL)isRecevierOrSpeaker;
{
    return _appSetting.recevierOrSpeaker;
}

- (void)setRecevierOrSpeaker:(BOOL)recevierOrSpeaker
{
    _appSetting.recevierOrSpeaker = recevierOrSpeaker;
    [self saveAppSetting];
}

- (void)logout
{
    [self cleanAccountInfo];
    [self cleanAppSetting];
    [self cleanCurrentForeignUserIdAndCurrentUserInfo];
    [self cleanDeviceId];
    [self createAccount];
}


#pragma mark - 申请匿名账号
- (void)createAccount
{
    YSFCreateAccountRequest *request = [[YSFCreateAccountRequest alloc] init];
    
    [YSFHttpApi post:request
             completion:^(NSError *error, id returendObject) {
             if (error == nil && [returendObject isKindOfClass:[YSFAccountInfo class]]) {
                 _accountInfo = returendObject;
                 YSFLogApp(@"createAccount success accid: %@", _accountInfo.accid);

                 
                 [self saveAccountInfo];
                 [self login];
                 //创建账号成功后回调
                 if (_delegate && [_delegate respondsToSelector:@selector(didCreateAccountSuccessfully)]) {
                     [_delegate didCreateAccountSuccessfully];
                 }
             }
             else
             {
                 YSFLogErr(@"createAccount failed %@", error);
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self createAccount];
                 });
             }
         }];
}

#pragma mark - 汇报用户信息

- (void)reportUserInfo
{
    if (_qyUserInfo)
    {
        YSFLogApp(@"reportUserInfo userId:%@ data:%@", _qyUserInfo.userId, _qyUserInfo.data);

        YSFSetInfoRequest *request = [[YSFSetInfoRequest alloc] init];
        request.authToken = [QYSDK sharedSDK].authToken;
        request.userInfo = _qyUserInfo;
        QYUserInfo *cachedUserInfo = _qyUserInfo;

        __weak typeof(self) weakSelf = self;
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:@"-1"
               completion:^(NSError *error) {
                    if (error == nil && cachedUserInfo == _qyUserInfo)
                    {
                        [self cleanCurrentUserInfo];
                        [weakSelf mapForeignId:cachedUserInfo.userId];
                    }
                    YSFLogApp(@"reportUserInfo error:%@", error);
               }];
    }
}

- (void)mapForeignId:(NSString *)foreignId
{
    NSString *accid = [_accountInfo accid];
    [[self relationStore] mapYsf:accid
                          toUser:foreignId];
}

- (YSFRelationStore *)relationStore
{
    if (_relationStore == nil) {
        _relationStore = [[YSFRelationStore alloc] init];
    }
    return _relationStore;
}


#pragma mark - Info读写
- (YSFKeyValueStore *)store
{
    if (_store == nil)
    {
        NSString *path = [[[QYSDK sharedSDK] pathManager] sdkGlobalPath];
        if (path)
        {
            NSString *storePath = [path stringByAppendingPathComponent:@"app_info.db"];
            _store = [YSFKeyValueStore storeByPath:storePath];
        }
    }
    return _store;
}

- (NSDictionary *)dictByKey:(NSString *)key
{
    NSDictionary *dict = nil;
    NSString *value = [[self store] valueByKey:key];
    if (value)
    {
        dict = [value ysf_toDict];
    }
    return dict;
}

- (NSArray *)arrayByKey:(NSString *)key
{
    NSArray *array = nil;
    NSString *value = [[self store] valueByKey:key];
    if (value)
    {
        array = [value ysf_toArray];
    }
    return array;
}

- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key
{
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error)
        {
            YSFLogErr(@"save dict %@ failed",dict);
        }
        
        if (data)
        {
            [[self store] saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                             forKey:key];

        }

    }
}

- (void)saveArray:(NSArray *)array forKey:(NSString *)key
{
    if ([array isKindOfClass:[NSArray class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error)
        {
            YSFLogErr(@"save dict %@ failed",array);
        }
        
        if (data)
        {
            [[self store] saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                             forKey:key];
            
        }
        
    }
}

#pragma mark - UserInfo
- (void)readUserInfo
{
    _currentForeignUserId = [[self dictByKey:YSFCurrentForeignUserIdKey] objectForKey:@"id"];
    
    NSString *userId = [[self dictByKey:YSFCurrentUserInfoKey] objectForKey:@"id"];
    NSString *data = [[self dictByKey:YSFCurrentUserInfoKey] objectForKey:@"data"];
    if (userId) {
        _qyUserInfo = [QYUserInfo new];
        _qyUserInfo.userId = userId;
        _qyUserInfo.data = data;
    }
}

- (void)saveUserInfo
{
    if (_currentForeignUserId) {
        [self saveDict:@{@"id" : _currentForeignUserId}
                forKey:YSFCurrentForeignUserIdKey];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        if (_qyUserInfo.userId) {
            [userInfo setObject:_qyUserInfo.userId forKey:@"id"];
        }
        if (_qyUserInfo.data) {
            [userInfo setObject:_qyUserInfo.data forKey:@"data"];
        }
        [self saveDict:userInfo forKey:YSFCurrentUserInfoKey];
    }
}

- (void)cleanCurrentForeignUserIdAndCurrentUserInfo
{
    _currentForeignUserId = nil;
    [[self store] removeObjectByID:YSFCurrentForeignUserIdKey];
    [self cleanCurrentUserInfo];
}

- (void)cleanCurrentUserInfo
{
    _qyUserInfo = nil;
    [[self store] removeObjectByID:YSFCurrentUserInfoKey];
}

#pragma mark - AppInfo
- (void)readAccountInfo
{
    NSDictionary *dict = [self dictByKey:YSFAppInfoKey];
    if (dict)
    {
        YSFAccountInfo *info = [YSFAccountInfo infoByDict:dict];
        if ([info isValid]) {
            _accountInfo = info;
        }

    }
}

- (void)saveAccountInfo
{
    if ([_accountInfo isValid])
    {
        NSDictionary *dict = [_accountInfo toDict];
        [self saveDict:dict
                forKey:YSFAppInfoKey];
    }
}

- (void)cleanAccountInfo
{
    _accountInfo = nil;
    [[self store] removeObjectByID:YSFAppInfoKey];
}

#pragma mark - AppSetting
- (void)initSessionViewControllerInfo
{
    NSDictionary *dict = [self dictByKey:YSFAppSettingKey];
    if (dict)
    {
        YSFAppSetting *info = [YSFAppSetting infoByDict:dict];
        if ([info isValid]) {
            _appSetting = info;
        }
    }
    else {
        YSFAppSetting *info = [YSFAppSetting defaultSetting];
        if ([info isValid]) {
            _appSetting = info;
        }
    }
    
    [self changeNimSDKAudioPlayMode];
    
    _cachedTextDict = [[[self store] dictByKey:YSFCachedTextKey] mutableCopy];
    if (!_cachedTextDict) {
        _cachedTextDict = [NSMutableDictionary new];
    }
}

- (void)saveAppSetting
{
    if ([_appSetting isValid])
    {
        NSDictionary *dict = [_appSetting toDict];
        [self saveDict:dict
                forKey:YSFAppSettingKey];
        [self changeNimSDKAudioPlayMode];
    }
}

- (void)changeNimSDKAudioPlayMode
{
    if (_appSetting.recevierOrSpeaker) {
        [[YSF_NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:NO];
        [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:YSF_NIMAudioOutputDeviceReceiver];
    }
    else {
        [[YSF_NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:YES];
        [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:YSF_NIMAudioOutputDeviceSpeaker];
    }
}

- (void)cleanAppSetting
{
    _appSetting = nil;
    [[self store] removeObjectByID:YSFAppSettingKey];
}

#pragma mark - DeviceId
- (void)cleanDeviceId
{
    @synchronized(self)
    {
        _deviceId = nil;
        [[self store] removeObjectByID:YSFDeviceInfoKey];
    }
}

#pragma mark - CachedText
- (NSString *)cachedText:(NSString *)shopId
{
    NSString *catchText = @"";
    if (shopId) {
        catchText = _cachedTextDict[shopId];
    }
    
    return catchText;
}

- (void)setCachedText:(NSString *)cachedText shopId:(NSString *)shopId
{
    if (cachedText && ![_cachedTextDict[shopId] isEqualToString:cachedText])
    {
        _cachedTextDict[shopId] = cachedText;
        [[self store] saveDict:_cachedTextDict forKey:YSFCachedTextKey];
    }
}


#pragma mark - misc
- (void)login
{
    [_loginManager tryToLogin:_accountInfo];
}

#pragma mark - YSFLoginManagerDelegate
- (void)onLoginSuccess:(NSString *)accid
{
    YSFLogApp(@"on login success %@ vs cache account %@",accid,_accountInfo.accid);
    if (_accountInfo.accid && accid && [_accountInfo.accid isEqualToString:accid] &&
        !_accountInfo.isEverLogined)
    {
        _accountInfo.isEverLogined = YES;
        [self saveAccountInfo];
    }
}

- (void)onFatalLoginFailed:(NSError *)error
{
    YSFLogErr(@"on fatal login error rebuild account ing......%@", error);
    [self cleanAccountInfo];
    [self cleanAppSetting];
    [self cleanDeviceId];
    [self createAccount];
}

#pragma mark - YSF_NIMLoginManagerDelegate
- (void)onLogin:(YSF_NIMLoginStep)step
{
    if (step == YSF_NIMLoginStepSyncOK)
    {
        [self reportUserInfo];
        [self requestSessionStatus];
    }
}

- (void)requestSessionStatus
{
    if ([[[QYSDK sharedSDK] infoManager].accountInfo isPop]) {
        YSFSessionStatusRequest *request = [YSFSessionStatusRequest new];
        [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
            YSFLogApp(@"requestSessionStatus error:%@", error);
        }];
    }
}

- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@",content);
    NSDictionary *dict = [content ysf_toDict];
    if (dict) {
        NSInteger cmd = [dict ysf_jsonInteger:YSFApiKeyCmd];
        switch (cmd) {
            case YSFCommandSetCrmResult:
            {
                NSString *foreignId = [dict ysf_jsonString:YSFApiKeyForeignId];
                NSString *authToken = [dict ysf_jsonString:YSFApiKeyAuthToken];
                BOOL result = [dict ysf_jsonBool:YSFApiKeyResult];
                if ([_currentForeignUserId isEqualToString:foreignId]
                    && [[QYSDK sharedSDK].authToken isEqualToString:authToken]) {
                    if (_completionWithResultBlock) {
                        _completionWithResultBlock(result);
                    }
                }
            }
                break;
        }
    }
}

@end
