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
#import "YSFHistoryMsgTokenRequest.h"
#import "YSFHistoryMessageRequest.h"
#import "NIMDataTracker.h"
#import "NSArray+YSF.h"
#import "QYSDK_Private.h"
#import "YSFDARequest.h"
#import "YSFDARequestConfig.h"
#import "YSFUploadLog.h"

static NSInteger YSFMaxCreateAccountCount = 5;

typedef NS_ENUM(NSInteger, YSFTrackHistoryType) {
    YSFTrackHistoryTypeNone,
    YSFTrackHistoryTypePage,      //访问轨迹
    YSFTrackHistoryTypeAction,    //行为轨迹
};

@interface YSFAppInfoManager () <YSFLoginManagerDelegate,YSF_NIMLoginManagerDelegate, YSF_NIMSystemNotificationManagerDelegate>

@property (nonatomic, strong) YSFLoginManager *loginManager;
@property (nonatomic, strong) YSFAccountInfo *accountInfo;
@property (nonatomic, strong) YSFAppSetting *appSetting;
@property (nonatomic, strong) QYUserInfo *qyUserInfo;
@property (nonatomic, copy) NSString *currentForeignUserId;
@property (nonatomic, copy) NSString *deviceId;

@property (nonatomic, strong) YSFKeyValueStore *store;
@property (nonatomic, strong) YSFRelationStore *relationStore;
@property (nonatomic, strong) NSMutableDictionary *cachedTextDict;
@property (nonatomic, copy) QYCompletionWithResultBlock completionWithResultBlock;

@property (nonatomic, assign) BOOL isSendingTrackData;
@property (nonatomic, assign) BOOL track;
@property (nonatomic, assign) BOOL uploadedLog;
@property (nonatomic, assign) NSInteger createAccountCount;
@property (nonatomic, copy) QYCompletionBlock logoutCompletion;

@end


