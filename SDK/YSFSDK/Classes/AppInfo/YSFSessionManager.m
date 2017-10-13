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

@interface YSFSessionManager ()
<YSF_NIMSystemNotificationManagerDelegate,
YSF_NIMChatManagerDelegate,
YSFServiceRequestDelegate>

@property (nonatomic, strong)   NSMutableDictionary *sessionStateType;
@property (nonatomic,strong)    NSMutableDictionary *sessions;          //当前会话列表
@property (nonatomic,strong)    YSFServiceRequestManager    *requestManager;    //请求管理类
@property (nonatomic,strong)    NSMutableDictionary *staffIdIconUrl;
@property (nonatomic,strong)    NSMutableDictionary *shopInfo;
@property (nonatomic,strong)    NSMutableDictionary *evaluationInfo;
@property (nonatomic,strong)    NSMutableArray *unreadPushMessageSessionId;

@end


@implementation YSFSessionManager

- (instancetype)init
{
    if (self = [super init])
    {
        _requestManager = [[YSFServiceRequestManager alloc] init];
        _requestManager.delegate = self;
        
        [[[YSF_NIMSDK sharedSDK] systemNotificationManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];
        _sessionStateType = [NSMutableDictionary new];
        _sessions = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] systemNotificationManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] chatManager] removeDelegate:self];
}

- (YSFSessionStateType)getSessionStateType:(NSString *)shopId
{
    if (!shopId) return YSFSessionStateTypeError;
    return [self.sessionStateType[shopId] integerValue];
}

- (void)setSessionStateType:(NSString *)shopId type:(YSFSessionStateType)type
{
    if (!shopId) return ;
    self.sessionStateType[shopId] = @(type);
}

- (void)cleanSessionStateTypeByShopId:(NSString *)shopId
{
    if (!shopId) return;
    [self.sessionStateType removeObjectForKey:shopId];
}

- (void)readData
{
    [self readStaffIdIconUrl];
    [self readShopInfo];
    [self readEvaluationInfo];
    [self readUnreadPushMessageSessionId];
}

- (void)readStaffIdIconUrl
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _staffIdIconUrl = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [infoManager dictByKey:YSFStaffIdIconUrl];
    if (dict) {
        [_staffIdIconUrl addEntriesFromDictionary:dict];
    }    
}

- (void)readShopInfo
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _shopInfo = [[infoManager dictByKey:YSFShopInfoKey] mutableCopy];
    if (!_shopInfo) {
        _shopInfo = [[NSMutableDictionary alloc] init];
    }
}

- (void)readEvaluationInfo
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _evaluationInfo = [[infoManager dictByKey:YSFEvalution] mutableCopy];
    if (!_evaluationInfo) {
        _evaluationInfo = [[NSMutableDictionary alloc] init];
    }
}

- (void)readUnreadPushMessageSessionId
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    _unreadPushMessageSessionId = [[NSMutableArray alloc] init];
    NSArray *array = [infoManager arrayByKey:YSFUnreadPushMessageSessionId];
    if (array) {
        [_unreadPushMessageSessionId addObjectsFromArray:array];
    }
}

- (NSString *)queryIconUrlFromStaffId:(NSString *)staffId
{
    if ([staffId isEqualToString:@"-1"]) {
        staffId = [[_staffIdIconUrl allKeys] lastObject];
        if (!staffId) {
            staffId = @"-1";
        }
    }
    return [_staffIdIconUrl objectForKey:staffId];
}

- (BOOL)serviceOutOfDate:(NSString *)shopId
{
    BOOL result = YES;
    if ([self getSession:shopId])
    {
        result = NO;
    }
    if (result)
    {
        YSFLogApp(@"@%: out of date", shopId);
    }
    return result;
}

