//
//  YSFSessionManager.m
//  YSFSDK
//
//  Created by amao on 8/31/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFSessionManager.h"
#import "YSFIMCustomSystemMessageApi.h"
#import "YSFCustomSystemNotificationParser.h"
#import "YSFCloseServiceNotification.h"
#import "YSFServiceRequestManager.h"
#import "QYSDK_Private.h"
#import "YSFKFBypassNotification.h"
#import "YSFMessageMaker.h"
#import "YSFPushMessageStatusChangeRequest.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFShopInfo.h"
#import "NSString+YSF.h"
#import "YSFConversationManager.h"
#import "YSFSessionStatusResponse.h"
#import "YSFQueryWaitingStatus.h"
#import "YSFEvaluationNotification.h"
#import "YSFNotification.h"
#import "YSFSessionWillCloseNotification.h"
#import "YSFSystemConfig.h"
#import "YSFTrashWords.h"
#import "NSArray+YSF.h"
#import "YSFLongMessage.h"
#import "YSFRichText.h"
#import "YSF_NIMMessage+YSF.h"
#import "YSFUploadLog.h"
#import "QYStaffInfo.h"
#import "YSFEvaluationData.h"
#import "YSFRevokeMessageResult.h"

@interface YSFSessionManager () <YSF_NIMSystemNotificationManagerDelegate, YSF_NIMChatManagerDelegate, YSFServiceRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *sessionStateType;
@property (nonatomic, strong) NSMutableDictionary *sessions; //当前会话列表
@property (nonatomic, strong) YSFServiceRequestManager *requestManager; //请求管理类

@property (nonatomic, strong) NSMutableDictionary *shopInfo;
@property (nonatomic, strong) NSMutableDictionary *evaluationRecentInfo;
@property (nonatomic, strong) NSMutableDictionary *evaluationHistoryInfo;

@property (nonatomic, strong) NSMutableDictionary *staffIconURLs;

@property (nonatomic, strong) NSMutableArray *unreadPushMessageSessionId;
@property (nonatomic, strong) NSMutableDictionary *longMessageDict;

@property (nonatomic, strong) NSMutableDictionary *lastSessionId;

@end


@implementation YSFSessionManager

- (instancetype)init {
    if (self = [super init]) {
        _requestManager = [[YSFServiceRequestManager alloc] init];
        _requestManager.delegate = self;
        
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];
        _sessionStateType = [NSMutableDictionary new];
        _sessions = [NSMutableDictionary new];
        _longMessageDict = [NSMutableDictionary new];
        _lastSessionId = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] chatManager] removeDelegate:self];
}

#pragma mark - session state
- (YSFSessionStateType)getSessionStateType:(NSString *)shopId {
    if (!shopId) {
        return YSFSessionStateTypeError;
    }
    return [self.sessionStateType[shopId] integerValue];
}

- (void)setSessionStateType:(NSString *)shopId type:(YSFSessionStateType)type {
    if (!shopId) {
        return;
    }
    self.sessionStateType[shopId] = @(type);
}

- (void)cleanSessionStateTypeByShopId:(NSString *)shopId {
    if (!shopId) {
        return;
    }
    [self.sessionStateType removeObjectForKey:shopId];
}

#pragma mark - read data
- (void)readData {
    [self readStaffIconURLs];
    [self readShopInfo];
    [self readEvaluationInfo];
    [self readUnreadPushMessageSessionId];
    [self readLastSessionId];
}

- (void)readShopInfo {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _shopInfo = [[infoManager dictByKey:YSFShopInfoKey] mutableCopy];
    if (!_shopInfo) {
        _shopInfo = [[NSMutableDictionary alloc] init];
    }
}

- (void)readEvaluationInfo {
    //清除原有的评价信息
    [self removeEvaluationInfoForKey:YSFEvaluation_2];
    NSDictionary *total = [[[QYSDK sharedSDK] infoManager] dictByKey:YSFEvaluation_3];
    _evaluationRecentInfo = [[total objectForKey:YSFEvaluationKeyRecentData] mutableCopy];
    if (!_evaluationRecentInfo) {
        _evaluationRecentInfo = [[NSMutableDictionary alloc] init];
    }
    _evaluationHistoryInfo = [[total objectForKey:YSFEvaluationKeyHistoryData] mutableCopy];
    if (!_evaluationHistoryInfo) {
        _evaluationHistoryInfo = [[NSMutableDictionary alloc] init];
    }
}

- (void)readUnreadPushMessageSessionId {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _unreadPushMessageSessionId = [[NSMutableArray alloc] init];
    NSArray *array = [infoManager arrayByKey:YSFUnreadPushMessageSessionId];
    if (array) {
        [_unreadPushMessageSessionId addObjectsFromArray:array];
    }
}

#pragma mark - last session
- (void)readLastSessionId {
    _lastSessionId = [NSMutableDictionary dictionary];
    NSDictionary *dict = [[[QYSDK sharedSDK] infoManager] dictByKey:YSFLastSessionIdKey];
    if (dict && dict.count) {
        [_lastSessionId addEntriesFromDictionary:dict];
    }
}