@implementation YSFAppInfoManager
- (void)dealloc {
    [[[YSF_NIMSDK sharedSDK] loginManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
}

- (instancetype)init {
    if (self = [super init]) {
        _loginManager = [[YSFLoginManager alloc] init];
        _loginManager.delegate = self;
        
        [[[YSF_NIMSDK sharedSDK] loginManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
        
        _createAccountCount = 0;
    }
    return self;
}

- (void)initSessionViewControllerInfo {
    NSDictionary *dict = [self dictByKey:YSFAppSettingKey];
    if (dict) {
        YSFAppSetting *info = [YSFAppSetting infoByDict:dict];
        if ([info isValid]) {
            _appSetting = info;
        }
    } else {
        YSFAppSetting *info = [YSFAppSetting defaultSetting];
        if ([info isValid]) {
            _appSetting = info;
        }
    }
    [self changeNimSDKAudioPlayMode];
    _cachedTextDict = [[[self store] dictByKey:YSFCachedTextKey] mutableCopy];
    if (!_cachedTextDict) {
        _cachedTextDict = [NSMutableDictionary dictionary];
    }
}

- (void)saveAppSetting {
    if ([_appSetting isValid]) {
        NSDictionary *dict = [_appSetting toDict];
        [self saveDict:dict forKey:YSFAppSettingKey];
        [self changeNimSDKAudioPlayMode];
    }
}

- (void)cleanAppSetting {
    _appSetting = nil;
    [[self store] removeObjectByID:YSFAppSettingKey];
}

- (void)changeNimSDKAudioPlayMode {
    if (_appSetting.recevierOrSpeaker) {
        [[YSF_NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:NO];
        [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:YSF_NIMAudioOutputDeviceReceiver];
    } else {
        [[YSF_NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:YES];
        [[YSF_NIMSDK sharedSDK].mediaManager switchAudioOutputDevice:YSF_NIMAudioOutputDeviceSpeaker];
    }
}

#pragma mark - version
- (NSString *)version {
    return @"4.11.0";
}

- (NSString *)versionNumber {
    return @"52";
}

#pragma mark - ID
- (NSString *)currentUserId {
    return _accountInfo.accid;
}

- (NSString *)currentForeignUserId {
    return _currentForeignUserId;
}

- (NSString *)appDeviceId {
    @synchronized(self) {
        if (!_deviceId) {
            _deviceId = [[self store] valueByKey:YSFDeviceInfoKey];;
            if ([_deviceId length] == 0) {
                _deviceId = [[[[[NSUUID UUID] UUIDString] lowercaseString] componentsSeparatedByString:@"-"] componentsJoinedByString:@""];
                [[self store] saveValue:_deviceId forKey:YSFDeviceInfoKey];
            }
        }
        return _deviceId;
    }
}

- (void)cleanCurrentForeignUserIdAndCurrentUserInfo {
    _currentForeignUserId = nil;
    [[self store] removeObjectByID:YSFCurrentForeignUserIdKey];
    [self cleanCurrentUserInfo];
}

- (void)cleanDeviceId {
    @synchronized(self) {
        _deviceId = nil;
        [[self store] removeObjectByID:YSFDeviceInfoKey];
    }
}

#pragma mark - AccountInfo
- (void)readAccountInfo {
    NSDictionary *dict = [self dictByKey:YSFAppInfoKey];
    if (dict) {
        YSFAccountInfo *info = [YSFAccountInfo infoByDict:dict];
        if ([info isValid]) {
            _accountInfo = info;
        }
    }
}

- (void)saveAccountInfo {
    if ([_accountInfo isValid]) {
        NSDictionary *dict = [_accountInfo toDict];
        [self saveDict:dict forKey:YSFAppInfoKey];
    }
}

- (void)cleanAccountInfo {
    _accountInfo = nil;
    [[self store] removeObjectByID:YSFAppInfoKey];
}

#pragma mark - Register/Login/Logout
- (void)checkAppInfo {
    [self readAccountInfo];
    [self readUserInfo];
    if (![_accountInfo isValid]) {
        _createAccountCount = 0;
        [self createAccount];
    } else {
        [self login];
    }
    //访问/行为轨迹是否可用
    YSFDARequestConfig *request = [[YSFDARequestConfig alloc] init];
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi get:request completion:^(NSError *error, YSFDARequestConfig *config) {
        if (!error) {
            weakSelf.track = config.track;
        }
    }];
}

- (void)login {
    _uploadedLog = NO;
    [_loginManager tryToLogin:_accountInfo];
}

- (void)logout:(QYCompletionBlock)completion {
    [self cleanAccountInfo];
    [self cleanAppSetting];
    [[QYSDK sharedSDK] cleanAuthToken];
    [self cleanCurrentForeignUserIdAndCurrentUserInfo];
    [self cleanDeviceId];
    
    _logoutCompletion = completion;
    _createAccountCount = 0;
    [self createAccount];
}

- (void)createAccount {
    _createAccountCount++;
    YSFCreateAccountRequest *request = [[YSFCreateAccountRequest alloc] init];
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi post:request completion:^(NSError *error, id returendObject) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error && [returendObject isKindOfClass:[YSFAccountInfo class]]) {
            strongSelf.accountInfo = returendObject;
            YSFLogApp(@"createAccount success accid: %@", strongSelf.accountInfo.accid);
            [strongSelf saveAccountInfo];
            [strongSelf login];
            //创建账号成功后回调
            if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didCreateAccountSuccessfully)]) {
                [strongSelf.delegate didCreateAccountSuccessfully];
            }
        } else {
            if (strongSelf->_createAccountCount <= YSFMaxCreateAccountCount) {
                YSFLogErr(@"createAccount failed %@", error);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [strongSelf createAccount];
                });
            }
        }
    }];
}

- (YSFRelationStore *)relationStore {
    if (!_relationStore) {
        _relationStore = [[YSFRelationStore alloc] init];
    }
    return _relationStore;
}