- (BOOL)shouldRequestService:(BOOL)isInit shopId:(NSString *)shopId;
{
    BOOL waitingOrNotExist = false;
    if (![self getSession:shopId] && ([self getSessionStateType:shopId] == YSFSessionStateTypeWaiting
                               || [self getSessionStateType:shopId] == YSFSessionStateTypeNotExist
                               || [self getSessionStateType:shopId] == YSFSessionStateNotExistAndLeaveMessageClosed)) {
        waitingOrNotExist = true;
    }
    YSFLogApp(@"@%: shouldRequestService isInit=%d  waitingOrNotExist=%d", shopId, isInit, waitingOrNotExist);
    if ([self serviceOutOfDate:shopId] && (isInit || !waitingOrNotExist)) {
        return true;
    }
    else {
        return false;
    }
}

#pragma mark - 请求客服
- (void)requestServicewithSource:(YSFRequestServiceRequest *)request shopId:(NSString *)shopId
{
    if ([_requestManager isInRequest:shopId])
    {
        YSFLogWar(@"@%: in request service process", shopId);
        return;
    }
    
    [_requestManager updateRequestState:shopId inRequest:YES];

    if (_delegate && [_delegate respondsToSelector:@selector(didBeginSendReqeustWithShopId:)])
    {
        [_delegate didBeginSendReqeustWithShopId:shopId];
    }
    
    
    //这里在请求接口上做个小hack,发生错误如果请求时间过短就尝试延长,使得界面能够有表现
    static const int64_t minProcessDuration = 2;
    NSDate *startDate = [NSDate date];
    __weak typeof(self) weakSelf = self;
    [YSFIMCustomSystemMessageApi sendMessage:request shopId:shopId 
           completion:^(NSError *error) {
               
               NSDate *endDate = [NSDate date];
               NSTimeInterval duration = fabs([endDate timeIntervalSinceDate:startDate]);
               
               if (error && duration < (double)minProcessDuration)
               {
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(minProcessDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [weakSelf onSendRequest:shopId error:error];
                       
                   });

               }
               else
               {
                   [weakSelf onSendRequest:shopId error:error];
               }
           }];
}

- (void)onSendRequest:(NSString*)shopId error:(NSError *)error
{
    //收到云信回包后发现还没收到云商服回包就开启timer进行等待
    if ([self serviceOutOfDate:shopId])
    {
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

#pragma mark - 客服更新
- (void)onGetNewServiceSession:(YSFServiceSession *)session shopId:(NSString *)shopId
{
    if (session.shopInfo) {
        [self addShopInfo:session.shopInfo];
    }
    [_requestManager stopWaitResponseTimer:shopId];
    [_requestManager updateRequestState:shopId inRequest:NO];
    
    
    NSInteger code = session.code;
    NSError *error = code == YSFCodeSuccess ? nil : [NSError errorWithDomain:YSFErrorDomain
                                                                        code:code
                                                                    userInfo:nil];
    if (code == YSFCodeSuccess)
    {
        [self setSessionStateType:shopId type:YSFSessionStateTypeOnline];
        [self addSession:session shopId:shopId];
    }
    else {
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
        }
        else if (code == YSFCodeServiceNotExist)
        {
            [self setSessionStateType:shopId type:YSFSessionStateTypeNotExist];
        }
        else if (code == YSFCodeServiceNotExistAndLeaveMessageClosed)
        {
            [self setSessionStateType:shopId type:YSFSessionStateNotExistAndLeaveMessageClosed];
        }
        else {
            [self setSessionStateType:shopId type:YSFSessionStateTypeError];
        }
    }

    //发起回调
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:shopId:)])
    {
        [_delegate didReceiveSessionError:error session:session shopId:shopId];
    }
    
    if (code == YSFCodeSuccess)
    {
        [self updateEvaluationDataStatusWithSession:session shopId:shopId];
    }
}