- (void)setLastSessionId:(long long)sessionId forShopId:(NSString *)shopId {
    if (!shopId.length) {
        return;
    }
    [self.lastSessionId setValue:@(sessionId) forKey:shopId];
    [[QYSDK sharedSDK].infoManager saveDict:self.lastSessionId forKey:YSFLastSessionIdKey];
}

- (long long)getLastSessionIdForShopId:(NSString *)shopId {
    if (!shopId.length) {
        return 0;
    }
    id obj = [self.lastSessionId objectForKey:shopId];
    if (obj) {
        return [obj longLongValue];
    }
    return 0;
}

#pragma mark - staff icon
- (void)setStaffInfo:(QYStaffInfo *)staffInfo {
    _staffInfo = staffInfo;
    if (staffInfo) {
        [[YSF_NIMSDK sharedSDK].chatManager setUniqueMessageFrom:staffInfo.staffId];
    } else {
        [[YSF_NIMSDK sharedSDK].chatManager setUniqueMessageFrom:nil];
    }
}

- (void)updateStaffInfoForOnlineSession:(NSString *)shopId {
    if (![self shouldRequestService:YES shopId:shopId]) {
        YSFServiceSession *session = [self getOnlineSession:shopId];
        if (session && session.humanOrMachine) {
            if (self.staffInfo && self.staffInfo.staffId) {
                [self addStaffIconURL:self.staffInfo.iconURL forStaffId:self.staffInfo.staffId];
                [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:self.staffInfo.staffId];
            } else {
                [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:session.staffId];
            }
        }
    }
}

- (void)readStaffIconURLs {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _staffIconURLs = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [infoManager dictByKey:YSFStaffIdIconUrl];
    if (dict) {
        [_staffIconURLs addEntriesFromDictionary:dict];
    }
}

- (NSString *)getIconURLFromStaffId:(NSString *)staffId {
    if ([staffId isEqualToString:@"-1"]) {
        staffId = [[_staffIconURLs allKeys] lastObject];
        if (!staffId) {
            staffId = @"-1";
        }
    }
    return [_staffIconURLs objectForKey:staffId];
}

- (void)addStaffIconURL:(NSString *)iconURL forStaffId:(NSString *)staffId {
    if (staffId.length && iconURL) {
        iconURL = [iconURL ysf_https];
        [_staffIconURLs setValue:iconURL forKey:staffId];
        [[QYSDK sharedSDK].infoManager saveDict:_staffIconURLs forKey:YSFStaffIdIconUrl];
    }
}

- (NSString *)getOnlineStaffId:(NSString *)shopId {
    if (shopId.length) {
        return [[YSF_NIMSDK sharedSDK].chatManager getReceiveMessageFrom:shopId];
    }
    return nil;
}

#pragma mark - 请求客服
- (void)requestServiceWithSource:(YSFRequestServiceRequest *)request shopId:(NSString *)shopId {
    if ([_requestManager isInRequest:shopId]) {
        YSFLogWar(@"@%: in request service process", shopId);
        return;
    }
    
    [_requestManager updateRequestState:shopId inRequest:YES];

    if (_delegate && [_delegate respondsToSelector:@selector(didBeginSendReqeustWithShopId:)]) {
        [_delegate didBeginSendReqeustWithShopId:shopId];
    }
    //这里在请求接口上做个小hack,发生错误如果请求时间过短就尝试延长,使得界面能够有表现
    static const int64_t minProcessDuration = 2;
    NSDate *startDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:shopId completion:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSDate *endDate = [NSDate date];
        NSTimeInterval duration = fabs([endDate timeIntervalSinceDate:startDate]);
        if (error && duration < (double)minProcessDuration) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(minProcessDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [strongSelf onSendRequest:shopId error:error];
            });
        } else {
            [strongSelf onSendRequest:shopId error:error];
        }
        //日志上传节点：请求客服失败
        if (error) {
            [strongSelf uploadLog];
        }
    }];
}

- (void)uploadLog {
    YSFUploadLog *uploadLog = [[YSFUploadLog alloc] init];
    uploadLog.version = [[QYSDK sharedSDK].infoManager version];
    uploadLog.type = YSFUploadLogTypeRequestStaffFail;
    uploadLog.logString = YSF_GetMessage(50000);
    [YSFHttpApi post:uploadLog
          completion:^(NSError *error, id returendObject) {
              
          }];
}

- (void)onSendRequest:(NSString*)shopId error:(NSError *)error {
    //收到云信回包后发现还没收到云商服回包就开启timer进行等待
    if ([self serviceOutOfDate:shopId]) {
        [[self requestManager] startWaitResponseTimer:shopId];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(didSendSessionRequest:shopId:)]) {
        if (error) {
            [_requestManager stopWaitResponseTimer:shopId];
            [_requestManager updateRequestState:shopId inRequest:NO];
        }
        [_delegate didSendSessionRequest:error shopId:shopId];
    }
}

- (BOOL)serviceOutOfDate:(NSString *)shopId {
    BOOL result = YES;
    if ([self getOnlineSession:shopId]) {
        result = NO;
    }
    if (result) {
        YSFLogApp(@"@%: out of date", shopId);
    }
    return result;
}