- (void)mapForeignId:(NSString *)foreignId {
    NSString *accid = [_accountInfo accid];
    [[self relationStore] mapYsf:accid toUser:foreignId];
}

#pragma mark - UserInfo
- (void)readUserInfo {
    _currentForeignUserId = [[self dictByKey:YSFCurrentForeignUserIdKey] objectForKey:@"id"];
    
    NSString *userId = [[self dictByKey:YSFCurrentUserInfoKey] objectForKey:@"id"];
    NSString *data = [[self dictByKey:YSFCurrentUserInfoKey] objectForKey:@"data"];
    if (userId) {
        _qyUserInfo = [[QYUserInfo alloc] init];
        _qyUserInfo.userId = userId;
        _qyUserInfo.data = data;
    }
}

- (void)setUserInfo:(QYUserInfo *)userInfo authTokenVerificationResultBlock:(QYCompletionWithResultBlock)block; {
    if (userInfo) {
        self.qyUserInfo = userInfo;
        self.currentForeignUserId = userInfo.userId;
        self.completionWithResultBlock = block;
        [self saveUserInfo];
        [self reportUserInfo];
    }
}

- (void)saveUserInfo {
    if (_currentForeignUserId) {
        [self saveDict:@{@"id" : _currentForeignUserId} forKey:YSFCurrentForeignUserIdKey];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (_qyUserInfo.userId) {
            [userInfo setValue:_qyUserInfo.userId forKey:@"id"];
        }
        if (_qyUserInfo.data) {
            [userInfo setValue:_qyUserInfo.data forKey:@"data"];
        }
        [self saveDict:userInfo forKey:YSFCurrentUserInfoKey];
    }
}

- (void)reportUserInfo {
    if (_qyUserInfo) {
        YSFLogApp(@"reportUserInfo userId:%@ data:%@", _qyUserInfo.userId, _qyUserInfo.data);
        
        YSFCreateAccountRequest *request = [[YSFCreateAccountRequest alloc] init];
        request.foreignID = _currentForeignUserId;
        request.authToken = [[QYSDK sharedSDK] authToken];
        NSMutableArray *array = [[_qyUserInfo.data ysf_toArray] mutableCopy];
        if (array) {
            NSDictionary *versionDict = @{ @"key" : @"sdk_version",
                                           @"value" : YSFStrParam([[QYSDK sharedSDK].infoManager versionNumber]),
                                           @"hidden" : @(YES),
                                          };
            [array addObject:versionDict];
            NSString *crmInfo = [array ysf_toUTF8String];
            if (crmInfo.length) {
                NSString *chars = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
                NSCharacterSet *allowedChars = [[NSCharacterSet characterSetWithCharactersInString:chars] invertedSet];
                request.crmInfo = [crmInfo stringByAddingPercentEncodingWithAllowedCharacters:allowedChars];
            }
        }
        __weak typeof(self) weakSelf = self;
        [YSFHttpApi post:request completion:^(NSError *error, id returendObject) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!error && [returendObject isKindOfClass:[YSFAccountInfo class]]) {
                YSFAccountInfo *account = (YSFAccountInfo *)returendObject;
                //若账号发生变化，需重新记录并登录
                if (!strongSelf.accountInfo || ![account isEqual:strongSelf.accountInfo]) {
                    strongSelf.accountInfo = account;
                    [strongSelf saveAccountInfo];
                    [strongSelf login];
                    if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(didCreateAccountSuccessfully)]) {
                        [strongSelf.delegate didCreateAccountSuccessfully];
                    }
                }
                YSFLogApp(@"reportUserInfo success accid: %@", strongSelf.accountInfo.accid);
                [weakSelf cleanCurrentUserInfo];
                [weakSelf mapForeignId:strongSelf.qyUserInfo.userId];
                //拉取未读消息
                [weakSelf requestHistoryMessagesToken];
            } else {
                YSFLogErr(@"reportUserInfo failed error: %@", error);
            }
        }];
    }
}