- (void)updateEvaluationDataStatusWithSession:(YSFServiceSession *)session shopId:(NSString *)shopId
{
    NSMutableDictionary *evalueDict = [[[[QYSDK sharedSDK] infoManager] dictByKey:YSFEvalution] mutableCopy];
    if (!evalueDict) {
        evalueDict = [[NSMutableDictionary alloc] init];
    }
    NSMutableDictionary *shopDict = [[evalueDict objectForKey:shopId] mutableCopy];
    if (!shopDict) {
        shopDict = [[NSMutableDictionary alloc] init];
    }
    [shopDict setObject:[[NSNumber alloc]initWithLongLong:session.sessionId] forKey:YSFCurrentSessionId];
    [shopDict setObject:@"0" forKey:YSFSessionTimes];
    if (session.evaluation) {
        [shopDict setObject:session.evaluation forKey:YSFEvaluationData];
    }
    if (session.messageInvite) {
        [shopDict setObject:session.messageInvite forKey:YSFApiKeyEvaluationMessageInvite];
    }
    if (session.messageThanks) {
        [shopDict setObject:session.messageThanks forKey:YSFApiKeyEvaluationMessageThanks];
    }

    if (session.humanOrMachine) {
        [shopDict setObject:@(2) forKey:YSFSessionStatus];
    }
    else {
        [shopDict setObject:@(1) forKey:YSFSessionStatus];
    }
    [self setEvaluationInfo:shopDict shopId:shopId];
}

- (void)onUpdateSessionByMessage:(YSF_NIMMessage *)message
{
    //每收到一条客服的消息就更新一把服务时间
//    _sessions.lastServiceTime =  [NSDate dateWithTimeIntervalSince1970:message.timestamp];
}

- (void)clear
{
    [_sessionStateType removeAllObjects];
    [_sessions removeAllObjects];
}

- (void)clearByShopId:(NSString *)shopId
{
    if (!shopId) return;
    [self cleanSessionStateTypeByShopId:shopId];
    [self removeSessionByShopId:shopId];
}

- (void)onCloseSession:(YSFCloseServiceNotification *)object shopId:(NSString *)shopId
{
    if (object.evaluate) {
        [self addEvaluationMessage:object.sessionId shopId:shopId];
    }
    
    if (object.message.length > 0) {
        YSFNotification *notification = [[YSFNotification alloc] init];
        notification.command = YSFCommandNotification;
        notification.localCommand = YSFCommandSessionWillClose;
        notification.message = object.message;
        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
        YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
    }
    
    [_delegate didClose:object.evaluate session:[self getSession:shopId] shopId:shopId];
    [self clearByShopId:shopId];
}

- (void)addEvaluationMessage:(long long)sessionId shopId:(NSString *)shopId
{
    YSFInviteEvaluationObject *inviteEvaluation = [[YSFInviteEvaluationObject alloc] init];
    inviteEvaluation.command = YSFCommandInviteEvaluation;
    inviteEvaluation.sessionId = sessionId;
    NSDictionary *dict = [self getEvaluationInfoByShopId:shopId];
    inviteEvaluation.evaluationDict = [dict objectForKey:YSFEvaluationData];
    inviteEvaluation.evaluationMessageInvite = [dict objectForKey:YSFApiKeyEvaluationMessageInvite];
    inviteEvaluation.evaluationMessageThanks = [dict objectForKey:YSFApiKeyEvaluationMessageThanks];
    YSF_NIMMessage *currentInviteEvaluationMessage = [YSFMessageMaker msgWithCustom:inviteEvaluation];
    YSF_NIMSession *session  =[YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:currentInviteEvaluationMessage
                                                   forSession:session addUnreadCount:YES completion:nil];
}

- (void)onServiceRequestTimeout:(NSString *)shopId
{
    [self setSessionStateType:shopId type:YSFSessionStateTypeError];
    [_requestManager updateRequestState:shopId inRequest:NO];
    
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:shopId:)])
    {
        NSError *error = [NSError errorWithDomain:YSFErrorDomain
                                             code:YSFCodeServerTimeout
                                         userInfo:nil];
        
        [_delegate didReceiveSessionError:error
                              session:nil shopId:shopId];
    }
    
}