- (BOOL)shouldRequestService:(BOOL)isInit shopId:(NSString *)shopId {
    //sessionExist表示当前会话是否存在
    BOOL sessionExist = [self getOnlineSession:shopId] ? YES : NO;
    //waitingOrNotExist表示当前会话因客服需排队或不在线而未申请到
    YSFSessionStateType type = [self getSessionStateType:shopId];
    BOOL waitingOrNotExist = (!sessionExist
                              && (type == YSFSessionStateTypeWaiting
                                  || type == YSFSessionStateTypeNotExist
                                  || type == YSFSessionStateNotExistAndLeaveMessageClosed));
    
    if (waitingOrNotExist) {
        //若当前会话因客服需排队或不在线而未申请到，即waitingOrNotExist=YES，则若初始进入会话界面需请求客服，否则一律不请求客服
        return isInit;
    } else {
        //若非上述需排队或不在线状况，则仅判断会话是否存在，若不存在则需请求客服，否则不请求
        return !sessionExist;
    }
    YSFLogApp(@"@%: shouldRequestService isInit=%d  waitingOrNotExist=%d", shopId, isInit, waitingOrNotExist);
}

#pragma mark - 客服更新
- (void)onGetNewServiceSession:(YSFServiceSession *)session shopId:(NSString *)shopId {
    if (session.shopInfo) {
        [self addShopInfo:session.shopInfo];
    }
    [_requestManager stopWaitResponseTimer:shopId];
    [_requestManager updateRequestState:shopId inRequest:NO];
    
    NSInteger code = session.code;
    NSError *error = (code == YSFCodeSuccess) ? nil : [NSError errorWithDomain:YSFErrorDomain code:code userInfo:nil];
    
    if (code == YSFCodeSuccess) {
        [self setSessionStateType:shopId type:YSFSessionStateTypeOnline];
        [self addSession:session shopId:shopId];
        [self sendInvisibleStaffInfoWithShopId:shopId];
    } else {
        [self removeSessionByShopId:shopId];
        if (code == YSFCodeServiceWaiting) {
            YSF_NIMSession *nimSession = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
            YSF_NIMRecentSession *recentSession = [[[YSF_NIMSDK sharedSDK] conversationManager] queryRecentSession:nimSession];
            if (!recentSession) {
                recentSession = [YSF_NIMRecentSession new];
                YSF_NIMMessage *message = [YSFMessageMaker msgWithText:@""];
                message.session = nimSession;
                recentSession.lastMessage = message;
                recentSession.session = message.session;
                [[[YSF_NIMSDK sharedSDK] conversationManager] addRecentSession:recentSession];
            }
            [self addSession:session shopId:shopId];
            [self setSessionStateType:shopId type:YSFSessionStateTypeWaiting];
        } else if (code == YSFCodeServiceNotExist) {
            [self setSessionStateType:shopId type:YSFSessionStateTypeNotExist];
        } else if (code == YSFCodeServiceNotExistAndLeaveMessageClosed) {
            [self setSessionStateType:shopId type:YSFSessionStateNotExistAndLeaveMessageClosed];
        } else {
            [self setSessionStateType:shopId type:YSFSessionStateTypeError];
        }
    }

    //发起回调
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:bypass:shopId:)]) {
        [_delegate didReceiveSessionError:error session:session bypass:NO shopId:shopId];
    }
    
    if (code == YSFCodeSuccess) {
        [self updateEvaluationDataWithSession:session shopId:shopId];
    }
}

- (void)onUpdateSessionByMessage:(YSF_NIMMessage *)message {
    //每收到一条客服的消息就更新一把服务时间
//    _sessions.lastServiceTime =  [NSDate dateWithTimeIntervalSince1970:message.timestamp];
}

- (void)sendInvisibleStaffInfoWithShopId:(NSString *)shopId {
    if (self.staffInfo && self.staffInfo.infoDesc.length) {
        YSFServiceSession *onlineSession = [self getOnlineSession:shopId];
        if (onlineSession.humanOrMachine) {
            YSF_NIMMessage *message = [YSFMessageMaker msgWithText:self.staffInfo.infoDesc];
            YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
            [[[YSF_NIMSDK sharedSDK] chatManager] sendMessage:message toSession:session visible:NO error:nil];
        }
    }
}

#pragma mark - clear
- (void)clear {
    [_sessionStateType removeAllObjects];
    [_sessions removeAllObjects];
}

- (void)clearByShopId:(NSString *)shopId {
    if (!shopId) {
        return;
    }
    [self cleanSessionStateTypeByShopId:shopId];
    [self removeSessionByShopId:shopId];
}

#pragma mark - YSFServiceRequestDelegate
- (void)onServiceRequestTimeout:(NSString *)shopId {
    [self setSessionStateType:shopId type:YSFSessionStateTypeError];
    [_requestManager updateRequestState:shopId inRequest:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:bypass:shopId:)]) {
        NSError *error = [NSError errorWithDomain:YSFErrorDomain
                                             code:YSFCodeServerTimeout
                                         userInfo:nil];
        [_delegate didReceiveSessionError:error session:nil bypass:NO shopId:shopId];
    }
}

