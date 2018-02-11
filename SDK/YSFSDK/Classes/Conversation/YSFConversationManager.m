//
//  YSFConversationManager.m
//  YSFSDK
//
//  Created by amao on 9/8/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFConversationManager.h"
#import "QYPOPSessionInfo.h"
#import "QYPOPMessageInfo.h"
#import "NIMSession.h"
#import "YSFNotification.h"
#import "YSFWelcome.h"
#import "YSFCommodityInfoShow.h"
#import "YSFInviteEvaluationObject.h"
#import "YSFEvaluationTipObject.h"
#import "YSFStartServiceObject.h"
#import "YSFMachineResponse.h"
#import "YSFKFBypassNotification.h"
#import "YSFWeChatMessage.h"
#import "YSFReportQuestion.h"
#import "QYSDK_Private.h"
#import "YSFShopInfo.h"
#import "NSDictionary+YSFJson.h"
#import "YSF_NIMMessage+YSF.h"

@interface YSFConversationManager ()<YSF_NIMConversationManagerDelegate, YSF_NIMChatManagerDelegate>
@property (nonatomic,weak)  id<QYConversationManagerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray<QYSessionInfo *> *sessionListArray;
@end

@implementation YSFConversationManager
- (instancetype)init
{
    if (self = [super init])
    {
        [[[YSF_NIMSDK sharedSDK] conversationManager] addDelegate:self];
        [[[YSF_NIMSDK sharedSDK] chatManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [[[YSF_NIMSDK sharedSDK] chatManager] removeDelegate:self];
    [[[YSF_NIMSDK sharedSDK] conversationManager] removeDelegate:self];
}

- (NSArray<QYSessionInfo *> *)getSessionList
{
//    if (!self.sessionListArray) {
        [self updateSessionList];
//    }
    
    return _sessionListArray;
}

- (void)updateSessionList
{
    NSArray *recentSessions = [[[YSF_NIMSDK sharedSDK] conversationManager] allRecentSession];
    NSMutableArray *sessionListArray = [NSMutableArray arrayWithCapacity:recentSessions.count];
    for (YSF_NIMRecentSession *item in recentSessions) {
        NSDictionary *shopInfoDict = [[[[QYSDK sharedSDK] sessionManager] getShopInfo] objectForKey:item.session.sessionId];
        if (!shopInfoDict) {
            shopInfoDict = [[item.lastMessage.ext ysf_toDict] ysf_jsonDict:YSFApiKeyShop];
        }
        YSFShopInfo *shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
        
        QYSessionInfo *sessionInfo = [[QYSessionInfo alloc] init];
        sessionInfo.shopId = item.session.sessionId;
        sessionInfo.avatarImageUrlString = shopInfo ? shopInfo.logo : @"";
        sessionInfo.sessionName = shopInfo ? shopInfo.name : @"";
        sessionInfo.lastMessageText = [item.lastMessage getDisplayMessageContent];
        if (item.lastMessage.messageType == YSF_NIMMessageTypeText) {
            sessionInfo.lastMessageType = QYMessageTypeText;
        }
        else if (item.lastMessage.messageType == YSF_NIMMessageTypeImage) {
            sessionInfo.lastMessageType = QYMessageTypeImage;
        }
        else if (item.lastMessage.messageType == YSF_NIMMessageTypeAudio) {
            sessionInfo.lastMessageType = QYMessageTypeAudio;
        }
        else {
            sessionInfo.lastMessageType = QYMessageTypeCustom;
        }
        
        sessionInfo.unreadCount = item.unreadCount;
        sessionInfo.lastMessageTimeStamp = item.lastMessage.timestamp;
        YSFSessionStateType stateType = [[[QYSDK sharedSDK] sessionManager] getSessionStateType:sessionInfo.shopId];
        if (stateType == YSFSessionStateTypeOnline) {
            sessionInfo.status = QYSessionStatusInSession;
        }
        else if (stateType == YSFSessionStateTypeWaiting) {
            sessionInfo.status = QYSessionStatusWaiting;
        }
        else {
            sessionInfo.status = QYSessionStatusNone;
        }
        
        [sessionListArray addObject:sessionInfo];
    }
    
    self.sessionListArray = sessionListArray;
}

- (void)deleteRecentSessionByShopId:(NSString *)shopId deleteMessages:(BOOL)isDelete
{
    if (!shopId) return;
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    YSF_NIMRecentSession *recentSession = [YSF_NIMRecentSession recentSessionWithSession:session];
    [[[YSF_NIMSDK sharedSDK] conversationManager] deleteRecentSession:recentSession];
    if (isDelete) {
        [[[YSF_NIMSDK sharedSDK] conversationManager] deleteAllmessagesInSession:YES session:session removeRecentSession:YES];
    }
}

- (NSInteger)allUnreadCount
{
    return MAX(0, [[[YSF_NIMSDK sharedSDK] conversationManager] allUnreadCount]);
}

- (void)clearUnreadCount
{
    [self clearUnreadCount:@"-1"];
}

- (void)clearUnreadCount:(NSString *)shopId
{
    YSF_NIMSession *session = [YSF_NIMSession session:shopId type:YSF_NIMSessionTypeYSF];
    [[[YSF_NIMSDK sharedSDK] conversationManager] cleanRecentSession:session];
}

- (QYMessageInfo *)getLastMessage
{
    NSArray *recentSessions = [[[YSF_NIMSDK sharedSDK] conversationManager] allRecentSession];
    for (YSF_NIMRecentSession *item in recentSessions) {
        if ([item.session.sessionId isEqualToString:@"-1"]) {
            QYMessageInfo *messageInfo = [QYMessageInfo new];
            YSF_NIMMessage *message = item.lastMessage;
            messageInfo.text = [message getDisplayMessageContent];
            messageInfo.timeStamp = message.timestamp;
            if (message.messageType == YSF_NIMMessageTypeText) {
                messageInfo.type = QYMessageTypeText;
            }
            else if (message.messageType == YSF_NIMMessageTypeImage) {
                messageInfo.type = QYMessageTypeImage;
            }
            else if (message.messageType == YSF_NIMMessageTypeAudio) {
                messageInfo.type = QYMessageTypeAudio;
            }
            else {
                messageInfo.type = QYMessageTypeCustom;
            }
            
            return messageInfo;
        }
    }
    
    return nil;
}

#pragma mark - YSF_NIMConversationManagerDelegate
- (void)didAddRecentSession:(YSF_NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self onUnreadCountChanged:totalUnreadCount];
    [self onSessionListChanged];
}


- (void)didUpdateRecentSession:(YSF_NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self onUnreadCountChanged:totalUnreadCount];
    [self onSessionListChanged];
}

- (void)didRemoveRecentSession:(YSF_NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount
{
    [self onUnreadCountChanged:totalUnreadCount];
    [self onSessionListChanged];
}

- (void)onUnreadCountChanged:(NSInteger)count
{
    if (_delegate && [_delegate respondsToSelector:@selector(onUnreadCountChanged:)])
    {
        [_delegate onUnreadCountChanged:count];
    }
}

- (void)onSessionListChanged
{
    [self updateSessionList];
    if (_delegate && [_delegate respondsToSelector:@selector(onSessionListChanged:)]) {
        [_delegate onSessionListChanged:_sessionListArray];
    }
}

- (void)onRecvMessages:(NSArray *)messages
{
    for (YSF_NIMMessage *message in messages) {
        NSDictionary *shopInfoDict = [[[[QYSDK sharedSDK] sessionManager] getShopInfo] objectForKey:message.session.sessionId];
        if (!shopInfoDict) {
            shopInfoDict = [[message.ext ysf_toDict] ysf_jsonDict:YSFApiKeyShop];
        }
        YSFShopInfo *shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
        QYMessageInfo *messageInfo = [QYMessageInfo new];
        messageInfo.shopId = shopInfo.shopId;
        messageInfo.avatarImageUrlString = shopInfo ? shopInfo.logo : @"";
        messageInfo.sender = shopInfo ? shopInfo.name : @"";
        messageInfo.text = [message getDisplayMessageContent];
        messageInfo.timeStamp = message.timestamp;
        if (message.messageType == YSF_NIMMessageTypeText) {
            messageInfo.type = QYMessageTypeText;
        }
        else if (message.messageType == YSF_NIMMessageTypeImage) {
            messageInfo.type = QYMessageTypeImage;
        }
        else if (message.messageType == YSF_NIMMessageTypeAudio) {
            messageInfo.type = QYMessageTypeAudio;
        }
        else {
            messageInfo.type = QYMessageTypeCustom;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(onReceiveMessage:)]) {
            [_delegate onReceiveMessage:messageInfo];
        }
    }

}

@end