- (void)onGetKFBypassNotification:(YSFKFBypassNotification *)object shopId:(NSString *)shopId
{
    YSFKFBypassNotification *notification = (YSFKFBypassNotification *)object;
    if (notification.shopInfo) {
        [self addShopInfo:object.shopInfo];
    }
    
    [_requestManager stopWaitResponseTimer:shopId];
    [_requestManager updateRequestState:shopId inRequest:NO];
    //发起回调
    if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:shopId:)])
    {
        [_delegate didReceiveSessionError:nil session:nil shopId:shopId];
    }
    
    notification.disable = NO;
    [self addStaffIdIconUrl:@"YSFKFBypassNotification" icornUrl:notification.iconUrl];
    
    YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    [customMessage performSelector:@selector(setFrom:) withObject:@"YSFKFBypassNotification"];
    [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:YES completion:nil];
    
    [self clearByShopId:shopId];
}

#pragma mark - YSF_NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(YSF_NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    YSFLogApp(@"notification: %@",content);
    
    //平台电商时sender就等于shopId，目前服务器这样处理
    NSString *shopId = notification.sender;
    if (!shopId) {
        shopId = @"-1";
    }

    id object =  [YSFCustomSystemNotificationParser parse:content];
    if ([object isKindOfClass:[YSFServiceSession class]])
    {
        [self onGetNewServiceSession:object shopId:shopId];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    }
    else if ([object isKindOfClass:[YSFCloseServiceNotification class]])
    {
        [self onCloseSession:(YSFCloseServiceNotification *)object shopId:shopId];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    }
    else if ([object isKindOfClass:[YSFKFBypassNotification class]])
    {
        [self onGetKFBypassNotification:object shopId:shopId];
    }
    else if ([object isKindOfClass:[YSFSessionStatusResponse class]])
    {
        [((YSFSessionStatusResponse *)object).shopSessionStatus enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj integerValue] == YSFCodeSuccess) {
                [self setSessionStateType:key type:YSFSessionStateTypeOnline];
            }
            else if ([obj integerValue] == YSFCodeServiceWaiting) {
                [self setSessionStateType:key type:YSFSessionStateTypeWaiting];
            }
            else if ([obj integerValue] == YSFCodeServiceNotExist) {
                [self setSessionStateType:key type:YSFSessionStateTypeNotExist];
            }
            else if ([obj integerValue] == YSFCodeServiceNotExistAndLeaveMessageClosed) {
                [self setSessionStateType:key type:YSFSessionStateNotExistAndLeaveMessageClosed];
            }
        }];
        [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
    }
    else if ([object isKindOfClass:[YSFQueryWaitingStatusResponse class]])
    {
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
            }
            else if (wait_status.code == YSFCodeServiceWaitingToNotExsitAndLeaveMessageClosed) {
                [self setSessionStateType:shopId type:YSFSessionStateNotExistAndLeaveMessageClosed];
                session.code = YSFCodeServiceNotExistAndLeaveMessageClosed;
                error = [NSError errorWithDomain:YSFErrorDomain code:YSFCodeServiceNotExist userInfo:nil];
            }

            if (_delegate && [_delegate respondsToSelector:@selector(didReceiveSessionError:session:shopId:)])
            {
                [_delegate didReceiveSessionError:error session:session shopId:shopId];
            }
            
            [[[QYSDK sharedSDK] sdkConversationManager] onSessionListChanged];
        }
    }
    else if ([object isKindOfClass:[YSFEvaluationNotification class]])
    {
        [self addEvaluationMessage:((YSFEvaluationNotification *)object).sessionId shopId:shopId];
    }
    else if ([object isKindOfClass:[YSFSessionWillCloseNotification class]])
    {
        YSFNotification *notification = [[YSFNotification alloc] init];
        notification.command = YSFCommandNotification;
        notification.localCommand = YSFCommandSessionWillClose;
        notification.message = ((YSFCloseServiceNotification *)object).message;
        YSF_NIMMessage *customMessage = [YSFMessageMaker msgWithCustom:notification];
        YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
        [[[YSF_NIMSDK sharedSDK] conversationManager] saveMessage:YES message:customMessage forSession:session addUnreadCount:NO completion:nil];
        
    }
}

