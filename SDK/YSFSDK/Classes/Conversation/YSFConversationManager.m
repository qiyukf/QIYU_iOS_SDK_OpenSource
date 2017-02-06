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

@interface YSFConversationManager ()<YSF_NIMConversationManagerDelegate, YSF_NIMChatManagerDelegate>
@property (nonatomic,weak)  id<QYConversationManagerDelegate> delegate;
@property (nonatomic,weak)  id<QYPOPConversationManagerDelegate> popDelegate;

@property (nonatomic, strong) NSMutableArray<QYPOPSessionInfo *> *sessionListArray;
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

- (void)popSetDelegate:(id<QYPOPConversationManagerDelegate>)delegate
{
    self.popDelegate = delegate;
}

- (NSArray<QYPOPSessionInfo *> *)getSessionList
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
        YSFShopInfo *shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
        
        QYPOPSessionInfo *sessionInfo = [[QYPOPSessionInfo alloc] init];
        sessionInfo.shopId = item.session.sessionId;
        sessionInfo.avatarImageUrlString = shopInfo ? shopInfo.logo : @"";
        sessionInfo.sessionName = shopInfo ? shopInfo.name : @"";
        sessionInfo.lastMessageText = [self getLastMessageTextWithMessage:item.lastMessage];
        sessionInfo.unreadCount = item.unreadCount;
        sessionInfo.lastMessageTimeStamp = item.lastMessage.timestamp;
        YSFSessionStateType stateType = [[[[QYSDK sharedSDK] sessionManager].sessionStateType
                               ysf_jsonString:sessionInfo.shopId] integerValue];
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

- (NSString *)getLastMessageTextWithMessage:(YSF_NIMMessage *)message
{
    NSString *text = @"";
    switch (message.messageType) {
        case YSF_NIMMessageTypeText:
            text = message.text;
            break;
        case YSF_NIMMessageTypeCustom:
        {
            
            YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)message.messageObject;
            id<YSF_NIMCustomAttachment> attachment = object.attachment;
            if ([attachment isMemberOfClass:[YSFNotification class]]) {
                YSFNotification *notification = attachment;
                text = [NSString stringWithFormat:@"[%@]", notification.message];
            }
            else if ([attachment isMemberOfClass:[YSFWelcome class]]) {
                YSFWelcome *notification = attachment;
                text = [NSString stringWithFormat:@"[%@]", notification.welcome];
            }
            else if ([attachment isMemberOfClass:[YSFCommodityInfoShow class]])
            {
                YSFCommodityInfoShow *commodityInfoShow = attachment;
                text = [NSString stringWithFormat:@"%@", commodityInfoShow.urlString];
            } else if ([attachment isMemberOfClass:[YSFInviteEvaluationObject class]])
            {
                text = @"感谢您的咨询，请对我们的服务作出评价";
            } else if ([attachment isMemberOfClass:[YSFEvaluationTipObject class]])
            {
                YSFEvaluationTipObject *evaluationTipObject = attachment;
                text = [NSString stringWithFormat:@"[%@%@]", evaluationTipObject.tipContent, evaluationTipObject.tipResult];
            } else if ([attachment isMemberOfClass:[YSFStartServiceObject class]])
            {
                YSFStartServiceObject *startServiceObject = attachment;
                text = [NSString stringWithFormat:@"[客服%@为您服务]", startServiceObject.staffName];
            } else if ([attachment isMemberOfClass:[YSFMachineResponse class]])
            {
                YSFMachineResponse *machineResponse = attachment;
                if (machineResponse.operatorHint) {
                    text = [NSString stringWithFormat:@"%@", machineResponse.operatorHintDesc];
                } else {
                    text = [NSString stringWithFormat:@"%@", machineResponse.answerLabel];
                    for (NSDictionary *item in machineResponse.answerArray) {
                        NSString *answerText = item[@"answer"] ? : @"";
                        text = [text stringByAppendingString:answerText];
                    }
                }
                
            } else if ([attachment isMemberOfClass:[YSFReportQuestion class]])
            {
                YSFReportQuestion *reportQuestion = attachment;
                text = [NSString stringWithFormat:@"%@", reportQuestion.question];
            } else if ([attachment isMemberOfClass:[YSFKFBypassNotification class]])
            {
                YSFKFBypassNotification *kfBypassNotification = attachment;
                text = [NSString stringWithFormat:@"[%@:", kfBypassNotification.message];
                NSInteger index = 0;
                for (NSDictionary *item in kfBypassNotification.entries) {
                    NSString *labelText = item[@"label"] ? : @"";
                    if (index != kfBypassNotification.entries.count - 1) {
                        text = [text stringByAppendingFormat:@"%@ / ", labelText];
                    } else {
                        text = [text stringByAppendingFormat:@"%@]", labelText];
                    }
                    index++;
                }
            }
        }
            break;
        case YSF_NIMMessageTypeAudio:
            text = @"[语音]";
            break;
        case YSF_NIMMessageTypeImage:
            text = @"[图片]";
            break;
        case YSF_NIMMessageTypeVideo:
            text = @"[视频]";
            break;
        case YSF_NIMMessageTypeLocation:
            text = @"[位置]";
            break;
        case YSF_NIMMessageTypeNotification:{
            text = @"[通知消息]";
        }
        case YSF_NIMMessageTypeFile:
            text = @"[文件]";
            break;
        default:
            text = @"[未知消息]";
    }
    
    return text;
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
    if (_popDelegate && [_popDelegate respondsToSelector:@selector(onSessionListChanged)]) {
        [_popDelegate onSessionListChanged];
    }
}

- (void)onRecvMessages:(NSArray *)messages
{
    for (YSF_NIMMessage *message in messages) {
        NSDictionary *shopInfoDict = [[[[QYSDK sharedSDK] sessionManager] getShopInfo] objectForKey:message.session.sessionId];
        YSFShopInfo *shopInfo = [YSFShopInfo instanceByJson:shopInfoDict];
        QYPOPMessageInfo *messageInfo = [QYPOPMessageInfo new];
        messageInfo.shopId = shopInfo.shopId;
        messageInfo.avatarImageUrlString = shopInfo ? shopInfo.logo : @"";
        messageInfo.sender = shopInfo ? shopInfo.name : @"";
        messageInfo.text = [self getLastMessageTextWithMessage:message];
        messageInfo.timeStamp = message.timestamp;
        
        if (_popDelegate && [_popDelegate respondsToSelector:@selector(onReceiveMessage:)]) {
            [_popDelegate onReceiveMessage:messageInfo];
        }
    }

}

@end