#pragma mark - YSF_NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification {
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@", content);
    //平台电商时sender就等于shopId，目前服务器这样处理
    NSString *shopId = notification.sender;
    if (!shopId) {
        shopId = @"-1";
    }
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    
    //解析content
    id object =  [YSFCustomSystemNotificationParser parse:content shopId:shopId];
    
    if ([object isKindOfClass:[YSFServiceSession class]]) {
        [self onGetNewServiceSession:object shopId:shopId];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    } else if ([object isKindOfClass:[YSFCloseServiceNotification class]]) {
        [YSFSystemConfig sharedInstance:shopId].switchOpen = YES;
        [self onCloseSession:(YSFCloseServiceNotification *)object shopId:shopId];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    } else if ([object isKindOfClass:[YSFKFBypassNotification class]]) {
        [self onGetKFBypassNotification:object shopId:shopId];
    } else if ([object isKindOfClass:[YSFSessionStatusResponse class]]) {
        [((YSFSessionStatusResponse *)object).shopSessionStatus enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj integerValue] == YSFCodeSuccess) {
                [self setSessionStateType:key type:YSFSessionStateTypeOnline];
            } else if ([obj integerValue] == YSFCodeServiceWaiting) {
                [self setSessionStateType:key type:YSFSessionStateTypeWaiting];
            } else if ([obj integerValue] == YSFCodeServiceNotExist) {
                [self setSessionStateType:key type:YSFSessionStateTypeNotExist];
            } else if ([obj integerValue] == YSFCodeServiceNotExistAndLeaveMessageClosed) {
                [self setSessionStateType:key type:YSFSessionStateNotExistAndLeaveMessageClosed];
            }
        }];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    } else if ([object isKindOfClass:[YSFQueryWaitingStatusResponse class]]) {
        if ([self getSessionStateType:shopId] == YSFSessionStateTypeOnline) {
            return;
        }
        YSFQueryWaitingStatusResponse *wait_status = object;
        if ([[[QYSDK sharedSDK] sessionManager] getSessionStateType:shopId] == YSFSessionStateTypeWaiting
            && (wait_status.code == YSFCodeServiceWaitingToNotExsit
                || wait_status.code == YSFCodeServiceWaitingToNotExsitAndLeaveMessageClosed)) {
            YSFServiceSession *session = [YSFServiceSession new];
            NSError *error = nil;
            session.message = wait_status.message;
            if (wait_status.code == YSFCodeServiceWaitingToNotExsit) {
                [self setSessionStateType:shopId type:YSFSessionStateTypeNotExist];
                session.code = YSFCodeServiceNotExist;
                error = [NSError errorWithDomain:YSFErrorDomain code:YSFCodeServiceNotExist userInfo:nil];
            } else if (wait_status.code == YSFCodeServiceWaitingToNotExsitAndLeaveMessageClosed) {
                [self setSessionStateType:shopId type:YSFSessionStateNotExistAndLeaveMessageClosed];
                session.code = YSFCodeServiceNotExistAndLeaveMessageClosed;
                error = [NSError errorWithDomain:YSFErrorDomain code:YSFCodeServiceNotExist userInfo:nil];
            }

            if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:bypass:shopId:)]) {
                [_delegate didReceiveSessionError:error session:session bypass:NO shopId:shopId];
            }
            
            [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
        }
    } else if ([object isKindOfClass:[YSFEvaluationNotification class]]) {
        YSFEvaluationNotification *notification = (YSFEvaluationNotification *)object;
        [self addInviteEvaluationMessageWithSessionId:notification.sessionId
                                               shopId:shopId
                                            autoPopup:notification.autoPopup
                                         closeSession:NO];
    } else if ([object isKindOfClass:[YSFSessionWillCloseNotification class]]) {
        YSFNotification *notification = [[YSFNotification alloc] init];
        notification.command = YSFCommandNotification;
        notification.localCommand = YSFCommandSessionWillClose;
        notification.message = ((YSFCloseServiceNotification *)object).message;
        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
        YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
    } else if ([object isKindOfClass:[YSFTrashWords class]]) {
        YSFTrashWords *transWords = (YSFTrashWords *)object;
        if (transWords.msgIdClient && transWords.trashWords) {
            YSF_QYKFMessage * message = (YSF_QYKFMessage *)[[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:transWords.msgIdClient
                                                                                                           forSession:session];
            NSMutableDictionary *extMutDic = [[NSMutableDictionary alloc] init];
            [extMutDic setValue:[transWords.trashWords ysf_toUTF8String] forKey:YSFApiKeyTrashWords];
            [extMutDic setValue:@(transWords.auditResultType) forKey:YSFApiKeyAuditResult];
            message.ext = [extMutDic ysf_toUTF8String];
            [[[YSF_NIMSDK sharedSDK] conversationManager] updateMessage:YES message:message forSession:session completion:nil];
        } else {
            assert(false);
        }
    } else if ([object isKindOfClass:[YSFLongMessage class]]) {
        YSFLongMessage *longMessage = (YSFLongMessage *)object;
        NSMutableArray *array = _longMessageDict[longMessage.splitId];
        if (!array) {
            array = [[NSMutableArray alloc] initWithCapacity:longMessage.splitCount];
            for (int i = 0; i < longMessage.splitCount; i++) {
                [array addObject:[NSNull null]];
            }
            _longMessageDict[longMessage.splitId] = array;
        }
        array[longMessage.splitIndex] = longMessage;
        BOOL isCompleted = YES;
        for (NSNull *message in array) {
            if (message == [NSNull null]) {
                isCompleted = NO;
                break;
            }
        }
        if (isCompleted) {
            NSString *content = @"";
            for (YSFLongMessage *message in array) {
                content = [content stringByAppendingString:message.splitContent];
            }
            NSData *data = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSString *messageContent = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            if (longMessage.msgType == YSFLongMessageTypeCustomMessage) {
                YSF_NIMCustomObject *customObject = [[YSF_NIMCustomObject alloc] init];
                [customObject decodeWithContent:messageContent];
                YSF_NIMMessage *customMessage = [[YSF_NIMMessage alloc] init];
                customMessage.messageObject = customObject;
                customMessage.messageId = longMessage.msgId;
                customMessage.messageType = YSF_NIMMessageTypeCustom;
                customMessage.rawAttachContent = messageContent;
                [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage
                                                               forSession:session addUnreadCount:NO completion:nil];
            } else if (longMessage.msgType == YSFLongMessageTypeSystemNotification) {
                YSF_NIMCustomSystemNotification *notification = [YSF_NIMCustomSystemNotification new];
                notification.content = messageContent;
                notification.sender = notification.sender;
                [[[YSF_NIMSDK sharedSDK] systemNotificationManager] onReceiveCustomSystemNotification:notification];
            }
        }
    } else if ([object isKindOfClass:[YSFRevokeMessageResult class]]) {
        YSFRevokeMessageResult *result = (YSFRevokeMessageResult *)object;
        if (result.resultCode == YSFCodeSuccess) {
            YSFServiceSession *onlineSession = [self getOnlineSession:shopId];
            if (onlineSession.sessionId == result.sessionId) {
                if (result.messageId.length) {
                    YSF_NIMMessage *message = [[[YSF_NIMSDK sharedSDK] conversationManager] queryMessage:result.messageId
                                                                                              forSession:session];
                    if (message) {
                        if (!message.session) {
                            message.session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
                        }
                        [[[YSF_NIMSDK sharedSDK] conversationManager] deleteMessage:message];
                        if (self.delegate && [self.delegate respondsToSelector:@selector(didRevokeMessage:)]) {
                            [self.delegate didRevokeMessage:message];
                        }
                        
                        YSFNotification *notification = [[YSFNotification alloc] init];
                        notification.command = YSFCommandNotification;
                        notification.localCommand = YSFCommandRevokeMessageResult;
                        NSString *tip = [NSString stringWithFormat:@"\"%@\" ", onlineSession.staffName];
                        if (result.message.length) {
                            tip = [tip stringByAppendingString:result.message];
                        } else {
                            tip = [tip stringByAppendingString:@"撤回了一条消息"];
                        }
                        notification.message = tip;
                        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
                        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                                          message:customMessage
                                                                       forSession:session
                                                                   addUnreadCount:NO
                                                                       completion:nil];
                    }
                }
            }
        }
    }
}