- (void)cleanCurrentUserInfo {
    _qyUserInfo = nil;
    [[self store] removeObjectByID:YSFCurrentUserInfoKey];
}

#pragma mark - YSFLoginManagerDelegate
- (void)onLoginSuccess:(NSString *)accid {
    YSFLogApp(@"on login success %@ vs cache account %@", accid, _accountInfo.accid);
    if (_accountInfo.accid && accid && [_accountInfo.accid isEqualToString:accid] && !_accountInfo.isEverLogined) {
        _accountInfo.isEverLogined = YES;
        [self saveAccountInfo];
    }
}

- (void)onFatalLoginFailed:(NSError *)error {
    YSFLogErr(@"on fatal login error rebuild account ing......%@", error);
    [self cleanAccountInfo];
    [self cleanAppSetting];
    [self cleanDeviceId];
    _createAccountCount = 0;
    [self createAccount];
    //日志上传节点：SDK初始化失败
    [self uploadLog];
    if (_logoutCompletion) {
        _logoutCompletion(NO);
        _logoutCompletion = nil;
    }
}

- (void)uploadLog {
    if (!_uploadedLog) {
        YSFUploadLog *uploadLog = [[YSFUploadLog alloc] init];
        uploadLog.version = [self version];
        uploadLog.type = YSFUploadLogTypeSDKInitFail;
        uploadLog.logString = YSF_GetMessage(50000);
        [YSFHttpApi post:uploadLog
              completion:^(NSError *error, id returendObject) {
                  
              }];
        _uploadedLog = YES;
    }
}

#pragma mark - YSF_NIMLoginManagerDelegate
- (void)onLogin:(YSF_NIMLoginStep)step {
    if (step == YSF_NIMLoginStepSyncOK) {
        [self reportUserInfo];
        [self requestSessionStatus];
        /**
         * 去掉wfd.netease.im域名访问，云信已不采集此部分数据
         [[YSF_NIMDataTracker shared] trackEvent];
         */
        [self sendTrackHistoryData];
        if (_logoutCompletion) {
            _logoutCompletion(YES);
            _logoutCompletion = nil;
        }
    }
}

- (void)requestSessionStatus {
    if ([[[QYSDK sharedSDK] infoManager].accountInfo isPop]) {
        YSFSessionStatusRequest *request = [[YSFSessionStatusRequest alloc] init];
        [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
            YSFLogApp(@"requestSessionStatus error:%@", error);
        }];
    }
}

#pragma mark - YSF_NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification {
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@",content);
    NSDictionary *dict = [content ysf_toDict];
    if (dict) {
        NSInteger cmd = [dict ysf_jsonInteger:YSFApiKeyCmd];
        switch (cmd) {
            case YSFCommandSetCrmResult: {
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
            case YSFCommandHistoryMsgTokenResult: {
                NSString *token = [dict ysf_jsonString:YSFApiKeyAccessToken];
                if (token.length) {
                    NSString *shopId = notification.sender ? notification.sender : @"-1";
                    [self requestHistoryMessages:token shopId:shopId];
                }
            }
                break;
        }
    }
}

#pragma mark - 访问/行为轨迹
- (void)trackHistory:(NSString *)title enterOrOut:(BOOL)enterOrOut key:(NSString *)key {
    if (!_track) {
        return;
    }
    [self saveTrackHistory:title type:YSFTrackHistoryTypePage enterOrOut:enterOrOut description:nil key:key];
    [self sendTrackHistoryData];
}

- (void)trackHistory:(NSString *)title description:(NSDictionary *)description key:(NSString *)key {
    if (!_track) {
        return;
    }
    [self saveTrackHistory:title type:YSFTrackHistoryTypeAction enterOrOut:NO description:description key:key];
    [self sendTrackHistoryData];
}