#pragma mark - YSF_NIMChatManagerDelegate
- (void)onRecvMessages:(NSArray *)messages
{
    for (YSF_NIMMessage *message in messages) {
        if (message.isPushMessageType) {
            QYPushMessageBlock pushMessageBlock = [QYSDK sharedSDK].pushMessageBlock;
            if (pushMessageBlock) {
                QYPushMessage *pushMessage = [QYPushMessage new];
                pushMessage.text = message.text;
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

#pragma mark - ServiceSession操作

- (YSFServiceSession *)getSession:(NSString *)shopId
{
    if (!shopId) return nil;
    YSFServiceSession *session = _sessions[shopId];
    if (session && session.code == YSFCodeSuccess) {
        return session;
    }
    else {
        return nil;
    }
}

- (YSFServiceSession *)getSessionInAll:(NSString *)shopId
{
    if (!shopId) return nil;
    YSFServiceSession *session = _sessions[shopId];
    return session;
}

- (void)addSession:(YSFServiceSession *)session shopId:(NSString *)shopId
{
    if (!session || !shopId) return;
    
    _sessions[shopId] = session;

    if (session) {
        [self addStaffIdIconUrl:session.staffId icornUrl:session.iconUrl];
        [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:session.staffId];
    }
    else {
        [[YSF_NIMSDK sharedSDK].chatManager setReceiveMessageFrom:shopId receiveMessageFrom:nil];
    }
    
}

- (void)removeSessionByShopId:(NSString *)shopId
{
    if(!shopId) return;
    if (_sessions) {
        [_sessions removeObjectForKey:shopId];
    }
}

- (NSDictionary *)getShopInfo
{
    return _shopInfo;
}

- (NSDictionary *)getEvaluationInfoByShopId:(NSString *)shopId
{
    if(!shopId) return nil;
    return [_evaluationInfo objectForKey:shopId];
}

- (void)setEvaluationInfo:(NSDictionary *)evaluation shopId:(NSString *)shopId
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    [_evaluationInfo setObject:evaluation forKey:shopId];
    [infoManager saveDict:_evaluationInfo forKey:YSFEvalution];
}

- (void)addShopInfo:(YSFShopInfo *)shop
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    [_shopInfo setObject:[shop toDict] forKey:shop.shopId];
    [infoManager saveDict:_shopInfo forKey:YSFShopInfoKey];
}

- (void)removeShopInfo:(NSString *)shopId;
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    [_shopInfo removeObjectForKey:shopId];
    [infoManager saveDict:_shopInfo forKey:YSFShopInfoKey];
}

- (void)addStaffIdIconUrl:(NSString *)staffId icornUrl:(NSString *)iconUrl
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    if (staffId && iconUrl) {
        iconUrl = [iconUrl ysf_https];
        [_staffIdIconUrl setObject:iconUrl forKey:staffId];
        [infoManager saveDict:_staffIdIconUrl forKey:YSFStaffIdIconUrl];
    }
}

- (void)reportPushMessageReadedStatus
{
    for (NSNumber *sessionId in _unreadPushMessageSessionId) {
        long long llSessionId = [sessionId longLongValue];
        YSFPushMessageStatusChangeRequest *request = [[YSFPushMessageStatusChangeRequest alloc] init];
        request.msgSessionId = llSessionId;
        request.status = 2;
        [YSFIMCustomSystemMessageApi sendMessage:request shopId:@"-1" completion:^(NSError *error) {
            if (!error) {
                [_unreadPushMessageSessionId removeAllObjects];
                YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
                [infoManager saveArray:_unreadPushMessageSessionId forKey:YSFUnreadPushMessageSessionId];
            }
        }];
    }
}

- (long long)getLastUnreadPushMessageSessionId
{
    return [[_unreadPushMessageSessionId lastObject] longLongValue];
}

- (void)addUnreadPushMessageSessionId:(long long)msgSessionId
{
    YSFAppInfoManager *infoManager = [QYSDK sharedSDK].infoManager;
    if (msgSessionId) {
        [_unreadPushMessageSessionId addObject:@(msgSessionId)];
        [infoManager saveArray:_unreadPushMessageSessionId forKey:YSFUnreadPushMessageSessionId];
    }
}
@end