- (void)onCloseSession:(YSFCloseServiceNotification *)object shopId:(NSString *)shopId {
    if (object.evaluate) {
        [self addInviteEvaluationMessageWithSessionId:object.sessionId shopId:shopId autoPopup:object.autoPopup closeSession:YES];
    } else {
        BOOL needSave = NO;
        NSMutableDictionary *sessionDict = [[self getHistoryEvaluationPersistDataByShopId:shopId sessionId:object.sessionId] mutableCopy];
        if (!sessionDict) {
            sessionDict = [[NSMutableDictionary alloc] init];
        }
        //若为关闭会话场景，需要计算出当前时间+时效=可评价的最大时间并存储，方便后续修改评价时做判断
        BOOL modifyEnable = [sessionDict ysf_jsonBool:YSFEvaluationKeyModifyEnable];
        if (modifyEnable) {
            NSInteger minutes = [sessionDict ysf_jsonInteger:YSFEvaluationKeyModifyTime];
            if (minutes >= 1 && minutes <= 480) {
                long long timestamp_limit = round(([[NSDate date] timeIntervalSince1970] + minutes * 60) * 1000);
                [sessionDict setValue:@(timestamp_limit) forKey:YSFEvaluationKeyModifyLimit];
                needSave = YES;
            }
        }
        if (needSave && sessionDict) {
            [self setHistoryEvaluationData:sessionDict shopId:shopId sessionId:object.sessionId];
        }
    }
    
    if (object.closeReason == 2 && object.message.length > 0) {
        YSFNotification *notification = [[YSFNotification alloc] init];
        notification.command = YSFCommandNotification;
        notification.localCommand = YSFCommandSessionWillClose;
        notification.message = object.message;
        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
        YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
    }
    
    [_delegate didClose:object.evaluate session:[self getOnlineSession:shopId] shopId:shopId];
    [self clearByShopId:shopId];
}