- (void)saveTrackHistory:(NSString *)title
                    type:(YSFTrackHistoryType)type
              enterOrOut:(BOOL)enterOrOut
             description:(NSDictionary *)description
                     key:(NSString *)key {
    //1.将轨迹信息转换为dictionary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:10];
    if (title) {
        [dict setValue:title forKey:YSFDARequestTitleKey];
    }
    if (key) {
        [dict setValue:key forKey:YSFDARequestKeyKey];
    }
    long long time =  [[NSDate date] timeIntervalSince1970] * 1000;
    [dict setValue:@(time) forKey:YSFDARequestTimeKey];

    if (YSFTrackHistoryTypePage == type) {
        [dict setValue:@"0" forKey:YSFDARequestTypeKey];
        [dict setValue:@(!enterOrOut) forKey:YSFDARequestEnterOrOutKey];
        YSFLogApp(@"trackHistory title:%@ type:page enterOrOut:%@", title, @(enterOrOut));
    } else if (YSFTrackHistoryTypeAction == type) {
        [dict setValue:@"1" forKey:YSFDARequestTypeKey];
        if (description && description.count) {
            NSError *parseError = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:description options:NSJSONWritingPrettyPrinted error:&parseError];
            if (!parseError) {
                NSString *descStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if (descStr) {
                    [dict setValue:descStr forKey:YSFDARequestDescriptionKey];
                    YSFLogApp(@"trackHistory title:%@ type:action description:%@", title, descStr);
                }
            }
        }
    }
    //2.读出本地未上传的轨迹
    NSMutableArray *array = [[self arrayByKey:YSFTrackHistoryDataKey] mutableCopy];
    if (!array) {
        array = [NSMutableArray array];
    }
    //3.新的轨迹信息追加至旧轨迹数组，并保存
    [array addObject:dict];
    [self saveArray:array forKey:YSFTrackHistoryDataKey];
}

- (void)sendTrackHistoryData {
    NSArray *array = [self arrayByKey:YSFTrackHistoryDataKey];
    NSArray *sendArray = [self arrayByKey:YSFTrackHistoryDataSendKey];
    if (sendArray.count == 0 && array.count >= 1) {
        [self saveArray:array forKey:YSFTrackHistoryDataSendKey];
        sendArray = array;
        [[self store] removeObjectByID:YSFTrackHistoryDataKey];
    }
    if (sendArray.count == 0) {
        return;
    }
    if (self.isSendingTrackData) {
        return;
    }
    YSFLogApp(@"sendTrackHistoryData");
    
    YSFDARequest *request = [YSFDARequest new];
    request.array = sendArray;
    
    self.isSendingTrackData = YES;
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi get:request
         completion:^(NSError *error, id returendObject) {
             weakSelf.isSendingTrackData = NO;
             if (!error || ([error.domain isEqualToString:YSFErrorDomain] && error.code == YSFCodeInvalidData)) {
                 [[weakSelf store] removeObjectByID:YSFTrackHistoryDataSendKey];
                 [weakSelf sendTrackHistoryData];
             }
         }];
}

#pragma mark - 拉取历史消息
- (void)requestHistoryMessagesToken {
    YSFHistoryMsgTokenRequest *request = [[YSFHistoryMsgTokenRequest alloc] init];
    [YSFIMCustomSystemMessageApi sendMessage:request completion:^(NSError *error) {
        YSFLogApp(@"requestHistoryMessagesToken error:%@", error);
    }];
}

- (void)requestHistoryMessages:(NSString *)token shopId:(NSString *)shopId {
    YSFHistoryMessageRequest *request = [[YSFHistoryMessageRequest alloc] init];
    request.token = token;
    long long endTime = round([[NSDate date] timeIntervalSince1970] * 1000);
    //过去7天毫秒：60 * 60 * 24 * 7 * 1000 = 604800000
    long long beginTime = endTime - 604800000;
    request.beginTime = beginTime;
    request.endTime = endTime;
    request.limit = 20;
    __weak typeof(self) weakSelf = self;
    [YSFHttpApi get:request completion:^(NSError *error, id returendObject) {
        if (!error && [returendObject isKindOfClass:[NSArray class]]) {
            [weakSelf makeHistoryMessages:returendObject shopId:shopId];
        } else {
            YSFLogApp(@"requestHistoryMessages error:%@", error);
        }
    }];
}