- (void)onGetKFBypassNotification:(YSFKFBypassNotification *)object shopId:(NSString *)shopId {
    YSFKFBypassNotification *notification = (YSFKFBypassNotification *)object;
    if (notification.shopInfo) {
        [self addShopInfo:object.shopInfo];
    }
    
    [_requestManager stopWaitResponseTimer:shopId];
    [_requestManager updateRequestState:shopId inRequest:NO];
    //发起回调
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:bypass:shopId:)]) {
        [_delegate didReceiveSessionError:nil session:nil bypass:YES shopId:shopId];
    }
    
    notification.disable = NO;
    [self addStaffIconURL:notification.iconUrl forStaffId:@"YSFKFBypassNotification"];
    
    YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    [customMessage performSelector:@selector(setFrom:) withObject:@"YSFKFBypassNotification"];
    [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:YES completion:nil];
    
    [self clearByShopId:shopId];
}

#pragma mark - YSF_NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray *)messages {
    for (YSF_NIMMessage *message in messages) {
        if (message.isPushMessageType) {
            QYPushMessageBlock pushMessageBlock = [QYSDK sharedSDK].pushMessageBlock;
            if (pushMessageBlock) {
                QYPushMessage *pushMessage = [QYPushMessage new];
                pushMessage.headImageUrl = message.staffHeadImageUrl;
                pushMessage.actionText = message.actionText;
                pushMessage.actionUrl = message.actionUrl;
                if (message.messageType == YSF_NIMMessageTypeText) {
                    pushMessage.text = message.text;
                    pushMessage.type = QYPushMessageTypeText;
                } else if (message.messageType == YSF_NIMMessageTypeImage) {
                    YSF_NIMImageObject *object = message.messageObject;
                    pushMessage.imageUrl = object.url;
                    pushMessage.type = QYPushMessageTypeImage;
                } else if (message.messageType == YSF_NIMMessageTypeCustom) {
                    YSF_NIMCustomObject *customObject = message.messageObject;
                    if ([customObject.attachment isKindOfClass:[YSFRichText class]]) {
                        YSFRichText *richText = (YSFRichText *)customObject.attachment;
                        pushMessage.richText = richText.content;
                        pushMessage.type = QYPushMessageTypeRichText;
                    }
                }
                pushMessage.time = message.timestamp;
                if (pushMessage) {
                    pushMessageBlock(pushMessage);
                }
            }
            
            YSFPushMessageStatusChangeRequest *request = [[YSFPushMessageStatusChangeRequest alloc] init];
            request.msgSessionId = [message extSessionId];
            request.status = 1;
            [YSFIMCustomSystemMessageApi sendMessage:request shopId:@"-1" completion:^(NSError *error) {
            }];
            
            [self addUnreadPushMessageSessionId:request.msgSessionId];
        };
    }
    YSF_NIMMessage *message = [messages lastObject];
    [self onUpdateSessionByMessage:message];
}

#pragma mark - service session
- (YSFServiceSession *)getOnlineSession:(NSString *)shopId {
    if (!shopId) {
        return nil;
    }
    YSFServiceSession *session = _sessions[shopId];
    if (session && session.code == YSFCodeSuccess) {
        return session;
    } else {
        return nil;
    }
}

- (YSFServiceSession *)getOnlineOrWaitingSession:(NSString *)shopId {
    if (!shopId) {
        return nil;
    }
    YSFServiceSession *session = _sessions[shopId];
    return session;
}

- (void)addSession:(YSFServiceSession *)session shopId:(NSString *)shopId {
    if (!session || !shopId) {
        return;
    }
    _sessions[shopId] = session;

    if (session) {
        if (session.staffId.length > 0) {
            if (session.humanOrMachine) {
                if (self.staffInfo && self.staffInfo.staffId.length && self.staffInfo.iconURL.length) {
                    [self addStaffIconURL:session.iconUrl forStaffId:session.staffId];
                    [self addStaffIconURL:self.staffInfo.iconURL forStaffId:self.staffInfo.staffId];
                    [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:self.staffInfo.staffId];
                } else {
                    [self addStaffIconURL:session.iconUrl forStaffId:session.staffId];
                    [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:session.staffId];
                }
            } else {
                [self addStaffIconURL:session.iconUrl forStaffId:session.staffId];
                [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:session.staffId];
            }
        }
    } else {
        [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:nil];
    }
}

- (void)removeSessionByShopId:(NSString *)shopId {
    if(!shopId) {
        return;
    }
    if (_sessions) {
        [_sessions removeObjectForKey:shopId];
    }
}

#pragma mark - 评价相关
- (NSDictionary *)getRecentEvaluationMemoryDataByShopId:(NSString *)shopId {
    if (shopId.length) {
        return [_evaluationRecentInfo objectForKey:shopId];
    }
    return nil;
}

- (NSDictionary *)getHistoryEvaluationMemoryDataByShopId:(NSString *)shopId sessionId:(long long)sessionId {
    if (shopId.length && sessionId) {
        NSDictionary *shopDict = [_evaluationHistoryInfo objectForKey:shopId];
        if (shopDict && shopDict.count) {
            return [shopDict objectForKey:[NSString stringWithFormat:@"%lld", sessionId]];
        }
    }
    return nil;
}

- (NSDictionary *)getRecentEvaluationPersistDataByShopId:(NSString *)shopId {
    if (shopId.length) {
        NSDictionary *totalDict = [[[QYSDK sharedSDK] infoManager] dictByKey:YSFEvaluation_3];
        if (totalDict && totalDict.count) {
            NSDictionary *recentDict = [totalDict objectForKey:YSFEvaluationKeyRecentData];
            if (recentDict && recentDict.count) {
                return [recentDict objectForKey:shopId];
            }
        }
    }
    return nil;
}

- (NSDictionary *)getHistoryEvaluationPersistDataByShopId:(NSString *)shopId sessionId:(long long)sessionId {
    if (shopId.length && sessionId) {
        NSDictionary *totalDict = [[[QYSDK sharedSDK] infoManager] dictByKey:YSFEvaluation_3];
        if (totalDict && totalDict.count) {
            NSDictionary *historyDict = [totalDict objectForKey:YSFEvaluationKeyHistoryData];
            if (historyDict && historyDict.count) {
                NSDictionary *shopDict = [historyDict objectForKey:shopId];
                return [shopDict objectForKey:[NSString stringWithFormat:@"%lld", sessionId]];
            }
        }
    }
    return nil;
}

- (void)setRecentEvaluationData:(NSDictionary *)data shopId:(NSString *)shopId {
    if (shopId.length && data) {
        [_evaluationRecentInfo setValue:data forKey:shopId];
        NSDictionary *dict = @{YSFEvaluationKeyRecentData : _evaluationRecentInfo,
                               YSFEvaluationKeyHistoryData : _evaluationHistoryInfo,
                               };
        [[[QYSDK sharedSDK] infoManager] saveDict:dict forKey:YSFEvaluation_3];
    }
}

- (void)setHistoryEvaluationData:(NSDictionary *)data shopId:(NSString *)shopId sessionId:(long long)sessionId {
    if (shopId.length && sessionId && data) {
        NSMutableDictionary *shopDict = [[_evaluationHistoryInfo objectForKey:shopId] mutableCopy];
        if (shopDict && shopDict.count) {
            [shopDict setValue:data forKey:[NSString stringWithFormat:@"%lld", sessionId]];
            [_evaluationHistoryInfo setValue:shopDict forKey:shopId];
        } else {
            NSDictionary *newShopDict = @{[NSString stringWithFormat:@"%lld", sessionId] : data};
            [_evaluationHistoryInfo setValue:newShopDict forKey:shopId];
        }
        NSDictionary *dict = @{YSFEvaluationKeyRecentData : _evaluationRecentInfo,
                               YSFEvaluationKeyHistoryData : _evaluationHistoryInfo,
                               };
        [[[QYSDK sharedSDK] infoManager] saveDict:dict forKey:YSFEvaluation_3];
    }
}

- (void)removeEvaluationInfoForKey:(NSString *)key {
    NSMutableDictionary *info = [[[[QYSDK sharedSDK] infoManager] dictByKey:key] mutableCopy];
    if (info && info.count) {
        [info removeAllObjects];
        [[[QYSDK sharedSDK] infoManager] saveDict:info forKey:key];
    }
}

- (void)updateEvaluationDataWithSession:(YSFServiceSession *)session shopId:(NSString *)shopId {
    if (!session.humanOrMachine) {
        return;
    }
    //remove old data
    [self removeEvaluationInfoForKey:YSFEvaluation_2];
    //update recent data
    NSMutableDictionary *recentDict = [[self getRecentEvaluationPersistDataByShopId:shopId] mutableCopy];
    if (!recentDict) {
        recentDict = [[NSMutableDictionary alloc] init];
    }
    [recentDict setValue:[NSNumber numberWithLongLong:session.sessionId] forKey:YSFEvaluationKeySessionId];
    if (session.humanOrMachine) {
        [recentDict setValue:@(2) forKey:YSFEvaluationKeySessionStatus];
    } else {
        [recentDict setValue:@(1) forKey:YSFEvaluationKeySessionStatus];
    }
    [recentDict setValue:@(0) forKey:YSFEvaluationKeySessionTimes];
    [self setRecentEvaluationData:recentDict shopId:shopId];
    //update session data
    NSMutableDictionary *sessionDict = [[self getHistoryEvaluationPersistDataByShopId:shopId sessionId:session.sessionId] mutableCopy];
    if (!sessionDict) {
        sessionDict = [[NSMutableDictionary alloc] init];
    }
    if (session.evaluationString) {
        [sessionDict setValue:session.evaluationString forKey:YSFEvaluationKeyData];
    }
    [sessionDict setValue:@(session.shopInfo.setting.multEvaluationEnable) forKey:YSFEvaluationKeyModifyEnable];
    [sessionDict setValue:@(session.shopInfo.setting.evaluationTimeLimit) forKey:YSFEvaluationKeyModifyTime];
    [self setHistoryEvaluationData:sessionDict shopId:shopId sessionId:session.sessionId];
}