- (void)makeHistoryMessages:(NSArray *)jsonMessages shopId:(NSString *)shopId {
    if (jsonMessages && [jsonMessages count]) {
        YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
        NSMutableArray *saveMsgs = [NSMutableArray arrayWithCapacity:[jsonMessages count]];
        //构建消息对象并去重
        for (NSDictionary *dict in jsonMessages) {
            YSF_NIMMessage *message = [YSF_NIMMessage msgWithDict:dict];
            //去重，注意部分带#消息ID
            BOOL needSave = NO;
            YSF_NIMMessage *queryMsg = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:message.messageId forSession:session];
            if (!queryMsg) {
                needSave = YES;
                NSRange range = [message.messageId rangeOfString:@"#"];
                if (range.location != NSNotFound) {
                    NSString *msgId = [message.messageId substringFromIndex:(range.location + 1)];
                    queryMsg = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:msgId forSession:session];
                    if (queryMsg) {
                        needSave = NO;
                    }
                }
            }
            if (needSave) {
                [saveMsgs addObject:message];
            }
        }
        //按照服务器时间排序
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
        NSArray *sortedMsgs = [saveMsgs sortedArrayUsingDescriptors:@[descriptor]];
        //持久化消息，同时更新界面，下载附件
        for (YSF_NIMMessage *message in sortedMsgs) {
            [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                              message:message
                                                           forSession:session
                                                       addUnreadCount:NO
                                                           completion:^(NSError *error) {
                                                               
                                                           }];
            [[[YSF_NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message error:nil];
        }
    }
}

#pragma mark - 数据持久化
- (YSFKeyValueStore *)store {
    if (!_store) {
        NSString *path = [[[QYSDK sharedSDK] pathManager] sdkGlobalPath];
        if (path) {
            NSString *storePath = [path stringByAppendingPathComponent:@"app_info.db"];
            _store = [YSFKeyValueStore storeByPath:storePath];
        }
    }
    return _store;
}

- (void)saveDict:(NSDictionary *)dict forKey:(NSString *)key {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error) {
            YSFLogErr(@"save dict %@ failed", dict);
        }
        if (data) {
            [[self store] saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:key];
        }
    }
}

- (void)saveArray:(NSArray *)array forKey:(NSString *)key {
    if ([array isKindOfClass:[NSArray class]]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:array
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
        if (error) {
            YSFLogErr(@"save dict %@ failed",array);
        }
        if (data) {
            [[self store] saveValue:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] forKey:key];
        }
    }
}

- (NSDictionary *)dictByKey:(NSString *)key {
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

#pragma mark - Audio
- (BOOL)isRecevierOrSpeaker; {
    return _appSetting.recevierOrSpeaker;
}

- (void)setRecevierOrSpeaker:(BOOL)recevierOrSpeaker {
    _appSetting.recevierOrSpeaker = recevierOrSpeaker;
    [self saveAppSetting];
}

#pragma mark - Cache Text
- (NSString *)cachedText:(NSString *)shopId {
    NSString *catchText = @"";
    if (shopId) {
        catchText = _cachedTextDict[shopId];
    }
    return catchText;
}

- (void)setCachedText:(NSString *)cachedText shopId:(NSString *)shopId {
    if (cachedText && shopId && ![_cachedTextDict[shopId] isEqualToString:cachedText]) {
        _cachedTextDict[shopId] = cachedText;
        [[self store] saveDict:_cachedTextDict forKey:YSFCachedTextKey];
    }
}

@end