- (void)addInviteEvaluationMessageWithSessionId:(long long)sessionId shopId:(NSString *)shopId autoPopup:(BOOL)autoPopup closeSession:(BOOL)isClose {
    [self removeEvaluationInfoForKey:YSFEvaluation_2];
    
    YSFInviteEvaluationObject *inviteEvaluation = [[YSFInviteEvaluationObject alloc] init];
    inviteEvaluation.command = YSFCommandInviteEvaluation;
    inviteEvaluation.sessionId = sessionId;
    NSDictionary *dict = [self getHistoryEvaluationMemoryDataByShopId:shopId sessionId:sessionId];
    if (dict && dict.count) {
        NSString *jsonString = [dict ysf_jsonString:YSFEvaluationKeyData];
        if (jsonString.length) {
            YSFEvaluationData *evaluationData = [YSFEvaluationData dataByDict:[jsonString ysf_toDict]];
            inviteEvaluation.inviteText = evaluationData.inviteText;
            inviteEvaluation.thanksText = evaluationData.thanksText;
        }
    }
    YSF_NIMMessage *message = [YSFMessageMaker msgWithCustom:inviteEvaluation];
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES
                                                      message:message
                                                   forSession:session
                                               addUnreadCount:YES
                                                   completion:nil];
    BOOL needSave = NO;
    NSMutableDictionary *sessionDict = [[self getHistoryEvaluationPersistDataByShopId:shopId sessionId:sessionId] mutableCopy];
    if (!sessionDict) {
        sessionDict = [[NSMutableDictionary alloc] init];
    }
    if (message.messageId) {
        [sessionDict setValue:message.messageId forKey:YSFEvaluationKeyMessageID];
        needSave = YES;
    }
    //若为关闭会话场景，需要计算出当前时间+时效=可评价的最大时间并存储，方便后续修改评价时做判断
    if (isClose) {
        BOOL modifyEnable = [sessionDict ysf_jsonBool:YSFEvaluationKeyModifyEnable];
        if (modifyEnable) {
            NSInteger minutes = [sessionDict ysf_jsonInteger:YSFEvaluationKeyModifyTime];
            if (minutes >= 1 && minutes <= 480) {
                long long timestamp_limit = round(([[NSDate date] timeIntervalSince1970] + minutes * 60) * 1000);
                [sessionDict setValue:@(timestamp_limit) forKey:YSFEvaluationKeyModifyLimit];
                needSave = YES;
            }
        }
    }
    if (needSave && sessionDict) {
        [self setHistoryEvaluationData:sessionDict shopId:shopId sessionId:sessionId];
    }
    
    needSave = NO;
    NSMutableDictionary *recentDict = [[self getRecentEvaluationPersistDataByShopId:shopId] mutableCopy];
    if (!recentDict) {
        recentDict = [[NSMutableDictionary alloc] init];
    }
    BOOL popup = NO;
    id popupObj = [sessionDict objectForKey:YSFEvaluationKeyAutoPopup];
    if (popupObj) {
        popupObj = (NSNumber *)popupObj;
        popup = [popupObj boolValue];
    }
    if (!popup) {
        [recentDict setValue:@(autoPopup) forKey:YSFEvaluationKeyAutoPopup];
        [recentDict setValue:@(sessionId) forKey:YSFEvaluationKeyAutoPopupSessionId];
        if (message.messageId) {
            [recentDict setValue:message.messageId forKey:YSFEvaluationKeyAutoPopupMessageID];
        }
        needSave = YES;
    }
    if (recentDict && needSave) {
        [self setRecentEvaluationData:recentDict shopId:shopId];
    }
}

#pragma mark - shop info
- (NSDictionary *)getShopInfo {
    return _shopInfo;
}

- (void)addShopInfo:(YSFShopInfo *)shop {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    [_shopInfo setValue:[shop toDict] forKey:shop.shopId];
    [infoManager saveDict:_shopInfo forKey:YSFShopInfoKey];
}

- (void)removeShopInfo:(NSString *)shopId; {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    [_shopInfo removeObjectForKey:shopId];
    [infoManager saveDict:_shopInfo forKey:YSFShopInfoKey];
}

#pragma mark - push message
- (void)reportPushMessageReadedStatus {
    for (NSNumber *sessionId in _unreadPushMessageSessionId) {
        long long llSessionId = [sessionId longLongValue];
        YSFPushMessageStatusChangeRequest *request = [[YSFPushMessageStatusChangeRequest alloc] init];
        request.msgSessionId = llSessionId;
        request.status = 2;
        __weak typeof(self) weakSelf = self;
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:@"-1" completion:^(NSError *error) {
            if (!error) {
                [weakSelf.unreadPushMessageSessionId removeAllObjects];
                YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
                [infoManager saveArray:weakSelf.unreadPushMessageSessionId forKey:YSFUnreadPushMessageSessionId];
            }
        }];
    }
}

- (long long)getLastUnreadPushMessageSessionId {
    return [[_unreadPushMessageSessionId lastObject] longLongValue];
}

- (void)addUnreadPushMessageSessionId:(long long)msgSessionId {
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    if (msgSessionId) {
        [_unreadPushMessageSessionId addObject:@(msgSessionId)];
        [infoManager saveArray:_unreadPushMessageSessionId forKey:YSFUnreadPushMessageSessionId];
    }
}
@end
